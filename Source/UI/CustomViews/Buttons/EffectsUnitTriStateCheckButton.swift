import Cocoa

class EffectsUnitTriStateCheckButton: NSButton {
    
    // The image displayed when the button is in an "Off" state
    @IBInspectable var offStateImage: NSImage?

    // The image displayed when the button is in an "On" state
    @IBInspectable var onStateImage: NSImage?

    var stateFunction: (() -> EffectsUnitState)?

    var unitState: EffectsUnitState {
        return stateFunction?() ?? .bypassed
    }
    
    var activeStateTintFunction: () -> NSColor = {Colors.Effects.activeUnitStateColor} {
        didSet {reTint()}
    }
    
    var bypassedStateTintFunction: () -> NSColor = {Colors.Effects.bypassedUnitStateColor} {
        didSet {reTint()}
    }
    
    var suppressedStateTintFunction: () -> NSColor = {Colors.Effects.suppressedUnitStateColor} {
        didSet {reTint()}
    }
    
    func updateState() {
        
        if isOff {return}

        switch unitState {

        case .bypassed:
            
            alternateImage = alternateImage?.applyingTint(bypassedStateTintFunction())

        case .active:
            
            alternateImage = alternateImage?.applyingTint(activeStateTintFunction())

        case .suppressed:

            alternateImage = alternateImage?.applyingTint(suppressedStateTintFunction())
        }
    }

    func reTint() {
        updateState()
    }
}
