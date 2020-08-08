import Cocoa
import AVFoundation

/*
    Contract for a metadata specification
 */
protocol AVAssetParser {
    
    func mapTrack(_ mapForTrack: AVFMetadataMap)
    
    func getDuration(_ mapForTrack: AVFMetadataMap) -> Double?
    
    func getTitle(_ mapForTrack: AVFMetadataMap) -> String?
    
    func getArtist(_ mapForTrack: AVFMetadataMap) -> String?
    
    func getAlbum(_ mapForTrack: AVFMetadataMap) -> String?
    
    func getGenre(_ mapForTrack: AVFMetadataMap) -> String?
    
    func getLyrics(_ mapForTrack: AVFMetadataMap) -> String?
    
    func getDiscNumber(_ mapForTrack: AVFMetadataMap) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(_ mapForTrack: AVFMetadataMap) -> (number: Int?, total: Int?)?
    
    func getArt(_ mapForTrack: AVFMetadataMap) -> CoverArt?
    
    func getArt(_ asset: AVURLAsset) -> CoverArt?
    
    func getGenericMetadata(_ mapForTrack: AVFMetadataMap) -> [String: MetadataEntry]
    
    // ----------- Chapter-related functions
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

protocol FFMpegMetadataParser {
    
    func mapTrack(_ mapForTrack: FFmpegMetadataMap)
    
    func getTitle(_ mapForTrack: FFmpegMetadataMap) -> String?
    
    func getArtist(_ mapForTrack: FFmpegMetadataMap) -> String?
    
    func getAlbum(_ mapForTrack: FFmpegMetadataMap) -> String?
    
    func getGenre(_ mapForTrack: FFmpegMetadataMap) -> String?
    
    func getLyrics(_ mapForTrack: FFmpegMetadataMap) -> String?
    
    func getDiscNumber(_ mapForTrack: FFmpegMetadataMap) -> (number: Int?, total: Int?)?
    
    func getTotalDiscs(_ mapForTrack: FFmpegMetadataMap) -> Int?
    
    func getTrackNumber(_ mapForTrack: FFmpegMetadataMap) -> (number: Int?, total: Int?)?
    
    func getTotalTracks(_ mapForTrack: FFmpegMetadataMap) -> Int?
    
    func getGenericMetadata(_ mapForTrack: FFmpegMetadataMap) -> [String: MetadataEntry]
}
