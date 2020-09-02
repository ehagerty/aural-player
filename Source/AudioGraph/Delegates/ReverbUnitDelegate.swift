import Foundation

class ReverbUnitDelegate: FXUnitDelegate<ReverbUnit>, ReverbUnitDelegateProtocol {
    
    let presets: ReverbPresets = ReverbPresets()
    
    override var unitDescription: String {"Reverb"}
    
    var space: ReverbSpaces {
        
        get {return unit.space}
        set(newValue) {unit.space = newValue}
    }
    
    var amount: Float {
        
        get {return unit.amount}
        set(newValue) {unit.amount = newValue}
    }
    
    var formattedAmount: String {
        return ValueFormatter.formatReverbAmount(amount)
    }
    
    init(_ unit: ReverbUnit, _ persistentUnitState: ReverbUnitState) {

        super.init(unit)
        
        unit.state = persistentUnitState.state
        unit.space = persistentUnitState.space
        unit.amount = persistentUnitState.amount
        
        presets.addPresets(persistentUnitState.userPresets)
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(ReverbPreset(presetName, .active, unit.space, unit.amount, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        unit.space = preset.space
        unit.amount = preset.amount
    }
    
    var settingsAsPreset: ReverbPreset {
        return ReverbPreset("reverbSettings", unit.state, unit.space, unit.amount, false)
    }
    
    var persistentState: ReverbUnitState {
        
        let unitState = ReverbUnitState()
        
        unitState.state = unit.state
        unitState.space = unit.space
        unitState.amount = unit.amount
        unitState.userPresets = presets.userDefinedPresets
        
        return unitState
    }
}
