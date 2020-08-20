import Cocoa

class LibraryTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        Colors.windowBackgroundColor.setFill()
//        Colors.Constants.white15Percent.setFill()
        cellFrame.fill()
        
        let attrsDict: [NSAttributedString.Key: Any] = [
            .font: Fonts.Playlist.chaptersListHeaderFont,
            .foregroundColor: Colors.Playlist.summaryInfoColor]

        let size: CGSize = stringValue.size(withAttributes: attrsDict)

        // Calculate the x co-ordinate for text rendering, according to its intended aligment
        let x: CGFloat = cellFrame.minX + 5
        
        let truncatedString = StringUtils.truncate(stringValue, Fonts.Playlist.chaptersListHeaderFont, cellFrame.width - 10)

        let rect = NSRect(x: x, y: cellFrame.minY, width: size.width, height: cellFrame.height)
        truncatedString.draw(in: rect, withAttributes: attrsDict)
        
        // Right Partition line
//        let lineColor = Colors.Constants.white50Percent
//        let cw = cellFrame.width
//        let pline = cellFrame.insetBy(dx: cw / 2 - 0.25, dy: 10).offsetBy(dx: cw / 2 - 3, dy: -3)
        if !stringValue.isEmpty {
            
            GraphicsUtils.drawLine(Colors.Playlist.summaryInfoColor,
                                   pt1: NSPoint(x: cellFrame.maxX - 3, y: cellFrame.minY + 6),
                                   pt2: NSPoint(x: cellFrame.maxX - 3, y: cellFrame.minY + 18), width: 1)
        }
        
//        let path = NSBezierPath.init(rect: pline)
//        lineColor.setFill()
//        path.lineWidth = 0.5
//        path.fill()
    }
}
