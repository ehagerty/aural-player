import Foundation

/*
    Encapsulates playback sequence state
 */
class PlayQueueState: PersistentState {
    
    var tracks: [URL] = []
    
    var repeatMode: RepeatMode = AppDefaults.repeatMode
    var shuffleMode: ShuffleMode = AppDefaults.shuffleMode
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlayQueueState()
        
        if let trackPathsArr = map["tracks"] as? [String] {
            state.tracks = trackPathsArr.map {URL(fileURLWithPath: $0)}
        }
        
        state.repeatMode = mapEnum(map, "repeatMode", AppDefaults.repeatMode)
        state.shuffleMode = mapEnum(map, "shuffleMode", AppDefaults.shuffleMode)
        
        return state
    }
}

extension PlayQueue: PersistentModelObject {
    
    var persistentState: PersistentState {
        
        let state = PlayQueueState()
        
        state.tracks = tracks.map {$0.file}
        
        let modes = sequence.repeatAndShuffleModes
        state.repeatMode = modes.repeatMode
        state.shuffleMode = modes.shuffleMode
        
        return state
    }
}
