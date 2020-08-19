import Cocoa

extension NSTableView {
    
    func enableDragDrop_reorderingAndFiles() {
        self.registerForDraggedTypes([.data, .file_URL])
    }
    
    func enableDragDrop_files() {
        self.registerForDraggedTypes([.file_URL])
    }
    
    func selectRow(_ row: Int) {
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: [Int]) {
        self.selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    /*
        An event handler for customized contextual menu behavior.
        This function needs to be overriden in order to:
     
        1 - Only display the contextual menu when at least one row is available, and the click occurred within a playlist row view (i.e. not in empty table view space)
        2 - Capture the row for which the contextual menu was requested, and select it
        3 - Disable the row highlight displayed when presenting the contextual menu
     */
    func menuHandler(for event: NSEvent) -> NSMenu? {
        
        // If tableView has no rows, don't show the menu
        if self.numberOfRows == 0 {return nil}
        
        // Calculate the clicked row
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        
        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if row == -1 {return nil}
        
        // Select the clicked row, implicitly clearing the previous selection
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        
        // Note that this view was clicked (this is required by the contextual menu)
        PlaylistViewState.registerTableViewClick(self)
        
        return self.menu
    }
    
    func pageUp() {
        
        // Determine if the first row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        
        let firstRowShown = self.rows(in: visibleRect).lowerBound
        let firstRowShownRect = self.rect(ofRow: firstRowShown)
        
        let truncationAmount =  visibleRect.minY - firstRowShownRect.minY
        let truncationRatio = truncationAmount / firstRowShownRect.height
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let lastRowToShow = truncationRatio > 0.1 ? firstRowShown : firstRowShown - 1
        let lastRowToShowRect = self.rect(ofRow: lastRowToShow)
        
        // Calculate the scroll amount, as a function of the last row to show next, using the visible rect origin (i.e. the top of the first row in the playlist) as the stopping point
        
        let scrollAmount = min(visibleRect.origin.y, visibleRect.maxY - lastRowToShowRect.maxY)
        
        if scrollAmount > 0 {
            
            let up = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: -scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: up)
        }
    }
    
    func pageDown() {
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        let visibleRows = self.rows(in: visibleRect)
        
        let lastRowShown = visibleRows.lowerBound + visibleRows.length - 1
        let lastRowShownRect = self.rect(ofRow: lastRowShown)
        
        let lastRowInPlaylistRect = self.rect(ofRow: self.numberOfRows - 1)
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let truncationAmount = lastRowShownRect.maxY - visibleRect.maxY
        let truncationRatio = truncationAmount / lastRowShownRect.height
        
        let firstRowToShow = truncationRatio > 0.1 ? lastRowShown : lastRowShown + 1
        let firstRowToShowRect = self.rect(ofRow: firstRowToShow)
        
        // Calculate the scroll amount, as a function of the first row to show next, using the visible rect maxY (i.e. the bottom of the last row in the playlist) as the stopping point

        let scrollAmount = min(firstRowToShowRect.origin.y - visibleRect.origin.y, lastRowInPlaylistRect.maxY - visibleRect.maxY)
        
        if scrollAmount > 0 {
            
            let down = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: down)
        }
    }
}

extension NSTableColumn {
    
    var isShown: Bool {!self.isHidden}
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func toggleShowOrHide() {
        self.isHidden.toggle()
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track. Customizes the selection look and feel.
 */
class GenericTableRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            Colors.playlistSelectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

class BasicTableCellView: NSTableCellView {
    
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var textFont: NSFont = Fonts.Constants.mainFont_10
    var selectedTextFont: NSFont = Fonts.Constants.mainFont_10
    
    var textColor: NSColor = Colors.playlistTextColor
    var selectedTextColor: NSColor = Colors.playlistSelectedTextColor
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            backgroundStyleChanged()
        }
    }
    
    func backgroundStyleChanged() {
        
        let isSelectedRow = rowIsSelected
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = isSelectedRow ?  selectedTextColor : textColor
        textField?.font = isSelectedRow ? selectedTextFont : textFont
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let uid_index: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.playlistIndexColumnID)
    
    static let uid_trackName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.playlistNameColumnID)
    
    static let uid_duration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.playlistDurationColumnID)
    
    static let uid_chapterIndex: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.chapterIndexColumnID)
    
    static let uid_chapterTitle: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.chapterTitleColumnID)
    
    static let uid_chapterStartTime: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.chapterStartTimeColumnID)
    
    static let uid_chapterDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.chapterDurationColumnID)
    

    static let playQueue_index: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("playQueue_index")
    
    static let playQueue_title: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("playQueue_title")
    
    static let playQueue_duration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("playQueue_duration")
    
    static let playQueue_artist: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("playQueue_artist")
    
    static let playQueue_album: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("playQueue_album")
    
    static let playQueue_genre: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("playQueue_genre")
    
    
    static let library_index: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("library_index")
    
    static let library_artistTitle: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("library_artistTitle")
    
    static let library_duration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("library_duration")
    
    static let library_title: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("library_title")
    
    static let library_artist: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("library_artist")
    
    static let library_album: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("library_album")
    
    static let library_genre: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("library_genre")
}

extension NSPasteboard.PasteboardType {

    // Enables drag/drop reordering of playlist rows
    static let data: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeData))
    
    // Enables drag/drop adding of tracks into the playlist from Finder
    static let file_URL: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeFileURL))
}
