import AVFoundation

class FFmpegPlaybackContext: PlaybackContextProtocol {
    
    private let fileContext: FFmpegFileContext
    let audioFormat: AVAudioFormat
    
    init(for fileContext: FFmpegFileContext) {
        
        self.fileContext = fileContext
        
        let channelLayout = FFmpegChannelLayoutsMapper.mapLayout(ffmpegLayout: Int(fileContext.audioCodec.channelLayout))!
        self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(fileContext.audioCodec.sampleRate), channelLayout: channelLayout)
    }
}
