import AVFoundation

class FFmpegMetadataContext {
    
    private let track: Track
    private let file: URL
    
    private let fileCtx: FFmpegFileContext
    private let readerCtx: FFmpegMetadataReaderContext
    
    ///
    /// The first / best audio stream in this file.
    ///
    let audioStream: FFmpegAudioStream
    
    ///
    /// The first / best video stream in this file, if one is present. May be nil.
    ///
    /// # Notes #
    ///
    /// While, in general, a video stream may contain a large number of packets,
    /// for our purposes, a video stream is treated as an "image" (i.e still image) stream
    /// with only one packet - containing our cover art.
    ///
    let imageStream: FFmpegImageStream?
    
    ///
    /// Attempts to construct a FormatContext instance for the given file.
    ///
    /// - Parameter file: The audio file to be read / decoded by this context.
    ///
    /// Fails (returns nil) if:
    ///
    /// - An error occurs while opening the file or reading (demuxing) its streams.
    /// - No audio stream is found in the file.
    ///
    init(for track: Track) throws {
        
        self.track = track
        self.file = track.file
        
        self.fileCtx = try FFmpegFileContext(for: file)
        self.readerCtx = FFMpegReader.createContext(for: fileCtx)
        
        guard let theAudioStream = fileCtx.audioStream else {
            throw FormatContextInitializationError(description: "\nUnable to find audio stream in file: '\(file.path)'")
        }
        
        self.audioStream = theAudioStream
        self.imageStream = fileCtx.imageStream
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
