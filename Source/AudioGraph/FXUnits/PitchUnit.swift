import AVFoundation

class PitchUnit: FXUnit, PitchShiftUnitProtocol {
    
    private let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    
    init() {
        super.init(.pitch)
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    var pitch: Float {
        
        get {return node.pitch}
        set(newValue) {node.pitch = newValue}
    }
    
    var overlap: Float {
        
        get {return node.overlap}
        set(newValue) {node.overlap = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
}
