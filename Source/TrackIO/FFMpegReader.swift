import Cocoa

class FFMpegReader {
    
    private static var allParsers: [FFMpegMetadataParser] = []
    
    // TODO: Is this useful/necessary ?
    private static var wmFileParsers: [FFMpegMetadataParser] = []
    private static var vorbisCommentFileParsers: [FFMpegMetadataParser] = []
    private static var apeFileParsers: [FFMpegMetadataParser] = []
    
    private static let genericMetadata_ignoreKeys: [String] = ["title", "artist", "duration", "disc", "track", "album", "genre"]
    
    static func initialize(_ commonFFMpegParser: CommonFFMpegMetadataParser, _ id3Parser: ID3Parser, _ vorbisParser: VorbisCommentParser, _ apeParser: ApeV2Parser, _ wmParser: WMParser, _ defaultParser: DefaultFFMpegMetadataParser) {
        
//        allParsers = [commonFFMpegParser, id3Parser, vorbisParser, apeParser, wmParser, defaultParser]
//
//        wmFileParsers = [commonFFMpegParser, wmParser, id3Parser, vorbisParser, apeParser, defaultParser]
//        vorbisCommentFileParsers = [commonFFMpegParser, vorbisParser, id3Parser, apeParser, wmParser, defaultParser]
//        apeFileParsers = [commonFFMpegParser, apeParser, id3Parser, vorbisParser, wmParser, defaultParser]
    }
}
