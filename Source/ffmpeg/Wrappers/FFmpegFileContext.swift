import Foundation

///
/// Encapsulates an ffmpeg AVFormatContext struct that represents an audio file's container format,
/// and provides convenient Swift-style access to its functions and member variables.
///
/// - Demultiplexing: Reads all streams within the audio file.
/// - Reads and provides audio stream data as encoded / compressed packets (which can be passed to the appropriate codec).
/// - Performs seeking to arbitrary positions within the audio stream.
///
class FFmpegFileContext {

    ///
    /// The file that is to be read by this context.
    ///
    let file: URL
    
    ///
    /// The absolute path of **file***, as a String.
    ///
    let filePath: String
    
    ///
    /// The encapsulated AVFormatContext object.
    ///
    var avContext: AVFormatContext {pointer.pointee}
    
    ///
    /// A pointer to the encapsulated AVFormatContext object.
    ///
    var pointer: UnsafeMutablePointer<AVFormatContext>!
    
    ///
    /// The first / best audio stream in this file, if one is present. May be nil.
    ///
    let audioStream: FFmpegAudioStream?
    
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
    
    lazy var metadata: [String: String] = FFmpegMetadataDictionary(readingFrom: avContext.metadata).dictionary
    
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
    init(for file: URL) throws {
        
        self.file = file
        self.filePath = file.path
        
        // MARK: Open the file ----------------------------------------------------------------------------------
        
        // Allocate memory for this format context.
        self.pointer = avformat_alloc_context()
        
        guard self.pointer != nil else {
            throw FormatContextInitializationError(description: "Unable to allocate memory for format context for file '\(filePath)'.")
        }
        
        // Try to open the audio file so that it can be read.
        var resultCode: ResultCode = avformat_open_input(&pointer, file.path, nil, nil)
        
        // If the file open failed, log a message and return nil.
        guard resultCode.isNonNegative, pointer?.pointee != nil else {
            throw FormatContextInitializationError(description: "Unable to open file '\(filePath)'. Error: \(resultCode.errorDescription)")
        }
        
        // MARK: Read the streams ----------------------------------------------------------------------------------
        
        // Try to read information about the streams contained in this file.
        resultCode = avformat_find_stream_info(pointer, nil)
        
        // If the read failed, log a message and return nil.
        guard resultCode.isNonNegative, let avStreamsArrayPointer = pointer.pointee.streams else {
            throw FormatContextInitializationError(description: "Unable to find stream info for file '\(file.path)'. Error: \(resultCode.errorDescription)")
        }
        
        let avStreamPointers: [UnsafeMutablePointer<AVStream>] = (0..<pointer.pointee.nb_streams).compactMap {avStreamsArrayPointer.advanced(by: Int($0)).pointee}
        
        let audioStreamIndex = av_find_best_stream(pointer, AVMEDIA_TYPE_AUDIO, -1, -1, nil, 0)
        self.audioStream = audioStreamIndex.isNonNegative ? try FFmpegAudioStream(encapsulating: avStreamPointers[Int(audioStreamIndex)]) : nil
        
        let imageStreamIndex = av_find_best_stream(pointer, AVMEDIA_TYPE_VIDEO, -1, -1, nil, 0)
        self.imageStream = imageStreamIndex.isNonNegative ? try FFmpegImageStream(encapsulating: avStreamPointers[Int(imageStreamIndex)]) : nil
    }
    
    ///
    /// Read and return a single packet from this context, that is part of a given stream.
    ///
    /// - Parameter stream: The stream we want to read from.
    ///
    /// - returns: A single packet, if its stream index matches that of the given stream, nil otherwise.
    ///
    /// - throws: **PacketReadError**, if an error occurred while attempting to read a packet.
    ///
    func readPacket(from stream: FFmpegStreamProtocol) throws -> FFmpegPacket? {
        
        let packet = try FFmpegPacket(readingFromFormat: pointer)
        return packet.streamIndex == stream.index ? packet : nil
    }
    
    /// Indicates whether or not this object has already been destroyed.
    private var destroyed: Bool = false
    
    ///
    /// Performs cleanup (deallocation of allocated memory space) when
    /// this object is about to be deinitialized or is no longer needed.
    ///
    func destroy() {

        // This check ensures that the deallocation happens
        // only once. Otherwise, a fatal error will be
        // thrown.
        if destroyed {return}

        // Close the context.
        avformat_close_input(&pointer)
        
        // Free the context and all its streams.
        avformat_free_context(pointer)
        
        destroyed = true
    }

    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        destroy()
    }
}
