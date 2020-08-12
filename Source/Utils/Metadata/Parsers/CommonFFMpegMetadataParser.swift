import Cocoa

fileprivate let key_title = "title"
fileprivate let key_artist = "artist"
fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"

fileprivate let key_lyrics = "lyrics"

fileprivate let key_albumArtist = "album_artist"
fileprivate let key_comment = "comment"
fileprivate let key_composer = "composer"
fileprivate let key_performer = "performer"
fileprivate let key_publisher = "publisher"
fileprivate let key_copyright = "copyright"

fileprivate let key_encodedBy = "encoded_by"
fileprivate let key_encoder = "encoder"
fileprivate let key_language = "language"
fileprivate let key_date = "date"

class CommonFFMpegMetadataParser: FFMpegMetadataParser {
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_disc, key_track, key_lyrics]
    
    private let genericKeys: [String: String] = [
        
        key_albumArtist: "Album Artist",
        key_composer: "Composer",
        key_performer: "Performer",
        key_publisher: "Publisher",
        key_copyright: "Copyright",
        key_encodedBy: "Encoded By",
        key_encoder: "Encoder",
        key_language: "Language",
        key_date: "Date",
        key_comment: "Comment"
    ]
    
    func mapTrack(_ mapForTrack: FFmpegMetadataReaderContext) {
        
        let metadata = FFmpegParserMetadataMap()
        mapForTrack.commonMetadata = metadata
        
        for (key, value) in mapForTrack.map {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys.contains(lcKey) {
                
                metadata.essentialFields[lcKey] = value
                mapForTrack.map.removeValue(forKey: key)
                
            } else if genericKeys[lcKey] != nil {
                
                metadata.genericFields[lcKey] = value
                mapForTrack.map.removeValue(forKey: key)
            }
        }
    }
    
    func getTitle(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return mapForTrack.commonMetadata?.essentialFields[key_title]
    }
    
    func getArtist(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return mapForTrack.commonMetadata?.essentialFields[key_artist]
    }
    
    func getAlbum(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return mapForTrack.commonMetadata?.essentialFields[key_album]
    }
    
    func getGenre(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return mapForTrack.commonMetadata?.essentialFields[key_genre]
    }
    
    func getLyrics(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return mapForTrack.commonMetadata?.essentialFields[key_lyrics]
    }
    
    func getDiscNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.commonMetadata?.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = mapForTrack.commonMetadata?.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: FFmpegMetadataReaderContext) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.commonMetadata?.genericFields {
            
            for (key, var value) in fields {
                
                if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                    value = langName
                }
                
                value = StringUtils.cleanUpString(value)
                
                metadata[key] = MetadataEntry(.common, readableKey(key), value)
            }
        }
        
        return metadata
    }
    
    func readableKey(_ key: String) -> String {
        return genericKeys[key] ?? key.capitalizingFirstLetter()
    }
}
