import AVFoundation

class EQUnit: FXUnit, EQUnitProtocol {
    
    private let node: ParametricEQNode = ParametricEQNode()
    
    init() {
        super.init(.eq)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    var globalGain: Float {
        
        get {return node.globalGain}
        set(newValue) {node.globalGain = newValue}
    }
    
    var bands: [Float] {
        
        get {return node.allBands()}
        set(newValue) {node.setBands(newValue)}
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    func setBand(_ index: Int , gain: Float) {
        node.setBand(index, gain: gain)
    }
    
    func increaseBass(_ increment: Float) -> [Float] {
        return node.increaseBass(increment)
    }
    
    func decreaseBass(_ decrement: Float) -> [Float] {
        return node.decreaseBass(decrement)
    }
    
    func increaseMids(_ increment: Float) -> [Float] {
        return node.increaseMids(increment)
    }
    
    func decreaseMids(_ decrement: Float) -> [Float] {
        return node.decreaseMids(decrement)
    }
    
    func increaseTreble(_ increment: Float) -> [Float] {
        return node.increaseTreble(increment)
    }
    
    func decreaseTreble(_ decrement: Float) -> [Float] {
        return node.decreaseTreble(decrement)
    }
}
