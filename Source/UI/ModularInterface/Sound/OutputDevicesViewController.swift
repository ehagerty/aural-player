import Cocoa

class OutputDevicesViewController: NSViewController, NotificationSubscriber {
    
    override var nibName: String? {return "OutputDevices"}
    
    @IBOutlet weak var lblCaption: VALabel!
    
    @IBOutlet weak var btn0: OutputDeviceRadioButton!
    @IBOutlet weak var btn1: OutputDeviceRadioButton!
    @IBOutlet weak var btn2: OutputDeviceRadioButton!
    @IBOutlet weak var btn3: OutputDeviceRadioButton!
    @IBOutlet weak var btn4: OutputDeviceRadioButton!
    
    private let baseImage: NSImage = Images.imgRadioButton
    private var offStateImage: NSImage = Images.imgRadioButton
    private var onStateImage: NSImage = Images.imgRadioButton
    
    private lazy var graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private var btnArr: [OutputDeviceRadioButton] = []
    
    override func viewDidLoad() {
        
        btnArr = [btn0, btn1, btn2, btn3, btn4]
        
        changeTextSize(EffectsViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        Messenger.subscribeAsync(self, .audioGraph_outputDeviceChanged, self.updateDevicesList, queue: .main)
        
        Messenger.subscribe(self, .fx_changeTextSize, self.changeTextSize(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        
        Messenger.subscribe(self, .changeMainCaptionTextColor, self.changeMainCaptionTextColor(_:))
        
        Messenger.subscribe(self, .fx_changeFunctionCaptionTextColor, self.changeFunctionCaptionTextColor(_:))
        Messenger.subscribe(self, .fx_changeFunctionValueTextColor, self.changeFunctionValueTextColor(_:))
        
        Messenger.subscribe(self, .fx_changeActiveUnitStateColor, self.changeActiveUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeBypassedUnitStateColor, self.changeBypassedUnitStateColor(_:))
    }
    
    override func viewDidAppear() {
        updateDevicesList()
    }
    
    private func updateDevicesList() {
        
        let devices = graph.availableDevices
        
        for (index, device) in devices.allDevices.enumerated() {
            
            let btn = btnArr[index]
            
            btn.title = device.name
            btn.device = device
            
            btn.onIf(device.uid == devices.outputDevice.uid)
            btn.show()
        }
        
        for index in devices.deviceCount..<btnArr.count {
            
            btnArr[index].off()
            btnArr[index].hide()
        }
    }
    
    @IBAction func deviceSelectorAction(_ sender: OutputDeviceRadioButton) {
        
        if let device = sender.device {

            sender.on()
            btnArr.filter{$0 != sender}.forEach {$0.off()}
            graph.setOutputDevice(device)
        }
    }
    
    private func changeTextSize(_ textSize: TextSize) {
        
        lblCaption.font = Fonts.Effects.unitCaptionFont
        btnArr.forEach {$0.redraw()}
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        lblCaption.textColor = scheme.general.mainCaptionTextColor
        
        offStateImage = baseImage.applyingTint(Colors.Effects.bypassedUnitStateColor)
        onStateImage = baseImage.applyingTint(Colors.Effects.activeUnitStateColor)
        
        btnArr.forEach {
            
            $0.image = offStateImage
            $0.alternateImage = onStateImage
        }
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        btnArr.filter{$0.isOff}.forEach {$0.redraw()}
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        btnArr.filter{$0.isOn}.forEach {$0.redraw()}
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        onStateImage = baseImage.applyingTint(Colors.Effects.activeUnitStateColor)
        
        btnArr.forEach {
            $0.alternateImage = onStateImage
        }
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        offStateImage = baseImage.applyingTint(Colors.Effects.bypassedUnitStateColor)
        
        btnArr.forEach {
            $0.image = offStateImage
        }
    }
}

class OutputDeviceRadioButton: NSButton {
    
    var device: AudioDevice?
}
