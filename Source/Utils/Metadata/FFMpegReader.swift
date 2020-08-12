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
    
    static func createContext(for fileCtx: FFmpegFileContext) -> FFmpegMetadataReaderContext {
        
        let context = FFmpegMetadataReaderContext(for: fileCtx)
        allParsers.forEach {$0.mapTrack(context)}
        
        return context
    }
    
    private static func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    static func getPrimaryMetadata(from context: FFmpegMetadataReaderContext) -> PrimaryMetadata {
        
        let title = nilIfEmpty(getTitle(from: context))
        let artist = nilIfEmpty(getArtist(from: context))
        let album = nilIfEmpty(getAlbum(from: context))
        let genre = nilIfEmpty(getGenre(from: context))
        
        let duration = getDuration(from: context)
        
        let art = getArt(from: context)
        
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
    
    private static func getTitle(from context: FFmpegMetadataReaderContext) -> String? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let title = parser.getTitle(context) {
                return title
            }
        }
        
        return nil
    }
    
    private static func getArtist(from context: FFmpegMetadataReaderContext) -> String? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let artist = parser.getArtist(context) {
                return artist
            }
        }
        
        return nil
    }
    
    private static func getAlbum(from context: FFmpegMetadataReaderContext) -> String? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let album = parser.getAlbum(context) {
                return album
            }
        }
        
        return nil
    }
    
    private static func getGenre(from context: FFmpegMetadataReaderContext) -> String? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let genre = parser.getGenre(context) {
                return genre
            }
        }
        
        return nil
    }
    
    static func getDuration(from context: FFmpegMetadataReaderContext) -> Double {
        
        // TODO: Here is where we may need to build a packet table !!! (if isRawFile, ...)
        let fileCtx = context.fileCtx
        guard let audioStream = fileCtx.audioStream else {return 0}

        let isRawAudioFile = AppConstants.SupportedTypes.rawAudioFileExtensions.contains(context.fileType)
        
        if isRawAudioFile {
            
            // TODO: Store the packet table somewhere for later use !!!
            return FFmpegPacketTable(forFile: fileCtx.file)?.duration ?? 0
            
        } else {
            
            let avContext = fileCtx.avContext
            return audioStream.duration ?? (avContext.duration > 0 ? (Double(avContext.duration) / Double(AV_TIME_BASE)) : 0)
        }
    }
    
    static func getSecondaryMetadata(from context: FFmpegMetadataReaderContext) -> SecondaryMetadata {
        
        var discNumberAndTotal = getDiscNumber(from: context)
        if let discNum = discNumberAndTotal?.number, discNumberAndTotal?.total == nil, let totalDiscs = getTotalDiscs(from: context) {
            discNumberAndTotal = (discNum, totalDiscs)
        }
        
        var trackNumberAndTotal = getTrackNumber(from: context)
        if let trackNum = trackNumberAndTotal?.number, trackNumberAndTotal?.total == nil, let totalTracks = getTotalTracks(from: context) {
            trackNumberAndTotal = (trackNum, totalTracks)
        }
        
        let lyrics = getLyrics(from: context)
        
        return SecondaryMetadata(discNumber: discNumberAndTotal?.number, totalDiscs: discNumberAndTotal?.total, trackNumber: trackNumberAndTotal?.number, totalTracks: trackNumberAndTotal?.total, lyrics: lyrics)
    }
    
    static func getChapters(from context: FFmpegMetadataReaderContext) -> [Chapter] {
        //        return track.ffmpegMetadata?.chapters.map {Chapter($0.title, $0.startTime, $0.endTime)} ?? []
        return []
    }
    
    private static func getDiscNumber(from context: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let discNum = parser.getDiscNumber(context) {
                return discNum
            }
        }
        
        return nil
    }
    
    private static func getTotalDiscs(from context: FFmpegMetadataReaderContext) -> Int? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let totalDiscs = parser.getTotalDiscs(context) {
                return totalDiscs
            }
        }
        
        return nil
    }
    
    private static func getTrackNumber(from context: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let trackNum = parser.getTrackNumber(context) {
                return trackNum
            }
        }
        
        return nil
    }
    
    private static func getTotalTracks(from context: FFmpegMetadataReaderContext) -> Int? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let totalTracks = parser.getTotalTracks(context) {
                return totalTracks
            }
        }
        
        return nil
    }
    
    private static func getLyrics(from context: FFmpegMetadataReaderContext) -> String? {
        
        for parser in parsersForTrack(context.fileType) {
            
            if let lyrics = parser.getLyrics(context) {
                return lyrics
            }
        }
        
        return nil
    }
    
    static func getArt(from context: FFmpegMetadataReaderContext) -> CoverArt? {
        
        guard let imageStream = context.fileCtx.imageStream else {return nil}
        
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
    
    static func getAllMetadata(from context: FFmpegMetadataReaderContext) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for parser in parsersForTrack(context.fileType) {
            
            let parserMetadata = parser.getGenericMetadata(context)
            parserMetadata.forEach({(k,v) in metadata[k] = v})
        }
        
        return metadata
    }
    
    static func getDurationForFile(_ file: URL) -> Double {
        
        // TODO (not needed yet)
        return 0
    }
}
