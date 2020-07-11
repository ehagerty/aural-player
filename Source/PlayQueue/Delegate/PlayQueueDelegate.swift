import Foundation

class PlayQueueDelegate: PlayQueueDelegateProtocol {
    
    private let playQueue: PlayQueueProtocol
    
    var tracks: [Track] {playQueue.tracks}
    
    var size: Int {playQueue.size}
    
    var duration: Double {playQueue.duration}
    
    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
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
    
    func playLater(_ tracks: [Track]) -> [Int] {
        return playQueue.enqueue(tracks)
    }
    
    func playNow(_ tracks: [Track]) -> [Int] {
        
        let indices = playQueue.enqueueAtHead(tracks)
        Messenger.publish(.playQueue_tracksAdded)
        return indices
    }
    
    func playNext(_ tracks: [Track]) -> [Int] {
        return playQueue.enqueueAfterCurrentTrack(tracks)
    }
    
    func removeTracks(_ indices: IndexSet) -> [Track] {
        return playQueue.removeTracks(indices)
    }
    
    func moveTracksUp(_ indices: IndexSet) -> ItemMoveResults {
        return playQueue.moveTracksUp(indices)
    }
    
    func moveTracksToTop(_ indices: IndexSet) -> ItemMoveResults {
        return playQueue.moveTracksToTop(indices)
    }
    
    func moveTracksDown(_ indices: IndexSet) -> ItemMoveResults {
        return playQueue.moveTracksDown(indices)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> ItemMoveResults {
        return playQueue.moveTracksToBottom(indices)
    }
    
    func dropTracks(_ sourceIndices: IndexSet, _ dropIndex: Int) -> ItemMoveResults {
        return playQueue.dropTracks(sourceIndices, dropIndex)
    }
    
    func clear() {
        playQueue.clear()
    }
}
