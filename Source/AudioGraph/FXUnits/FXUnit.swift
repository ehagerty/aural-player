import Foundation
import AVFoundation

class FXUnit {
    
    var unitType: EffectsUnit
    
    var state: EffectsUnitState {
        didSet {stateChanged()}
    }
    
    var stateFunction: EffectsUnitStateFunction {
        return {return self.state}
    }
    
    var avNodes: [AVAudioNode] {return []}
    
    var isActive: Bool {return state == .active}
    
    init(_ unitType: EffectsUnit) {
        
        self.unitType = unitType
        self.state = .bypassed
        stateChanged()
    }
    
    func stateChanged() {
        
        if isActive && unitType != .master {
            Messenger.publish(.fx_unitActivated)
        }
    }
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> EffectsUnitState {
        
        state = state == .active ? .bypassed : .active
        return state
    }
    
    // TODO: There is a feedback loop going from slaveUnit -> masterUnit that results in this function being called
    // again a 2nd time from its first call. FIX IT !!!
    func ensureActive() {
        if !isActive {_ = toggleState()}
    }
    
    func suppress() {
        state = state == .active ? .suppressed : state
    }
    
    func unsuppress() {
        state = state == .suppressed ? .active : state
    }
    
    func reset() {}
}

// Enumeration of all the effects units
enum EffectsUnit: Int {

    case master
    case eq
    case pitch
    case time
    case reverb
    case delay
    case filter
//    case recorder
}

typealias EffectsUnitStateFunction = () -> EffectsUnitState
