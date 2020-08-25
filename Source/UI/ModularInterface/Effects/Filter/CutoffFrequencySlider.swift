import Cocoa

class CutoffFrequencySlider: EffectsUnitSlider {
    
    var frequency: Float {
        return 20 * powf(10, (floatValue - 20) / 6660)
    }
    
    func setFrequency(_ freq: Float) {
        self.floatValue = 6660 * log10(freq/20) + 20
    }
}

class CutoffFrequencyCircularSlider: CircularSlider {
    
    var frequency: Float {
        return 20 * powf(10, (floatValue - 20) / 6660)
    }
    
    func setFrequency(_ freq: Float) {
        setValue(6660 * log10(freq/20) + 20)
    }
    
    override func setValue(_ value: Float) {
        
        let sweepAngle = computeAngle(value: value)
        perimeterPoint = convertAngleDegreesToPerimeterPoint(sweepAngle)
        
        arcEndAngle = 225 - sweepAngle
        
        self.floatValue = value
        self.integerValue = roundedInt(self.floatValue)
    }
    
    override func computeValueForClick(loc: NSPoint) {
     
        let dx = center.x - loc.x
        let dy = center.y - loc.y
        
        let xSign: CGFloat = dx == 0 ? 1 : dx / abs(dx)
        let ySign: CGFloat = dy == 0 ? 1 : dy / abs(dy)
        
        let angleRads = ySign > 0 ? min(atan((dy * ySign) / (dx * xSign)), 45 * CGFloat.pi / 180) : atan((dy * ySign) / (dx * xSign))
        
        let sweepAngle = convertAngleRadsToAngleDegrees(angleRads, xSign, ySign)
        perimeterPoint = convertAngleDegreesToPerimeterPoint(sweepAngle)
        self.floatValue = computeValue(angle: sweepAngle)
        
        arcEndAngle = 225 - sweepAngle
        
        sendAction(self.action, to: self.target)
    }
}

class CutoffFrequencySliderCell: EffectsTickedSliderCell {
    
    var filterType: FilterBandType = .lowPass
    
    override var backgroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:  return Colors.Effects.activeSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.bypassedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.suppressedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
        }
    }
    
    override var foregroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.activeSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.bypassedSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.suppressedSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
        }
    }
}

class CutoffFrequencySliderPreviewCell: CutoffFrequencySliderCell {
    
    override var knobColor: NSColor {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveUnitColor
            
        case .bypassed: return Colors.Effects.defaultBypassedUnitColor
            
        case .suppressed:   return Colors.Effects.defaultSuppressedUnitColor
            
        }
    }
    
    override var backgroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSliderBackgroundGradient
                
            case .highPass:  return Colors.Effects.defaultActiveSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.defaultBypassedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.defaultSuppressedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
        }
    }
    
    override var foregroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultActiveSliderGradient
                
            case .highPass:   return Colors.Effects.defaultSliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultBypassedSliderGradient
                
            case .highPass:   return Colors.Effects.defaultSliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSuppressedSliderGradient
                
            case .highPass:   return Colors.Effects.defaultSliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
        }
    }
}
