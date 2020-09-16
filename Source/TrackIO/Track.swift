import Cocoa
import AVFoundation

/*
    Encapsulates all information about a single track
 */
class Track: Hashable, PlayableItem {
    
    let file: URL
    let fileExtension: String
    
    let isNativelySupported: Bool
    
    var playbackContext: PlaybackContextProtocol?
    
    var isPlayable: Bool = true
    var validationError: Error?
    
    var hasPrimaryMetadata: Bool = false
    
    let defaultDisplayName: String
    
    var duration: Double = 0

    var title: String?
    var artist: String?
    
    var artistTitleString: String? {
        
        if let theArtist = artist, let theTitle = title {
            return "\(theArtist) - \(theTitle)"
        }
        
        return title
    }
    
    var album: String?
    var genre: String?
    
    var art: CoverArt?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var lyrics: String?
    
    // Generic metadata
    var genericMetadata: [String: MetadataEntry] = [:]
    
    var chapters: [Chapter] = []
    var hasChapters: Bool {!chapters.isEmpty}
    
    init(_ file: URL) {

        self.file = file
        self.fileExtension = file.pathExtension.lowercased()
        self.defaultDisplayName = file.deletingPathExtension().lastPathComponent
        
        self.isNativelySupported = AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension)
    }
    
    func loadPrimaryMetadata() {
        
//        do {
//
//            self.context = isNativelySupported ? try AVFTrackContext(for: self) : try FFmpegTrackContext(for: self)
//            context.loadPrimaryMetadata()
//
//        } catch {
//
//            isPlayable = false
//            validationError = error
//        }
    }
    
    func loadSecondaryMetadata() {
//        context?.loadSecondaryMetadata()
    }
    
    func loadAllMetadata() {
//        context?.loadAllMetadata()
    }
    
    func prepareForPlayback() throws {
//        try context?.prepareForPlayback()
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file.path)
    }
}

class LazyLoadingInfo {
    
    // Whether or not the track is ready for playback
    var validated: Bool = false
    var preparedForPlayback: Bool = false
    
    var primaryInfoLoaded: Bool = false
    var secondaryInfoLoaded: Bool = false
    
    var artLoaded: Bool = false
    
    // Whether or not optional track metadata and audio/filesystem info has been loaded
    var detailedInfoLoaded: Bool = false
    
    // Error info if track prep fails
    var preparationFailed: Bool = false
    var preparationError: InvalidTrackError?
    
    func preparationFailed(_ error: InvalidTrackError?) {
        
        preparationFailed = true
        preparationError = error
    }
}

// Wrapper around Track that includes its location within a group in a hierarchical playlist
//struct GroupedTrack {
//    
//    let track: Track
//    let group: Group
//    
//    let trackIndex: Int
//    let groupIndex: Int
//    
//    init(_ track: Track, _ group: Group, _ trackIndex: Int, _ groupIndex: Int) {
//        
//        self.track = track
//        self.group = group
//        self.trackIndex = trackIndex
//        self.groupIndex = groupIndex
//    }
//}
