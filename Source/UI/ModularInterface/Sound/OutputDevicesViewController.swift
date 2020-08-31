import Cocoa

class OutputDevicesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NotificationSubscriber {
    
    override var nibName: String? {return "OutputDevices"}
    
    @IBOutlet weak var lblCaption: VALabel!
    
    @IBOutlet weak var btnSystemDevice: NSButton!
    @IBOutlet weak var lblSystemDevice: VALabel!
    
    @IBOutlet weak var devicesView: NSTableView!
    
    private let baseImage: NSImage = Images.imgRadioButton
    private var offStateImage: NSImage = Images.imgRadioButton
    private var onStateImage: NSImage = Images.imgRadioButton
    
    private lazy var graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private var deviceList: AudioDeviceList!
    
    override func viewDidLoad() {
        
        changeTextSize(EffectsViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        Messenger.subscribeAsync(self, .deviceManager_deviceListUpdated, self.updateDevicesList, queue: .main)
        Messenger.subscribeAsync(self, .audioGraph_engineRestarted, self.updateDevicesList, queue: .main)
        
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
        
        deviceList = graph.availableDevices
        
        btnSystemDevice.onIf(graph.useSystemDevice)
        lblSystemDevice.textColor = btnSystemDevice.isOn ? Colors.Effects.functionValueTextColor : Colors.Effects.functionCaptionTextColor
        
        devicesView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {deviceList?.deviceCount ?? 0}
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let deviceList = self.deviceList, let colId = tableColumn?.identifier, row < deviceList.allDevices.count else {return nil}
        
        let device = deviceList.allDevices[row]
        let isSelected = deviceList.outputDevice.uid == device.uid
        
        switch colId {
            
        case .devices_selector:
            
            return createSelectorCell(tableView, row, isSelected)
            
        case .devices_name:
            
            return createNameCell(tableView, device.name, isSelected)
            
        default:
            
            return nil
        }
    }
    
    private func createSelectorCell(_ tableView: NSTableView, _ row: Int, _ selected: Bool) -> NSTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: .devices_selector, owner: nil) as? DeviceSelectorTableCellView {
            
            cell.selector.action = #selector(self.deviceSelectorAction(_:))
            cell.selector.target = self
            
            cell.selector.image = offStateImage
            cell.selector.alternateImage = onStateImage
            
            cell.selector.tag = row
            
            selected ? cell.selector.on() : cell.selector.off()
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ tableView: NSTableView, _ text: String, _ selected: Bool) -> NSTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: .devices_name, owner: nil) as? DeviceNameTableCellView {
            
            cell.text = text
            cell.textFont = Fonts.Effects.unitFunctionFont
            cell.textColor = selected ? Colors.Effects.functionValueTextColor : Colors.Effects.functionCaptionTextColor
            
            return cell
        }
        
        return nil
    }
    
    // Row selection
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {false}
    
    @IBAction func systemDeviceSelectorAction(_ sender: NSButton) {
        
        graph.useSystemDevice = sender.isOn
        
        if sender.isOn {
            updateDevicesList()
        }
        
        lblSystemDevice.textColor = btnSystemDevice.isOn ? Colors.Effects.functionValueTextColor : Colors.Effects.functionCaptionTextColor
    }
    
    @IBAction func deviceSelectorAction(_ sender: NSButton) {
        
        let device = deviceList.allDevices[sender.tag]
        graph.setOutputDevice(device)
        
        updateDevicesList()
    }
    
    private func changeTextSize(_ textSize: TextSize) {
        
        lblCaption.font = Fonts.Effects.unitCaptionFont
        lblSystemDevice.font = Fonts.Effects.unitFunctionFont
        
        devicesView.reloadData(forRowIndexes: IndexSet(0..<devicesView.numberOfRows), columnIndexes: [1])
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        lblSystemDevice.textColor = btnSystemDevice.isOn ? Colors.Effects.functionValueTextColor : Colors.Effects.functionCaptionTextColor
        
        btnSystemDevice.image = btnSystemDevice.image?.applyingTint(Colors.Effects.bypassedUnitStateColor)
        btnSystemDevice.alternateImage = btnSystemDevice.alternateImage?.applyingTint(Colors.Effects.activeUnitStateColor)
        
        offStateImage = baseImage.applyingTint(Colors.Effects.bypassedUnitStateColor)
        onStateImage = baseImage.applyingTint(Colors.Effects.activeUnitStateColor)
        
        devicesView.reloadData()
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        
        devicesView.backgroundColor = color
        devicesView.enclosingScrollView?.backgroundColor = color
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        if btnSystemDevice.isOff {
            lblSystemDevice.textColor = Colors.Effects.functionCaptionTextColor
        }
        
        var indicesOfNonOutputDevices = Array(deviceList.allDevices.indices)
        if let deviceIndex = deviceList.allDevices.firstIndex(where: {$0.uid == deviceList.outputDevice.uid}) {
            
            indicesOfNonOutputDevices.remove(at: deviceIndex)
            devicesView.reloadData(forRowIndexes: IndexSet(indicesOfNonOutputDevices), columnIndexes: [1])
        }
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        
        if btnSystemDevice.isOn {
            lblSystemDevice.textColor = Colors.Effects.functionValueTextColor
        }
        
        if let deviceIndex = deviceList.allDevices.firstIndex(where: {$0.uid == deviceList.outputDevice.uid}) {
            devicesView.reloadData(forRowIndexes: IndexSet([deviceIndex]), columnIndexes: [1])
        }
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        btnSystemDevice.alternateImage = btnSystemDevice.alternateImage?.applyingTint(Colors.Effects.activeUnitStateColor)
        onStateImage = baseImage.applyingTint(Colors.Effects.activeUnitStateColor)
        
        if let deviceIndex = deviceList.allDevices.firstIndex(where: {$0.uid == deviceList.outputDevice.uid}) {
            devicesView.reloadData(forRowIndexes: IndexSet([deviceIndex]), columnIndexes: [0])
        }
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        btnSystemDevice.image = btnSystemDevice.image?.applyingTint(Colors.Effects.bypassedUnitStateColor)
        offStateImage = baseImage.applyingTint(Colors.Effects.bypassedUnitStateColor)
        
        var indicesOfNonOutputDevices = Array(deviceList.allDevices.indices)
        if let deviceIndex = deviceList.allDevices.firstIndex(where: {$0.uid == deviceList.outputDevice.uid}) {
            
            indicesOfNonOutputDevices.remove(at: deviceIndex)
            devicesView.reloadData(forRowIndexes: IndexSet(indicesOfNonOutputDevices), columnIndexes: [0])
        }
    }
}

@IBDesignable
class DeviceSelectorTableCellView: NSTableCellView {
    
    @IBOutlet weak var selector: NSButton!
}

@IBDesignable
class DeviceNameTableCellView: NSTableCellView {
    
    var text: String = "" {
        didSet {textField?.stringValue = text}
    }
    
    var textFont: NSFont = Fonts.Effects.unitFunctionFont {
        didSet {textField?.font = textFont}
    }
    
    var textColor: NSColor = Colors.Effects.functionValueTextColor {
        didSet {textField?.textColor = textColor}
    }
}
