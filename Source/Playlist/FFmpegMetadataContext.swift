import AVFoundation

class FFmpegMetadataContext {
    
    private let track: Track
    private let readerCtx: FFmpegMetadataReaderContext
    
    init(for track: Track, with fileContext: FFmpegFileContext) {
        
        self.track = track
        self.readerCtx = FFMpegReader.createContext(for: fileContext)
    }
 
    func loadPrimaryMetadata() {
        track.metadata.setPrimaryMetadata(FFMpegReader.getPrimaryMetadata(from: readerCtx))
    }
    
    func loadSecondaryMetadata() {
        track.metadata.setSecondaryMetadata(FFMpegReader.getSecondaryMetadata(from: readerCtx))
    }
    
    func loadAllMetadata() {
        track.metadata.setGenericMetadata(FFMpegReader.getAllMetadata(from: readerCtx))
    }
}
