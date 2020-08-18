import Cocoa
import AVFoundation

/*
    Encapsulates all information about a single track
 */
class Track: Hashable, PlayableItem {
    
    let file: URL
    
    let isNativelySupported: Bool
    
    var context: TrackContextProtocol!
    var playbackContext: PlaybackContextProtocol? {context.playbackContext}
    
    let metadata: TrackMetadata
    var hasPrimaryMetadata: Bool {metadata.hasPrimaryMetadata}
    
    var isValidTrack: Bool = true
    var validationError: Error?
    
    var duration: Double {metadata.duration}
    var defaultDisplayName: String {metadata.defaultDisplayName}
    
    var title: String? {metadata.title}
    var artist: String? {metadata.artist}
    var album: String? {metadata.album}
    var genre: String? {metadata.genre}
    
    var trackNumber: Int? {metadata.trackNumber}
    var totalTracks: Int? {metadata.totalTracks}
    
    var discNumber: Int? {metadata.discNumber}
    var totalDiscs: Int? {metadata.totalDiscs}
    
    var lyrics: String? {metadata.lyrics}
    
    var art: CoverArt? {metadata.art}
    
    var chapters: [Chapter] {metadata.chapters}
    var hasChapters: Bool {metadata.hasChapters}
    
    init(_ file: URL) {

        self.file = file
        
        let fileExt = file.pathExtension.lowercased()
        self.isNativelySupported = AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExt)
        
        self.metadata = TrackMetadata(for: file)
    }
    
    func loadPrimaryMetadata() {
        
        do {
         
            self.context = isNativelySupported ? try AVFTrackContext(for: self) : try FFmpegTrackContext(for: self)
            context.loadPrimaryMetadata()
            
        } catch {
            
            isValidTrack = false
            validationError = error
        }
    }
    
    func loadSecondaryMetadata() {
        context?.loadSecondaryMetadata()
    }
    
    func loadAllMetadata() {
        context?.loadAllMetadata()
    }
    
    func prepareForPlayback() throws {
        try context?.prepareForPlayback()
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
