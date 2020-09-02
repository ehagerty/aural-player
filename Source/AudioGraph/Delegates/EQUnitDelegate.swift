import Foundation

class EQUnitDelegate: FXUnitDelegate<EQUnit>, EQUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    let presets: EQPresets = EQPresets()
    
    override var unitDescription: String {"Equalizer"}
    
    init(_ unit: EQUnit, _ persistentUnitState: EQUnitState, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
        
        unit.state = persistentUnitState.state
        unit.bands = persistentUnitState.bands
        unit.globalGain = persistentUnitState.globalGain
        
        presets.addPresets(persistentUnitState.userPresets)
    }
    
    var globalGain: Float {
        
        get {return unit.globalGain}
        set(newValue) {unit.globalGain = newValue}
    }
    
    var bands: [Float] {
        
        get {return unit.bands}
        set(newValue) {unit.bands = newValue}
    }
    
    func setBand(_ index: Int, gain: Float) {
        unit.setBand(index, gain: gain)
    }
    
    func increaseBass() -> [Float] {
        
        ensureEQActive()
        return unit.increaseBass(preferences.eqDelta)
    }
    
    func decreaseBass() -> [Float] {
        
        ensureEQActive()
        return unit.decreaseBass(preferences.eqDelta)
    }
    
    func increaseMids() -> [Float] {
        
        ensureEQActive()
        return unit.increaseMids(preferences.eqDelta)
    }
    
    func decreaseMids() -> [Float] {
        
        ensureEQActive()
        return unit.decreaseMids(preferences.eqDelta)
    }
    
    func increaseTreble() -> [Float] {
        
        ensureEQActive()
        return unit.increaseTreble(preferences.eqDelta)
    }
    
    func decreaseTreble() -> [Float] {
        
        ensureEQActive()
        return unit.decreaseTreble(preferences.eqDelta)
    }
    
    private func ensureEQActive() {
        
        // If the EQ unit is currently inactive, activate it
        if state != .active {
            
            _ = toggleState()
            
            // Reset to "flat" preset (because it is equivalent to an inactive EQ)
            unit.bands = EQPresets.defaultPreset.bands
        }
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(EQPreset(presetName, .active, unit.bands, unit.globalGain, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        unit.bands = preset.bands
        unit.globalGain = preset.globalGain
    }
    
    var settingsAsPreset: EQPreset {
        return EQPreset("eqSettings", unit.state, unit.bands, unit.globalGain, false)
    }
    
    var persistentState: EQUnitState {
        
        let unitState = EQUnitState()
        
        unitState.state = unit.state
        unitState.bands = unit.bands
        unitState.globalGain = unit.globalGain
        unitState.userPresets = presets.userDefinedPresets
        
        return unitState
    }
}
