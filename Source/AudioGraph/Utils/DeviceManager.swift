import Cocoa
import AVFoundation

/*
    Encapsulates low-level logic required to interact with the system's audio output hardware
 
    Serves as a helper class to AudioGraph to get/set the current audio output device
 */
public class DeviceManager {
    
    static var hardwareDefaultOutputDevicePropertyAddress: AudioObjectPropertyAddress =
        AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioHardwarePropertyDefaultOutputDevice)
    
    static let systemAudioObjectId: AudioObjectID = AudioObjectID(kAudioObjectSystemObject)
    
    // The AudioUnit underlying AVAudioEngine's output node (used to set the output device)
    let outputAudioUnit: AudioUnit
    
    let list: DeviceList
    
    var preferredOutputDevice: AudioDevice?
    
    private var lastEventTime: Double = 0
    
    init(_ outputAudioUnit: AudioUnit) {
        
        self.outputAudioUnit = outputAudioUnit
        self.list = DeviceList()
        
        DeviceManager.outputDeviceChangeHandler = self.outputDeviceChanged
        
        AudioUnitAddPropertyListener(outputAudioUnit, kAudioOutputUnitProperty_CurrentDevice, {_, _, _, _, _ in
            DeviceManager.outputDeviceChangedProxy()
        }, nil)
    }
    
    static var outputDeviceChangeHandler: () -> Void = {}
    
    static func outputDeviceChangedProxy() {
        outputDeviceChangeHandler()
    }
    
    func outputDeviceChanged() {
        
        let now = CFAbsoluteTimeGetCurrent()
        let timeDiff = now - self.lastEventTime
        self.lastEventTime = now
        
        if timeDiff > 0.1 {
            
            let newDeviceId = outputDeviceId
            
            // If the system tries to change the device when the user has selected a preferred device, revert back
            // to the user's chosen device.
            if let thePreferredDevice = preferredOutputDevice, thePreferredDevice.id != newDeviceId {
                
                // Check to make sure the preferred device is still available
                if list.isDeviceAvailable(thePreferredDevice) {
                    
                    NSLog("\nReverting back to: \(thePreferredDevice.name)")
                    outputDeviceId = thePreferredDevice.id
                    
                } else {
                    
                    preferredOutputDevice = outputDevice
                    NSLog("\nDevice \(thePreferredDevice.name) is no longer available. Keeping new device \(preferredOutputDevice!.name)")
                }
            }
            
        } else {
            NSLog("OutputDeviceChange - Time difference of \(timeDiff) too little. Ignoring notification.\n")
        }
    }
    
    // A listing of all available audio output devices
    var allDevices: AudioDeviceList {
        return AudioDeviceList(allDevices: list.devices, outputDeviceId: outputDeviceId, systemDeviceId: systemDeviceId)
    }
    
    var systemDevice: AudioDevice {
        list.deviceById(systemDeviceId) ?? AudioDevice(deviceId: systemDeviceId)!
    }
    
    // The AudioDeviceID of the audio output device currently being used by the OS
    private var systemDeviceId: AudioDeviceID {
        
        var curDeviceId: AudioDeviceID = kAudioObjectUnknown
        var size: UInt32 = 0
        
        AudioObjectGetPropertyDataSize(Self.systemAudioObjectId, &Self.hardwareDefaultOutputDevicePropertyAddress, 0, nil, &size)
        AudioObjectGetPropertyData(Self.systemAudioObjectId, &Self.hardwareDefaultOutputDevicePropertyAddress, 0, nil, &size, &curDeviceId)
        
        return curDeviceId
    }
    
    var outputDevice: AudioDevice {
        
        get {list.deviceById(outputDeviceId) ?? AudioDevice(deviceId: outputDeviceId) ?? systemDevice}
        set {outputDeviceId = newValue.id}
    }
    
    // The variable used to get/set the application's audio output device
    private var outputDeviceId: AudioDeviceID {
        
        get {
            
            var outDeviceID: AudioDeviceID = 0
            var size: UInt32 = sizeOfDeviceId
            let error = AudioUnitGetProperty(outputAudioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &outDeviceID, &size)
            
            return error == 0 ? outDeviceID : systemDeviceId
        }
        
        set(newDeviceId) {
            
            if outputDeviceId == newDeviceId {return}
            
            var outDeviceID: AudioDeviceID = newDeviceId
            let error = AudioUnitSetProperty(outputAudioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &outDeviceID, sizeOfDeviceId)
            
            if error > 0
            {
                NSLog("Error setting audio output device to: ", newDeviceId, ", errorCode=", error)
            }
        }
    }
    
    func useSystemDevice() {
        outputDeviceId = systemDeviceId
    }
}

extension AudioObjectPropertyAddress {
    
    init(globalPropertyWithSelector selector: AudioObjectPropertySelector) {
        self.init(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
    }
    
    init(outputPropertyWithSelector selector: AudioObjectPropertySelector) {
        self.init(mSelector: selector, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMaster)
    }
}

let sizeOfPropertyAddress: UInt32 = UInt32(MemoryLayout<AudioObjectPropertyAddress>.size)
let sizeOfDeviceId: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)
let sizeOfCFStringOptional: UInt32 = UInt32(MemoryLayout<CFString?>.size)
let sizeOfUInt32: UInt32 = UInt32(MemoryLayout<UInt32>.size)

extension Notification.Name {
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the application (i.e. app delegate). They represent different lifecycle stages/events.
    
    // Signifies that the application has finished launching
    static let deviceManager_deviceListUpdated = Notification.Name("deviceManager_deviceListUpdated")
}
