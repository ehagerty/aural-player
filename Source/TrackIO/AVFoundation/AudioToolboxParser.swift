import Cocoa
import AVFoundation

@available(OSX 10.13, *)
class AudioToolboxParser: AVAssetParser {
    
    let keySpace: AVMetadataKeySpace = .audioFile
    
    static let keySpace: String = AVMetadataKeySpace.audioFile.rawValue
    
    static let key_title: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-title")
    static let rawKey_title: String = "info-title"
    
    static let key_artist: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-artist")
    
    static let key_album: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-album")
    
    static let key_genre: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-genre")
    
    static let key_trackNumber: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-track number")
    
    static let key_duration: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-approximate duration in seconds")
    
    private static let readableKeys: [String: String] = [
        "info-comments" : "Comment",
        "info-year" : "Year"
    ]
    
    private static let essentialFieldKeys: Set<String> = {
        [key_title, key_artist, key_album, key_genre, key_duration, key_trackNumber]
    }()
//
//    func getDuration(_ mapForTrack: AVFMetadata) -> Double? {
//        
//        if let item = mapForTrack.map[AudioToolboxParser.key_duration], let durationStr = item.stringValue, let durationSecs = Double(durationStr) {
//            
//            return durationSecs
//        }
//        
//        return nil
//    }
//    
    func getTitle(_ mapForTrack: AVFMetadata) -> String? {
        
//        if let titleItem = mapForTrack.map[AudioToolboxParser.key_title] {
//            return titleItem.stringValue
//        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: AVFMetadata) -> String? {
        
//        if let artistItem = mapForTrack.map[AudioToolboxParser.key_artist] {
//            return artistItem.stringValue
//        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: AVFMetadata) -> String? {
        
//        if let albumItem = mapForTrack.map[AudioToolboxParser.key_album] {
//            return albumItem.stringValue
//        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: AVFMetadata) -> String? {
        
//        if let genreItem = mapForTrack.map[AudioToolboxParser.key_genre] {
//            return genreItem.stringValue
//        }
        
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: AVFMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: AVFMetadata) -> (number: Int?, total: Int?)? {
        
//        if let trackNumItem = mapForTrack.map[AudioToolboxParser.key_trackNumber] {
//            return parseDiscOrTrackNumber(trackNumItem)
//        }
        
        return nil
    }
    
    func getArt(_ meta: AVFMetadata) -> NSImage? {
        return nil
    }
//
//
//    
//    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
//        return items.first(where: {$0.keySpace == .audioFile && $0.keyAsString == AudioToolboxParser.rawKey_title})?.stringValue
//    }
//    
//    func getGenericMetadata(_ mapForTrack: AVFMetadata) -> [String: MetadataEntry] {
//        
//        var metadata: [String: MetadataEntry] = [:]
//        
//        for item in mapForTrack.genericItems.filter({item -> Bool in item.keySpace == .audioFile}) {
//            
//            if let key = item.keyAsString, let value = item.valueAsString {
//                
//                let rKey = AudioToolboxParser.readableKeys[key] ?? key.replacingOccurrences(of: "info-", with: "").capitalizingFirstLetter()
//                metadata[key] = MetadataEntry(.audioToolbox, rKey, value)
//            }
//        }
//        
//        return metadata
//    }
}
