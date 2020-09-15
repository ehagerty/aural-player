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
    
    func getYear(_ mapForTrack: AVFMetadataMap) -> Int?
    
    func getGenericMetadata(_ mapForTrack: AVFMetadataMap) -> [String: MetadataEntry]
    
    // ----------- Chapter-related functions
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

protocol FFMpegMetadataParser {
    
    func mapTrack(_ mapForTrack: FFmpegMetadataReaderContext)
    
    func getTitle(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
    
    func getArtist(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
    
    func getAlbum(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
    
    func getGenre(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
    
    func getLyrics(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
    
    func getDiscNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)?
    
    func getTotalDiscs(_ mapForTrack: FFmpegMetadataReaderContext) -> Int?
    
    func getTrackNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)?
    
    func getTotalTracks(_ mapForTrack: FFmpegMetadataReaderContext) -> Int?
    
    func getYear(_ mapForTrack: FFmpegMetadataReaderContext) -> Int?
    
    func getGenericMetadata(_ mapForTrack: FFmpegMetadataReaderContext) -> [String: MetadataEntry]
}

extension FFMpegMetadataParser {
    
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
    
    func getYear(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
}
