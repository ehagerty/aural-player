import Cocoa

class SoundPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnSystemDeviceOnStartup: NSButton!
    @IBOutlet weak var btnRememberDeviceOnStartup: NSButton!
    @IBOutlet weak var btnPreferredDeviceOnStartup: NSButton!
    @IBOutlet weak var preferredDevicesMenu: NSPopUpButton!
    
    @IBOutlet weak var volumeDeltaField: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPanDelta: NSTextField!
    @IBOutlet weak var panDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblEQDelta: NSTextField!
    @IBOutlet weak var eqDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPitchDelta: NSTextField!
    @IBOutlet weak var pitchDeltaUnitsMenu: NSPopUpButton!
    @IBOutlet weak var pitchDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblTimeDelta: NSTextField!
    @IBOutlet weak var timeDeltaStepper: NSStepper!
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    
    override var nibName: String? {return "SoundPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let soundPrefs = preferences.soundPreferences
        
        switch soundPrefs.outputDeviceOnStartup.option {
            
        case .system:                       btnSystemDeviceOnStartup.on()
                                            break
            
        case .rememberFromLastAppLaunch:    btnRememberDeviceOnStartup.on()
                                            break
            
        case .specific:                     btnPreferredDeviceOnStartup.on()
                                            break
        }
        
        updatePreferredDevicesMenu(soundPrefs)
        preferredDevicesMenu.enableIf(btnPreferredDeviceOnStartup.isOn)
        
        // Volume increment / decrement
        
        let volumeDelta = Int(round(soundPrefs.volumeDelta * AppConstants.ValueConversions.volume_audioGraphToUI))
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        // Balance increment / decrement
        
        let panDelta = Int(round(soundPrefs.panDelta * AppConstants.ValueConversions.pan_audioGraphToUI))
        panDeltaStepper.integerValue = panDelta
        panDeltaAction(self)
        
        let eqDelta = soundPrefs.eqDelta
        eqDeltaStepper.floatValue = eqDelta
        eqDeltaAction(self)
        
        let pitchDelta = soundPrefs.pitchDelta
        pitchDeltaStepper.integerValue = pitchDelta
        pitchDeltaUnitsMenu.selectItem(withTitle: soundPrefs.pitchDeltaUnit.rawValue)
        
        pitchDeltaStepper.minValue = 1
        
        switch soundPrefs.pitchDeltaUnit {
            
        case .octaves:
            
            pitchDeltaStepper.maxValue = 2
            
        case .semitones:
            
            pitchDeltaStepper.maxValue = 24
            
        case .cents:
            
            pitchDeltaStepper.maxValue = 2400
        }
        
        pitchDeltaStepper.integerValue = soundPrefs.pitchDelta
        lblPitchDelta.stringValue = String(describing: pitchDeltaStepper.integerValue)
        
        let timeDelta = soundPrefs.timeDelta
        timeDeltaStepper.floatValue = timeDelta
        timeDeltaAction(self)
    }
    
    private func updatePreferredDevicesMenu(_ prefs: SoundPreferences) {
        
        preferredDevicesMenu.removeAllItems()
        
        let prefDeviceName: String = prefs.outputDeviceOnStartup.preferredDeviceName ?? ""
        let prefDeviceUID: String = prefs.outputDeviceOnStartup.preferredDeviceUID ?? ""
        
        var prefDevice: PreferredDevice?
        
        var selItem: NSMenuItem?
        
        for device in audioGraph.availableDevices.allDevices {

            preferredDevicesMenu.insertItem(withTitle: device.name, at: 0)
            
            let repObject = PreferredDevice(device.name, device.uid)
            preferredDevicesMenu.item(at: 0)!.representedObject = repObject
            
            // If this device matches the preferred device, make note of it
            if (device.uid == prefDeviceUID) {
                prefDevice = repObject
                selItem = preferredDevicesMenu.item(at: 0)!
            }
        }
        
        // If the preferred device is not any of the available devices, add it to the menu
        if prefDevice == nil && prefDeviceUID != "" {
            
            preferredDevicesMenu.insertItem(withTitle: prefDeviceName + " (unavailable)", at: 0)
            preferredDevicesMenu.item(at: 0)!.representedObject = PreferredDevice(prefDeviceName, prefDeviceUID)
            selItem = preferredDevicesMenu.item(at: 0)!
        }
        
        preferredDevicesMenu.select(selItem)
    }
    
    @IBAction func outputDeviceRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
        preferredDevicesMenu.enableIf(btnPreferredDeviceOnStartup.isOn)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }
    
    @IBAction func eqDeltaAction(_ sender: Any) {
        lblEQDelta.stringValue = String(format: "%.1lf dB", eqDeltaStepper.floatValue)
    }
    
    @IBAction func pitchDeltaUnitsAction(_ sender: Any) {
        
        if let selItem = pitchDeltaUnitsMenu.selectedItem?.title {
            
            pitchDeltaStepper.minValue = 1
            
            let unit = PitchDeltaUnit(rawValue: selItem) ?? .cents
            
            switch unit {
                
            case .octaves:
                
                pitchDeltaStepper.maxValue = 2
                
            case .semitones:
                
                pitchDeltaStepper.maxValue = 24
                
            case .cents:
                
                pitchDeltaStepper.maxValue = 2400
            }
            
            pitchDeltaStepper.integerValue = 1
        }
        
        lblPitchDelta.stringValue = String(describing: pitchDeltaStepper.integerValue)
    }
    
    @IBAction func pitchDeltaAction(_ sender: Any) {
        lblPitchDelta.stringValue = String(describing: pitchDeltaStepper.integerValue)
    }
    
    @IBAction func timeDeltaAction(_ sender: Any) {
        lblTimeDelta.stringValue = String(format: "%.2lfx", timeDeltaStepper.floatValue)
    }
    
    func save(_ preferences: Preferences) throws {
        
        let soundPrefs = preferences.soundPreferences
        
        if btnSystemDeviceOnStartup.isOn {
            soundPrefs.outputDeviceOnStartup.option = .system
            
        } else if btnRememberDeviceOnStartup.isOn {
            soundPrefs.outputDeviceOnStartup.option = .rememberFromLastAppLaunch
            
        } else {
            soundPrefs.outputDeviceOnStartup.option = .specific
        }
        
        if let prefDevice: PreferredDevice = preferredDevicesMenu.selectedItem?.representedObject as? PreferredDevice {
            
            soundPrefs.outputDeviceOnStartup.preferredDeviceName = prefDevice.name
            soundPrefs.outputDeviceOnStartup.preferredDeviceUID = prefDevice.uid
        }
        
        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * AppConstants.ValueConversions.volume_UIToAudioGraph
        soundPrefs.panDelta = panDeltaStepper.floatValue * AppConstants.ValueConversions.pan_UIToAudioGraph
        
        soundPrefs.eqDelta = eqDeltaStepper.floatValue
        
        soundPrefs.pitchDelta = pitchDeltaStepper.integerValue
        soundPrefs.pitchDeltaUnit = .cents
        
        if let selItem = pitchDeltaUnitsMenu.selectedItem?.title, let selUnit = PitchDeltaUnit(rawValue: selItem) {
            soundPrefs.pitchDeltaUnit = selUnit
        }
        
        soundPrefs.timeDelta = timeDeltaStepper.floatValue
    }
}

// Encapsulates a user-preferred audio output device
public class PreferredDevice {
    
    var name: String
    var uid: String
    
    init(_ name: String, _ uid: String) {
        self.name = name
        self.uid = uid
    }
}
