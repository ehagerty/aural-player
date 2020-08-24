import Cocoa

class TimeView: NSView {
    
    @IBOutlet weak var timeSlider: TimeStretchSlider!
    
    @IBOutlet weak var btnShiftPitch: NSButton!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    
    var rate: Float {
        return timeSlider.rate
    }
    
    var shiftPitch: Bool {
        return btnShiftPitch.isOn
    }
    
    func initialize(_ stateFunction: (() -> EffectsUnitState)?) {
        
        timeSlider.stateFunction = stateFunction
        timeSlider.updateState()
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        timeSlider.setUnitState(state)
    }
    
    func stateChanged() {
        timeSlider.updateState()
    }
    
    func setState(_ rate: Float, _ rateString: String, _ shiftPitch: Bool, _ shiftPitchString: String) {
        
        btnShiftPitch.onIf(shiftPitch)
        updatePitchShift(shiftPitchString)
        
        timeSlider.rate = rate
        lblTimeStretchRateValue.stringValue = rateString
    }
    
    // Updates the label that displays the pitch shift value
    func updatePitchShift(_ shiftPitchString: String) {
        lblPitchShiftValue.stringValue = shiftPitchString
    }
    
    // Sets the playback rate to a specific value
    func setRate(_ rate: Float, _ rateString: String, _ shiftPitchString: String) {
        
        lblTimeStretchRateValue.stringValue = rateString
        timeSlider.rate = rate
        updatePitchShift(shiftPitchString)
    }
    
    func applyPreset(_ preset: TimePreset) {
        
        setUnitState(preset.state)
        btnShiftPitch.onIf(preset.shiftPitch)
        
        // TODO: Move this calculation to a new util functions class/file
        let shiftPitch = (preset.shiftPitch ? 1200 * log2(preset.rate) : 0) * AppConstants.ValueConversions.pitch_audioGraphToUI
        lblPitchShiftValue.stringValue = ValueFormatter.formatPitch(shiftPitch)
        
        timeSlider.rate = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
    }
    
    func redrawSliders() {
        timeSlider.redraw()
    }
    
    func changeFunctionCaptionTextColor() {
        
        btnShiftPitch.image = btnShiftPitch.image?.applyingTint(Colors.Effects.functionCaptionTextColor)
        btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(Colors.Effects.functionCaptionTextColor)
        
        btnShiftPitch.redraw()
    }
}
