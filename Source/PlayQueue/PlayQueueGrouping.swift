import Foundation

class PlayQueueGroup: Group<String, PlayQueueTrack> {}

class PlayQueueGrouping: Grouping<String, PlayQueueTrack> {}

class PlayQueueGenericGrouping: PlayQueueGrouping {
    
    private let keyFunction: (PlayQueueTrack) -> String
    
    init(keyFunction: @escaping (PlayQueueTrack) -> String) {
        self.keyFunction = keyFunction
    }
    
    override func keyForItem(_ item: PlayQueueTrack) -> String {
        return keyFunction(item)
    }
}

class PlayQueueArtistGrouping: PlayQueueGrouping {
    
    private static let defaultKey: String = "<Unknown Artist>"
    
    override func keyForItem(_ item: PlayQueueTrack) -> String {
        return item.track.artist ?? Self.defaultKey
    }
}

class PlayQueueAlbumGrouping: PlayQueueGrouping {
    
    private static let defaultKey: String = "<Unknown Album>"
    
    override func keyForItem(_ item: PlayQueueTrack) -> String {
        return item.track.album ?? Self.defaultKey
    }
}

class PlayQueueGenreGrouping: PlayQueueGrouping {
    
    private static let defaultKey: String = "<Unknown Genre>"
    
    override func keyForItem(_ item: PlayQueueTrack) -> String {
        return item.track.genre ?? Self.defaultKey
    }
}
