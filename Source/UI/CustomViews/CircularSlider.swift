import Cocoa

@IBDesignable
class CircularSlider: NSControl {
    
    var percentage: Float = 50
    
    @IBInspectable var value: Int = 50
    @IBInspectable var minValue: Int = 0
    @IBInspectable var maxValue: Int = 100
    
    @IBInspectable var radius: CGFloat = 30
    var center: NSPoint = NSPoint.zero
    var perimeterPoint: NSPoint = NSPoint.zero
    
    @IBInspectable var lineWidth: CGFloat = 4
    
    var backgroundColor: NSColor {return Colors.Player.transcoderArcBackgroundColor}
    var foregroundColor: NSColor {return Colors.Player.sliderForegroundColor}
    
    var textFont: NSFont {return Fonts.Player.infoBoxArtistAlbumFont}
    
    override func awakeFromNib() {
        radius = (self.width - (2 * lineWidth)) / 2
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        center = NSPoint(x: dirtyRect.width / 2, y: dirtyRect.height / 2)

        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
        layer?.sublayers?.removeAll()
        
        let circlePath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 3, dy: 3))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath

        shapeLayer.fillColor = Colors.Constants.white10Percent.cgColor
        shapeLayer.strokeColor = NSColor.clear.cgColor

        shapeLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
        shapeLayer.shouldRasterize = true

        self.layer?.addSublayer(shapeLayer)
        
        let line = NSBezierPath() // container for line(s)
        line.move(to: center) // start point
        line.line(to: perimeterPoint) // destination
//        line.lineWidth = 2  // hair line
//
//        NSColor.gray.setStroke()
//        line.stroke()
  
               
                
                // To prevent the arc from disappearing when we hit 100%
                percentage = Float(value - minValue) * 100 / Float(maxValue - minValue)
                if percentage >= 100 {percentage = 99.98}
                let endAngle: CGFloat = 225 - (CGFloat(percentage) * 2.7)

         let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: center, radius: radius + 2, startAngle: 225, endAngle: endAngle, clockwise: true)
        
//        print("\nVMMPE:", percentage, endAngle)
        
        foregroundColor.setStroke()
        arcPath.lineWidth = 1.5
        arcPath.stroke()
        
        let fgLayer = CAShapeLayer()
        fgLayer.path = line.CGPath
            
        fgLayer.fillColor = NSColor.clear.cgColor
        fgLayer.strokeColor = foregroundColor.cgColor
        fgLayer.lineWidth = 1.0
            
        self.layer?.addSublayer(fgLayer)
        
        // ---------------------- PERCENTAGE TEXT ----------------------
        
//        let text = String(format: "%d %%", Int(round(percentage)))
        
//        print("Perc:", text)
        
//        let dict: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.font: textFont,
//            NSAttributedString.Key.foregroundColor: Colors.Player.transcoderArcProgressTextColor]
//
//        let size: CGSize = text.size(withAttributes: dict)
//
//        // Draw title (adjacent to image)
//        text.draw(in: NSRect(x: (dirtyRect.width / 2) - (size.width / 2) + 2, y: (dirtyRect.height / 2) - (size.height / 2) + 2, width: size.width, height: size.height), withAttributes: dict)
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
        
        let rad: CGFloat = radius - 1
//        print("\n", dx, dy)
        
        var angle: CGFloat = 0
        
        var ppx: CGFloat = 0
        var ppy: CGFloat = 0
        
        if dx > 0 && dy > 0 {
            
            let angleRads = min(atan(dy / dx), 45 * CGFloat.pi / 180)
            print("AngleRads:", angleRads)
            
            // Bottom left quadrant
            angle = max(0, 45 - angleRads * (180 / CGFloat.pi))
            
            ppx = center.x - rad * cos(angleRads)
            ppy = center.y - rad * sin(angleRads)
            
        } else if dx > 0 && dy < 0 {
            
            let angleRads = atan(-dy / dx)
            print("AngleRads:", angleRads)
            
            // Top left quadrant
            angle = 45 + angleRads * (180 / CGFloat.pi)
            
            ppx = center.x - rad * cos(angleRads)
            ppy = center.y + rad * sin(angleRads)
            
        } else if dx < 0 && dy > 0 {
            
            let angleRads = min(atan(dy / -dx), 45 * CGFloat.pi / 180)
            print("AngleRads:", angleRads)
            
            // Bottom right quadrant
            angle = min(270, 225 + angleRads * (180 / CGFloat.pi))
            
            ppx = center.x + rad * cos(angleRads)
            ppy = center.y - rad * sin(angleRads)
            
        } else {
            
            let angleRads = atan(dy / dx)
            print("AngleRads:", angleRads)
            
            // Top right quadrant
            angle = 225 - angleRads * (180 / CGFloat.pi)
            
            ppx = center.x + rad * cos(angleRads)
            ppy = center.y + rad * sin(angleRads)
        }
        
        perimeterPoint = NSPoint(x: ppx, y: ppy)
        
        self.value = roundedInt(Float(CGFloat(minValue) + (angle * CGFloat(maxValue - minValue) / 270.0)))
//        print("Angle:", angle, ", Value:", value, ", Pt:", perimeterPoint)
        
        self.redraw()
    }
}
