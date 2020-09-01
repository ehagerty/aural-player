import Foundation

class PitchUnitDelegate: FXUnitDelegate<PitchUnit>, PitchUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    let presets: PitchPresets = PitchPresets()
    
    override var unitDescription: String {"Pitch Shift"}
    
    var pitch: PitchShift {
        
        get {PitchShift(fromCents: roundedInt(unit.pitch))}
        set(shift) {unit.pitch = Float(shift.asCents)}
    }
    
    init(_ unit: PitchUnit, _ persistentUnitState: PitchUnitState, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
        
        unit.state = persistentUnitState.state
        unit.pitch = persistentUnitState.pitch
        
        presets.addPresets(persistentUnitState.userPresets)
    }
    
    func increasePitch() -> PitchShift {
        
        ensureActiveAndResetPitch()
        return setUnitPitch(min(2400, unit.pitch + Float(preferences.pitchDelta)))
    }
    
    func decreasePitch() -> PitchShift {
        
        ensureActiveAndResetPitch()
        return setUnitPitch(max(-2400, unit.pitch - Float(preferences.pitchDelta)))
    }
    
    private func setUnitPitch(_ value: Float) -> PitchShift {

        unit.pitch = value
        return self.pitch
    }
    
    private func ensureActiveAndResetPitch() {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase/decrease
        if state != .active {
            
            _ = unit.toggleState()
            unit.pitch = AppDefaults.pitch
        }
    }
    
    override func savePreset(_ presetName: String) {
//        presets.addPreset(PitchPreset(presetName, .active, PitchShift(fromCents: roundedInt(pitch)), false))
    }

    override func applyPreset(_ presetName: String) {

        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: PitchPreset) {
//        pitch = Float(preset.pitch.asCents)
    }
    
//    var settingsAsPreset: PitchPreset {
//        return PitchPreset("pitchSettings", state, PitchShift(fromCents: roundedInt(pitch)), false)
//    }
    
    var persistentState: PitchUnitState {
            
            let unitState = PitchUnitState()
            
            unitState.state = state
//            unitState.pitch = pitch
//            unitState.overlap = overlap
    //        unitState.userPresets = presets.userDefinedPresets
            
            return unitState
        }
}
