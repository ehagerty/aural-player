import Cocoa

//protocol MetadataReader {
//
//    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata
//
//    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata
//
//    func getDurationForFile(_ file: URL) -> Double
//
//    func getArt(_ track: Track) -> CoverArt?
//
//    func getArt(_ file: URL) -> CoverArt?
//
//    func getAllMetadata(_ track: Track) -> [String: MetadataEntry]
//}

struct PrimaryMetadata {
    
    var fileType: String?
    var audioFormat: String?
    
    var title: String?
    var artist: String?
    var albumArtist: String?
    var album: String?
    var genre: String?
    
    var composer: String?
    var conductor: String?
    var performer: String?
    var lyricist: String?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var year: Int?
    
    var bpm: Int?
    
    var duration: Double = 0
    
    var art: CoverArt?
}

struct SecondaryMetadata {
    
    var lyrics: String?
    
    var genericMetadata: OrderedMetadataMap = OrderedMetadataMap()
    
    var chapters: [Chapter] = []
}
