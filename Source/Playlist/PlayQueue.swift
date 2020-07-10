import Foundation

class PlayQueue: PlayQueueProtocol {
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFile: [URL: Track] = [:]
    
    var tracks: [Track] = [Track]()
    
    // MARK: Accessor functions
    
    var size: Int {tracks.count}
    
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    func displayNameForTrack(_ track: Track) -> String {
        return track.conciseDisplayName
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return tracks.itemAtIndex(index)
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        return tracks.firstIndex(of: track)
    }
    
    func findTrackByFile(_ file: URL) -> Track? {
        return tracksByFile[file]
    }
    
    func hasTrack(_ track: Track) -> Bool {
        return tracksByFile[track.file] != nil
    }
    
    func hasTrackForFile(_ file: URL) -> Bool {
        return tracksByFile[file] != nil
    }
    
    func summary() -> (size: Int, totalDuration: Double) {
        return (size, duration)
    }
    
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
    
    // MARK: Mutator functions
    
    func addTrack(_ track: Track) -> Int {
        return tracks.addItem(track)
    }
    
    func clear() {
        tracks.removeAll()
    }
    
    func enqueueAtHead(_ tracks: [Track]) -> [TrackAddResult] {
        return []
    }
    
    func enqueueAfterCurrentTrack(_ tracks: [Track]) -> [TrackAddResult] {
        return []
    }
    
    func enqueue(_ tracks: [Track]) -> [TrackAddResult] {
        return []
    }
    
    func removeTracks(_ indexes: IndexSet) -> TrackRemovalResults {
        
        // Remove tracks from flat playlist
        let removedTracks = tracks.removeItems(indexes)
        
        // Remove secondary state associated with these tracks
        removedTracks.forEach({
            tracksByFile.removeValue(forKey: $0.file)
        })
        
        return TrackRemovalResults(groupingPlaylistResults: [:], flatPlaylistResults: indexes, tracks: removedTracks)
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
    
    func removeTracks(_ indices: IndexSet) -> [Track] {
        return tracks.removeItems(indices)
    }
    
    func moveTracksToTop(_ indices: IndexSet) -> ItemMoveResults {
        return ItemMoveResults(tracks.moveItemsToTop(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> ItemMoveResults {
        return ItemMoveResults(tracks.moveItemsToBottom(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
    
    func moveTracksUp(_ indices: IndexSet) -> ItemMoveResults {
        return ItemMoveResults(tracks.moveItemsUp(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
    
    func moveTracksDown(_ indices: IndexSet) -> ItemMoveResults {
        return ItemMoveResults(tracks.moveItemsDown(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults {
        return ItemMoveResults(tracks.dragAndDropItems(sourceIndexes, dropIndex).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
}
