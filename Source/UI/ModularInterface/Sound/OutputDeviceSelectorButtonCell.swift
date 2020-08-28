import Cocoa

class OutputDeviceSelectorButtonCell: NSButtonCell {
    
    var textFont: NSFont {return Fonts.Effects.unitFunctionFont}
    
    var textColor: NSColor {return isOff ? Colors.Effects.functionCaptionTextColor : Colors.Effects.functionValueTextColor}
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
//        let path = NSBezierPath(rect: frame)
//        NSColor.blue.setStroke()
//        path.stroke()
        
        let attrs: [String: AnyObject] = [
            NSAttributedString.Key.font.rawValue: textFont,
            NSAttributedString.Key.foregroundColor.rawValue: textColor]
        
        let titleText = title.string
        
        let attrDict = convertToOptionalNSAttributedStringKeyDictionary(attrs)
        
        let size: CGSize = titleText.size(withAttributes: attrDict)
        let sx = frame.minX
        let sy = frame.minY + (frame.height - size.height) / 2 - 2.5
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        titleText.draw(in: textRect, withAttributes: attrDict)
        
        return frame
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
