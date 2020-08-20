import Cocoa

/*
    Delegate for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class LibraryTracksViewDelegate: NSObject, NSTableViewDelegate {
    
    @IBOutlet weak var libraryView: AuralLibraryTableView!
    
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // MARK: Table view functions --------------------------------------------------------------------------------
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn columnIndex: Int) -> CGFloat {
        
        guard tableView.numberOfRows > 0 else {return tableView.tableColumns[columnIndex].width}
        
        let rowsRange: Range<Int> = 0..<tableView.numberOfRows
        var widths: [CGFloat] = [0]
        
        // NOTE - For large numbers of tracks, this could be slow !
        // Should this be done only for visible rows ???
        
        let column = tableView.tableColumns[columnIndex]
        
        switch column.identifier {
            
            // TODO: Using column index won't work because columns can be reordered.
            // Use the column identifier instead.
            
        case .library_title:
            
            // Title
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.title}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        case .library_artistTitle:

            // Title
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.artistTitleString}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        case .library_title:

            // Artist
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.artist}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        case .library_album:

            // Album
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.album}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        case .library_genre:

            // Genre
            widths = rowsRange.compactMap {library.trackAtIndex($0)?.genre}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}

        default:
            
            // Index / Duration
            return tableView.tableColumns[columnIndex].maxWidth
        }
        
        return max(widths.max() ?? 0, tableView.tableColumns[columnIndex].width) + 10
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
            
        case .library_artistTitle:
            
            return createTextCell(tableView, .library_artistTitle, track.artistTitleString ?? track.defaultDisplayName, row)
            
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
            
        default:
            
            // Custom column
            if let customColumn = libraryView.customColumnsMap[columnId] {
                return createTextCell(tableView, columnId, customColumn.text(for: track), row)
            }
            
            return nil // Impossible
            
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
}
