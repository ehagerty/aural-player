import AVFoundation

class DelayUnit: FXUnit, DelayUnitProtocol {
    
    private let node: AVAudioUnitDelay = AVAudioUnitDelay()
    
    init() {
        super.init(.delay)
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    override func reset() {
        node.reset()
    }
    
    var amount: Float {
        
        get {return node.wetDryMix}
        set(newValue) {node.wetDryMix = newValue}
    }
    
    var time: Double {
        
        get {return node.delayTime}
        set(newValue) {node.delayTime = newValue}
    }
    
    var feedback: Float {
        
        get {return node.feedback}
        set(newValue) {node.feedback = newValue}
    }
    
    var lowPassCutoff: Float {
        
        get {return node.lowPassCutoff}
        set(newValue) {node.lowPassCutoff = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
}
