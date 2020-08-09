import Cocoa

class PitchView: NSView {
    
    @IBOutlet weak var octavesSlider: TickedCircularSlider!
    @IBOutlet weak var semitonesSlider: TickedCircularSlider!
    @IBOutlet weak var centsSlider: TickedCircularSlider!
    @IBOutlet weak var overlapSlider: CircularSlider!
    
    @IBOutlet weak var lblPitch: VALabel!
    @IBOutlet weak var lblPitchMin: VALabel!
    @IBOutlet weak var lblPitchMax: VALabel!
    @IBOutlet weak var lblPitchValue: VALabel!
    @IBOutlet weak var lblOctaves: NSTextField!
    @IBOutlet weak var lblSemitones: NSTextField!
    @IBOutlet weak var lblCents: NSTextField!
    
    @IBOutlet weak var lblOverlap: VALabel!
    @IBOutlet weak var lblOverlapMin: VALabel!
    @IBOutlet weak var lblOverlapMax: VALabel!
    @IBOutlet weak var lblOverlapValue: NSTextField!
    
    private var sliders: [EffectsUnitSliderProtocol] = []
    
    var pitch: Int {
        
        applyCorrection()
        
        return (octavesSlider.integerValue * AppConstants.ValueConversions.pitch_octaveToCents) +
            (semitonesSlider.integerValue * AppConstants.ValueConversions.pitch_semitoneToCents) +
            centsSlider.integerValue
    }
    
    private func applyCorrection() {
        
        let octaves = octavesSlider.integerValue
        let semitones = semitonesSlider.integerValue
        let cents = centsSlider.integerValue
        
        switch octaves {
            
        case -2:
            
            // Semitones can only be non-negative
            semitonesSlider.allowedValues = 0...12
            if semitones < 0 {
                semitonesSlider.setValue(0)
            }
            
            if semitonesSlider.integerValue == 0 {
                
                centsSlider.allowedValues = 0...100
                if cents < 0 {
                    centsSlider.setValue(0)
                }
            }
            
        case -1:
            
            semitonesSlider.allowedValues = -12...12
            
            if semitones == -12 {
                
                centsSlider.allowedValues = 0...100
                if cents < 0 {
                    centsSlider.setValue(0)
                }
                
            } else {
                
                centsSlider.allowedValues = -100...100
            }
            
        case 1:
            
            semitonesSlider.allowedValues = -12...12
            
            if semitones == 12 {
                
                centsSlider.allowedValues = -100...0
                if cents > 0 {
                    centsSlider.setValue(0)
                }
                
            } else {
                
                centsSlider.allowedValues = -100...100
            }

        case 2:
            
            semitonesSlider.allowedValues = -12...0
            if semitones > 0 {
                semitonesSlider.setValue(0)
            }
            
            if semitonesSlider.integerValue == 0 {
                
                centsSlider.allowedValues = -100...0
                if cents > 0 {
                    centsSlider.setValue(0)
                }
            }

        default:
            
            semitonesSlider.allowedValues = -12...12
            centsSlider.allowedValues = -100...100
        }
    }
    
    var overlap: Float {overlapSlider.floatValue}
    
    override func awakeFromNib() {
        sliders = [octavesSlider, semitonesSlider, centsSlider, overlapSlider]
    }
    
    func initialize(_ stateFunction: @escaping () -> EffectsUnitState) {
        
        for var slider in sliders {
            slider.stateFunction = stateFunction
            slider.updateState()
        }
    }
    
    func setState(_ pitch: (octaves: Int, semitones: Int, cents: Int), _ pitchString: String, _ overlap: Float, _ overlapString: String) {
        
        setPitch(pitch.octaves, pitch.semitones, pitch.cents, pitchString)
        setPitchOverlap(overlap, overlapString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        for var slider in sliders {
            slider.unitState = state
        }
    }
    
    func setPitch(_ octaves: Int, _ semitones: Int, _ cents: Int, _ pitchString: String) {
        
        octavesSlider.setValue(Float(octaves))
        lblOctaves.stringValue = String(octavesSlider.integerValue)
        
        semitonesSlider.setValue(Float(semitones))
        lblSemitones.stringValue = String(semitonesSlider.integerValue)
        
        centsSlider.setValue(Float(cents))
        lblCents.stringValue = String(centsSlider.integerValue)
        
        lblPitchValue.stringValue = pitchString
    }
    
    func setPitchOverlap(_ overlap: Float, _ overlapString: String) {
        
        overlapSlider.setValue(overlap)
        lblOverlapValue.stringValue = overlapString
        
//        pitchOverlapSlider.floatValue = overlap
//        lblPitchOverlapValue.stringValue = overlapString
    }
    
    func pitchUpdated(formattedString: String) {
        
        lblOctaves.stringValue = String(octavesSlider.integerValue)
        lblSemitones.stringValue = String(semitonesSlider.integerValue)
        lblCents.stringValue = String(centsSlider.integerValue)
        
        lblPitchValue.stringValue = formattedString
    }
    
    func stateChanged() {
        sliders.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: PitchPreset) {
        
//        let pitch = preset.pitch * AppConstants.ValueConversions.pitch_audioGraphToUI
//        setPitch(pitch, ValueFormatter.formatPitch(pitch))
//        setPitchOverlap(preset.overlap, ValueFormatter.formatOverlap(preset.overlap))
//        setUnitState(preset.state)
    }
    
    func redrawSliders() {
//        [pitchSlider, pitchOverlapSlider].forEach({$0?.redraw()})
    }
}
