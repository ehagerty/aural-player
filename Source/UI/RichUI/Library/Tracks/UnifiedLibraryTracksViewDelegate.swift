import Cocoa

class UnifiedLibraryTracksViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate {
    
    @IBOutlet weak var libraryView: NSTableView!
    
    @IBOutlet weak var artistColumnMenuItem: NSMenuItem!
    @IBOutlet weak var albumColumnMenuItem: NSMenuItem!
    @IBOutlet weak var genreColumnMenuItem: NSMenuItem!
    
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    override func awakeFromNib() {
        
        artistColumnMenuItem.action = #selector(self.toggleArtistColumnAction(_:))
        artistColumnMenuItem.target = self
        
        albumColumnMenuItem.action = #selector(self.toggleAlbumColumnAction(_:))
        albumColumnMenuItem.target = self
        
        genreColumnMenuItem.action = #selector(self.toggleGenreColumnAction(_:))
        genreColumnMenuItem.target = self
    }
    
    var isShowingArtistColumn: Bool {!libraryView.tableColumn(withIdentifier: .library_artist)!.isHidden}
    
    var isShowingAlbumColumn: Bool {!libraryView.tableColumn(withIdentifier: .library_album)!.isHidden}
    
    var isShowingGenreColumn: Bool {!libraryView.tableColumn(withIdentifier: .library_genre)!.isHidden}
    
    func menuWillOpen(_ menu: NSMenu) {
        
        artistColumnMenuItem.onIf(isShowingArtistColumn)
        albumColumnMenuItem.onIf(isShowingAlbumColumn)
        genreColumnMenuItem.onIf(isShowingGenreColumn)
    }
    
    @IBAction func toggleArtistColumnAction(_ sender: AnyObject) {
        libraryView.tableColumn(withIdentifier: .library_artist)!.isHidden.toggle()
    }
    
    @IBAction func toggleAlbumColumnAction(_ sender: AnyObject) {
        libraryView.tableColumn(withIdentifier: .library_album)!.isHidden.toggle()
    }
    
    @IBAction func toggleGenreColumnAction(_ sender: AnyObject) {
        libraryView.tableColumn(withIdentifier: .library_genre)!.isHidden.toggle()
    }
    
    // MARK: Table view functions --------------------------------------------------------------------------------
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return library.size
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        return tableColumn?.identifier == .library_title ? library.trackAtIndex(row)?.defaultDisplayName : nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = library.trackAtIndex(row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .library_index:
            
            let indexText: String = String(row + 1)
            
            // Check if there is a track currently playing, and if this row matches that track.
            if let currentTrack = playbackInfo.currentTrack, currentTrack == track {
                
                var image: NSImage!
                
                switch playbackInfo.state {
                    
                case .playing, .paused:
                    
                    image = Images.imgPlayingTrack
                    
                case .waiting:
                    
                    image = Images.imgWaitingTrack
                    
                default: return nil // Impossible
                
                }
                
                return createIndexImageCell(tableView, row, image.applyingTint(Colors.Playlist.playingTrackIconColor))
            }
            
            // Otherwise, create a text cell with the track index
            return createIndexTextCell(tableView, indexText, row)
            
        case .library_title:

            return createTextCell(tableView, .library_title, track.title ?? track.defaultDisplayName, row)

        case .library_duration:

            return createDurationCell(tableView, ValueFormatter.formatSecondsToHMS(track.duration), row)

        case .library_artist:

            if let artist = track.artist {
                return createTextCell(tableView, .library_artist, artist, row)
            }

            return nil

        case .library_album:

            if let album = track.album {
                return createTextCell(tableView, .library_album, album, row)
            }

            return nil

        case .library_genre:

            if let genre = track.genre {
                return createTextCell(tableView, .library_genre, genre, row)
            }

            return nil
            
        default: return nil // Impossible
            
        }
    }
    
    private func createIndexTextCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> IndexCellView? {
     
        guard let cell = tableView.makeView(withIdentifier: .library_index, owner: nil) as? IndexCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ row: Int, _ image: NSImage) -> IndexCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .library_index, owner: nil) as? IndexCellView else {return nil}
            
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateImage(image)
        
        return cell
    }
    
    private func createTextCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ text: String, _ row: Int) -> TextCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? TextCellView else {return nil}
            
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.trackNameFont, text)
        
        return cell
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> DurationCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .library_duration, owner: nil) as? DurationCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
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
    }
}
