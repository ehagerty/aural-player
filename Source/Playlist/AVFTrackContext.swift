import AVFoundation

class AVFTrackContext: TrackContextProtocol {
    
    private let track: Track
    
    private let metadataContext: AVFMetadataContext
    var playbackContext: PlaybackContextProtocol?
    
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
        self.playbackContext = try AVFPlaybackContext(for: track.file)
    }
}
