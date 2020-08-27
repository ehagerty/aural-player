import Cocoa
import AVFoundation

/*
    Encapsulates low-level logic required to interact with the system's audio output hardware
 
    Serves as a helper class to AudioGraph to get/set the current audio output device
 */
public class DeviceManager {
    
    static var hardwareDevicesPropertyAddress: AudioObjectPropertyAddress =
        AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioHardwarePropertyDevices)
    
    static var hardwareDefaultOutputDevicePropertyAddress: AudioObjectPropertyAddress =
        AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioHardwarePropertyDefaultOutputDevice)
    
    static let systemAudioObjectId: AudioObjectID = AudioObjectID(kAudioObjectSystemObject)
    
    // The AudioUnit underlying AVAudioEngine's output node (used to set the output device)
    let outputAudioUnit: AudioUnit
    
    init(_ outputAudioUnit: AudioUnit) {
        self.outputAudioUnit = outputAudioUnit
    }
    
    // A listing of all available audio output devices
    var allDevices: AudioDeviceList {
        
        var propSize: UInt32 = 0
        var result: OSStatus = AudioObjectGetPropertyDataSize(Self.systemAudioObjectId, &Self.hardwareDevicesPropertyAddress, sizeOfPropertyAddress, nil, &propSize)
        if result != 0 {return AudioDeviceList.unknown}
        
        let numDevices = Int(propSize / sizeOfDeviceId)
        var devids: [AudioDeviceID] = Array(repeating: AudioDeviceID(), count: numDevices)
        
        result = AudioObjectGetPropertyData(Self.systemAudioObjectId, &Self.hardwareDevicesPropertyAddress, 0, nil, &propSize, &devids)
        if result != 0 {return AudioDeviceList.unknown}
        
        let devices: [AudioDevice] = devids.compactMap {AudioDevice(deviceID: $0)}
        return AudioDeviceList(allDevices: devices, outputDeviceId: outputDeviceId, systemDeviceId: systemDeviceId)
    }
    
    // The AudioDeviceID of the audio output device currently being used by the OS
    private var systemDeviceId: AudioDeviceID {
        
        var curDeviceId: AudioDeviceID = kAudioObjectUnknown
        var size: UInt32 = 0
        
        AudioObjectGetPropertyDataSize(Self.systemAudioObjectId, &Self.hardwareDefaultOutputDevicePropertyAddress, 0, nil, &size)
        AudioObjectGetPropertyData(Self.systemAudioObjectId, &Self.hardwareDefaultOutputDevicePropertyAddress, 0, nil, &size, &curDeviceId)
        
        return curDeviceId
    }
    
    // The variable used to get/set the application's audio output device
    var outputDeviceId: AudioDeviceID {
        
        get {
            
            var outDeviceID: AudioDeviceID = 0
            var sizeOfDeviceId: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)
            let error = AudioUnitGetProperty(outputAudioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &outDeviceID, &sizeOfDeviceId)
            
            return error == 0 ? outDeviceID : systemDeviceId
        }
        
        set(newDeviceId) {
            
            var outDeviceID: AudioDeviceID = newDeviceId
            let error = AudioUnitSetProperty(outputAudioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &outDeviceID, sizeOfDeviceId)
            
            if error > 0
            {
                NSLog("Error setting audio output device to: ", newDeviceId, ", errorCode=", error)
            }
        }
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

func getCFStringProperty(deviceID: AudioDeviceID, addressPtr: UnsafePointer<AudioObjectPropertyAddress>) -> String? {
    
    var prop: CFString? = nil
    var sizeOfCFStringOptional: UInt32 = UInt32(MemoryLayout<CFString?>.size)
    
    let result: OSStatus = AudioObjectGetPropertyData(deviceID, addressPtr, 0, nil, &sizeOfCFStringOptional, &prop)
    return result == noErr ? prop as String? : nil
}

func getCodeProperty(deviceID: AudioDeviceID, addressPtr: UnsafePointer<AudioObjectPropertyAddress>) -> String? {
    
    var prop: UInt32 = 0
    var sizeOfUInt32: UInt32 = UInt32(MemoryLayout<UInt32>.size)
    
    let result: OSStatus = AudioObjectGetPropertyData(deviceID, addressPtr, 0, nil, &sizeOfUInt32, &prop)
    return result == noErr ? AudioUtils.codeToString(prop) : nil
}
