import Foundation

class FFmpegTrackContext: TrackContextProtocol {
    
    private let track: Track
    private let fileContext: FFmpegFileContext
    
    required init(for track: Track) throws {
        
        self.track = track
        self.fileContext = try FFmpegFileContext(forFile: track.file)
    }
    
    func loadPrimaryMetadata() {
        
    }
    
    func loadSecondaryMetadata() {
        
    }
    
    func loadAllMetadata() {
        
    }
    
    func prepareForPlayback() throws {
        
    }
}
