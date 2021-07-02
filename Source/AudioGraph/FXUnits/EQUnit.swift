//
//  EQUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An Equalizer effects unit that controls the volume of sound in
/// different frequency bands. So, it can emphasize or suppress bass (low frequencies),
/// vocals (mid frequencies), or treble (high frequencies).
///
/// - SeeAlso: `EQUnitProtocol`
///
class EQUnit: EffectsUnit, EQUnitProtocol {
    
    private let node: ParametricEQ
    let presets: EQPresets
    
    init(persistentState: EQUnitPersistentState?) {
        
        node = ParametricEQ(type: persistentState?.type ?? AudioGraphDefaults.eqType)
        presets = EQPresets(persistentState: persistentState)
        super.init(.eq, persistentState?.state ?? AudioGraphDefaults.eqState)

        // TODO: Validate persistent bands array ... if not 10 or 15 values, fix it.
        bands = persistentState?.bands ?? AudioGraphDefaults.eqBands
        globalGain = persistentState?.globalGain ?? AudioGraphDefaults.eqGlobalGain
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    var type: EQType {
        
        get {return node.type}
        set(newType) {node.chooseType(newType)}
    }
    
    var globalGain: Float {
        
        get {return node.globalGain}
        set {node.globalGain = newValue}
    }
    
    var bands: [Float] {
        
        get {node.bands}
        set(newBands) {node.bands = newBands}
    }
    
    override var avNodes: [AVAudioNode] {
        return node.allNodes
    }
    
    /// Gets / sets the gain for the band at the given index.
    subscript(_ index: Int) -> Float {
        
        get {node[index]}
        set {node[index] = newValue}
    }
    
    func increaseBass(_ increment: Float) -> [Float] {
        return node.increaseBass(increment)
    }
    
    func decreaseBass(_ decrement: Float) -> [Float] {
        return node.decreaseBass(decrement)
    }
    
    func increaseMids(_ increment: Float) -> [Float] {
        return node.increaseMids(increment)
    }
    
    func decreaseMids(_ decrement: Float) -> [Float] {
        return node.decreaseMids(decrement)
    }
    
    func increaseTreble(_ increment: Float) -> [Float] {
        return node.increaseTreble(increment)
    }
    
    func decreaseTreble(_ decrement: Float) -> [Float] {
        return node.decreaseTreble(decrement)
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(EQPreset(presetName, .active, bands, globalGain, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        bands = preset.bands
        globalGain = preset.globalGain
    }
    
    var settingsAsPreset: EQPreset {
        return EQPreset("eqSettings", state, bands, globalGain, false)
    }
    
    var persistentState: EQUnitPersistentState {

        let unitState = EQUnitPersistentState()

        unitState.state = state
        unitState.type = type
        unitState.bands = bands
        unitState.globalGain = globalGain
        unitState.userPresets = presets.userDefinedPresets.map {EQPresetPersistentState(preset: $0)}

        return unitState
    }
}
