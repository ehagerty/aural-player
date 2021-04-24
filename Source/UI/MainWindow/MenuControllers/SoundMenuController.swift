import Cocoa

/*
    Provides actions for the Sound menu that alter the sound output.
 
    NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
 */
class SoundMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var devicesMenu: NSMenu!
    
    // Menu items that are not always accessible
    @IBOutlet weak var panLeftMenuItem: NSMenuItem!
    @IBOutlet weak var panRightMenuItem: NSMenuItem!
    
    @IBOutlet weak var masterBypassMenuItem: ToggleMenuItem!
    
    @IBOutlet weak var eqMenu: NSMenuItem!
    @IBOutlet weak var pitchMenu: NSMenuItem!
    @IBOutlet weak var timeMenu: NSMenuItem!
    
    // Menu items that hold specific associated values
    
    // Pitch shift menu items (with specific pitch shift values)
    @IBOutlet weak var twoOctavesBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var oneOctaveBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var halfOctaveBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var thirdOctaveBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var sixthOctaveBelowMenuItem: SoundParameterMenuItem!
    
    @IBOutlet weak var sixthOctaveAboveMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var thirdOctaveAboveMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var halfOctaveAboveMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var oneOctaveAboveMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var twoOctavesAboveMenuItem: SoundParameterMenuItem!
    
    // Playback rate (Time) menu items (with specific playback rate values)
    @IBOutlet weak var rate0_25MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate0_5MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate0_75MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate1_25MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate1_5MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate2MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate3MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate4MenuItem: SoundParameterMenuItem!
    
    @IBOutlet weak var rememberSettingsMenuItem: ToggleMenuItem!
    
    // Delegate that alters the audio graph
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let preferences: SoundPreferences = ObjectGraph.preferences.soundPreferences
    
    private lazy var presetsEditor: EditorWindowController = EditorWindowController.instance
    
    // One-time setup.
    override func awakeFromNib() {
        
        // Associate each of the menu items with a specific pitch shift or playback rate value, so that when the item is clicked later, that value can be readily retrieved and used in performing the action.
        
        // Pitch shift menu items
        twoOctavesBelowMenuItem.paramValue = -2
        oneOctaveBelowMenuItem.paramValue = -1
        halfOctaveBelowMenuItem.paramValue = -0.5
        thirdOctaveBelowMenuItem.paramValue = -1/3
        sixthOctaveBelowMenuItem.paramValue = -1/6
        
        sixthOctaveAboveMenuItem.paramValue = 1/6
        thirdOctaveAboveMenuItem.paramValue = 1/3
        halfOctaveAboveMenuItem.paramValue = 0.5
        oneOctaveAboveMenuItem.paramValue = 1
        twoOctavesAboveMenuItem.paramValue = 2
        
        // Playback rate (Time) menu items
        rate0_25MenuItem.paramValue = 0.25
        rate0_5MenuItem.paramValue = 0.5
        rate0_75MenuItem.paramValue = 0.75
        rate1_25MenuItem.paramValue = 1.25
        rate1_5MenuItem.paramValue = 1.5
        rate2MenuItem.paramValue = 2
        rate3MenuItem.paramValue = 3
        rate4MenuItem.paramValue = 4
    }
    
    // When the menu is about to open, update the menu item states
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        [panLeftMenuItem, panRightMenuItem].forEach({$0?.enableIf(!WindowManager.instance.isShowingModalComponent)})
        rememberSettingsMenuItem.enableIf(player.currentTrack != nil)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // Audio output devices menu
        if (menu == devicesMenu) {
            
            // Recreate the menu each time
            
            devicesMenu.removeAllItems()
            
            let outputDeviceName: String = graph.outputDevice.name
            
            // Add menu items for each available device
            for device in graph.availableDevices.allDevices {
                
                let menuItem = NSMenuItem(title: device.name, action: #selector(self.outputDeviceAction(_:)), keyEquivalent: "")
                menuItem.representedObject = device
                menuItem.target = self
                
                self.devicesMenu.insertItem(menuItem, at: 0)
            
                // Select this item if it represents the current output device
                menuItem.onIf(outputDeviceName == menuItem.title)
            }
            
        } else {
            
            masterBypassMenuItem.onIf(!graph.masterUnit.isActive)
            rememberSettingsMenuItem.showIf_elseHide(preferences.rememberEffectsSettingsOption == .individualTracks)
            
            if let playingTrack = player.currentTrack {
                rememberSettingsMenuItem.onIf(soundProfiles.hasFor(playingTrack))
            }
        }
    }
    
    @IBAction func outputDeviceAction(_ sender: NSMenuItem) {
        
        if let outputDevice = sender.representedObject as? AudioDevice {
            graph.outputDevice = outputDevice
        }
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        Messenger.publish(.player_muteOrUnmute)
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        Messenger.publish(.player_decreaseVolume, payload: UserInputMode.discrete)
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        Messenger.publish(.player_increaseVolume, payload: UserInputMode.discrete)
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    @IBAction func panLeftAction(_ sender: Any) {
        Messenger.publish(.player_panLeft)
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    @IBAction func panRightAction(_ sender: Any) {
        Messenger.publish(.player_panRight)
    }
    
    // Whether or not the Effects window is loaded (and is able to receive commands).
    var effectsWindowLoaded: Bool {WindowManager.instance.effectsWindowLoaded}
    
    // Toggles the master bypass switch
    @IBAction func masterBypassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.masterFXUnit_toggleEffects)
        } else {
            _ = graph.masterUnit.toggleState()
        }
    }
    
    @IBAction func managePresetsAction(_ sender: Any) {
        presetsEditor.showEffectsPresetsEditor()
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    @IBAction func decreaseBassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.eqFXUnit_decreaseBass)
        } else {
            _ = graph.eqUnit.decreaseBass()
        }
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    @IBAction func increaseBassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.eqFXUnit_increaseBass)
        } else {
            _ = graph.eqUnit.increaseBass()
        }
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    @IBAction func decreaseMidsAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.eqFXUnit_decreaseMids)
        } else {
            _ = graph.eqUnit.decreaseMids()
        }
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    @IBAction func increaseMidsAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.eqFXUnit_increaseMids)
        } else {
            _ = graph.eqUnit.increaseMids()
        }
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    @IBAction func decreaseTrebleAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.eqFXUnit_decreaseTreble)
        } else {
            _ = graph.eqUnit.decreaseTreble()
        }
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    @IBAction func increaseTrebleAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.eqFXUnit_increaseTreble)
        } else {
            _ = graph.eqUnit.increaseTreble()
        }
    }
    
    // Decreases the pitch by a certain preset decrement
    @IBAction func decreasePitchAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.pitchFXUnit_decreasePitch)
        } else {
            _ = graph.pitchUnit.decreasePitch()
        }
    }
    
    // Increases the pitch by a certain preset increment
    @IBAction func increasePitchAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.pitchFXUnit_increasePitch)
        } else {
            _ = graph.pitchUnit.increasePitch()
        }
    }
    
    // Sets the pitch to a value specified by the menu item clicked
    @IBAction func setPitchAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the pitch shift value associated with the menu item (in octaves)
        let pitch = sender.paramValue
        
        if effectsWindowLoaded {
            Messenger.publish(.pitchFXUnit_setPitch, payload: pitch)
            
        } else {
            
            graph.pitchUnit.pitch = pitch
            graph.pitchUnit.ensureActive()
        }
    }
    
    // Decreases the playback rate by a certain preset decrement
    @IBAction func decreaseRateAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.timeFXUnit_decreaseRate)
        } else {
            _ = graph.timeUnit.decreaseRate()
        }
    }
    
    // Increases the playback rate by a certain preset increment
    @IBAction func increaseRateAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            Messenger.publish(.timeFXUnit_increaseRate)
        } else {
            _ = graph.timeUnit.increaseRate()
        }
    }
    
    // Sets the playback rate to a value specified by the menu item clicked
    @IBAction func setRateAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the playback rate value associated with the menu item
        let rate = sender.paramValue
        
        if effectsWindowLoaded {
            Messenger.publish(.timeFXUnit_setRate, payload: rate)
            
        } else {
            
            graph.timeUnit.rate = rate
            graph.timeUnit.ensureActive()
        }
    }
    
    @IBAction func rememberSettingsAction(_ sender: ToggleMenuItem) {
        Messenger.publish(!rememberSettingsMenuItem.isOn ? .fx_saveSoundProfile : .fx_deleteSoundProfile)
    }
}

// An NSMenuItem subclass that contains extra fields to hold information (similar to tags) associated with the menu item
class SoundParameterMenuItem: NSMenuItem {
    
    // A generic numerical parameter value
    var paramValue: Float = 0
}
