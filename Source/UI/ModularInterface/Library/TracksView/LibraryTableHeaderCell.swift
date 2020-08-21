import Cocoa

class LibraryTableHeaderCell: NSTableHeaderCell {
    
    convenience init(stringValue: String) {
        
        self.init()
        self.stringValue = stringValue
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        Colors.windowBackgroundColor.setFill()
        cellFrame.fill()
        
        let attrsDict: [NSAttributedString.Key: Any] = [
            .font: Fonts.Playlist.chaptersListHeaderFont,
            .foregroundColor: Colors.Playlist.summaryInfoColor]

        let size: CGSize = stringValue.size(withAttributes: attrsDict)
        let truncatedString = StringUtils.truncate(stringValue, Fonts.Playlist.chaptersListHeaderFont, cellFrame.width - 10)

        let rect = NSRect(x: cellFrame.minX + 5, y: cellFrame.minY, width: size.width, height: cellFrame.height)
        truncatedString.draw(in: rect, withAttributes: attrsDict)
        
        // Right Partition line
        if !stringValue.isEmpty {
            
            GraphicsUtils.drawLine(Colors.Playlist.summaryInfoColor,
                                   pt1: NSPoint(x: cellFrame.maxX - 3, y: cellFrame.minY + 6),
                                   pt2: NSPoint(x: cellFrame.maxX - 3, y: cellFrame.minY + 18), width: 1)
        }
    }
}
