import Foundation

/*
    Encapsulates library state
 */
struct LibraryState: PersistentState {
    
    // List of track files
    var tracks: [URL] = []
    
    init() {}
    
    init(files: [URL]) {
        self.tracks = files
    }
    
    init(tracks: [Track]) {
        self.tracks = tracks.map {$0.file}
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        return LibraryState(files: (map["tracks"] as? [String])?.compactMap {URL(fileURLWithPath: $0)} ?? [])
    }
}

extension Library: PersistentModelObject {
    
    // Returns all state for the library that needs to be persisted to disk
    var persistentState: PersistentState {LibraryState(tracks: tracks)}
}
