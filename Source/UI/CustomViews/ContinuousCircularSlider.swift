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
    
    var percentage: Float = 50
    
    override var floatValue: Float {
        didSet {redraw()}
    }
    
    @IBInspectable var minValue: Float = 0
    @IBInspectable var maxValue: Float = 100
        
    var radius: CGFloat = 30
    var center: NSPoint = NSPoint.zero
    var perimeterPoint: NSPoint = NSPoint.zero
    
    var backgroundColor: NSColor {return Colors.Player.progressArcBackgroundColor}
    
    var foregroundColor: NSColor {
        return unitState == .active ? Colors.Effects.activeUnitStateColor : Colors.Effects.bypassedUnitStateColor
    }
    
    var textFont: NSFont {return Fonts.Player.infoBoxArtistAlbumFont}
    
    func setValue(_ value: Float) {
        
        let angle = computeAngle(value: value)
        perimeterPoint = convertAngleDegreesToPerimeterPoint(CGFloat(angle))
        
        self.floatValue = value
        self.integerValue = roundedInt(self.floatValue)
    }
    
    override func awakeFromNib() {
        
        self.enable()
        
        center = NSPoint(x: frame.width / 2, y: frame.height / 2)
        radius = self.width / 2
        perimeterPoint = convertAngleDegreesToPerimeterPoint(0)
    }
   
    private func computeAngle(value: Float) -> Float {

        let percentage = (value - minValue) * 100 / (maxValue - minValue)
        return percentage * 2.7
    }

    private func computeValue(angle: CGFloat) -> Float {
        return Float(CGFloat(minValue) + (angle * CGFloat(maxValue - minValue) / 270.0))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
        layer?.sublayers?.removeAll()
        
        let circlePath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 0, dy: 0))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath

        shapeLayer.fillColor = Colors.Constants.white10Percent.cgColor
        shapeLayer.strokeColor = NSColor.clear.cgColor

        shapeLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
        shapeLayer.shouldRasterize = true

        self.layer?.addSublayer(shapeLayer)
        
        // ------------------------ ARC ----------------------------
                
        // To prevent the arc from disappearing when we hit 100%
        percentage = (floatValue - minValue) * 100 / (maxValue - minValue)
        if percentage >= 100 {percentage = 99.98}

        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: center, radius: radius - 2, startAngle: 225, endAngle: -45, clockwise: true)

        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.CGPath

        arcLayer.fillColor = NSColor.clear.cgColor

        let arcColor: CGColor = unitState == .active ? NSColor(red: 0, green: 0.35, blue: 0.7, alpha: 1).cgColor : Colors.Constants.white70Percent.cgColor
        arcLayer.strokeColor = arcColor
        arcLayer.lineWidth = 2

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
    
    private func computeValueForClick(loc: NSPoint) {
     
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
    
    private func convertAngleRadsToAngleDegrees(_ rads: CGFloat, _ xSign: CGFloat, _ ySign: CGFloat) -> CGFloat {
        
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
    
    private func convertAngleDegreesToPerimeterPoint(_ angle: CGFloat) -> NSPoint {
        
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
