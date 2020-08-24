import Foundation

class TimeUnitDelegate: FXUnitDelegate<TimeUnit>, TimeUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
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
    
    var presets: TimePresets {unit.presets}
    
    init(_ unit: TimeUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
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
}
