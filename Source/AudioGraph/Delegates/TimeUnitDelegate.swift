import Foundation

class TimeUnitDelegate: FXUnitDelegate<TimeUnit>, TimeUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    let presets: TimePresets = TimePresets()
    
    override var unitDescription: String {"Time Stretch"}
    
    var rate: Float {
        
        get {unit.rate}
        set {unit.rate = newValue}
    }
    
    var effectiveRate: Float {
        return isActive ? rate : 1.0
    }
    
    var formattedRate: String {ValueFormatter.formatTimeStretchRate(rate)}
    
    var shiftPitch: Bool {
        
        get {unit.shiftPitch}
        set {unit.shiftPitch = newValue}
    }
    
    var pitch: Float {unit.pitch}
    
    var formattedPitch: String {ValueFormatter.formatPitchShift(PitchShift(fromCents: roundedInt(unit.pitch)))}
    
    init(_ unit: TimeUnit, _ persistentUnitState: TimeUnitState, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
        
        unit.state = persistentUnitState.state
        unit.rate = persistentUnitState.rate
        unit.shiftPitch = persistentUnitState.shiftPitch
        
        presets.addPresets(persistentUnitState.userPresets)
    }
    
    func increaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is increased by an amount set in the user preferences
        // TODO: Put this value in a constant
        rate = min(4, rate + preferences.timeDelta)
        
        return (rate, formattedRate)
    }
    
    func decreaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is decreased by an amount set in the user preferences
        // TODO: Put this value in a constant
        rate = max(0.25, rate - preferences.timeDelta)
        
        return (rate, formattedRate)
    }
    
    private func ensureActiveAndResetRate() {
        
        if state != .active {
            
            _ = toggleState()
            
            // If the time unit is currently inactive, start at default playback rate, before the increase
            rate = AppDefaults.timeStretchRate
        }
    }
    
    override func savePreset(_ presetName: String) {
//        presets.addPreset(TimePreset(presetName, .active, node.rate, node.overlap, node.shiftPitch, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: TimePreset) {
        
        rate = preset.rate
//        overlap = preset.overlap
        shiftPitch = preset.shiftPitch
    }
    
//    var settingsAsPreset: TimePreset {
//        return TimePreset("timeSettings", state, rate, overlap, shiftPitch, false)
//    }
    
        var persistentState: TimeUnitState {

            let unitState = TimeUnitState()

            unitState.state = state
            unitState.rate = rate
//            unitState.overlap = overlap
            unitState.shiftPitch = shiftPitch
            unitState.userPresets = presets.userDefinedPresets

            return unitState
        }
}
