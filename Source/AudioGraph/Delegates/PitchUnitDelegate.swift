import Foundation

class PitchUnitDelegate: FXUnitDelegate<PitchUnit>, PitchUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    override var unitDescription: String {"Pitch Shift"}
    
    var pitch: PitchShift {
        
        get {
            
            var cents = roundedInt(unit.pitch)
            
            let octaves = cents / AppConstants.ValueConversions.pitch_octaveToCents
            cents -= octaves * AppConstants.ValueConversions.pitch_octaveToCents
            
            let semitones = cents / AppConstants.ValueConversions.pitch_semitoneToCents
            cents -= semitones * AppConstants.ValueConversions.pitch_semitoneToCents
            
            return PitchShift(octaves: octaves, semitones: semitones, cents: cents)
        }
        
        set(shift) {
            
            let cents = (shift.octaves * AppConstants.ValueConversions.pitch_octaveToCents) +
                        (shift.semitones * AppConstants.ValueConversions.pitch_semitoneToCents) +
                        shift.cents
            
            unit.pitch = Float(cents)
        }
    }
    
    var presets: PitchPresets {return unit.presets}
    
    init(_ unit: PitchUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
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
}
