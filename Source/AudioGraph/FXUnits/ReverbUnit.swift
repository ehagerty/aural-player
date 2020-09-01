import AVFoundation

class ReverbUnit: FXUnit, ReverbUnitProtocol {
    
    private let node: AVAudioUnitReverb = AVAudioUnitReverb()
    
    init() {
        
        avSpace = ReverbSpaces.smallRoom.avPreset
        
        super.init(.reverb)
        
//        avSpace = reverbState.space.avPreset
//        amount = reverbState.amount
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    override func reset() {
        node.reset()
    }
    
    var avSpace: AVAudioUnitReverbPreset {
        didSet {node.loadFactoryPreset(avSpace)}
    }
    
    var space: ReverbSpaces {
        
        get {return ReverbSpaces.mapFromAVPreset(avSpace)}
        set(newValue) {avSpace = newValue.avPreset}
    }
    
    var amount: Float {
        
        get {return node.wetDryMix}
        set(newValue) {node.wetDryMix = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
}
