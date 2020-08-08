import Cocoa

class PlayQueueViewDelegate: NSObject, NSTableViewDelegate, NSMenuDelegate {
    
    @IBOutlet weak var playQueueView: NSTableView!
    
    private let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // MARK: Table view functions --------------------------------------------------------------------------------
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        return tableColumn?.identifier == .playQueue_title ? playQueue.trackAtIndex(row)?.defaultDisplayName : nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = playQueue.trackAtIndex(row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .playQueue_index:
            
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
                
                return createIndexImageCell(tableView, track, row)
            }
            
            // Otherwise, create a text cell with the track index
            return createIndexImageCell(tableView, track, row)
            
        case .playQueue_title:
            
            return createTextCell(tableView, .playQueue_title, track, row)
            
        case .playQueue_duration:
            
            return createDurationCell(tableView, ValueFormatter.formatSecondsToHMS(track.duration), row)
            
        default: return nil // Impossible
            
        }
    }
    
    private func createIndexTextCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> IndexCellView? {
     
        guard let cell = tableView.makeView(withIdentifier: .playQueue_index, owner: nil) as? IndexCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ track: Track, _ row: Int) -> PlayQueueTrackArtCell? {
        
        guard let cell = tableView.makeView(withIdentifier: .playQueue_index, owner: nil) as? PlayQueueTrackArtCell else {return nil}
            
        cell.art = track.art?.image ?? Images.imgPlayingArt
        
        return cell
    }
    
    private let titleFont: NSFont = NSFont(name: "Play Regular", size: 13)!
    private let artistAlbumFont: NSFont = NSFont(name: "Play Regular", size: 12)!
    
    private func createTextCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ track: Track, _ row: Int) -> PlayQueueTrackInfoCell? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? PlayQueueTrackInfoCell else {return nil}
            
//        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.titleFont = titleFont
        cell.artistAlbumFont = artistAlbumFont
        cell.initializeForTrack(track)
        
        return cell
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> DurationCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .playQueue_duration, owner: nil) as? DurationCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
    }
}
