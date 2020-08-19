import Cocoa

/*
    Delegate for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class LibraryTracksViewDelegate: NSObject, NSTableViewDelegate {
    
    @IBOutlet weak var libraryView: NSTableView!
    
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // MARK: Table view functions --------------------------------------------------------------------------------
    
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
}
