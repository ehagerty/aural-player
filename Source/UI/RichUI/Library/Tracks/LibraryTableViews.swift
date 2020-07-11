import Cocoa

class LibraryTableView: NSTableView {
    
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
