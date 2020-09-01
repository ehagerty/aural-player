import Foundation

class DelayUnitDelegate: FXUnitDelegate<DelayUnit>, DelayUnitDelegateProtocol {
    
    let presets: DelayPresets = DelayPresets()
    
    override var unitDescription: String {"Delay"}
    
    var amount: Float {
        
        get {return unit.amount}
        set(newValue) {unit.amount = newValue}
    }
    
    var formattedAmount: String {return ValueFormatter.formatDelayAmount(amount)}
    
    var time: Double {
        
        get {return unit.time}
        set(newValue) {unit.time = newValue}
    }
    
    var formattedTime: String {return ValueFormatter.formatDelayTime(time)}
    
    var feedback: Float {
        
        get {return unit.feedback}
        set(newValue) {unit.feedback = newValue}
    }
    
    var formattedFeedback: String {return ValueFormatter.formatDelayFeedback(feedback)}
    
    var lowPassCutoff: Float {
        
        get {return unit.lowPassCutoff}
        set(newValue) {unit.lowPassCutoff = newValue}
    }
    
    var formattedLowPassCutoff: String {return ValueFormatter.formatDelayLowPassCutoff(lowPassCutoff)}
    
    init(_ unit: DelayUnit, _ persistentUnitState: DelayUnitState) {

        super.init(unit)
        
        unit.state = persistentUnitState.state
        unit.time = persistentUnitState.time
        unit.amount = persistentUnitState.amount
        unit.feedback = persistentUnitState.feedback
        unit.lowPassCutoff = persistentUnitState.lowPassCutoff
        
        presets.addPresets(persistentUnitState.userPresets)
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(DelayPreset(presetName, .active, amount, time, feedback, lowPassCutoff, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: DelayPreset) {
        
        time = preset.time
        amount = preset.amount
        feedback = preset.feedback
        lowPassCutoff = preset.lowPassCutoff
    }
    
    var settingsAsPreset: DelayPreset {
        return DelayPreset("delaySettings", state, amount, time, feedback, lowPassCutoff, false)
    }
    
    var persistentState: DelayUnitState {
        
        let unitState = DelayUnitState()
        
        unitState.state = state
        unitState.time = time
        unitState.amount = amount
        unitState.feedback = feedback
        unitState.lowPassCutoff = lowPassCutoff
        unitState.userPresets = presets.userDefinedPresets
        
        return unitState
    }
}

