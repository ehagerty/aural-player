//
//  EffectsUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An abstract representation of (base class for) an effects unit that processes audio. It contains
/// properties and functions common to all effects units - eg. unit state.
///
/// No instances of this type are to be used directly, as this class is only intended to be used as a base
/// class for concrete effects unit classes.
///
class EffectsUnit {
    
    var unitType: EffectsUnitType
    
    var state: EffectsUnitState {
        didSet {stateChanged()}
    }
    
    var stateFunction: EffectsUnitStateFunction {
        return {return self.state}
    }
    
    var avNodes: [AVAudioNode] {return []}
    
    var isActive: Bool {return state == .active}
    
    init(_ unitType: EffectsUnitType, _ state: EffectsUnitState) {
        
        self.unitType = unitType
        self.state = state
        stateChanged()
    }
    
    func stateChanged() {
        
        if isActive && unitType != .master {
            Messenger.publish(.effects_unitActivated)
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
        
        if state == .active {
            state = .suppressed
        }
    }
    
    func unsuppress() {
        
        if state == .suppressed {
            state = .active
        }
    }
    
    func reset() {}
    
    func savePreset(_ presetName: String) {}
    
    func applyPreset(_ presetName: String) {}
}
