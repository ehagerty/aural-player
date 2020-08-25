import Cocoa

@IBDesignable
class CircularSlider: NSControl, EffectsUnitSliderProtocol {
    
    var unitState: EffectsUnitState = .bypassed {
        
        didSet {
            redraw()
        }
    }
    
    var stateFunction: (() -> EffectsUnitState)?
    
    func updateState() {
        
        if let function = stateFunction {
            
            unitState = function()
            redraw()
        }
    }
    
    override var floatValue: Float {
        didSet {redraw()}
    }
    
    @IBInspectable var minValue: Float = 0
    @IBInspectable var maxValue: Float = 100
        
    var radius: CGFloat = 30
    var center: NSPoint = NSPoint.zero
    var perimeterPoint: NSPoint = NSPoint.zero
    
    var backgroundColor: NSColor {Colors.Effects.sliderBackgroundColor}

    var foregroundColor: NSColor {
        
        switch unitState {
            
        case .active:
            
            return Colors.Effects.activeUnitStateColor
            
        case .bypassed:
            
            return Colors.Effects.bypassedUnitStateColor
            
        case .suppressed:
            
            return Colors.Effects.suppressedUnitStateColor
        }
    }
    
    func setValue(_ value: Float) {
        
        let angle = computeAngle(value: value)
        perimeterPoint = convertAngleDegreesToPerimeterPoint(angle)
        
        self.floatValue = value
        self.integerValue = roundedInt(self.floatValue)
    }
    
    override func awakeFromNib() {
        
        self.enable()
        
        center = NSPoint(x: frame.width / 2, y: frame.height / 2)
        radius = self.width / 2
        perimeterPoint = convertAngleDegreesToPerimeterPoint(0)
        
        setValue(minValue)
    }
   
    func computeAngle(value: Float) -> CGFloat {

        let percentage = (value - minValue) * 100 / (maxValue - minValue)
        return CGFloat(percentage * 2.7)
    }

    func computeValue(angle: CGFloat) -> Float {
        return Float(CGFloat(minValue) + (angle * CGFloat(maxValue - minValue) / 270.0))
    }
    
    var arcEndAngle: CGFloat = -45
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
        layer?.sublayers?.removeAll()
        
        let circlePath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 0, dy: 0))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath

        shapeLayer.fillColor = backgroundColor.cgColor
        shapeLayer.strokeColor = NSColor.clear.cgColor

        shapeLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
        shapeLayer.shouldRasterize = true

        self.layer?.addSublayer(shapeLayer)
        
        // ------------------------ ARC ----------------------------
        
        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: center, radius: radius - 2, startAngle: 225, endAngle: arcEndAngle, clockwise: true)

        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.CGPath

        arcLayer.fillColor = NSColor.clear.cgColor

        arcLayer.strokeColor = foregroundColor.cgColor
        arcLayer.lineWidth = 3

        arcLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
        arcLayer.shouldRasterize = true

        self.layer?.addSublayer(arcLayer)
        
        // ------------------------ LINE ----------------------------
        
        let line = NSBezierPath() // container for line(s)
        line.move(to: center) // start point
        line.line(to: perimeterPoint) // destination

        let fgLayer = CAShapeLayer()
        fgLayer.path = line.CGPath

        fgLayer.fillColor = NSColor.clear.cgColor
        fgLayer.strokeColor = foregroundColor.cgColor
        fgLayer.lineWidth = 2.0

        self.layer?.addSublayer(fgLayer)
    }
    
    override func mouseDown(with event: NSEvent) {
        computeValueForClick(loc: self.convert(event.locationInWindow, from: nil))
    }
    
    override func mouseDragged(with event: NSEvent) {
        computeValueForClick(loc: self.convert(event.locationInWindow, from: nil))
    }
    
    func computeValueForClick(loc: NSPoint) {
     
        let dx = center.x - loc.x
        let dy = center.y - loc.y
        
        let xSign: CGFloat = dx == 0 ? 1 : dx / abs(dx)
        let ySign: CGFloat = dy == 0 ? 1 : dy / abs(dy)
        
        let angleRads = ySign > 0 ? min(atan((dy * ySign) / (dx * xSign)), 45 * CGFloat.pi / 180) : atan((dy * ySign) / (dx * xSign))
        
        let correctedAngle: CGFloat = convertAngleRadsToAngleDegrees(angleRads, xSign, ySign)
        perimeterPoint = convertAngleDegreesToPerimeterPoint(correctedAngle)
        self.floatValue = computeValue(angle: correctedAngle)
        
        sendAction(self.action, to: self.target)
    }
    
    func convertAngleRadsToAngleDegrees(_ rads: CGFloat, _ xSign: CGFloat, _ ySign: CGFloat) -> CGFloat {
        
        let rawAngle = rads * (180 / CGFloat.pi)
        
        if xSign > 0 && ySign > 0 {
            
            // Bottom left quadrant
            return max(0, 45 - rawAngle)
            
        } else if xSign > 0 && ySign < 0 {
            
            // Top left quadrant
            return 45 + rawAngle
            
        } else if xSign < 0 && ySign > 0 {
            
            // Bottom right quadrant
            return min(270, 225 + rawAngle)
            
        } else {
            
            // Top right quadrant
            return 225 - rawAngle
        }
    }
    
    func convertAngleDegreesToPerimeterPoint(_ angle: CGFloat) -> NSPoint {
        
        let radius = self.radius - 5
        
        if angle < 45 {
            
            let angleRads: CGFloat = (45 - angle) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x - radius * cos(angleRads)
            let ppy: CGFloat = center.y - radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
            
        } else if angle < 135 {
            
            let angleRads: CGFloat = (angle - 45) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x - radius * cos(angleRads)
            let ppy: CGFloat = center.y + radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
            
        } else if angle < 225 {
            
            let angleRads: CGFloat = (225 - angle) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x + radius * cos(angleRads)
            let ppy: CGFloat = center.y + radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
            
        } else {
            
            let angleRads: CGFloat = (angle - 225) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x + radius * cos(angleRads)
            let ppy: CGFloat = center.y - radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
        }
    }
}
