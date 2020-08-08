import Cocoa

class FFMpegReader {
    
    private static var allParsers: [FFMpegMetadataParser] = []
    
    //    private static let theReader: FFmpegMetadataReader = FFmpegMetadataReader()
    
    // TODO: Is this useful/necessary ?
    private static var wmFileParsers: [FFMpegMetadataParser] = []
    private static var vorbisCommentFileParsers: [FFMpegMetadataParser] = []
    private static var apeFileParsers: [FFMpegMetadataParser] = []
    
    private static let genericMetadata_ignoreKeys: [String] = ["title", "artist", "duration", "disc", "track", "album", "genre"]
    
    static func initialize(_ commonFFMpegParser: CommonFFMpegMetadataParser, _ id3Parser: ID3Parser, _ vorbisParser: VorbisCommentParser, _ apeParser: ApeV2Parser, _ wmParser: WMParser, _ defaultParser: DefaultFFMpegMetadataParser) {
        
        allParsers = [commonFFMpegParser, id3Parser, vorbisParser, apeParser, wmParser, defaultParser]
        
        wmFileParsers = [commonFFMpegParser, wmParser, id3Parser, vorbisParser, apeParser, defaultParser]
        vorbisCommentFileParsers = [commonFFMpegParser, vorbisParser, id3Parser, apeParser, wmParser, defaultParser]
        apeFileParsers = [commonFFMpegParser, apeParser, id3Parser, vorbisParser, wmParser, defaultParser]
    }
    
    static func buildMap(for context: FFmpegFileContext) -> FFmpegMetadataMap {
        
        var metadata: [String: String] = [:]
        
        for (key, value) in context.format.metadata {
            metadata[key] = value
        }
        
        for (key, value) in context.audioStream.metadata {
            metadata[key] = value
        }
        
        let map = FFmpegMetadataMap(context, metadata)
        allParsers.forEach {$0.mapTrack(map)}
        
        return map
    }
    
    private static func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    static func getPrimaryMetadata(from map: FFmpegMetadataMap) -> PrimaryMetadata {
        
        let title = nilIfEmpty(getTitle(from: map))
        let artist = nilIfEmpty(getArtist(from: map))
        let album = nilIfEmpty(getAlbum(from: map))
        let genre = nilIfEmpty(getGenre(from: map))
        
        let duration = getDuration(from: map)
        
        let art = getArt(from: map)
        
        return PrimaryMetadata(title: title, artist: artist, album: album, genre: genre, duration: duration, coverArt: art)
    }
    
    // TODO: Is this useful/necessary ?
    private static func parsersForTrack(_ ext: String) -> [FFMpegMetadataParser] {
        
        switch ext {
            
        case "wma":     return wmFileParsers
            
        case "flac", "ogg", "opus":     return vorbisCommentFileParsers
            
        case "ape":     return apeFileParsers
            
        default: return allParsers
            
        }
    }
    
    private static func getTitle(from map: FFmpegMetadataMap) -> String? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let title = parser.getTitle(map) {
                return title
            }
        }
        
        return nil
    }
    
    private static func getArtist(from map: FFmpegMetadataMap) -> String? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let artist = parser.getArtist(map) {
                return artist
            }
        }
        
        return nil
    }
    
    private static func getAlbum(from map: FFmpegMetadataMap) -> String? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let album = parser.getAlbum(map) {
                return album
            }
        }
        
        return nil
    }
    
    private static func getGenre(from map: FFmpegMetadataMap) -> String? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let genre = parser.getGenre(map) {
                return genre
            }
        }
        
        return nil
    }
    
    static func getDuration(from map: FFmpegMetadataMap) -> Double {
        
        // TODO: Here is where we may need to build a packet table !!! (if isRawFile, ...)
        return map.context.format.duration
    }
    
    static func getSecondaryMetadata(from map: FFmpegMetadataMap) -> SecondaryMetadata {
        
        var discNumberAndTotal = getDiscNumber(from: map)
        if let discNum = discNumberAndTotal?.number, discNumberAndTotal?.total == nil, let totalDiscs = getTotalDiscs(from: map) {
            discNumberAndTotal = (discNum, totalDiscs)
        }
        
        var trackNumberAndTotal = getTrackNumber(from: map)
        if let trackNum = trackNumberAndTotal?.number, trackNumberAndTotal?.total == nil, let totalTracks = getTotalTracks(from: map) {
            trackNumberAndTotal = (trackNum, totalTracks)
        }
        
        let lyrics = getLyrics(from: map)
        
        return SecondaryMetadata(discNumber: discNumberAndTotal?.number, totalDiscs: discNumberAndTotal?.total, trackNumber: trackNumberAndTotal?.number, totalTracks: trackNumberAndTotal?.total, lyrics: lyrics)
    }
    
    static func getChapters(from map: FFmpegMetadataMap) -> [Chapter] {
        //        return track.ffmpegMetadata?.chapters.map {Chapter($0.title, $0.startTime, $0.endTime)} ?? []
        return []
    }
    
    private static func getDiscNumber(from map: FFmpegMetadataMap) -> (number: Int?, total: Int?)? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let discNum = parser.getDiscNumber(map) {
                return discNum
            }
        }
        
        return nil
    }
    
    private static func getTotalDiscs(from map: FFmpegMetadataMap) -> Int? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let totalDiscs = parser.getTotalDiscs(map) {
                return totalDiscs
            }
        }
        
        return nil
    }
    
    private static func getTrackNumber(from map: FFmpegMetadataMap) -> (number: Int?, total: Int?)? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let trackNum = parser.getTrackNumber(map) {
                return trackNum
            }
        }
        
        return nil
    }
    
    private static func getTotalTracks(from map: FFmpegMetadataMap) -> Int? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let totalTracks = parser.getTotalTracks(map) {
                return totalTracks
            }
        }
        
        return nil
    }
    
    private static func getLyrics(from map: FFmpegMetadataMap) -> String? {
        
        for parser in parsersForTrack(map.fileType) {
            
            if let lyrics = parser.getLyrics(map) {
                return lyrics
            }
        }
        
        return nil
    }
    
    static func getArt(from map: FFmpegMetadataMap) -> CoverArt? {
        
        guard let imageStream = map.context.imageStream else {return nil}
        
        // Check if the attached pic in the image stream
        // has any data.
        if let imageData = imageStream.attachedPic.data, let image = NSImage(data: imageData) {
            
            // TODO: Image metadata
            return CoverArt(image, nil)
        }
        
        // No attached pic data.
        return nil
    }
    
    static func getArt(_ file: URL) -> CoverArt? {
        //        return FFMpegWrapper.getArt(file)
        return nil
    }
    
    static func getAllMetadata(from map: FFmpegMetadataMap) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for parser in parsersForTrack(map.fileType) {
            
            let parserMetadata = parser.getGenericMetadata(map)
            parserMetadata.forEach({(k,v) in metadata[k] = v})
        }
        
        return metadata
    }
    
    static func getDurationForFile(_ file: URL) -> Double {
        
        // TODO (not needed yet)
        return 0
    }
}
