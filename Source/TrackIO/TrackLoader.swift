import Foundation

protocol TrackListProtocol {
    
    func shouldLoad(file: URL) -> Bool
    
    func acceptBatch(_ batch: FileMetadataBatch)
}

class FileReadSession {

    let metadataType: MetadataType
    var files: [URL] = []
    let trackList: TrackListProtocol
    
    // For history
    var historyItems: [URL] = []
    
    // Progress
    var filesProcessed: Int = 0
    var errors: [DisplayableError] = []
    
    init(metadataType: MetadataType, files: [URL], trackList: TrackListProtocol) {
        
        self.metadataType = metadataType
        self.files = files
        self.trackList = trackList
    }
    
    func addHistoryItem(_ item: URL) {
        historyItems.append(item)
    }
    
    func addError(_ error: DisplayableError) {
        errors.append(error)
    }
}

class FileMetadataBatch {
    
    let size: Int
    fileprivate var files: [URL] = []
    fileprivate var metadata: [URL: FileMetadata] = [:]
    
    var orderedMetadata: [(file: URL, metadata: FileMetadata)] {files.map {(file: $0, metadata: self.metadata[$0]!)}}
    
    var fileCount: Int {files.count}
    
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    fileprivate init(ofSize size: Int) {
        self.size = size
    }
    
    fileprivate func append(file: URL) -> Bool {
        
        files.append(file)
        return files.count == size
    }
    
    fileprivate func setMetadata(_ metadata: FileMetadata, for file: URL) {
        
        semaphore.wait()
        self.metadata[file] = metadata
        semaphore.signal()
    }
    
    fileprivate func clear() {
        
        files.removeAll()
        metadata.removeAll()
    }
}

// TODO: How to deal with duplicate tracks ? (track is loaded individually and as part of a playlist)
// What if a track exists in a different track list ? (Play Queue / Library). Should we have a global track registry ?
// What about notifications / errors ? Return a result ?
// Create a track load session and a batch class
// How to deal with 2 simultaneous sessions on startup ? Play queue / Library / Custom playlists ? Adjust batch size accordingly ?
class TrackLoader {
    
    private let fileReader: FileReader = FileReader()
    
    private var session: FileReadSession!
    private var batch: FileMetadataBatch!
    var blockOpFunction: ((URL) -> BlockOperation)!
    
    func blockOp(metadataType: MetadataType) -> ((URL) -> BlockOperation) {
        
        return {file in BlockOperation {
            
            let fileMetadata = FileMetadata()
            
            do {
                
                switch metadataType {
                    
                case .primary:
                    
                    fileMetadata.primary = try self.fileReader.getPrimaryMetadata(for: file)
                    
                case .playback:
                
                    fileMetadata.playback = try self.fileReader.getPlaybackMetadata(file: file)
                }
                
            } catch {
                fileMetadata.validationError = error as? DisplayableError
            }
            
            self.batch.setMetadata(fileMetadata, for: file)
        }}
    }
    
    private let queue: OperationQueue = OperationQueue()
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    init() {
        
        queue.maxConcurrentOperationCount = concurrentAddOpCount
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.qualityOfService = .userInteractive
    }
    
    // TODO: Allow the caller to specify a "sort order" for the files, eg. by file path ???
    func loadMetadata(ofType type: MetadataType, from files: [URL], into trackList: TrackListProtocol) {
        
        session = FileReadSession(metadataType: type, files: files, trackList: trackList)
        batch = FileMetadataBatch(ofSize: concurrentAddOpCount)
        blockOpFunction = blockOp(metadataType: type)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.readFiles(files)
            
            if self.batch.fileCount > 0 {
                self.flushBatch()
            }
            
            // Cleanup
            self.session = nil
            self.batch = nil
            self.blockOpFunction = nil
        }
    }
    
    /*
     Adds a bunch of files synchronously.
     
     The autoplayOptions argument encapsulates all autoplay options.
     
     The progress argument indicates current progress.
     */
    private func readFiles(_ files: [URL], _ isRecursiveCall: Bool = false) {
        
        for file in files {
            
            // Playlists might contain broken file references
            if !FileSystemUtils.fileExists(file) {

                session.addError(FileNotFoundError(file))
                continue
            }

            // Always resolve sym links and aliases before reading the file
            let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
            let resolvedFile = resolvedFileInfo.resolvedURL

            if resolvedFileInfo.isDirectory {

                // Directory
                if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                
                if let dirContents = FileSystemUtils.getContentsOfDirectory(resolvedFile) {
                    readFiles(dirContents.sorted(by: {$0.lastPathComponent < $1.lastPathComponent}), true)
                }

            } else {

                // Single file - playlist or track
                let fileExtension = resolvedFile.pathExtension.lowercased()

                if AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension) {

                    // Playlist
                    if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                    
                    if let loadedPlaylist = PlaylistIO.loadPlaylist(resolvedFile) {
                        readFiles(loadedPlaylist.tracks, true)
                    }

                } else if AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension),
                session.trackList.shouldLoad(file: resolvedFile) {

                    // Track
                    if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                    
                    // True means batch is full and needs to be flushed.
                    if batch.append(file: resolvedFile) {
                        flushBatch()
                    }
                }
            }
        }
    }
    
    func flushBatch() {
        
        queue.addOperations(batch.files.map(blockOpFunction), waitUntilFinished: true)
        session.trackList.acceptBatch(batch)
        batch.clear()
    }
}
