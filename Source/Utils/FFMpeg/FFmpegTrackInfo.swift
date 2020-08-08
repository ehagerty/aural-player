import Foundation

/*
    Encapsulates all metadata for a single track read by ffmpeg
 */
class FFmpegTrackInfo {
    
    let duration: Double
    let fileFormatDescription: String?
    let streams: [LibAVStream]
//    let metadata: FFmpegMetadataMap
    let drmProtected: Bool
    
    let chapters: [Chapter]
    
    // Computed values
    let hasValidAudioTrack: Bool
    let hasArt: Bool
    let audioStream: LibAVStream?
    let audioFormat: String?
    
    init(_ duration: Double, _ fileFormatDescription: String?, _ streams: [LibAVStream], _ metadata: [String: String], _ drmProtected: Bool, _ chapters: [Chapter]) {
        
        self.duration = duration
        self.fileFormatDescription = fileFormatDescription
        self.streams = streams
//        self.metadata = FFmpegMetadataMap(metadata)
        self.drmProtected = drmProtected
        
        self.chapters = chapters
        
        self.audioStream = streams.isEmpty ? nil : streams.filter({$0.type == .audio}).first
        
        if let stream = audioStream {
            
            hasValidAudioTrack =
                (stream.channelCount ?? 0) > 0 &&
                (stream.sampleRate ?? 0) > 0 &&
                AppConstants.SupportedTypes.allAudioFormats.contains(stream.format)
            
        } else {
            
            hasValidAudioTrack = false
        }
        
        if let stream = streams.filter({$0.type == .art}).first {
            hasArt = AppConstants.SupportedTypes.artFormats.contains(stream.format)
        } else {
            hasArt = false
        }
        
        audioFormat = audioStream?.format
    }
}

class FFmpegMetadataMap {
    
    var context: FFmpegFileContext
    
    var fileType: String {context.file.pathExtension.lowercased()}
    
    var map: [String: String]
    
    var commonMetadata: FFmpegParserMetadataMap?
    var id3Metadata: FFmpegParserMetadataMap?
    var wmMetadata: FFmpegParserMetadataMap?
    var vorbisMetadata: FFmpegParserMetadataMap?
    var apeMetadata: FFmpegParserMetadataMap?
    var otherMetadata: FFmpegParserMetadataMap?
    
    init(_ context: FFmpegFileContext, _ map: [String: String]) {
        
        self.context = context
        self.map = map
    }
}

class FFmpegParserMetadataMap {
    
    var essentialFields: [String: String] = [:]
    var genericFields: [String: String] = [:]
}

class LibAVStream {
    
    let type: LibAVStreamType
    let format: String
    
    // These properties only apply to audio streams
    var formatDescription: String?
    var bitRate: Double?
    var channelCount: Int?
    var channelLayout: String?
    var sampleRate: Double?
    
    // For audio streams
    init(_ format: String, _ formatDescription: String?, _ bitRate: Double?, _ channelCount: Int, _ channelLayout: String?, _ sampleRate: Double) {
        
        self.type = .audio
        self.format = format
        self.formatDescription = formatDescription
        
        self.bitRate = bitRate
        self.channelCount = channelCount
        self.channelLayout = channelLayout
        self.sampleRate = sampleRate
    }
    
    // For video streams (i.e. art)
    init(_ format: String) {
        
        self.type = .art
        self.format = format
    }
}

enum LibAVStreamType: String {
    
    case audio
    case art
    case other
    
    static func fromString(_ string: String) -> LibAVStreamType {
        return LibAVStreamType(rawValue: string) ?? .other
    }
}
