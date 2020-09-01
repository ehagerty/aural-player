import AVFoundation

class TimeUnit: FXUnit, TimeUnitProtocol {
    
    private let node: VariableRateNode = VariableRateNode()
    
    init() {
        super.init(.time)
    }
    
    override var avNodes: [AVAudioNode] {return [node.timePitchNode, node.variNode]}

    var rate: Float {
        
        get {return node.rate}
        set(newValue) {node.rate = newValue}
    }
    
    var overlap: Float {
        
        get {return node.overlap}
        set(newValue) {node.overlap = newValue}
    }
    
    var shiftPitch: Bool {
        
        get {return node.shiftPitch}
        set(newValue) {node.shiftPitch = newValue}
    }
    
    var pitch: Float {
        return node.pitch
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
}
