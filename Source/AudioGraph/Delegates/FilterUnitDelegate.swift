import AVFoundation

class FilterUnitDelegate: FXUnitDelegate<FilterUnit>, FilterUnitDelegateProtocol {

    let presets: FilterPresets = FilterPresets()
    
    override var unitDescription: String {"Filter"}
    
    var bands: [FilterBand] {
        
        get {return unit.bands}
        set(newValue) {unit.bands = newValue}
    }
    
    init(_ unit: FilterUnit, _ persistentUnitState: FilterUnitState) {

        super.init(unit)
        
        unit.state = persistentUnitState.state
        unit.bands = persistentUnitState.bands
        
        presets.addPresets(persistentUnitState.userPresets)
    }
    
    func addBand(_ band: FilterBand) -> Int {
        return unit.addBand(band)
    }
    
    func updateBand(_ index: Int, _ band: FilterBand) {
        unit.updateBand(index, band)
    }
    
    func removeBands(_ indexSet: IndexSet) {
        unit.removeBands(indexSet)
    }
    
    func removeAllBands() {
        unit.removeAllBands()
    }
    
    func getBand(_ index: Int) -> FilterBand {
        return unit.getBand(index)
    }
    
    override func savePreset(_ presetName: String) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        presets.addPreset(FilterPreset(presetName, .active, unit.bands.map {$0.clone()}, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: FilterPreset) {
        unit.bands = preset.bands.map {$0.clone()}
    }
    
    var settingsAsPreset: FilterPreset {
        return FilterPreset("filterSettings", unit.state, unit.bands, false)
    }
    
    var persistentState: FilterUnitState {
        
        let filterState = FilterUnitState()
        
        filterState.state = unit.state
        filterState.bands = unit.bands
        filterState.userPresets = presets.userDefinedPresets
        
        return filterState
    }
}
