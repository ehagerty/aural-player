import Foundation

class PlayQueueTrack: PlayableItem {
    
    // Unique ID (i.e. UUID) ... used to differentiate two PlayQueueItem objects
    let id: String
    
    let track: Track
    var duration: Double {track.duration}
    
    init(track: Track) {
        
        self.id = UUID().uuidString
        self.track = track
    }
    
    static func == (lhs: PlayQueueTrack, rhs: PlayQueueTrack) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
