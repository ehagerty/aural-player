import Foundation

class PitchUnitDelegate: FXUnitDelegate<PitchUnit>, PitchUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    override var unitDescription: String {"Pitch Shift"}
    
    var pitch: Int {
        
        get {roundedInt(unit.pitch)}
        set(newValue) {unit.pitch = Float(newValue)}
    }
    
    var formattedPitch: String {
        
        let pitch = self.pitch
        
        if pitch == 0 {
            return "0"
            
        } else if pitch > 0 {
            
            if pitch % AppConstants.ValueConversions.pitch_octaveToCents == 0 {
                
                let octaves = pitch / AppConstants.ValueConversions.pitch_octaveToCents
                return "+\(octaves) 8ve"
            }
            
            if pitch % AppConstants.ValueConversions.pitch_semitoneToCents == 0 {
                
                let semitones = pitch / AppConstants.ValueConversions.pitch_semitoneToCents
                return "+\(semitones) m2"
            }
            
            return "+\(pitch) cents"
            
        } else {
            
            if pitch % AppConstants.ValueConversions.pitch_octaveToCents == 0 {
                
                let octaves = pitch / AppConstants.ValueConversions.pitch_octaveToCents
                return "\(octaves) 8ve"
            }
            
            if pitch % AppConstants.ValueConversions.pitch_semitoneToCents == 0 {
                
                let semitones = pitch / AppConstants.ValueConversions.pitch_semitoneToCents
                return "\(semitones) m2"
            }
            
            return "\(pitch) cents"
        }
    }
    
    var overlap: Float {
        
        get {return unit.overlap}
        set(newValue) {unit.overlap = newValue}
    }
    
    var formattedOverlap: String {
        return ValueFormatter.formatOverlap(overlap)
    }
    
    var presets: PitchPresets {return unit.presets}
    
    init(_ unit: PitchUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
    }
    
    func increasePitch() -> (pitch: Float, pitchString: String) {
        
        ensureActiveAndResetPitch()
        return setUnitPitch(min(2400, unit.pitch + Float(preferences.pitchDelta)))
    }
    
    func decreasePitch() -> (pitch: Float, pitchString: String) {
        
        ensureActiveAndResetPitch()
        return setUnitPitch(max(-2400, unit.pitch - Float(preferences.pitchDelta)))
    }
    
    private func setUnitPitch(_ value: Float) -> (pitch: Float, pitchString: String) {
        
        unit.pitch = value
        return (Float(pitch), formattedPitch)
    }
    
    private func ensureActiveAndResetPitch() {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase/decrease
        if state != .active {
            
            _ = unit.toggleState()
            unit.pitch = AppDefaults.pitch
        }
    }
}
