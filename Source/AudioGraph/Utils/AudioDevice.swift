import Cocoa
import AVFoundation

public class AudioDeviceList {
    
    static let unknown: AudioDeviceList = AudioDeviceList(allDevices: [], outputDeviceId: kAudioObjectUnknown, systemDeviceId: kAudioObjectUnknown)
    
    let allDevices: [AudioDevice]
    var deviceCount: Int {allDevices.count}
    
    let systemDevice: AudioDevice!
    let outputDevice: AudioDevice!
    
    init(allDevices: [AudioDevice], outputDeviceId: AudioDeviceID, systemDeviceId: AudioDeviceID) {
        
        self.allDevices = allDevices
        
        let systemDevice = allDevices.first(where: {$0.id == systemDeviceId})
        self.systemDevice = systemDevice
        
        self.outputDevice = allDevices.first(where: {$0.id == outputDeviceId}) ?? systemDevice
    }
}

/*
    Encapsulates a single audio hardware device
 */
public class AudioDevice {
    
    static var deviceUIDPropertyAddress: AudioObjectPropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyDeviceUID)
    
    static var modelUIDPropertyAddress: AudioObjectPropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyModelUID)
    
    static var namePropertyAddress: AudioObjectPropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyDeviceNameCFString)
    
    static var manufacturerPropertyAddress: AudioObjectPropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyDeviceManufacturerCFString)
    
    static var streamConfigPropertyAddress: AudioObjectPropertyAddress = AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioDevicePropertyStreamConfiguration)
    
    static var dataSourcePropertyAddress: AudioObjectPropertyAddress = AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioDevicePropertyDataSource)
    
    static var transportTypePropertyAddress: AudioObjectPropertyAddress = AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioDevicePropertyTransportType)
    
    // The unique device ID relative to other devices currently available. Used to set the output device (is NOT persistent).
    let id: AudioDeviceID
    
    // Persistent unique identifer of this device (not user-friendly)
    let uid: String?
    
    let modelUID: String?
    
    // User-friendly (and persistent) display name string for this device
    let name: String
    
    // User-friendly (and persistent) manufacturer name string for this device
    let manufacturer: String?
    
    // Whether or not this device is capable of output
    let hasOutput: Bool
    let channelCount: Int
    
    let dataSource: String?
    let transportType: String?
    let isConnectedViaBluetooth: Bool
    
    init?(deviceID: AudioDeviceID) {
        
        guard let name = getCFStringProperty(deviceID: deviceID, addressPtr: &Self.namePropertyAddress),
            !name.contains("CADefaultDeviceAggregate") else {return nil}
        
        let channelCount: Int = {
            
            var sizeOfCFStringOptional: UInt32 = UInt32(MemoryLayout<CFString?>.size)
            var result: OSStatus = AudioObjectGetPropertyDataSize(deviceID, &Self.streamConfigPropertyAddress, 0, nil, &sizeOfCFStringOptional)
            if result != 0 {return 0}
            
            let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(sizeOfCFStringOptional))
            result = AudioObjectGetPropertyData(deviceID, &Self.streamConfigPropertyAddress, 0, nil, &sizeOfCFStringOptional, bufferList)
            if result != 0 {return 0}
            
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            
            return Int((0..<buffers.count).map{buffers[$0]}.reduce(0, {(channelCountSoFar: UInt32, buffer: AudioBuffer) -> UInt32 in channelCountSoFar + buffer.mNumberChannels}))
        }()
        
        // We are only interested in output devices
        if channelCount <= 0 {return nil}
        
        self.id = deviceID
        self.uid = getCFStringProperty(deviceID: deviceID, addressPtr: &Self.deviceUIDPropertyAddress)
        self.modelUID = getCFStringProperty(deviceID: deviceID, addressPtr: &Self.modelUIDPropertyAddress)
        
        self.name = name
        self.manufacturer = getCFStringProperty(deviceID: deviceID, addressPtr: &Self.manufacturerPropertyAddress)
        
        self.channelCount = channelCount
        self.hasOutput = channelCount > 0
        
        self.dataSource = getCodeProperty(deviceID: deviceID, addressPtr: &Self.dataSourcePropertyAddress)
        self.transportType = getCodeProperty(deviceID: deviceID, addressPtr: &Self.transportTypePropertyAddress)
        self.isConnectedViaBluetooth = transportType?.lowercased() == "blue"
    }
}
