import Cocoa

/*
    Data source for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class LibraryTracksViewDataSource: NSObject, NSTableViewDataSource, NSMenuDelegate, NotificationSubscriber {
    
    @IBOutlet weak var libraryView: AuralLibraryTableView!
    @IBOutlet weak var headerView: NSTableHeaderView!
    private var theHeaderView: NSTableHeaderView!
    
    @IBOutlet weak var columnsMenu: NSMenu!
    @IBOutlet weak var indexColumn: NSTableColumn!
    @IBOutlet weak var artistTitleColumn: NSTableColumn!
    @IBOutlet weak var durationColumn: NSTableColumn!
    @IBOutlet weak var titleColumn: NSTableColumn!
    @IBOutlet weak var artistColumn: NSTableColumn!
    @IBOutlet weak var albumColumn: NSTableColumn!
    @IBOutlet weak var genreColumn: NSTableColumn!
    
    private lazy var customColumnEditor: CustomColumnEditorDialogController = CustomColumnEditorDialogController()
    
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    override func awakeFromNib() {

        // TODO: Later, control this based on saved app state (remembered) and/or preferences.
//        [indexColumn, titleColumn, artistColumn, albumColumn, genreColumn].forEach {$0.hide()}
//        libraryView.headerView = nil
        theHeaderView = headerView
        
        Messenger.subscribe(self, .library_toggleTableHeader, self.toggleTableHeader)
        Messenger.subscribe(self, .library_addCustomColumn, self.addCustomColumn(_:))
    }
    
    var isShowingArtistColumn: Bool {artistColumn.isShown}
    
    var isShowingAlbumColumn: Bool {albumColumn.isShown}
    
    var isShowingGenreColumn: Bool {genreColumn.isShown}
    
    func menuWillOpen(_ menu: NSMenu) {
        
//        while menu.items.count > 7 {
//            menu.removeItem(at: 7)
//        }
//
//        for customCol in libraryView.customColumns {
//            menu.
//        }
//
        for item in menu.items {
            
            if let id = item.identifier {
                item.onIf(libraryView.tableColumn(withIdentifier: id)?.isShown ?? false)
            }
        }
    }
    
    func toggleTableHeader() {
        libraryView.headerView = libraryView.headerView != nil ? nil : theHeaderView
    }
    
    func addCustomColumn(_ notif: LibraryCustomColumnAddCommandNotification) {
        
        let customColumn = notif.column
        customColumn.id = "library_custom\(libraryView.customColumnsMap.count)"
        
        let column = libraryView.tableColumns[libraryView.column(withIdentifier: NSUserInterfaceItemIdentifier(customColumn.id))]
        column.headerCell.title = customColumn.title
        
        libraryView.customColumns.append(customColumn)
        libraryView.customColumnsMap[column.identifier] = customColumn
        
        let item: NSMenuItem = NSMenuItem(title: customColumn.title, action: #selector(self.toggleColumnAction(_:)), keyEquivalent: "")
        item.identifier = column.identifier
        item.target = self
        
        columnsMenu.insertItem(item, at: columnsMenu.items.count - 3)
        column.show()
    }
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        if let id = sender.identifier {
            libraryView.tableColumn(withIdentifier: id)?.isHidden.toggle()
        }
    }
    
    @IBAction func addColumnAction(_ sender: NSMenuItem) {
        customColumnEditor.showDialog()
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
            
        case "artistTitle":
            
            library.sort(by: {t1, t2 in
                
                ascending ?
                    (t1.artistTitleString ?? "") < (t2.artistTitleString ?? "") :
                    (t1.artistTitleString ?? "") > (t2.artistTitleString ?? "")
            })
            
            tableView.reloadData()
            return
            
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
    }
}

class CustomColumn {
    
    var id: String
    var title: String
    var formatComponents: [ColumnFormatComponent] = []
    
    // TODO:
    // var coloringPolicy: CustomColumnColoringPolicy
    
    init(title: String, formatComponents: [ColumnFormatComponent]) {
        
        // TODO
        self.id = "library_custom"
        
        self.title = title
        self.formatComponents = formatComponents
    }
    
    func text(for track: Track) -> String {
        
        var str: String = ""
        
        for component in formatComponents {
            
            if let metadataField = component as? ColumnFormatMetadataField {
                str += metadataField.value(for: track) ?? ""
                
            } else if let separator = component as? ColumnFormatFieldSeparator {
                str += separator.value
            }
        }
        
        return str
    }
}
