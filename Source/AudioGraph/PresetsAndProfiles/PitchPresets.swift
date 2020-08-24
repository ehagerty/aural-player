import Foundation

class PitchPresets: FXPresets<PitchPreset> {
    
    override init() {
        
        super.init()
        addPresets(SystemDefinedPitchPresets.presets)
    }
    
    static var defaultPreset: PitchPreset = {SystemDefinedPitchPresets.presets.first(where: {$0.name == SystemDefinedPitchPresetParams.normal.rawValue})!}()
}

class PitchPreset: EffectsUnitPreset {
    
    let pitch: PitchShift
    
    init(_ name: String, _ state: EffectsUnitState, _ pitch: PitchShift, _ systemDefined: Bool) {
        
        self.pitch = pitch
        super.init(name, state, systemDefined)
    }
}

fileprivate struct SystemDefinedPitchPresets {
    
    static let presets: [PitchPreset] = SystemDefinedPitchPresetParams.allValues.map {
        PitchPreset($0.rawValue, $0.state, $0.pitch, true)
    }
}

/*
    An enumeration of built-in pitch presets the user can choose from
 */
fileprivate enum SystemDefinedPitchPresetParams: String {
    
    case normal = "Normal"  // default
    case happyLittleGirl = "Happy little girl"
    case chipmunk = "Chipmunk"
    case oneOctaveUp = "+1 8ve"
    case twoOctavesUp = "+2 8ve"
    
    case deep = "A bit deep"
    case robocop = "Robocop"
    case oneOctaveDown = "-1 8ve"
    case twoOctavesDown = "-2 8ve"
    
    static var allValues: [SystemDefinedPitchPresetParams] = [.normal, .chipmunk, .happyLittleGirl, .oneOctaveUp, .twoOctavesUp, .deep, .robocop, .oneOctaveDown, .twoOctavesDown]
    
    // Converts a user-friendly display name to an instance of PitchPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedPitchPresetParams {
        return SystemDefinedPitchPresetParams(rawValue: displayName) ?? .normal
    }
    
    var pitch: PitchShift {
        
        switch self {
            
        case .normal:   return PitchShift(fromCents: 0)
            
        case .happyLittleGirl: return PitchShift(octaves: 0, semitones: 3, cents: 60)
            
        case .chipmunk: return PitchShift(octaves: 0, semitones: 6, cents: 0)
            
        case .oneOctaveUp:  return PitchShift(octaves: 1, semitones: 0, cents: 0)
            
        case .twoOctavesUp: return PitchShift(octaves: 2, semitones: 0, cents: 0)
            
        case .deep: return PitchShift(octaves: 0, semitones: -3, cents: -60)
            
        case .robocop:  return PitchShift(octaves: 0, semitones: -6, cents: 0)
            
        case .oneOctaveDown:    return PitchShift(octaves: -1, semitones: 0, cents: 0)
            
        case .twoOctavesDown:   return PitchShift(octaves: -2, semitones: 0, cents: 0)
            
        }
    }
    
    var state: EffectsUnitState {
        return .active
    }
}
