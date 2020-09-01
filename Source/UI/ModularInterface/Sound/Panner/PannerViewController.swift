import Cocoa

class PannerViewController: AuralViewController {
    
    override var nibName: String? {return "Panner"}
    
    @IBOutlet weak var lblCaption: VALabel!
    
    @IBOutlet weak var lblPanLeft: VALabel!
    @IBOutlet weak var lblPanRight: VALabel!
    
    @IBOutlet weak var panSlider: NSSlider!
    @IBOutlet weak var lblPanValue: VALabel!
    
    private var functionLabels: [NSTextField] = []
    
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    private let soundPreferences: SoundPreferences = ObjectGraph.preferences.soundPreferences
    
    override func viewDidLoad() {
        
        functionLabels = [lblPanLeft, lblPanRight, lblPanValue]
        super.viewDidLoad()
    }
    
    override func initializeUI() {
        
        panUpdated()
        
        changeTextSize(EffectsViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
    }
    
    private func panUpdated() {
        
        let balance = audioGraph.balance
        
        panSlider.floatValue = balance
        lblPanValue.stringValue = ValueFormatter.formatPan(balance)
    }
    
    override func initializeSubscriptions() {
        
        Messenger.subscribe(self, .player_panLeft, self.panLeft)
        Messenger.subscribe(self, .player_panRight, self.panRight)
        
        Messenger.subscribe(self, .fx_changeTextSize, self.changeTextSize(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        
        Messenger.subscribe(self, .changeMainCaptionTextColor, self.changeMainCaptionColor(_:))
        
        Messenger.subscribe(self, .fx_changeFunctionCaptionTextColor, self.changeFunctionCaptionColor(_:))
        Messenger.subscribe(self, .fx_changeFunctionValueTextColor, self.changeFunctionValueColor(_:))
        
        Messenger.subscribe(self, .fx_changeSliderColors, self.changeSliderColors)
        Messenger.subscribe(self, .fx_changeActiveUnitStateColor, {(color: NSColor) in self.changeSliderColors()})
    }
    
    // Updates the stereo pan
    @IBAction func panAction(_ sender: AnyObject) {
        
        let balance = panSlider.floatValue
        
        audioGraph.balance = balance
        lblPanValue.stringValue = ValueFormatter.formatPan(balance)
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    private func panLeft() {
        
        let balance = audioGraph.panLeft()
        
        lblPanValue.stringValue = ValueFormatter.formatPan(balance)
        panSlider.floatValue = balance
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    private func panRight() {
        
        let balance = audioGraph.panRight()
        
        lblPanValue.stringValue = ValueFormatter.formatPan(balance)
        panSlider.floatValue = balance
    }
    
    private func changeTextSize(_ size: TextSize) {
        
        lblCaption.font = Fonts.Effects.unitCaptionFont
        functionLabels.forEach {$0.font = Fonts.Effects.unitFunctionFont}
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeMainCaptionColor(scheme.general.mainCaptionTextColor)
        changeFunctionCaptionColor(scheme.effects.functionCaptionTextColor)
        changeFunctionValueColor(scheme.effects.functionValueTextColor)
        changeSliderColors()
    }
    
    private func changeMainCaptionColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    private func changeFunctionCaptionColor(_ color: NSColor) {
        
        lblPanLeft.textColor = color
        lblPanRight.textColor = color
    }
    
    private func changeFunctionValueColor(_ color: NSColor) {
        lblPanValue.textColor = color
    }
    
    private func changeSliderColors() {
        panSlider.redraw()
    }
    
    private func trackChanged(_ newTrack: Track?) {
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if soundPreferences.rememberEffectsSettings, let theNewTrack = newTrack, soundProfiles.hasFor(theNewTrack) {
            panUpdated()
        }
    }
}
