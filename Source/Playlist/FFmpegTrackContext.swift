import Foundation

class FFmpegTrackContext: TrackContextProtocol {
    
    private let track: Track
    
    private let fileContext: FFmpegFileContext
    private let metadataContext: FFmpegMetadataContext
    
    var playbackContext: PlaybackContextProtocol?
    
    required init(for track: Track) throws {
        
        self.track = track
        self.fileContext = try FFmpegFileContext(forFile: track.file)
        self.metadataContext = FFmpegMetadataContext(for: track, fileContext: fileContext)
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
        self.playbackContext = try FFmpegPlaybackContext(for: fileContext)
    }
}
