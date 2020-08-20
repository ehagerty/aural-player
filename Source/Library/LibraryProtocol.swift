import Foundation

protocol LibraryProtocol {
    
    var tracks: [Track] {get}
    
    var size: Int {get}
    
    var duration: Double {get}
    
    var summary: (size: Int, totalDuration: Double) {get}
    
    func trackAtIndex(_ index: Int) -> Track?
    
    func indexOfTrack(_ track: Track) -> Int?
    
    func hasTrack(_ track: Track) -> Bool
    
    func hasTrackForFile(_ file: URL) -> Bool
    
    func findTrackByFile(_ file: URL) -> Track?
    
    func search(_ searchQuery: SearchQuery) -> SearchResults
  
    func addTrack(_ track: Track) -> Int?
    
    func removeTracks(_ indices: IndexSet) -> [Track]
  
    func sort(_ sort: Sort) -> SortResults
    
    func sort(by comparator: (Track, Track) -> Bool)
    
    func clear()
}
