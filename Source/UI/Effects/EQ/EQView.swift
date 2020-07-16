import Cocoa

class EQView: NSView {
    
    @IBOutlet weak var globalGainSlider: EffectsUnitSlider!
    
    var bandSliders: [EffectsUnitSlider] = []
    var allSliders: [EffectsUnitSlider] = []
    
    override func awakeFromNib() {
        
        let sliders = self.subviews.compactMap({$0 as? EffectsUnitSlider})
        
        bandSliders = sliders.filter {$0.tag >= 0}
        allSliders.append(contentsOf: sliders)
    }
    
    func initialize(_ stateFunction: @escaping EffectsUnitStateFunction, _ sliderAction: Selector?, _ sliderActionTarget: AnyObject?) {
        
        allSliders.forEach {$0.stateFunction = stateFunction}
        
        for slider in bandSliders {
            
            slider.action = sliderAction
            slider.target = sliderActionTarget
        }
    }
    
    func stateChanged() {
        allSliders.forEach {$0.updateState()}
    }
    
    func changeSliderColor() {
        allSliders.forEach {$0.redraw()}
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        allSliders.forEach {$0.redraw()}
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        allSliders.forEach {$0.redraw()}
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        allSliders.forEach {$0.redraw()}
    }
    
    func setState(_ state: EffectsUnitState) {
        allSliders.forEach {$0.setUnitState(state)}
    }
    
    func updateBands(_ bands: [Float], _ globalGain: Float) {
        
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        bandSliders.forEach {$0.floatValue = bands[$0.tag]}
        globalGainSlider.floatValue = globalGain
    }
    
    // bands argument is a map of Frequency -> Gain
    func updateBands(_ bands: [Float: Float], _ globalGain: Float) {
        
        let sortedBands: [Float] = bands.sorted(by: {r1, r2 -> Bool in r1.key < r2.key}).map {$0.value}
        updateBands(sortedBands, globalGain)
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        setState(preset.state)
        updateBands(preset.bands, preset.globalGain)
    }
}
