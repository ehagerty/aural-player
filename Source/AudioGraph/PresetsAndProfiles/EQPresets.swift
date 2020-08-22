import Foundation

class EQPresets: FXPresets<EQPreset> {
    
    override init() {
     
        super.init()
        addPresets(SystemDefinedEQPresets.presets)
    }
    
    static var defaultPreset: EQPreset = {return SystemDefinedEQPresets.presets.first(where: {$0.name == SystemDefinedEQPresetParams.flat.rawValue})!}()
}

class EQPreset: EffectsUnitPreset {
    
    let bands: [Float]
    let globalGain: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ bands: [Float], _ globalGain: Float, _ systemDefined: Bool) {
        
        self.bands = bands
        self.globalGain = globalGain
        super.init(name, state, systemDefined)
    }
}

fileprivate struct SystemDefinedEQPresets {
    
    static let presets: [EQPreset] = SystemDefinedEQPresetParams.allCases.map { EQPreset($0.rawValue, $0.state, $0.bands, $0.globalGain, true) }
}

/*
    An enumeration of Equalizer presets the user can choose from
 */
fileprivate enum SystemDefinedEQPresetParams: String, CaseIterable {
    
    case flat = "Flat" // default
    case highBassAndTreble = "High bass and treble"
    
    case dance = "Dance"
    case electronic = "Electronic"
    case hipHop = "Hip Hop"
    
    case acoustic = "Acoustic"
    case classical = "Classical"
    case jazz = "Jazz"
    case latin = "Latin"
    case lounge = "Lounge"
    case piano = "Piano"
    case pop = "Pop"
    case rAndB = "R&B"
    case rock = "Rock"
    
    case soft = "Soft"
    case karaoke = "Karaoke"
    case vocal = "Vocal"
    
    // Converts a user-friendly display name to an instance of EQPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedEQPresetParams {
        return SystemDefinedEQPresetParams(rawValue: displayName) ?? .flat
    }
    
    // Returns the frequency->gain mappings for each of the frequency bands, for this preset
    var bands: [Float] {
        
        switch self {
            
        case .flat: return EQPresetsBands.flatBands
        case .highBassAndTreble: return EQPresetsBands.highBassAndTrebleBands
            
        case .dance: return EQPresetsBands.danceBands
        case .electronic: return EQPresetsBands.electronicBands
        case .hipHop: return EQPresetsBands.hipHopBands
        case .pop: return EQPresetsBands.popBands
        case .rAndB: return EQPresetsBands.rAndBBands
        case .rock: return EQPresetsBands.rockBands
            
        case .acoustic: return EQPresetsBands.acousticBands
        case .classical: return EQPresetsBands.classicalBands
        case .jazz: return EQPresetsBands.jazzBands
        case .latin: return EQPresetsBands.latinBands
        case .lounge: return EQPresetsBands.loungeBands
        case .piano: return EQPresetsBands.pianoBands
            
        case .soft: return EQPresetsBands.softBands
        case .vocal: return EQPresetsBands.vocalBands
        case .karaoke: return EQPresetsBands.karaokeBands
            
        }
    }
    
    var globalGain: Float {
        return 0
    }
    
    var state: EffectsUnitState {
        return .active
    }
}

// Container for specific frequency->gain mappings for different EQ presets
fileprivate struct EQPresetsBands {
    
    static let flatBands: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    static let highBassAndTrebleBands: [Float] = [15.0, 13.75, 12.5, 10.0, 7.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 12.5, 13.75, 15.0]
    
    static let danceBands: [Float] = [0.0, 5.0, 10.0, 7.0, 4.0, 0.0, -1.0, -1.0, -2.0, -4.0, -2.0, 0.0, 4.0, 6.0, 8.0]
    
    static let electronicBands: [Float] = [9.0, 8.5, 7.0, 4.0, 1.0, 0.0, -5.0, -2.0, 4.0, 1.0, 2.0, 3.0, 5.0, 8.0, 9.0]
    
    static let hipHopBands: [Float] = [9.0, 8.5, 7.0, 3.0, 2.0, 5.0, -1.0, -3.0, -2.0, 2.0, 1.0, 0.0, 2.0, 4.0, 5.0]
    
    static let acousticBands: [Float] = [8.0, 7.75, 7.5, 6.25, 5.0, 2.0, 3.5, 3.25, 3.0, 5.0, 6.75, 7.5, 7.0, 5.0, 3.5]
    
    static let classicalBands: [Float] = [7.5, 7.0, 6.0, 5.5, 5.0, 4.0, -1.0, -3.0, -3.0, -1.0, 2.0, 4.0, 5.0, 6.0, 6.5]
    
    static let jazzBands: [Float] = [6.0, 6.0, 5.0, 2.0, 2.0, 4.0, -1.0, -3.0, -3.0, -1.0, 2.0, 3.0, 4.0, 5.25, 6.5]
    
    static let latinBands: [Float] = [7.5, 6.5, 5.0, 1.5, 0.0, 0.0, -2.0, -2.5, -2.5, -2.5, -1.5, 1.0, 3.5, 5.5, 7.5]
    
    static let loungeBands: [Float] = [-4.25, -3.75, -2.5, -0.5, 0.5, 2.5, 5.5, 6.5, 4.5, 2.5, -1, -2.5, 0.5, 3.0, 2.5]
    
    static let pianoBands: [Float] = [1.0, 1.0, -1.0, -3.0, -3.0, 0.0, 1.0, 1.0, -1.0, 2.0, 2.0, 3.0, 1.0, 1.0, 2.0]
    
    static let popBands: [Float] = [-2.0, -2.0, -1.5, 0.0, 0.0, 3.0, 7.0, 7.0, 7.0, 3.5, 3.5, 0.0, -2.0, -2.0, -3.0]
    
    static let rAndBBands: [Float] = [4.0, 5.0, 10.0, 8.0, 5.5, 2.5, -2.0, -2.5, -2.0, 1.0, 4.0, 5.0, 5.5, 6.0, 7.0]
    
    static let rockBands: [Float] = [8.5, 7.5, 6.5, 6.0, 4.0, 2.5, 0.5, -1.0, -2.0, 0.0, 3.0, 4.5, 6.0, 6.5, 7.0]
    
    static let softBands: [Float] = [0.0, 0.0, 1.0, 2.0, 2.0, 6.0, 8.0, 8.0, 10.0, 12.0, 12.0, 12.0, 13.0, 13.0, 14.0]
    
    static let karaokeBands: [Float] = [8.0, 8.0, 6.0, 4.0, 4.0, -20.0, -20.0, -20.0, -20.0, -20.0, -20.0, 4.0, 6.0, 6.0, 8.0]
    
    static let vocalBands: [Float] = [-20.0, -20.0, -20.0, -20.0, -20.0, 12.0, 14.0, 14.0, 14.0, 12.0, 12.0, -20.0, -20.0, -20.0, -20.0]
}
