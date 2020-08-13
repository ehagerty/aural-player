import AVFoundation

class AVFTrackContext: TrackContextProtocol {
    
    private let track: Track
    
    private let metadataContext: AVFMetadataContext
    
    private var thePlaybackContext: AVFPlaybackContext!
    var playbackContext: PlaybackContextProtocol? {thePlaybackContext}
    
    required init(for track: Track) throws {
        
        self.track = track
        self.metadataContext = try AVFMetadataContext(for: track)
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
        self.thePlaybackContext = try AVFPlaybackContext(for: track.file)
        
        // TODO: Update track duration and send out track updated notification.
//        track.metadata.duration = self.thePlaybackContext.computedDuration
    }
}
