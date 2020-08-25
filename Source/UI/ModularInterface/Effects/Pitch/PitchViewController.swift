import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchViewController: FXUnitViewController {
    
    @IBOutlet weak var pitchView: PitchView!
    @IBOutlet weak var box: NSBox!
    
    @IBOutlet weak var lblPitch: VALabel!
    @IBOutlet weak var lblPitchMin: VALabel!
    @IBOutlet weak var lblPitchMax: VALabel!
    
    override var nibName: String? {return "Pitch"}
    
    private var pitchUnit: PitchUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.pitchUnit
 
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // TODO: Could some of this move to AudioGraphDelegate ??? e.g. graph.getUnit(self.unitType) OR graph.getStateFunction(self.unitTyp
        unitType = .pitch
        fxUnit = pitchUnit
        presetsWrapper = PresetsWrapper<PitchPreset, PitchPresets>(pitchUnit.presets)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribe(self, .pitchFXUnit_decreasePitch, self.decreasePitch)
        Messenger.subscribe(self, .pitchFXUnit_increasePitch, self.increasePitch)
        Messenger.subscribe(self, .pitchFXUnit_setPitch, self.setPitch(_:))
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        pitchView.initialize(self.unitStateFunction)
    }
    
    override func initControls() {
        
        super.initControls()
        pitchView.pitch = pitchUnit.pitch
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        pitchView.stateChanged()
    }
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        
        pitchUnit.pitch = pitchView.pitch
        pitchView.pitchUpdated()
    }
    
    func setPitch(_ pitch: PitchShift) {
        
        pitchUnit.ensureActive()
        
        pitchUnit.pitch = pitch
        pitchView.pitch = pitch
        
        Messenger.publish(.fx_unitStateChanged)
        showThisTab()
    }
    
    func decreasePitch() {
        
        pitchView.pitch = pitchUnit.decreasePitch()

        Messenger.publish(.fx_unitStateChanged)
        showThisTab()
    }
    
    func increasePitch() {
        
        pitchView.pitch = pitchUnit.increasePitch()

        Messenger.publish(.fx_unitStateChanged)
        showThisTab()
    }
    
    // MARK: Appearance --------------------------------------------------------------------------------
    
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
