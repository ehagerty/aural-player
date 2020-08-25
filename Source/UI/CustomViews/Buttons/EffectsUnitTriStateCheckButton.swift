import Cocoa

@IBDesignable
class EffectsUnitTriStateCheckButton: NSButton {
    
    var stateFunction: (() -> EffectsUnitState)? {
        didSet {reTint()}
    }

    var unitState: EffectsUnitState {
        return stateFunction?() ?? .bypassed
    }
    
    var activeStateColor: NSColor {Colors.Effects.activeUnitStateColor}
    
    var bypassedStateColor: NSColor {Colors.Effects.bypassedUnitStateColor}
    
    var suppressedStateColor: NSColor {Colors.Effects.suppressedUnitStateColor}
        
    func stateChanged() {
     
        switch unitState {

        case .bypassed:

            alternateImage = alternateImage?.applyingTint(bypassedStateColor)

        case .active:

            alternateImage = alternateImage?.applyingTint(activeStateColor)

        case .suppressed:

            alternateImage = alternateImage?.applyingTint(suppressedStateColor)
        }
    }
    
    func reTint() {
        
        image = image?.applyingTint(bypassedStateColor)

        switch unitState {

        case .bypassed:
            
            alternateImage = alternateImage?.applyingTint(bypassedStateColor)

        case .active:
            
            alternateImage = alternateImage?.applyingTint(activeStateColor)

        case .suppressed:

            alternateImage = alternateImage?.applyingTint(suppressedStateColor)
        }
    }
}
