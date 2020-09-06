import Cocoa

class PlayQueueTableViewDelegate: NSObject, NSTableViewDelegate, NSMenuDelegate, NotificationSubscriber {
    
    @IBOutlet weak var playQueueView: NSTableView!
    @IBOutlet weak var header: NSTableHeaderView!
    private var theHeaderView: NSTableHeaderView!
    
    private let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func awakeFromNib() {
        
        if let clipView = playQueueView.enclosingScrollView?.contentView {
        
            header.setFrameSize(NSMakeSize(header.width, header.height + 6))
            clipView.setFrameSize(NSMakeSize(clipView.width, clipView.height + 6))
            clipView.contentInsets.top = header.height
        }
        
        var displayedColumnIds: [String] = PlayQueueUIState.tableViewColumns.map {$0.id}
        
        // Show default columns if none have been selected (eg. first time app is launched).
        if displayedColumnIds.isEmpty {
            
            displayedColumnIds = [NSUserInterfaceItemIdentifier.playQueue_tableView_index, NSUserInterfaceItemIdentifier.playQueue_tableView_artistTitle, NSUserInterfaceItemIdentifier.playQueue_tableView_duration].map {$0.rawValue}
        }
        
        for column in playQueueView.tableColumns {
            
            column.headerCell = LibraryTableHeaderCell(stringValue: column.headerCell.stringValue)
            column.isHidden = !displayedColumnIds.contains(column.identifier.rawValue)
        }
        
        for (index, columnId) in displayedColumnIds.enumerated() {
            
            let oldIndex = playQueueView.column(withIdentifier: NSUserInterfaceItemIdentifier(columnId))
            playQueueView.moveColumn(oldIndex, toColumn: index)
        }
        
        theHeaderView = header
        Messenger.subscribe(self, .library_toggleTableHeader, self.toggleTableHeader)
        //            Messenger.subscribe(self, .library_addCustomColumn, self.addCustomColumn(_:))
        Messenger.subscribe(self, .modularInterface_initialLayoutCompleted, self.initialLayoutCompleted)
        Messenger.subscribe(self, .application_exitRequest, self.onAppExit(_:))
    }
    
    func initialLayoutCompleted() {
        
        for column in PlayQueueUIState.tableViewColumns {
            playQueueView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(column.id))?.width = column.width
        }
    }
    
    private func onAppExit(_ request: AppExitRequestNotification) {
        
        PlayQueueUIState.tableViewColumns = playQueueView.tableColumns.filter {$0.isShown}.map {DisplayedTableColumn(id: $0.identifier.rawValue, width: $0.width)}
        request.acceptResponse(okToExit: true)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        for item in menu.items {
            
            if let id = item.identifier {
                item.onIf(playQueueView.tableColumn(withIdentifier: id)?.isShown ?? false)
            }
        }
    }
    
    func toggleTableHeader() {
        
        playQueueView.headerView = playQueueView.headerView != nil ? nil : theHeaderView
        //        print("\nDoc view: \(libraryView.frame) \(libraryView.enclosingScrollView!.contentView.documentView?.frame)")
        
        print("\nInsets: \(playQueueView.enclosingScrollView!.contentView.contentInsets)")
    }
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        // TODO: Validation - Don't allow 0 columns to be shown.
        
        if let id = sender.identifier {
            playQueueView.tableColumn(withIdentifier: id)?.isHidden.toggle()
        }
    }
    
    //        func addCustomColumn(_ notif: LibraryCustomColumnAddCommandNotification) {
    //
    //            let customColumn = notif.column
    //            customColumn.id = "library_custom\(libraryView.customColumnsMap.count)"
    //
    //            let column = libraryView.tableColumns[libraryView.column(withIdentifier: NSUserInterfaceItemIdentifier(customColumn.id))]
    //            column.headerCell.title = customColumn.title
    //
    //            libraryView.customColumns.append(customColumn)
    //            libraryView.customColumnsMap[column.identifier] = customColumn
    //
    //            let item: NSMenuItem = NSMenuItem(title: customColumn.title, action: #selector(self.toggleColumnAction(_:)), keyEquivalent: "")
    //            item.identifier = column.identifier
    //            item.target = self
    //
    //            columnsMenu.insertItem(item, at: columnsMenu.items.count - 3)
    //            column.show()
    //        }
    
//        @IBAction func addColumnAction(_ sender: NSMenuItem) {
//            customColumnEditor.showDialog()
//        }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        return tableColumn?.identifier == .playQueue_listView_title ? playQueue.trackAtIndex(row)?.defaultDisplayName : nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = playQueue.trackAtIndex(row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .playQueue_tableView_index:
            
//            // Check if there is a track currently playing, and if this row matches that track.
//            if let currentTrack = playbackInfo.currentTrack, currentTrack == track {
//
//                var image: NSImage!
//
//                switch playbackInfo.state {
//
//                case .playing, .paused:
//
//                    image = Images.imgPlayingTrack
//
//                case .waiting:
//
//                    image = Images.imgWaitingTrack
//
//                default: return nil // Impossible
//
//                }
                
            return createIndexTextCell(tableView, String(describing: (row + 1)), row)
            
        case .playQueue_tableView_artistTitle:
            
            return createArtistTitleCell(tableView, .playQueue_tableView_artistTitle, track.title == nil ? nil : track.artist, track.title ?? track.defaultDisplayName, row)
            
        case .playQueue_tableView_duration:
            
            return createDurationCell(tableView, ValueFormatter.formatSecondsToHMS(track.duration), row)
            
        case .playQueue_tableView_title:

            return createArtistTitleCell(tableView, .playQueue_tableView_title, nil, track.title ?? track.defaultDisplayName, row)

        case .playQueue_tableView_artist:

            if let artist = track.artist {
                return createTextCell(tableView, .playQueue_tableView_artist, artist, row)
            }

        case .playQueue_tableView_album:

            if let album = track.album {
                return createTextCell(tableView, .playQueue_tableView_album, album, row)
            }

        case .playQueue_tableView_genre:

            if let genre = track.genre {
                return createTextCell(tableView, .playQueue_tableView_genre, genre, row)
            }
            
        default:
            
            return nil // Impossible
        }
        
        return nil
    }
    
    private func createIndexTextCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> IndexCellView? {
     
        guard let cell = tableView.makeView(withIdentifier: .playQueue_tableView_index, owner: nil) as? IndexCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ track: Track, _ row: Int) -> PlayQueueTrackArtCell? {
        
        guard let cell = tableView.makeView(withIdentifier: .playQueue_listView_art, owner: nil) as? PlayQueueTrackArtCell else {return nil}
            
        cell.art = track.art?.image ?? Images.imgPlayingArt
        
        return cell
    }
    
    private let titleFont: NSFont = NSFont(name: "Play Regular", size: 13)!
    private let artistAlbumFont: NSFont = NSFont(name: "Play Regular", size: 12)!
    
    private func createTextCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ text: String, _ row: Int) -> TextCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? TextCellView else {return nil}
            
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        cell.updateText(Fonts.Playlist.trackNameFont, text)
        
        return cell
    }
    
    private func createArtistTitleCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ artist: String?, _ title: String, _ row: Int) -> ArtistTitleRichTextCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? ArtistTitleRichTextCellView else {return nil}
            
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        cell.update(artist: artist, title: title)
        
        return cell
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> DurationCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .playQueue_tableView_duration, owner: nil) as? DurationCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
    }
}
