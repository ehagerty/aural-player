import AVFoundation

class FFmpegMetadataContext {
    
    private let track: Track
    private let fileContext: FFmpegFileContext
    
    private let map: FFmpegMetadataMap
 
    init(for track: Track, fileContext: FFmpegFileContext) {
        
        self.track = track
        self.fileContext = fileContext
        self.map = FFMpegReader.buildMap(for: fileContext)
    }
    
    func loadPrimaryMetadata() {
        track.metadata.setPrimaryMetadata(FFMpegReader.getPrimaryMetadata(from: map))
    }
    
    func loadSecondaryMetadata() {
        track.metadata.setSecondaryMetadata(FFMpegReader.getSecondaryMetadata(from: map))
    }
    
    func loadAllMetadata() {
        track.metadata.setGenericMetadata(FFMpegReader.getAllMetadata(from: map))
    }
}
