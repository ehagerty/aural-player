import AVFoundation

class AVFPlaybackContext: PlaybackContextProtocol {
    
    let file: URL
    let audioFile: AVAudioFile

    let audioFormat: AVAudioFormat
    
    let sampleRate: Double
    let frameCount: AVAudioFramePosition
    let computedDuration: Double
    
//    init(for file: URL) throws {
//
//        self.file = file
//        self.audioFile = try AVAudioFile(forReading: file)
//
//        self.audioFormat = audioFile.processingFormat
//        self.sampleRate = audioFormat.sampleRate
//        self.frameCount = audioFile.length
//        self.computedDuration = Double(frameCount) / sampleRate
//    }
    
    init(for file: URL) throws {
        
        self.file = file
        self.audioFile = try AVAudioFile(forReading: file)
        
        self.audioFormat = audioFile.processingFormat
        self.sampleRate = audioFormat.sampleRate
        
        let asset = AVURLAsset(url: file, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        self.computedDuration = asset.duration.seconds
        self.frameCount = AVAudioFramePosition(computedDuration * sampleRate)
    }
    
    // Called when preparing for playback
    func open() {
        
    }
    
    // Called upon completion of playback
    func close() {
        
    }
}
