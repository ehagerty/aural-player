import Cocoa

class PlayQueueListViewDataSource: PlayQueueViewDataSource {}

class PlayQueueViewDataSource: NSObject, NSTableViewDataSource {
    
    @IBOutlet weak var playQueueView: NSTableView!
    
    let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {playQueue.size}
    
    // MARK: Drag n drop -------------------------------------------------------------------------------------------------------------------
    
    // Writes source information to the pasteboard
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        
        if playQueue.isBeingModified {return false}
        
        let item = NSPasteboardItem()
        item.setData(NSKeyedArchiver.archivedData(withRootObject: rowIndexes), forType: .data)
        pboard.writeObjects([item])
        
        return true
    }
    
    // Helper function to retrieve source indexes from the NSDraggingInfo pasteboard
    private func getSourceIndexes(_ draggingInfo: NSDraggingInfo) -> IndexSet? {
        
        if let data = draggingInfo.draggingPasteboard.pasteboardItems?.first?.data(forType: .data) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet
        }
        
        return nil
    }
    
    // Validates the proposed drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int,
                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        if playQueue.isBeingModified {return .invalid}
        
        // If the source is the tableView, that means playlist tracks are being reordered
        if let sourceTableView = info.draggingSource as? NSTableView {
            
            if sourceTableView.identifier == .library_tracksView {
                
                // Tracks are being dragged from the library -> play queue.
                return .copy
                
            } else if sourceTableView.identifier == .playQueue, let sourceIndexSet = getSourceIndexes(info),
                validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) {
                
                // Tracks are being reordered within the play queue.
                return .move
            }
            
            return .invalid
        }
        
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Given source indexes, a destination index (dropRow), and the drop operation (on/above), determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination indexes)
    private func validateReorderOperation(_ tableView: NSTableView, _ sourceIndexSet: IndexSet,
                                          _ dropRow: Int, _ operation: NSTableView.DropOperation) -> Bool {
        
        // If all rows are selected, they cannot be moved, and dropRow cannot be one of the source rows
        return operation == .above && (sourceIndexSet.count < tableView.numberOfRows) && !sourceIndexSet.contains(dropRow)
    }
    
    // Performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        if playQueue.isBeingModified {return false}
        
        if let sourceTableView = info.draggingSource as? NSTableView {
            
            // TODO: Should the 2 tableViews have different IDs ?
            // Just check that sourceTV.id == tableView.id
            if sourceTableView.identifier == tableView.identifier, let sourceIndices = getSourceIndexes(info) {
                
                let results = playQueue.dropTracks(sourceIndices, row)
                Messenger.publish(PlayQueueTracksDragDroppedNotification(results: results))

                // Select all the destination rows (the new locations of the moved tracks)
                let destinationIndices: [Int] = results.map {$0.destinationIndex}
                tableView.selectRowIndexes(IndexSet(destinationIndices), byExtendingSelection: false)
                
                return true
            }
            
            // Tracks have been dragged from the Library and dropped here.
            if sourceTableView.identifier == .library_tracksView, let sourceIndices = getSourceIndexes(info) {
                
                // Convert the indices from the library view into tracks, then enqueue them onto the play queue.
                
                let tracks = sourceIndices.compactMap {library.trackAtIndex($0)}
                _ = playQueue.enqueueToPlayLater(tracks)
                
                return true
            }
            
        } else if let files = info.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {

            // Files added from Finder, add them to the playlist as URLs
            playQueue.addTracks(from: files)
            return true
        }
        
        return false
    }
}
