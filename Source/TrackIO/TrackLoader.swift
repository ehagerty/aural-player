import Foundation

protocol TrackList {
    
    func willAcceptTrack(for file: URL) -> Bool
    
    func append(track: Track)
    
    func trackLoadBatchCompleted()
}

// TODO: How to deal with duplicate tracks ? (track is loaded individually and as part of a playlist)
// What if a track exists in a different track list ? (Play Queue / Library). Should we have a global track registry ?
// What about notifications / errors ? Return a result ?
// Create a track load session and a batch class
// How to deal with 2 simultaneous sessions on startup ? Play queue / Library / Custom playlists ? Adjust batch size accordingly ?
class TrackLoader {
    
    private var addSession: TrackAddSession<TrackAddResult>!
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()
    
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    init() {
        
        trackAddQueue.maxConcurrentOperationCount = concurrentAddOpCount
        trackAddQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        trackAddQueue.qualityOfService = .userInteractive
        
        trackUpdateQueue.maxConcurrentOperationCount = concurrentAddOpCount
        trackUpdateQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        trackUpdateQueue.qualityOfService = .utility
    }
    
    func loadTracks(from files: [URL], into trackList: TrackList) {
        
    }
    
    func addFiles(_ files: [URL]) {
        addFiles_async(files)
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], _ userAction: Bool = true) {
        
        addSession = TrackAddSession<TrackAddResult>(files.count, .defaultOptions)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // ------------------ ADD --------------------
            
            Messenger.publish(.library_startedAddingTracks)
            
            self.collectTracks(files, false)
            self.addSessionTracks()
            
            // ------------------ NOTIFY ------------------
            
            let results = self.addSession.results
            
            if userAction {
                Messenger.publish(.history_itemsAdded, payload: self.addSession.addedItems)
            }
            
            Messenger.publish(.library_doneAddingTracks)
            
            // If errors > 0, send AsyncMessage to UI
            if self.addSession.errors.isNonEmpty {
                Messenger.publish(.library_tracksNotAdded, payload: self.addSession.errors)
            }
            
            self.addSession = nil
            
            // ------------------ UPDATE --------------------
            
            self.trackUpdateQueue.addOperations(results.map {result in BlockOperation {result.track.loadSecondaryMetadata()}},
                                                waitUntilFinished: false)
        }
    }
    
    /*
     Adds a bunch of files synchronously.
     
     The autoplayOptions argument encapsulates all autoplay options.
     
     The progress argument indicates current progress.
     */
    private func collectTracks(_ files: [URL], _ isRecursiveCall: Bool) {
        
//        for file in files.sorted(by: {$0.path < $1.path}) {
//
//            // Playlists might contain broken file references
//            if !FileSystemUtils.fileExists(file) {
//
//                addSession.addError(FileNotFoundError(file))
//                continue
//            }
//
//            // Always resolve sym links and aliases before reading the file
//            let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
//            let resolvedFile = resolvedFileInfo.resolvedURL
//
//            if resolvedFileInfo.isDirectory {
//
//                // Directory
//                if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
//                expandDirectory(resolvedFile)
//
//            } else {
//
//                // Single file - playlist or track
//                let fileExtension = resolvedFile.pathExtension.lowercased()
//
//                if AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension) {
//
//                    // Playlist
//                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
//                    expandPlaylist(resolvedFile)
//
//                } else if AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension),
//                trackList.willAccept {
//
//                    // Track
//                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
//                    addSession.tracks.append(Track(resolvedFile))
//                }
//            }
//        }
    }
    
    // Expands a playlist into individual tracks
    private func expandPlaylist(_ playlistFile: URL) {
        
        if let loadedPlaylist = PlaylistIO.loadPlaylist(playlistFile) {
            
            addSession.totalTracks += loadedPlaylist.tracks.count - 1
            collectTracks(loadedPlaylist.tracks, true)
        }
    }
    
    // Expands a directory into individual tracks (and subdirectories)
    private func expandDirectory(_ dir: URL) {
        
        if let dirContents = FileSystemUtils.getContentsOfDirectory(dir) {
            
            addSession.totalTracks += dirContents.count - 1
            collectTracks(dirContents, true)
        }
    }
    
    private func addSessionTracks() {
        
        var firstBatchIndex: Int = 0
        while addSession.tracksProcessed < addSession.tracks.count {
            
            let remainingTracks = addSession.tracks.count - addSession.tracksProcessed
            let lastBatchIndex = firstBatchIndex + min(remainingTracks, concurrentAddOpCount) - 1
            
            let batch = firstBatchIndex...lastBatchIndex
            processBatch(batch)
            addSession.tracksProcessed += batch.count
            
            firstBatchIndex = lastBatchIndex + 1
        }
    }
    
    private func processBatch(_ batch: AddBatch) {
        
//        let addSessionTracks: [Track] = batch.map({addSession.tracks[$0]})
//
//        // Process all tracks in batch concurrently and wait until the entire batch finishes.
//        trackAddQueue.addOperations(addSessionTracks.map {track in BlockOperation {track.loadPrimaryMetadata()}}, waitUntilFinished: true)
//
//        for track in addSessionTracks {
//
//            if track.isPlayable, let result = self.library.addTrack(track) {
//
//                addSession.tracksAdded.increment()
//                addSession.results.append(TrackAddResult(track: track, flatPlaylistResult: result))
//
//                let progress = TrackAddOperationProgress(tracksAdded: addSession.tracksAdded, totalTracks: addSession.totalTracks)
//                Messenger.publish(LibraryTrackAddedNotification(trackIndex: result, addOperationProgress: progress))
//
//            } else if !track.isPlayable {
//                addSession.errors.append(track.validationError as? DisplayableError ?? InvalidTrackError(track))
//            }
//        }
    }
}
