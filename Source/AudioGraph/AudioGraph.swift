import Cocoa
import AVFoundation

func renderCallback(inRefCon: UnsafeMutableRawPointer,
                    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                    inTimeStamp: UnsafePointer<AudioTimeStamp>,
                    inBusNumber: UInt32,
                    inNumberFrames: UInt32,
                    ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    
    let graph = unsafeBitCast(inRefCon, to: AudioGraph.self)
    
    if ioActionFlags.pointee == .unitRenderAction_PostRender, let bufferList = ioData?.pointee, let observer = graph.outputRenderObserver {
        
        DispatchQueue.global(qos: .userInteractive).async {
            observer.renderCallback(timeStamp: inTimeStamp.pointee, frameCount: inNumberFrames, audioBuffer: bufferList)
        }
    }
    
    return noErr
}

/*
    Wrapper around AVAudioEngine. Manages the AVAudioEngine audio graph.
 */
class AudioGraph: AudioGraphProtocol {
    
    var outputRenderObserver: AudioGraphOutputRenderObserverProtocol?
    
    func installOutputTap() {
        
        let au = engine.outputNode.audioUnit!
        AudioUnitAddRenderNotify(au, renderCallback, Unmanaged.passUnretained(self).toOpaque())
    }
    
    var availableDevices: AudioDeviceList {deviceManager.allDevices}
    
    var outputDevice: AudioDevice {
        
        get {deviceManager.outputDevice}
        set {deviceManager.outputDevice = newValue}
    }
    
    private let engine: AVAudioEngine
    internal let outputNode: AVAudioOutputNode
    internal let playerNode: AuralPlayerNode
    internal let nodeForRecorderTap: AVAudioNode
    private let auxMixer: AVAudioMixerNode  // Used for conversions of sample rates / channel counts
    
    private let deviceManager: DeviceManager
    
    // FX units
    var masterUnit: MasterUnit
    var eqUnit: EQUnit = EQUnit()
    var pitchUnit: PitchUnit = PitchUnit()
    var timeUnit: TimeUnit = TimeUnit()
    var reverbUnit: ReverbUnit = ReverbUnit()
    var delayUnit: DelayUnit = DelayUnit()
    var filterUnit: FilterUnit = FilterUnit()
    
    // Sound setting value holders
    private var playerVolume: Float
    
    // Sets up the audio engine
    init(_ state: AudioGraphState) {
        
        engine = AVAudioEngine()
        
        // If running on 10.12 Sierra or older, use the legacy AVAudioPlayerNode APIs
        if #available(OSX 10.13, *) {
            playerNode = AuralPlayerNode(useLegacyAPI: false)
        } else {
            playerNode = AuralPlayerNode(useLegacyAPI: true)
        }
        
        playerVolume = state.volume
        muted = state.muted
        playerNode.volume = muted ? 0 : playerVolume
        playerNode.pan = state.balance
        
        nodeForRecorderTap = engine.mainMixerNode
        self.outputNode = engine.outputNode
        auxMixer = AVAudioMixerNode()
        
        let slaveUnits = [eqUnit, pitchUnit, timeUnit, reverbUnit, delayUnit, filterUnit]
        masterUnit = MasterUnit(slaveUnits)

        deviceManager = DeviceManager(outputAudioUnit: engine.outputNode.audioUnit!,
                                      preferredDeviceUID: state.useSystemDevice ? nil : state.outputDevice.uid)
        
        let nodes = [playerNode, auxMixer] + slaveUnits.flatMap {$0.avNodes}
        nodes.forEach {engine.attach($0)}
        
        for index in 0..<nodes.lastIndex {
            engine.connect(nodes[index], to: nodes[index + 1], format: nil)
        }
        
        // Connect last node to main mixer
        engine.connect(nodes.last!, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        
        installOutputTap()
        
        startEngine()
        
        // Register self as an observer for notifications when the audio output device has changed (e.g. headphones)
        NotificationCenter.default.addObserver(self, selector: #selector(self.engineStopped(_:)), name: .AVAudioEngineConfigurationChange, object: engine)
    }
    
    // MARK: Audio engine-related functions
    
    func startEngine() {
        
        do {
            try engine.start()
        } catch let error as NSError {
            NSLog("Error starting audio engine: %@", error.description)
        }
    }
    
    @objc func engineStopped(_ notif: Notification) {
        
        startEngine()
        
        // Send out a notification
        Messenger.publish(.audioGraph_outputDeviceChanged)
    }
    
    var volume: Float {
        
        get {playerVolume}
        
        set {
            playerVolume = newValue
            if !muted {playerNode.volume = newValue}
        }
    }
    
    var balance: Float {
        
        get {return playerNode.pan}
        set(newValue) {playerNode.pan = newValue}
    }
    
    var muted: Bool {
        didSet {playerNode.volume = muted ? 0 : playerVolume}
    }

    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
        
        let currentFormat = playerNode.outputFormat(forBus: 0)
        
        // TODO: If newFormat == curFormat, don't reconnect.
        
//        print("\nCurFormat: \(currentFormat.channelLayout?.layoutTag) \(currentFormat.sampleRate)")
//        print("\nNewFormat: \(format.channelLayout?.layoutTag) \(format.sampleRate)")
        print(currentFormat.sampleRate == format.sampleRate, currentFormat == format, currentFormat.isEqual(to: format))
        
        if !currentFormat.isEqual(to: format) {
            
            engine.disconnectNodeOutput(playerNode)
            engine.connect(playerNode, to: auxMixer, format: format)
        }
    }
    
    // MARK: Miscellaneous functions
    
    func clearSoundTails() {
        
        // Clear sound tails from reverb and delay nodes, if they're active
        [delayUnit, reverbUnit].forEach({
            if $0.isActive {$0.reset()}
        })
    }
    
    func tearDown() {
        
        // Release the audio engine resources
        engine.stop()
    }
}

enum EffectsUnitState: String {
    
    // Master unit on, and effects unit on
    case active
    
    // Effects unit off
    case bypassed
    
    // Master unit off, and effects unit on
    case suppressed
}
