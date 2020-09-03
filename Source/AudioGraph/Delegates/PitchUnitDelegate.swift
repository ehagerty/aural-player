import Foundation

class PitchUnitDelegate: FXUnitDelegate<PitchUnit>, PitchUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    let presets: PitchPresets = PitchPresets()
    
    override var unitDescription: String {"Pitch Shift"}
    
    var pitch: PitchShift {
        
        didSet {
            unit.pitch = Float(pitch.asCents)
        }
    }
    
    init(_ unit: PitchUnit, _ persistentUnitState: PitchUnitState, _ preferences: SoundPreferences) {
        
        self.pitch = persistentUnitState.pitch
        self.preferences = preferences
        
        super.init(unit)
        
        unit.state = persistentUnitState.state
        unit.pitch = Float(self.pitch.asCents)
        
        presets.addPresets(persistentUnitState.userPresets)
    }
    
    func increasePitch() -> PitchShift {
        
        ensureActiveAndResetPitch()
        self.pitch = PitchShift(fromCents: (self.pitch.asCents + preferences.pitchDeltaAsCents).clampedTo(range: AppConstants.Sound.pitchRange))
        
        return self.pitch
    }
    
    func decreasePitch() -> PitchShift {
        
        ensureActiveAndResetPitch()
        self.pitch = PitchShift(fromCents: (self.pitch.asCents - preferences.pitchDeltaAsCents).clampedTo(range: AppConstants.Sound.pitchRange))
        
        return self.pitch
    }
    
    private func ensureActiveAndResetPitch() {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase/decrease
        if state != .active {
            
            _ = unit.toggleState()
            self.pitch = AppDefaults.pitch
        }
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(PitchPreset(presetName, .active, self.pitch, false))
    }

    override func applyPreset(_ presetName: String) {

        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: PitchPreset) {
        self.pitch = preset.pitch
    }
    
    var settingsAsPreset: PitchPreset {
        return PitchPreset("pitchSettings", unit.state, self.pitch, false)
    }
    
    var persistentState: PitchUnitState {
        
        let unitState = PitchUnitState()
        
        unitState.state = unit.state
        unitState.pitch = self.pitch
        unitState.userPresets = presets.userDefinedPresets
        
        return unitState
    }
}
