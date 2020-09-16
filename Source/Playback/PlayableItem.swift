import AVFoundation

protocol PlayableItem: Hashable {
    
    var duration: Double {get}
}

protocol PlaybackContextProtocol {
    
    var audioFormat: AVAudioFormat {get}
    
//    func open()
//
//    func close()
}
