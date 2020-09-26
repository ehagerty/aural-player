import Foundation

class PlayQueueDelegate: PlayQueueDelegateProtocol, TrackListProtocol, NotificationSubscriber {

    private let playQueue: PlayQueueProtocol
    private let library: LibraryProtocol
    
    var tracks: [Track] {playQueue.tracks}
    
    var size: Int {playQueue.size}
    
    var duration: Double {playQueue.duration}
    
    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()
    
    private let trackReader: TrackReader
    
    private var addSession: TrackAddSession<PlayQueueTrackAddResult>!
    
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    let trackLoader: TrackLoader = TrackLoader()
    
    var isBeingModified: Bool {addSession != nil}
    
    init(playQueue: PlayQueueProtocol, library: LibraryProtocol, trackReader: TrackReader, persistentStateOnStartup: PlayQueueState) {
        
        self.playQueue = playQueue
        self.library = library
        self.trackReader = trackReader
        
        Messenger.subscribe(self, .library_doneAddingTracks, {
            
            self.addTracks(from: persistentStateOnStartup.tracks)
            Messenger.unsubscribe(self, .library_doneAddingTracks)
        })
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
        trackLoader.loadMetadata(ofType: .primary, from: files, into: self)
    }
    
    func computeDuration(for files: [URL]) {
        
    }
    
    func shouldLoad(file: URL) -> Bool {
        
        if let trackInLibrary = self.library.findTrackByFile(file) {
            
            _ = playQueue.enqueue([trackInLibrary])
            return false
        }
        
        return true
        // TODO: Should check if we already have a track for this file,
        // then simply duplicate it instead of re-reading the file.
    }
    
    func acceptBatch(_ batch: FileMetadataBatch) {
        
//        let tracks = batch.orderedMetadata.map {(file, metadata) in Track(file, fileMetadata: metadata)}
        let tracks = batch.orderedMetadata.map {(file, metadata) -> Track in
            let track = Track(file, fileMetadata: metadata)
            
            do {
                try self.trackReader.computePlaybackContext(for: track)
            } catch {}
            
            return track
        }
        
        
        let indices = playQueue.enqueue(tracks)
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
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
