import Foundation

class PlayQueue: PlayQueueProtocol {
    
    var tracks: [Track] = []
    
    // MARK: Accessor functions
    
    var size: Int {tracks.count}
    
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return tracks.itemAtIndex(index)
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        return tracks.firstIndex(of: track)
    }
    
    var summary: (size: Int, totalDuration: Double) {(size, duration)}
    
    // MARK: Mutator functions ------------------------------------------------------------------------
    
    func enqueue(_ tracks: [Track]) -> ClosedRange<Int> {
        return self.tracks.addItems(tracks)
    }
    
    func enqueueAtHead(_ tracks: [Track]) -> ClosedRange<Int> {
        
        self.tracks.insert(contentsOf: tracks, at: 0)
        return 0...tracks.lastIndex
    }
    
    // TODO
    func enqueueAfterCurrentTrack(_ tracks: [Track]) -> ClosedRange<Int> {
        return 0...0
    }
    
    func removeTracks(_ indexes: IndexSet) -> [Track] {
        return tracks.removeItems(indexes)
    }
    
    private func removeTrackAtIndex(_ index: Int) -> Track? {
        return tracks.removeItem(index)
    }
    
    private func removeTrack(_ track: Track) -> Int? {
        return tracks.removeItem(track)
    }
    
    func removeTracks(_ removedTracks: [Track]) -> IndexSet {
        return tracks.removeItems(removedTracks)
    }
    
    func clear() {
        tracks.removeAll()
    }
    
    func moveTracksToTop(_ indices: IndexSet) -> [TrackMoveResult] {
        return tracks.moveItemsToTop(indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> [TrackMoveResult] {
        return tracks.moveItemsToBottom(indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveTracksUp(_ indices: IndexSet) -> [TrackMoveResult] {
        return tracks.moveItemsUp(indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveTracksDown(_ indices: IndexSet) -> [TrackMoveResult] {
        return tracks.moveItemsDown(indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> [TrackMoveResult] {
        return tracks.dragAndDropItems(sourceIndexes, dropIndex).map {TrackMoveResult($0.key, $0.value)}
    }
    
    // MARK: Search ------------------------------------------------------------------------------------------------------
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        
        return SearchResults(tracks.compactMap {executeQuery($0, searchQuery)}.map {
            
            SearchResult(location: SearchResultLocation(trackIndex: -1, track: $0.track, groupInfo: nil),
                         match: ($0.matchedField, $0.matchedFieldValue))
        })
    }
    
    private func executeQuery(_ track: Track, _ query: SearchQuery) -> SearchQueryMatch? {
        
        // Check both the filename and the display name
        if query.fields.name {
            
            let filename = track.fileSystemInfo.fileName
            if query.compare(filename) {
                return SearchQueryMatch(track: track, matchedField: "filename", matchedFieldValue: filename)
            }
            
            let displayName = track.conciseDisplayName
            if query.compare(displayName) {
                return SearchQueryMatch(track: track, matchedField: "name", matchedFieldValue: displayName)
            }
        }
        
        // Compare title field if included in search
        if query.fields.title, query.compare(track.displayInfo.title) {
            return SearchQueryMatch(track: track, matchedField: "title", matchedFieldValue: track.displayInfo.title)
        }
        
        // Didn't match
        return nil
    }
}
