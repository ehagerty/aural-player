import Cocoa

extension NSView {
    
    func activateAndAddConstraint(_ constraint: NSLayoutConstraint) {
        
        constraint.isActive = true
        self.addConstraint(constraint)
    }
    
    func deactivateAndRemoveConstraint(_ constraint: NSLayoutConstraint) {
        
        constraint.isActive = false
        self.removeConstraint(constraint)
    }
}

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralPlaylistTableView: NSTableView {
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
}

class AuralLibraryTableView: NSTableView {
    
    var customColumns: [CustomColumn] = []
    var customColumnsMap: [NSUserInterfaceItemIdentifier: CustomColumn] = [:]
    
    override func menu(for event: NSEvent) -> NSMenu? {
        
        let clickedRow: Int = self.row(at: self.convert(event.locationInWindow, from: nil))

        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if clickedRow == -1 {return nil}
        
        if !self.isRowSelected(clickedRow) {
            self.selectRow(clickedRow)
        }
        
        return self.menu
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class PlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != .none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            Colors.Playlist.selectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

class BasicFlatPlaylistCellView: NSTableCellView {
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textField?.font = font
        textField?.stringValue = text
        textField?.show()
        
        imageView?.hide()
    }
    
    func updateImage(_ image: NSImage) {
        
        imageView?.image = image
        imageView?.show()
        
        textField?.hide()
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {backgroundStyleChanged()}
    }

    // Check if this row is selected, change font and color accordingly
    func backgroundStyleChanged() {
        
        textField?.textColor = rowIsSelected ? Colors.Playlist.trackNameSelectedTextColor : Colors.Playlist.trackNameTextColor
        textField?.font = Fonts.Playlist.trackNameFont
    }
    
    func placeTextFieldOnTop() {
        
        guard let textField = self.textField else {return}
            
        // Remove any existing constraints on the text field's 'top' attribute
        self.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .top}.forEach {self.deactivateAndRemoveConstraint($0)}
        
        // textField.top == self.top
        let textFieldOnTopConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -2)
        self.activateAndAddConstraint(textFieldOnTopConstraint)
    }
    
    func placeTextFieldBelowView(_ view: NSView) {
        
        guard let textField = self.textField else {return}
        
        // Remove any existing constraints on the text field's 'top' attribute
        self.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .top}.forEach {self.deactivateAndRemoveConstraint($0)}
        
        let textFieldBelowViewConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -2)
        self.activateAndAddConstraint(textFieldBelowViewConstraint)
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class TextCellView: BasicFlatPlaylistCellView {
    
    var gapImage: NSImage!
    
    @IBInspectable @IBOutlet weak var gapBeforeImg: NSImageView!
    @IBInspectable @IBOutlet weak var gapAfterImg: NSImageView!
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool) {

        gapBeforeImg.image = gapBeforeTrack ? gapImage : nil
        gapBeforeImg.showIf(gapBeforeTrack)

        gapAfterImg.image = gapAfterTrack ? gapImage : nil
        gapAfterImg.showIf(gapAfterTrack)

        gapBeforeTrack ? placeTextFieldBelowView(gapBeforeImg) : placeTextFieldOnTop()
    }
}

@IBDesignable
class RichTextCellView: BasicFlatPlaylistCellView {
    
    func attributedString(_ text: String, _ font: NSFont, _ color: NSColor) -> NSAttributedString {
        
        let attributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]
        return NSAttributedString(string: text, attributes: attributes)
    }
}

@IBDesignable
class ArtistTitleRichTextCellView: RichTextCellView {
    
    func update(artist: String?, title: String) {
        
        // TODO: Truncation

        if let theArtist = artist {
            
            let richText: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString(theArtist + "   ", Fonts.Playlist.trackNameFont, Colors.Player.trackInfoArtistAlbumTextColor))
            
            richText.append(attributedString(title, Fonts.Playlist.trackNameFont, Colors.Player.trackInfoTitleTextColor))
            
            textField?.attributedStringValue = richText
            
        } else {
            
            textField?.attributedStringValue = attributedString(title, Fonts.Playlist.trackNameFont, Colors.Player.trackInfoTitleTextColor)
        }
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class DurationCellView: BasicFlatPlaylistCellView {
    
    @IBInspectable @IBOutlet weak var gapBeforeTextField: NSTextField!
    @IBInspectable @IBOutlet weak var gapAfterTextField: NSTextField!
    
    override func backgroundStyleChanged() {
        
        let isSelectedRow = rowIsSelected
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = Fonts.Playlist.indexFont
        
//        gapBeforeTextField.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
//        gapBeforeTextField.font = Fonts.Playlist.indexFont
//
//        gapAfterTextField.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
//        gapAfterTextField.font = Fonts.Playlist.indexFont
    }
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool, _ gapBeforeDuration: Double?, _ gapAfterDuration: Double?) {
        
//        gapBeforeTextField.showIf(gapBeforeTrack)
//        gapBeforeTextField.stringValue = gapBeforeTrack ? ValueFormatter.formatSecondsToHMS(gapBeforeDuration!) : ""
//
//        gapAfterTextField.showIf(gapAfterTrack)
//        gapAfterTextField.stringValue = gapAfterTrack ? ValueFormatter.formatSecondsToHMS(gapAfterDuration!) : ""
//
//        gapBeforeTrack ? placeTextFieldBelowView(gapBeforeTextField) : placeTextFieldOnTop()
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class IndexCellView: BasicFlatPlaylistCellView {
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool) {

        switch (gapBeforeTrack, gapAfterTrack) {

        case (false, false), (true, true):
            
            adjustIndexConstraints_centered()
            
        case (false, true):

            adjustIndexConstraints_afterGapOnly()

        case (true, false):
            
            adjustIndexConstraints_beforeGapOnly()
        }
    }
    
    override func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = rowIsSelected ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = Fonts.Playlist.indexFont
    }
    
    func adjustIndexConstraints_beforeGapOnly() {
        
        guard let textField = self.textField, let imgView = self.imageView else {return}
        
        // Remove any existing constraints on the text field's and image view's 'centerY' attribute
        self.constraints.filter {($0.firstItem === textField || $0.firstItem === imgView) && $0.firstAttribute == .centerY}.forEach {self.deactivateAndRemoveConstraint($0)}

        // textField.centerY = self.bottom
        let textFieldCtrYConstraint = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -14.5)
        self.activateAndAddConstraint(textFieldCtrYConstraint)
        
        // imgView.centerY = self.bottom
        let imgViewCtrYConstraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -12)
        self.activateAndAddConstraint(imgViewCtrYConstraint)
    }
    
    func adjustIndexConstraints_afterGapOnly() {
        
        guard let textField = self.textField, let imgView = self.imageView else {return}
        
        // Remove any existing constraints on the text field's and image view's 'centerY' attribute
        self.constraints.filter {($0.firstItem === textField || $0.firstItem === imgView) && $0.firstAttribute == .centerY}.forEach {self.deactivateAndRemoveConstraint($0)}
        
        // textField.centerY = self.top
        let textFieldCtrYConstraint = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 10.5)
        self.activateAndAddConstraint(textFieldCtrYConstraint)
        
        // imgView.centerY = self.bottom
        let imgViewCtrYConstraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -30)
        self.activateAndAddConstraint(imgViewCtrYConstraint)
    }
    
    func adjustIndexConstraints_centered() {
        
        guard let textField = self.textField, let imgView = self.imageView else {return}
        
        // Remove any existing constraints on the text field's and image view's 'centerY' attribute
        self.constraints.filter {($0.firstItem === textField || $0.firstItem === imgView) && $0.firstAttribute == .centerY}.forEach {self.deactivateAndRemoveConstraint($0)}
        
        // textField.centerY = self.centerY
        let textFieldCtrYConstraint = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -2)
        self.activateAndAddConstraint(textFieldCtrYConstraint)
        
        // imgView.centerY = self.centerY
        let imgViewCtrYConstraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        self.activateAndAddConstraint(imgViewCtrYConstraint)
    }
}
