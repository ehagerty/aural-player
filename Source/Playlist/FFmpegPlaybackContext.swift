import AVFoundation

class FFmpegPlaybackContext: PlaybackContextProtocol {
    
//    var fileContext: FFmpegFileContext
    
    var audioFormat: AVAudioFormat {AVAudioFormat(settings: [:])!}
    
    ///
    /// The maximum number of samples that will be read, decoded, and scheduled for **immediate** playback,
    /// i.e. when **play(file)** is called, triggered by the user.
    ///
    /// # Notes #
    ///
    /// 1. This value should be small enough so that, when starting playback
    /// of a file, there is little to no perceived lag. Typically, this should represent about 2-5 seconds of audio (depending on sample rate).
    ///
    /// 2. This value should generally be smaller than *sampleCountForDeferredPlayback*.
    ///
    let sampleCountForImmediatePlayback: Int32
    
    ///
    /// The maximum number of samples that will be read, decoded, and scheduled for **deferred** playback, i.e. playback that will occur
    /// at a later time, as the result, of a recursive scheduling task automatically triggered when a previously scheduled audio buffer has finished playing.
    ///
    /// # Notes #
    ///
    /// 1. The greater this value, the longer each recursive scheduling task will take to complete, and the larger the memory footprint of each audio buffer.
    /// The smaller this value, the more often disk reads will occur. Choose a value that is a good balance between memory usage, decoding / resampling time, and frequency of disk reads.
    /// Example: 10-20 seconds of audio (depending on sample rate).
    ///
    /// 2. This value should generally be larger than *sampleCountForImmediatePlayback*.
    ///
    let sampleCountForDeferredPlayback: Int32
    
    init(for file: URL) {
        
//        self.fileContext = fileContext
//        let codec: FFmpegAudioCodec = fileContext.audioCodec
//
//        let sampleRate: Int32 = codec.sampleRate
//        let channelLayout: AVAudioChannelLayout = FFmpegChannelLayoutsMapper.mapLayout(ffmpegLayout: Int(codec.channelLayout))!
//        self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channelLayout: channelLayout)
//
//        // The effective sample rate, which also takes into account the channel count, gives us a better idea
//        // of the computational cost of decoding and resampling the given file, as opposed to just the
//        // sample rate.
//        let channelCount: Int32 = codec.channelCount
//        let effectiveSampleRate: Int32 = sampleRate * channelCount
//
//        switch effectiveSampleRate {
//
//        case 0..<100000:
//
//            // 44.1 / 48 KHz stereo
//
//            sampleCountForImmediatePlayback = 5 * sampleRate    // 5 seconds of audio
//            sampleCountForDeferredPlayback = 10 * sampleRate    // 10 seconds of audio
//
//        case 100000..<500000:
//
//            // 96 / 192 KHz stereo
//
//            sampleCountForImmediatePlayback = 3 * sampleRate    // 3 seconds of audio
//            sampleCountForDeferredPlayback = 10 * sampleRate    // 10 seconds of audio
//
//        default:
//
//            // 96 KHz surround and higher sample rates
//
//            sampleCountForImmediatePlayback = 2 * sampleRate    // 2 seconds of audio
//            sampleCountForDeferredPlayback = 7 * sampleRate     // 7 seconds of audio
//        }
        sampleCountForImmediatePlayback = 0
        sampleCountForDeferredPlayback = 0
    }
    
    func prepareForPlayback() throws {
        
        // If the PCM sample format produced by the codec for this file is not suitable for use with our audio engine,
        // all samples need to be resampled (converted) to a suitable format. So, prepare the resampler for that
        // conversion if required.
        
//        let codec: FFmpegAudioCodec = fileContext.audioCodec
//
//        if !codec.isOpen {
//            try codec.open()
//
//        } else {
//
//            let time = measureExecutionTime {
//
////
////                fileContext = try FFmpegFileContext(forFile: fileContext.file)
////                try fileContext.audioCodec.open()
////            }
//
//            fileContext.format.seekToStart(within: fileContext.audioStream)
//            }
//
//            print("\nTook \(time * 1000) msec to seek to START for \(fileContext.file.lastPathComponent)")
//        }
//
//        if codec.sampleFormat.needsResampling {
//            ObjectGraph.ffmpegResampler.allocateFor(channelCount: codec.channelCount, sampleCount: sampleCountForDeferredPlayback)
//        }
    }
}
