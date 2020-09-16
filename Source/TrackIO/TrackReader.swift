import Foundation

class TrackReader {
    
    func loadPrimaryMetadata(for track: Track) {
        
        do {
            
//            track.isNativelySupported ? try AVFTrackContext(for: self) : try FFmpegTrackContext(for: self)
            
        } catch {
            
//            isPlayable = false
//            validationError = error
        }
    }
    
    func loadSecondaryMetadata(for track: Track) {
        
    }
    
    func loadAllMetadata() {
    }
    
    func prepareForPlayback() throws {
    }
}
