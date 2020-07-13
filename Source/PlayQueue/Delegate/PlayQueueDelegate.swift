import Foundation

class PlayQueueDelegate: PlayQueueDelegateProtocol {
    
    private let playQueue: PlayQueueProtocol
    
    var tracks: [Track] {playQueue.tracks}
    
    var size: Int {playQueue.size}
    
    var duration: Double {playQueue.duration}
    
    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
    var isBeingModified: Bool {false}
    
    init(playQueue: PlayQueueProtocol) {
        self.playQueue = playQueue
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
    
    func enqueueToPlayLater(_ tracks: [Track]) -> ClosedRange<Int> {
        
        tracks.forEach {TrackIO.loadArt($0)}
        
        let indices = playQueue.enqueue(tracks)
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func enqueueToPlayNow(_ tracks: [Track]) -> ClosedRange<Int> {
        
        tracks.forEach {TrackIO.loadArt($0)}
        
        let indices = playQueue.enqueueAtHead(tracks)
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func enqueueToPlayNext(_ tracks: [Track]) -> ClosedRange<Int> {
        
        tracks.forEach {TrackIO.loadArt($0)}
        
        let indices = playQueue.enqueueAfterCurrentTrack(tracks)
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func removeTracks(_ indices: IndexSet) -> [Track] {
        
        let removedTracks = playQueue.removeTracks(indices)
        
        Messenger.publish(.playQueue_tracksRemoved,
                          payload: TrackRemovalResults(groupingPlaylistResults: [:], flatPlaylistResults: indices, tracks: removedTracks))
        
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
    
    func clear() {
        playQueue.clear()
    }
}
