import Foundation

protocol LibraryDelegateProtocol {
    
    var tracks: [Track] {get}
    
    var size: Int {get}
    
    var duration: Double {get}
    
    var summary: (size: Int, totalDuration: Double) {get}
    
    // Whether or not tracks are being added to the playlist (which could be time consuming)
    var isBeingModified: Bool {get}
    
    func trackAtIndex(_ index: Int) -> Track?
    
    func indexOfTrack(_ track: Track) -> Int?
    
    func findTrackByFile(_ file: URL) -> Track?
    
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    
    
  
    func addFiles(_ files: [URL])
    
    func findOrAddFile(_ file: URL) throws -> Track?
    
    func removeTracks(_ indices: IndexSet)
  
    func sort(_ sort: Sort)
    
    func sort(by comparator: (Track, Track) -> Bool)
    
    func clear()
}
