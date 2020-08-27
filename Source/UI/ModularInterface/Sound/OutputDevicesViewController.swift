import Cocoa

class OutputDevicesViewController: NSViewController, NotificationSubscriber {
    
    override var nibName: String? {return "OutputDevices"}
    
    @IBOutlet weak var btn0: OutputDeviceRadioButton!
    @IBOutlet weak var btn1: OutputDeviceRadioButton!
    @IBOutlet weak var btn2: OutputDeviceRadioButton!
    @IBOutlet weak var btn3: OutputDeviceRadioButton!
    @IBOutlet weak var btn4: OutputDeviceRadioButton!
    
    private lazy var graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private var btnArr: [OutputDeviceRadioButton] = []
    
    override func viewDidLoad() {
        
        btnArr = [btn0, btn1, btn2, btn3, btn4]
        btnArr.forEach {
            
            $0.image = $0.image?.applyingTint(Colors.Effects.bypassedUnitStateColor)
            $0.alternateImage = $0.alternateImage?.applyingTint(Colors.Effects.activeUnitStateColor)
        }
        
        let devices = graph.availableDevices
        
        for (index, device) in devices.allDevices.enumerated() {
            
            let btn = btnArr[index]
            
            btn.title = device.name
            btn.device = device
            
            btn.onIf(device.uid == devices.outputDevice.uid)
            btn.show()
        }
        
        for index in devices.deviceCount..<btnArr.count {
            btnArr[index].hide()
        }
    }
    
    @IBAction func deviceSelectorAction(_ sender: OutputDeviceRadioButton) {
        
        if let device = sender.device {

            btnArr.filter{$0 != sender}.forEach {$0.off()}
            graph.setOutputDevice(device)
        }
    }
}

class OutputDeviceRadioButton: NSButton {
    
    var device: AudioDevice?
}
