import Foundation

class MasterUnitDelegate: FXUnitDelegate<MasterUnit>, MasterUnitDelegateProtocol {
    
//    let graph: AudioGraphProtocol
    
    var slaveUnits: [FXUnitDelegateProtocol]
    
    var eqUnit: EQUnitDelegate
    var pitchUnit: PitchUnitDelegate
    var timeUnit: TimeUnitDelegate
    var reverbUnit: ReverbUnitDelegate
    var delayUnit: DelayUnitDelegate
    var filterUnit: FilterUnitDelegate
    
    let presets: MasterPresets = MasterPresets()
    
    override var unitDescription: String {"Master"}
    
    init(_ unit: MasterUnit, slaveUnits: [FXUnitDelegateProtocol]) {
        
//        self.graph = graph
        self.slaveUnits = slaveUnits
        
        eqUnit = slaveUnits.first(where: {$0 is EQUnitDelegate})! as! EQUnitDelegate
        pitchUnit = slaveUnits.first(where: {$0 is PitchUnitDelegate})! as! PitchUnitDelegate
        timeUnit = slaveUnits.first(where: {$0 is TimeUnitDelegate})! as! TimeUnitDelegate
        reverbUnit = slaveUnits.first(where: {$0 is ReverbUnitDelegate})! as! ReverbUnitDelegate
        delayUnit = slaveUnits.first(where: {$0 is DelayUnitDelegate})! as! DelayUnitDelegate
        filterUnit = slaveUnits.first(where: {$0 is FilterUnitDelegate})! as! FilterUnitDelegate
        
        super.init(unit)
    }
    
    override func savePreset(_ presetName: String) {
        
//        let eqPreset = eqUnit.settingsAsPreset
//        eqPreset.name = String(format: "EQ settings for Master preset: '%@'", presetName)
//
//        let pitchPreset = pitchUnit.settingsAsPreset
//        pitchPreset.name = String(format: "Pitch settings for Master preset: '%@'", presetName)
//
//        let timePreset = timeUnit.settingsAsPreset
//        timePreset.name = String(format: "Time settings for Master preset: '%@'", presetName)
//
//        let reverbPreset = reverbUnit.settingsAsPreset
//        reverbPreset.name = String(format: "Reverb settings for Master preset: '%@'", presetName)
//
//        let delayPreset = delayUnit.settingsAsPreset
//        delayPreset.name = String(format: "Delay settings for Master preset: '%@'", presetName)
//
//        let filterPreset = filterUnit.settingsAsPreset
//        filterPreset.name = String(format: "Filter settings for Master preset: '%@'", presetName)
//
//        // Save the new preset
//        let masterPreset = MasterPreset(presetName, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
//        presets.addPreset(masterPreset)
    }
    
//    var settingsAsPreset: MasterPreset {
//
//        let eqPreset = eqUnit.settingsAsPreset
//        let pitchPreset = pitchUnit.settingsAsPreset
//        let timePreset = timeUnit.settingsAsPreset
//        let reverbPreset = reverbUnit.settingsAsPreset
//        let delayPreset = delayUnit.settingsAsPreset
//        let filterPreset = filterUnit.settingsAsPreset
//
//        return MasterPreset("masterSettings", eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
//    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
//        eqUnit.applyPreset(preset.eq)
//        eqUnit.state = preset.eq.state
//
//        pitchUnit.applyPreset(preset.pitch)
//        pitchUnit.state = preset.pitch.state
//
//        timeUnit.applyPreset(preset.time)
//        timeUnit.state = preset.time.state
//
//        reverbUnit.applyPreset(preset.reverb)
//        reverbUnit.state = preset.reverb.state
//
//        delayUnit.applyPreset(preset.delay)
//        delayUnit.state = preset.delay.state
//
//        filterUnit.applyPreset(preset.filter)
//        filterUnit.state = preset.filter.state
    }
    
    var persistentState: MasterUnitState {
        
        let unitState = MasterUnitState()
        
        unitState.state = state
        unitState.userPresets = presets.userDefinedPresets
        
        return unitState
    }
}
