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
        
        switch timeSlider.unitState {
            
        case .active:
            
            if btnShiftPitch.isOn {
                
                btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(ColorSchemes.systemScheme.effects.activeUnitStateColor)
                btnShiftPitch.redraw()
            }
            
        case .bypassed:
            
            btnShiftPitch.image = btnShiftPitch.image?.applyingTint(ColorSchemes.systemScheme.effects.bypassedUnitStateColor)
            btnShiftPitch.redraw()
            
        case .suppressed:
            
            if btnShiftPitch.isOn {
                
                btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(ColorSchemes.systemScheme.effects.suppressedUnitStateColor)
                btnShiftPitch.redraw()
            }
        }
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
    
    func applyColorScheme(_ scheme: ColorScheme) {
        stateChanged()
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        redrawSliders()
        
        if btnShiftPitch.isOn {
            btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(color)
            
        } else {
            btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(ColorSchemes.systemScheme.effects.bypassedUnitStateColor)
        }
        
        btnShiftPitch.redraw()
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        redrawSliders()
        
        btnShiftPitch.image = btnShiftPitch.image?.applyingTint(color)
        btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(color)
        
        btnShiftPitch.redraw()
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        redrawSliders()
        
        if btnShiftPitch.isOn {
            btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(color)
            
        } else {
            btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.applyingTint(ColorSchemes.systemScheme.effects.bypassedUnitStateColor)
        }
        
        btnShiftPitch.redraw()
    }
}
