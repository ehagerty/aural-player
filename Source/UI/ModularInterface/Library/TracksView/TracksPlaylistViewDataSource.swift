import Cocoa

/*
    Data source for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class LibraryTracksViewDataSource: NSObject, NSTableViewDataSource, NSMenuDelegate, NotificationSubscriber {
    
    @IBOutlet weak var libraryView: NSTableView!
    @IBOutlet weak var headerView: NSTableHeaderView!
    private var theHeaderView: NSTableHeaderView!
    
    @IBOutlet weak var indexColumn: NSTableColumn!
    @IBOutlet weak var artistTitleColumn: NSTableColumn!
    @IBOutlet weak var durationColumn: NSTableColumn!
    @IBOutlet weak var titleColumn: NSTableColumn!
    @IBOutlet weak var artistColumn: NSTableColumn!
    @IBOutlet weak var albumColumn: NSTableColumn!
    @IBOutlet weak var genreColumn: NSTableColumn!
    
    @IBOutlet weak var artistColumnMenuItem: NSMenuItem!
    @IBOutlet weak var albumColumnMenuItem: NSMenuItem!
    @IBOutlet weak var genreColumnMenuItem: NSMenuItem!
    
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    override func awakeFromNib() {

        // TODO: Later, control this based on saved app state (remembered) and/or preferences.
        [indexColumn, titleColumn, artistColumn, albumColumn, genreColumn].forEach {$0.hide()}
//        libraryView.headerView = nil
        theHeaderView = headerView
        Messenger.subscribe(self, .library_toggleTableHeader, self.toggleTableHeader)
    }
    
    var isShowingArtistColumn: Bool {artistColumn.isShown}
    
    var isShowingAlbumColumn: Bool {albumColumn.isShown}
    
    var isShowingGenreColumn: Bool {genreColumn.isShown}
    
    func menuWillOpen(_ menu: NSMenu) {
        
        for item in menu.items {
            
            if let id = item.identifier {
                item.onIf(libraryView.tableColumn(withIdentifier: id)?.isShown ?? false)
            }
        }
    }
    
    func toggleTableHeader() {
        libraryView.headerView = libraryView.headerView != nil ? nil : theHeaderView
    }
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        if let id = sender.identifier {
            libraryView.tableColumn(withIdentifier: id)?.isHidden.toggle()
        }
        
        print("\(sender.identifier!.rawValue) triggered this action !!!")
    }
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return library.size
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        guard let sortDescriptor = tableView.sortDescriptors.first, let key = sortDescriptor.key else {return}
        let ascending = sortDescriptor.ascending
        
        let tracksSort: TracksSort = TracksSort()
        let sort: Sort = Sort().withTracksSort(tracksSort)
        
        switch key {
            
        case "title":
            
            _ = tracksSort.withFields(.title)
            
        case "duration":
            
            _ = tracksSort.withFields(.duration)
            
        case "artist":
            
            _ = tracksSort.withFields(.artist, .album, .discNumberAndTrackNumber)
            
        case "album":
            
            _ = tracksSort.withFields(.album, .discNumberAndTrackNumber)
            
        case "genre":
            
            _ = tracksSort.withFields(.genre, .artist, .album, .discNumberAndTrackNumber)
            
        default: return
            
        }
        
        _ = tracksSort.withOrder(ascending ? .ascending : .descending).withNoOptions()

        library.sort(sort)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        
        guard tableView.numberOfRows > 0 else {return tableView.tableColumns[column].width}
        
        let rowsRange: Range<Int> = 0..<tableView.numberOfRows
        var widths: [CGFloat] = [0]
        
        switch column {
            
            // TODO: Using column index won't work because columns can be reordered.
            // Use the column identifier instead.

        case 1:

            // Title
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.title}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        case 3:

            // Artist
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.artist}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        case 4:

            // Album
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.album}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        case 5:

            // Genre
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.genre}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        default:
            
            // Index / Duration
            return tableView.tableColumns[column].maxWidth
        }
        
        return max(widths.max() ?? 0, tableView.tableColumns[column].width) + 10
    }

    // MARK: Drag n drop
    
    // Validates the proposed drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {

        // Files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return library.isBeingModified || info.draggingSource is NSTableView ? invalidDragOperation : .copy
    }
    
    // Given source indexes, a destination index (dropRow), and the drop operation (on/above), determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination indexes)
    private func validateReorderOperation(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableView.DropOperation) -> Bool {
        
        // If all rows are selected, they cannot be moved, and dropRow cannot be one of the source rows
        return operation == .above && (sourceIndexSet.count < tableView.numberOfRows) && !sourceIndexSet.contains(dropRow)
    }
    
    // Performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        if library.isBeingModified || info.draggingSource is NSTableView {return false}
        
        if let files = info.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            
            // Files added from Finder, add them to the playlist as URLs
            library.addFiles(files)
            return true
        }
        
        return false
    }}
