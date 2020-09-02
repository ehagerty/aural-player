import Foundation

class FXUnitDelegate<T: FXUnit>: FXUnitDelegateProtocol {
    
    var unit: T
    
    var unitType: EffectsUnit {unit.unitType}
    
    // Override this property
    var unitDescription: String {""}
    
    init(_ unit: T) {
        self.unit = unit
    }
    
    var state: EffectsUnitState {
        
        get {unit.state}
        set {unit.state = newValue}
    }
    
    var stateFunction: EffectsUnitStateFunction {unit.stateFunction}
    
    var isActive: Bool {unit.isActive}
    
    func toggleState() -> EffectsUnitState {
        unit.toggleState()
    }
    
    func ensureActive() {
        unit.ensureActive()
    }
    
    // Override these 2 functions
    
    func savePreset(_ presetName: String) {}
    
    func applyPreset(_ presetName: String) {}
}
