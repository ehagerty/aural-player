import AVFoundation

protocol TrackContextProtocol {
    
    init(for track: Track) throws
    
    var playbackContext: PlaybackContextProtocol? {get}
    
    func loadPrimaryMetadata()
    
    func loadSecondaryMetadata()
    
    func loadAllMetadata()
    
    func prepareForPlayback() throws
}

protocol PlaybackContextProtocol {
    
    var audioFormat: AVAudioFormat {get}
}
