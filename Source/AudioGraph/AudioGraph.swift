import Cocoa
import AVFoundation

/*
    Wrapper around AVAudioEngine. Manages the AVAudioEngine audio graph.
 */
class AudioGraph: AudioGraphProtocol, PersistentModelObject {
    
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
    var eqUnit: EQUnit
    var pitchUnit: PitchUnit
    var timeUnit: TimeUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit
    
    // Sound setting value holders
    private var playerVolume: Float
    
    var soundProfiles: SoundProfiles
    
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
        
        eqUnit = EQUnit(state)
        pitchUnit = PitchUnit(state)
        timeUnit = TimeUnit(state)
        reverbUnit = ReverbUnit(state)
        delayUnit = DelayUnit(state)
        filterUnit = FilterUnit(state)
        
        let slaveUnits = [eqUnit, pitchUnit, timeUnit, reverbUnit, delayUnit, filterUnit]
        masterUnit = MasterUnit(state, slaveUnits)

        deviceManager = DeviceManager(outputAudioUnit: engine.outputNode.audioUnit!,
                                      preferredDeviceUID: state.useSystemDevice ? nil : state.outputDevice.uid)
        
        soundProfiles = SoundProfiles()
        state.soundProfiles.forEach({
            soundProfiles.add($0.file, $0)
        })
        
        soundProfiles.audioGraph = self
        
        let nodes = [playerNode, auxMixer] + slaveUnits.flatMap {$0.avNodes}
        nodes.forEach {engine.attach($0)}
        
        for index in 0..<nodes.lastIndex {
            engine.connect(nodes[index], to: nodes[index + 1], format: nil)
        }
        
        // Connect last node to main mixer
        engine.connect(nodes.last!, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        
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
    
    var settingsAsMasterPreset: MasterPreset {
        return masterUnit.settingsAsPreset
    }

    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
        
        let cur = playerNode.outputFormat(forBus: 0)
        
        // TODO: If newFormat == curFormat, don't reconnect.
        
        print("\nCurFormat: \(cur.channelLayout?.layoutTag) \(cur.sampleRate)")
        print("\nNewFormat: \(format.channelLayout?.layoutTag) \(format.sampleRate)")
        print(cur.sampleRate == format.sampleRate, cur == format, cur.isEqual(to: format))
        
        if !cur.isEqual(to: format) {
            
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
    
    var persistentState: PersistentState {
        
        let state: AudioGraphState = AudioGraphState()
        
        let outputDevice = deviceManager.outputDevice
        
        state.outputDevice.name = outputDevice.name
        state.outputDevice.uid = outputDevice.uid
        
        // TODO: This whole func moves to Delegate, this value is obtained from preferences.
        state.useSystemDevice = true
        
        // Volume and pan (balance)
        state.volume = playerVolume
        state.muted = muted
        state.balance = playerNode.pan
        
        state.masterUnit = masterUnit.persistentState
        state.eqUnit = eqUnit.persistentState
        state.pitchUnit = pitchUnit.persistentState
        state.timeUnit = timeUnit.persistentState
        state.reverbUnit = reverbUnit.persistentState
        state.delayUnit = delayUnit.persistentState
        state.filterUnit = filterUnit.persistentState
        
        state.soundProfiles.append(contentsOf: soundProfiles.all())
        
        return state
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
