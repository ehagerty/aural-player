import Cocoa

class TimeStretchSlider: EffectsUnitSlider {
    
    var rate: Float {
        
        get {0.25 * powf(2, floatValue)}
        
        set {floatValue = log2(newValue / 0.25)}
    }
}
