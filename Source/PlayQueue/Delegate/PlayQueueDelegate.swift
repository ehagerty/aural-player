import Foundation

class PlayQueueDelegate: PlayQueueDelegateProtocol {

    private let playQueue: PlayQueueProtocol
    private let library: LibraryProtocol
    
    var tracks: [Track] {playQueue.tracks}
    
    var size: Int {playQueue.size}
    
    var duration: Double {playQueue.duration}
    
    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()
    
    private var addSession: TrackAddSession<PlayQueueTrackAddResult>!
    
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    var isBeingModified: Bool {addSession != nil}
    
    init(playQueue: PlayQueueProtocol, library: LibraryProtocol) {
        
        self.playQueue = playQueue
        self.library = library
        
        // TODO: Load tracks from persistent play queue state here, on app startup ... checking if the library already has the tracks.
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return playQueue.indexOfTrack(track)
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        playQueue.trackAtIndex(index)
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return playQueue.search(searchQuery)
    }
    
    func addTracks(from files: [URL]) {
        addTracks_async(files)
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addTracks_async(_ files: [URL], _ userAction: Bool = true) {
        
        addSession = TrackAddSession<PlayQueueTrackAddResult>(files.count, .defaultOptions)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // ------------------ ADD --------------------
            
            Messenger.publish(.playQueue_startedAddingTracks)
            
            self.collectTracks(files, false)
            self.addSessionTracks()
            
            // ------------------ NOTIFY ------------------
            
            let results = self.addSession.results
            
//            if userAction {
//                Messenger.publish(.history_itemsAdded, payload: self.addSession.addedItems)
//            }
            
            Messenger.publish(.playQueue_doneAddingTracks)
            
            // If errors > 0, send AsyncMessage to UI
            if self.addSession.errors.isNonEmpty {
                Messenger.publish(.playQueue_tracksNotAdded, payload: self.addSession.errors)
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
        
        for file in files.sorted(by: {$0.path < $1.path}) {
            
            // Playlists might contain broken file references
            if !FileSystemUtils.fileExists(file) {
                
                addSession.addError(FileNotFoundError(file))
                continue
            }
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
            let resolvedFile = resolvedFileInfo.resolvedURL
            
            if resolvedFileInfo.isDirectory {
                
                // Directory
                if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                expandDirectory(resolvedFile)
                
            } else {
                
                // Single file - playlist or track
                let fileExtension = resolvedFile.pathExtension.lowercased()
                
                if AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
                    // Playlist
                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                    expandPlaylist(resolvedFile)
                    
                } else if AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension) {
                    
                    // Track
                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                    addSession.tracks.append(library.findTrackByFile(resolvedFile) ?? Track(resolvedFile))
                }
            }
        }
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
        
        let addSessionTracks = batch.map({addSession.tracks[$0]})
        
        // Process all tracks in batch concurrently and wait until the entire batch finishes.
        trackAddQueue.addOperations(addSessionTracks.compactMap {track in
            track.hasPrimaryMetadata ? nil : BlockOperation {track.loadPrimaryMetadata()}
        }, waitUntilFinished: true)
        
        for track in addSessionTracks {
            
            if track.isPlayable {
                
                let index = enqueue(track)
                let result = PlayQueueTrackAddResult(track: track, index: index)
                
                addSession.tracksAdded.increment()
                addSession.results.append(result)

                let progress = TrackAddOperationProgress(tracksAdded: addSession.tracksAdded, totalTracks: addSession.totalTracks)
                Messenger.publish(PlayQueueTrackAddedNotification(trackIndex: index, addOperationProgress: progress))
                
            } else {
                addSession.errors.append(track.validationError as? DisplayableError ?? InvalidTrackError(track))
            }
        }
    }
    
    func enqueue(_ track: Track) -> Int {
        return playQueue.enqueue([track]).first!
    }
    
    func enqueueToPlayLater(_ tracks: [Track]) -> ClosedRange<Int> {
        
        let indices = playQueue.enqueue(tracks)
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func enqueueToPlayNow(_ tracks: [Track]) -> ClosedRange<Int> {
        
        let indices = playQueue.enqueueAtHead(tracks)
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func enqueueToPlayNext(_ tracks: [Track]) -> ClosedRange<Int> {
        
        let indices = playQueue.enqueueAfterCurrentTrack(tracks)
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func removeTracks(_ indices: IndexSet) -> [Track] {
        
        let removedTracks = playQueue.removeTracks(indices)
        
        Messenger.publish(.playQueue_tracksRemoved,
                          payload: TrackRemovalResults(flatPlaylistResults: indices, tracks: removedTracks))
        
        return removedTracks
    }
    
    func moveTracksUp(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksUp(indices)
    }
    
    func moveTracksToTop(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksToTop(indices)
    }
    
    func moveTracksDown(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksDown(indices)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksToBottom(indices)
    }
    
    func dropTracks(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [TrackMoveResult] {
        return playQueue.dropTracks(sourceIndices, dropIndex)
    }
    
    func export(to file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.save(tracks: self.tracks, to: file)
        }
    }
    
    func clear() {
        playQueue.clear()
    }
    
    func sort(_ sort: Sort) {
        _ = playQueue.sort(sort)
    }
    
    func sort(by comparator: (Track, Track) -> Bool) {
        playQueue.sort(by: comparator)
    }
}
