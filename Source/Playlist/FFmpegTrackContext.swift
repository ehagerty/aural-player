import Foundation

class FFmpegTrackContext: TrackContextProtocol {
    
    private let track: Track
    private let metadataContext: FFmpegMetadataContext
    
    private var thePlaybackContext: FFmpegPlaybackContext!
    var playbackContext: PlaybackContextProtocol? {thePlaybackContext}
    
    required init(for track: Track) throws {
        
        self.track = track
        self.metadataContext = try FFmpegMetadataContext(for: track)
    }
    
    func loadPrimaryMetadata() {
        metadataContext.loadPrimaryMetadata()
    }
    
    func loadSecondaryMetadata() {
        metadataContext.loadSecondaryMetadata()
    }
    
    func loadAllMetadata() {
        metadataContext.loadAllMetadata()
    }
    
    func prepareForPlayback() throws {
        
        if thePlaybackContext == nil {
//            thePlaybackContext = FFmpegPlaybackContext(for: track.file)
        }
        
        try thePlaybackContext.prepareForPlayback()
    }
}
