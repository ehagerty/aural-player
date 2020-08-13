import Foundation

class FFmpegTrackContext: TrackContextProtocol {
    
    private let track: Track
    private let fileContext: FFmpegFileContext
    
    private let metadataContext: FFmpegMetadataContext

    private var thePlaybackContext: FFmpegPlaybackContext!
    var playbackContext: PlaybackContextProtocol? {thePlaybackContext}
    
    required init(for track: Track) throws {
        
        self.track = track
        
        self.fileContext = try FFmpegFileContext(for: track.file)
        self.metadataContext = FFmpegMetadataContext(for: track, with: fileContext)
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
            thePlaybackContext = FFmpegPlaybackContext(for: fileContext)
        }
        
        try thePlaybackContext.prepareForPlayback()
    }
}
