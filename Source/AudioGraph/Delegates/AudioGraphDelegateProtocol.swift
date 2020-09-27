/*
    Contract for a middleman/delegate that relays all requests to alter the audio graph, i.e. to tune the sound output - volume, panning, equalizer (EQ), sound effects, etc
 */
import Cocoa
import AVFoundation

protocol AudioGraphDelegateProtocol {
    
    var availableDevices: AudioDeviceList {get}
    var outputDevice: AudioDevice {get set}
    var outputDeviceBufferSize: Int {get set}
    var outputDeviceSampleRate: Double {get}
    
    // NOTE - All functions that return String values return user-friendly text representations of the value being get/set, for display in the UI. For instance, setDelayLowPassCutoff(64) might return a value like "64 Hz"
    var volume: Float {get set}
    
    var formattedVolume: String {get}
    
    /*
     Increases the player volume by a small increment. Returns the new player volume.
     
     The "inputMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The input mode will affect the amount by which the volume is increased.
     */
    func increaseVolume(_ inputMode: UserInputMode) -> Float
    
    /*
     Decreases the player volume by a small decrement. Returns the new player volume.
     
     The "inputMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The input mode will affect the amount by which the volume is decreased.
     */
    func decreaseVolume(_ inputMode: UserInputMode) -> Float
    
    var muted: Bool {get set}
    
    var balance: Float {get set}
    
    var formattedBalance: String {get}
    
    // Pans left by a small increment. Returns new balance value.
    func panLeft() -> Float
    
    // Pans right by a small increment. Returns new balance value.
    func panRight() -> Float
    
//    var settingsAsMasterPreset: MasterPreset {get}
    
    var masterUnit: MasterUnitDelegateProtocol {get}
    var eqUnit: EQUnitDelegateProtocol {get set}
    var pitchUnit: PitchUnitDelegateProtocol {get set}
    var timeUnit: TimeUnitDelegateProtocol {get set}
    var reverbUnit: ReverbUnitDelegateProtocol {get set}
    var delayUnit: DelayUnitDelegateProtocol {get set}
    var filterUnit: FilterUnitDelegateProtocol {get set}
    
    var soundProfiles: SoundProfiles {get}
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
}

protocol FXUnitDelegateProtocol {
    
    var state: EffectsUnitState {get}
    
    var unitType: EffectsUnit {get}
    
    var unitDescription: String {get}
    
    var stateFunction: EffectsUnitStateFunction {get}
    
    // Toggles the state of the pitch shift audio effects unit, and returns its new state
    func toggleState() -> EffectsUnitState
    
    var isActive: Bool {get}
    
    func ensureActive()
    
    func savePreset(_ presetName: String)
    
    func applyPreset(_ presetName: String)
}

protocol MasterUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    var presets: MasterPresets {get}
    
    func applyPreset(_ preset: MasterPreset)
}

protocol EQUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    var globalGain: Float {get set}
    
    var bands: [Float] {get set}
    
    // Sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    func setBand(_ index: Int, gain: Float)
    
    // Increases the equalizer bass band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func increaseBass() -> [Float]
    
    // Decreases the equalizer bass band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func decreaseBass() -> [Float]
    
    // Increases the equalizer mid-frequency band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func increaseMids() -> [Float]
    
    // Decreases the equalizer mid-frequency band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func decreaseMids() -> [Float]
    
    // Increases the equalizer treble band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func increaseTreble() -> [Float]
    
    // Decreases the equalizer treble band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func decreaseTreble() -> [Float]
    
    var presets: EQPresets {get}
}

protocol PitchUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    // The pitch shift value, in cents, specified as a value between -2400 and 2400
    var pitch: PitchShift {get set}
    
    // Increases the pitch shift by a small increment. Returns the new pitch shift value.
    func increasePitch() -> PitchShift
    
    // Decreases the pitch shift by a small decrement. Returns the new pitch shift value.
    func decreasePitch() -> PitchShift
    
    var presets: PitchPresets {get}
}

struct PitchShift {
    
    let octaves: Int
    let semitones: Int
    let cents: Int
    
    var asCents: Int {
        
        octaves * AppConstants.ValueConversions.pitch_octaveToCents +
        semitones * AppConstants.ValueConversions.pitch_semitoneToCents
        + cents
    }
    
    init(octaves: Int, semitones: Int, cents: Int) {
        
        self.octaves = octaves
        self.semitones = semitones
        self.cents = cents
    }
    
    init(fromCents pitchCents: Int) {
        
        var cents = pitchCents
        
        self.octaves = cents / AppConstants.ValueConversions.pitch_octaveToCents
        cents -= octaves * AppConstants.ValueConversions.pitch_octaveToCents
        
        self.semitones = cents / AppConstants.ValueConversions.pitch_semitoneToCents
        cents -= semitones * AppConstants.ValueConversions.pitch_semitoneToCents
        
        self.cents = cents
    }
}

protocol TimeUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    var rate: Float {get set}
    
    var effectiveRate: Float {get}
    
    var formattedRate: String {get}
    
    var shiftPitch: Bool {get set}
    
    var pitch: Float {get}
    
    var formattedPitch: String {get}
    
    // Increases the playback rate by a small increment. Returns the new playback rate value.
    func increaseRate() -> (rate: Float, rateString: String)
    
    // Decreases the playback rate by a small decrement. Returns the new playback rate value.
    func decreaseRate() -> (rate: Float, rateString: String)
    
    var presets: TimePresets {get}
}

protocol ReverbUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    var space: ReverbSpaces {get set}
    
    var amount: Float {get set}
    
    var formattedAmount: String {get}
    
    var presets: ReverbPresets {get}
}

protocol DelayUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    var amount: Float {get set}
    
    var formattedAmount: String {get}
    
    var time: Double {get set}
    
    var formattedTime: String {get}
    
    var feedback: Float {get set}
    
    var formattedFeedback: String {get}
    
    var lowPassCutoff: Float {get set}
    
    var formattedLowPassCutoff: String {get}
    
    var presets: DelayPresets {get}
}

protocol FilterUnitDelegateProtocol: FXUnitDelegateProtocol {

    var bands: [FilterBand] {get set}
    
    func addBand(_ band: FilterBand) -> Int
    
    func updateBand(_ index: Int, _ band: FilterBand)
    
    func removeBands(_ indexSet: IndexSet)
    
    func removeAllBands()
    
    func getBand(_ index: Int) -> FilterBand
    
    var presets: FilterPresets {get}
}
