import Foundation

class Library: LibraryProtocol {
    
    var tracks: [Track] = []
    
    private var tracksByFile: [URL: Track] = [:]
    
    // MARK: Accessor functions
    
    var size: Int {tracks.count}
    
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    var summary: (size: Int, totalDuration: Double) {(size, duration)}
    
    func trackAtIndex(_ index: Int) -> Track? {
        return tracks.item(at: index)
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
    
    func addTrack(_ track: Track) -> Int? {
        
        guard !hasTrack(track) else {return nil}
        
        // Add a mapping by track's file path
        tracksByFile[track.file] = track
        
        return tracks.addItem(track)
    }
    
    func clear() {
        
        tracks.removeAll()
        tracksByFile.removeAll()
    }
    
    func removeTracks(_ indices: IndexSet) -> [Track] {
        
        // TODO: Resolve file URL ?
        
        let removedTracks = tracks.removeItems(at: indices)
        for track in removedTracks {
            tracksByFile.removeValue(forKey: track.file)
        }
        
        return removedTracks
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        
        return SearchResults(tracks.compactMap {executeQuery($0, searchQuery)}.map {
            
            SearchResult(location: SearchResultLocation(trackIndex: -1, track: $0.track),
                         match: ($0.matchedField, $0.matchedFieldValue))
        })
    }
    
    private func executeQuery(_ track: Track, _ query: SearchQuery) -> SearchQueryMatch? {

        // Check both the filename and the display name
        if query.fields.name {
            
//            let filename = track.fileSystemInfo.fileName
//            if query.compare(filename) {
//                return SearchQueryMatch(track: track, matchedField: "filename", matchedFieldValue: filename)
//            }
            
            let displayName = track.defaultDisplayName
            if query.compare(displayName) {
                return SearchQueryMatch(track: track, matchedField: "name", matchedFieldValue: displayName)
            }
        }
        
        // Compare title field if included in search
        if query.fields.title, let theTitle = track.title, query.compare(theTitle) {
            return SearchQueryMatch(track: track, matchedField: "title", matchedFieldValue: theTitle)
        }
        
        // Didn't match
        return nil
    }
    
    func sort(_ sort: Sort) -> SortResults {
        
        tracks.sort(by: SortComparator(sort, {track in track.defaultDisplayName}).compareTracks)
        return SortResults(.tracks, sort)
    }
    
    func sort(by comparator: (Track, Track) -> Bool) {
        
        tracks.sort(by: comparator)
    }
}
