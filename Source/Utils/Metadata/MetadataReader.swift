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
    
    let title: String?
    let artist: String?
    let album: String?
    let genre: String?
    
    let duration: Double
    
    let coverArt: CoverArt?
}

struct SecondaryMetadata {
    
    let discNumber: Int?
    let totalDiscs: Int?
    
    let trackNumber: Int?
    let totalTracks: Int?
    
    let lyrics: String?
}
