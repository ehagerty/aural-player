import Cocoa

class DefaultFFMpegMetadataParser: FFMpegMetadataParser {
    
    private let ignoredKeys: [String] = ["priv.www.amazon.com"]
    
    func mapTrack(_ mapForTrack: FFmpegMetadataReaderContext) {
        
        let metadata = FFmpegParserMetadataMap()
        mapForTrack.otherMetadata = metadata
        
        for (key, value) in mapForTrack.map {
            
            for iKey in ignoredKeys {
                
                if !key.lowercased().contains(iKey) {
                    metadata.genericFields[formatKey(key)] = value
                }
            }
            
            mapForTrack.map.removeValue(forKey: key)
        }
    }

    private func formatKey(_ key: String) -> String {
        
        let tokens = key.split(separator: "_")
        var fTokens = [String]()
        
        tokens.forEach({fTokens.append(String($0).capitalizingFirstLetter())})
        
        return fTokens.joined(separator: " ")
    }
    
    func getGenericMetadata(_ mapForTrack: FFmpegMetadataReaderContext) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.otherMetadata?.genericFields {
            
            for (key, value) in fields {
                metadata[key] = MetadataEntry(.other, key, StringUtils.cleanUpString(value.trim()))
            }
        }
        
        return metadata
    }
    
    func getTitle(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getArtist(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getAlbum(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getGenre(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getLyrics(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
}
