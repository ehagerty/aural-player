import Cocoa
import AVFoundation

/*
    Contract for a metadata specification
 */
protocol AVAssetParser {
    
    var keySpace: AVMetadataKeySpace {get}
    
    func getDuration(_ meta: AVFMetadata) -> Double?
    
    func getTitle(_ meta: AVFMetadata) -> String?
    
    func getArtist(_ meta: AVFMetadata) -> String?
    
    func getAlbumArtist(_ meta: AVFMetadata) -> String?
    
    func getAlbum(_ meta: AVFMetadata) -> String?
    
    func getComposer(_ meta: AVFMetadata) -> String?
    
    func getConductor(_ meta: AVFMetadata) -> String?
    
    func getPerformer(_ meta: AVFMetadata) -> String?
    
    func getLyricist(_ meta: AVFMetadata) -> String?
    
    func getGenre(_ meta: AVFMetadata) -> String?
    
    func getLyrics(_ meta: AVFMetadata) -> String?
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(_ meta: AVFMetadata) -> NSImage?
    
    func getYear(_ meta: AVFMetadata) -> Int?
    
    func getBPM(_ meta: AVFMetadata) -> Int?
//    
//    func getGenericMetadata(_ mapForTrack: AVFMetadata) -> [String: MetadataEntry]
//    
//    // ----------- Chapter-related functions
//    
//    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

extension AVAssetParser {
    
    func getAlbumArtist(_ meta: AVFMetadata) -> String? {nil}
    
    func getDuration(_ meta: AVFMetadata) -> Double? {nil}
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getLyrics(_ meta: AVFMetadata) -> String? {nil}
    
    func getComposer(_ meta: AVFMetadata) -> String? {nil}
    
    func getConductor(_ meta: AVFMetadata) -> String? {nil}
    
    func getPerformer(_ meta: AVFMetadata) -> String? {nil}
    
    func getLyricist(_ meta: AVFMetadata) -> String? {nil}
    
    func getYear(_ meta: AVFMetadata) -> Int? {nil}
    
    func getBPM(_ meta: AVFMetadata) -> Int? {nil}
}

protocol FFMpegMetadataParser {
    
//    func mapTrack(_ mapForTrack: FFmpegMetadataReaderContext)
//
//    func getTitle(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
//
//    func getArtist(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
//
//    func getAlbum(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
//
//    func getGenre(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
//
//    func getLyrics(_ mapForTrack: FFmpegMetadataReaderContext) -> String?
//
//    func getDiscNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)?
//
//    func getTotalDiscs(_ mapForTrack: FFmpegMetadataReaderContext) -> Int?
//
//    func getTrackNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)?
//
//    func getTotalTracks(_ mapForTrack: FFmpegMetadataReaderContext) -> Int?
//
//    func getYear(_ mapForTrack: FFmpegMetadataReaderContext) -> Int?
//
//    func getGenericMetadata(_ mapForTrack: FFmpegMetadataReaderContext) -> [String: MetadataEntry]
}

extension FFMpegMetadataParser {
    
//    func getTitle(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
//        return nil
//    }
//
//    func getArtist(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
//        return nil
//    }
//
//    func getAlbum(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
//        return nil
//    }
//
//    func getGenre(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
//        return nil
//    }
//
//    func getLyrics(_ mapForTrack: FFmpegMetadataReaderContext) -> String? {
//        return nil
//    }
//
//    func getDiscNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
//        return nil
//    }
//
//    func getTotalDiscs(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
//        return nil
//    }
//
//    func getTrackNumber(_ mapForTrack: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
//        return nil
//    }
//
//    func getTotalTracks(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
//        return nil
//    }
//
//    func getYear(_ mapForTrack: FFmpegMetadataReaderContext) -> Int? {
//        return nil
//    }
}
