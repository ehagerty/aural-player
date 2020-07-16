import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchViewController: FXUnitViewController {
    
    @IBOutlet weak var pitchView: PitchView!
    
    @IBOutlet weak var octavesSlider: TickedCircularSlider!
    @IBOutlet weak var semitonesSlider: TickedCircularSlider!
    @IBOutlet weak var centsSlider: TickedCircularSlider!
    
    @IBOutlet weak var overlapSlider: CircularSlider!
    @IBOutlet weak var lblOverlapV: NSTextField!
    
    @IBOutlet weak var lblOctaves: NSTextField!
    @IBOutlet weak var lblSemitones: NSTextField!
    @IBOutlet weak var lblCents: NSTextField!
    
    @IBOutlet weak var lblPitchCents: NSTextField!
    
    @IBOutlet weak var lblPitch: VALabel!
    @IBOutlet weak var lblPitchMin: VALabel!
    @IBOutlet weak var lblPitchMax: VALabel!
    @IBOutlet weak var lblPitchValue: VALabel!
    
    @IBOutlet weak var lblOverlap: VALabel!
    @IBOutlet weak var lblOverlapMin: VALabel!
    @IBOutlet weak var lblOverlapMax: VALabel!
    @IBOutlet weak var lblPitchOverlapValue: VALabel!
    
    override var nibName: String? {return "Pitch"}
    
    private var pitchUnit: PitchUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.pitchUnit
 
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // TODO: Could some of this move to AudioGraphDelegate ??? e.g. graph.getUnit(self.unitType) OR graph.getStateFunction(self.unitTyp
        unitType = .pitch
        fxUnit = pitchUnit
        presetsWrapper = PresetsWrapper<PitchPreset, PitchPresets>(pitchUnit.presets)
        
        octavesSlider.integerValue = 0
        semitonesSlider.integerValue = 0
        centsSlider.integerValue = 0
        
        octavesSlider.enable()
        semitonesSlider.enable()
        centsSlider.enable()
        
        lblOctaves.stringValue = String(octavesSlider.integerValue)
        lblSemitones.stringValue = String(semitonesSlider.integerValue)
        lblCents.stringValue = String(centsSlider.integerValue)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribe(self, .pitchFXUnit_decreasePitch, self.decreasePitch)
        Messenger.subscribe(self, .pitchFXUnit_increasePitch, self.increasePitch)
        Messenger.subscribe(self, .pitchFXUnit_setPitch, self.setPitch(_:))
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        
        // TODO: Move this to a generic view
        pitchView.initialize(self.unitStateFunction)
        
//        functionLabels = [lblPitch, lblOverlap, lblPitchMin, lblPitchMax, lblPitchValue, lblOverlapMin, lblOverlapMax, lblPitchOverlapValue]
    }
    
    override func initControls() {
        
        super.initControls()
        pitchView.setState(Float(pitchUnit.pitch), pitchUnit.formattedPitch, pitchUnit.overlap, pitchUnit.formattedOverlap)
        
        [lblOctaves, lblSemitones, lblCents].forEach {$0?.textColor = Colors.Effects.activeUnitStateColor}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        pitchView.stateChanged()
    }
    
    // Updates the pitch
    @IBAction func pitchOctavesAction(_ sender: AnyObject) {
        
        [lblOctaves, lblSemitones, lblCents].forEach {$0?.textColor = Colors.Effects.activeUnitStateColor}
        
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
        
        lblOctaves.stringValue = String(octavesSlider.integerValue)
        lblSemitones.stringValue = String(semitonesSlider.integerValue)
        lblCents.stringValue = String(centsSlider.integerValue)
        
        pitchUnit.pitch = computePitch()
        lblPitchCents.stringValue = pitchUnit.formattedPitch
    }
    
    @IBAction func pitchSemitonesAction(_ sender: AnyObject) {
            
//        pitchUnit.pitch = pitchView.pitch
//        pitchView.setPitch(pitchUnit.pitch, pitchUnit.formattedPitch)
        
        let octaves = octavesSlider.integerValue
        let semitones = semitonesSlider.integerValue
        let cents = centsSlider.integerValue
        
        switch octaves {
            
        case -2:
            
            if semitones == 0 {
                
                centsSlider.allowedValues = 0...100
                if cents < 0 {
                    centsSlider.setValue(0)
                }
            }
            
        case -1:
            
            if semitones == -12 {
                
                centsSlider.allowedValues = 0...100
                if cents < 0 {
                    centsSlider.setValue(0)
                }
                
            } else {
                
                centsSlider.allowedValues = -100...100
            }
            
        case 1:
            
            if semitones == 12 {
                
                centsSlider.allowedValues = -100...0
                if cents > 0 {
                    centsSlider.setValue(0)
                }
                
            } else {
                
                centsSlider.allowedValues = -100...100
            }

        case 2:
            
            if semitones == 0 {
                
                centsSlider.allowedValues = -100...0
                if cents > 0 {
                    centsSlider.setValue(0)
                }
            }

        default:
            
            semitonesSlider.allowedValues = -12...12
            centsSlider.allowedValues = -100...100
        }
        
        lblSemitones.stringValue = String(semitonesSlider.integerValue)
        lblCents.stringValue = String(centsSlider.integerValue)
        
        pitchUnit.pitch = computePitch()
        lblPitchCents.stringValue = pitchUnit.formattedPitch
    }
    
    @IBAction func pitchCentsAction(_ sender: AnyObject) {
            
//        pitchUnit.pitch = pitchView.pitch
//        pitchView.setPitch(pitchUnit.pitch, pitchUnit.formattedPitch)
        
        lblCents.stringValue = String(centsSlider.integerValue)
        
        pitchUnit.pitch = computePitch()
        lblPitchCents.stringValue = pitchUnit.formattedPitch
    }
    
    private func computePitch() -> Int {
        return (octavesSlider.integerValue * 1200) + (semitonesSlider.integerValue * 100) + centsSlider.integerValue
    }
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        pitchUnit.pitch = roundedInt(pitch)
        pitchUnit.ensureActive()
        
        pitchView.setPitch(pitch, pitchUnit.formattedPitch)
        
        pitchView.stateChanged()
        
        Messenger.publish(.fx_unitStateChanged)
        
        // Show the Pitch tab
        showThisTab()
    }
    
    // Updates the Overlap parameter of the Pitch shift effects unit
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {

        pitchUnit.overlap = pitchView.overlap
        pitchView.setPitchOverlap(pitchUnit.overlap, pitchUnit.formattedOverlap)
        
        lblOverlapV.stringValue = String(format: "%.2f", overlapSlider.floatValue)
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        
        let newPitch = pitchUnit.increasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        
        let newPitch = pitchUnit.decreasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitch: Float, _ pitchString: String) {
        
        Messenger.publish(.fx_unitStateChanged)
        
        pitchView.setPitch(pitch, pitchString)
        pitchView.stateChanged()
        
        // Show the Pitch tab if the Effects panel is shown
        showThisTab()
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        changeSliderColors()
    }
    
    override func changeSliderColors() {
        pitchView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if pitchUnit.isActive {
            pitchView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if pitchUnit.state == .bypassed {
            pitchView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if pitchUnit.state == .suppressed {
            pitchView.redrawSliders()
        }
    }
}
