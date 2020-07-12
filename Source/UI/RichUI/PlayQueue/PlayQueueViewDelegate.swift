import Cocoa

class PlayQueueViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate {
    
    @IBOutlet weak var playQueueView: NSTableView!
    
    private let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // MARK: Table view functions --------------------------------------------------------------------------------
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playQueue.size
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        return tableColumn?.identifier == .playQueue_title ? playQueue.trackAtIndex(row)?.conciseDisplayName : nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = playQueue.trackAtIndex(row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .playQueue_index:
            
            let indexText: String = String(row + 1)
            
            // Check if there is a track currently playing, and if this row matches that track.
            if let currentTrack = playbackInfo.currentTrack, currentTrack == track {
                
                var image: NSImage!
                
                switch playbackInfo.state {
                    
                case .playing, .paused:
                    
                    image = Images.imgPlayingTrack
                    
                case .waiting:
                    
                    image = Images.imgWaitingTrack
                    
                case .transcoding:
                    
                    image = Images.imgTranscodingTrack
                
                default: return nil // Impossible
                
                }
                
                return createIndexImageCell(tableView, row, image.applyingTint(Colors.Playlist.playingTrackIconColor))
            }
            
            // Otherwise, create a text cell with the track index
            return createIndexTextCell(tableView, indexText, row)
            
        case .playQueue_title:
            
            return createTextCell(tableView, .playQueue_title, displayName(track), row)
            
        case .playQueue_duration:
            
            return createDurationCell(tableView, ValueFormatter.formatSecondsToHMS(track.duration), row)
            
        default: return nil // Impossible
            
        }
    }
    
    private func displayName(_ track: Track) -> String {
        
        if let theArtist = track.groupingInfo.artist {
            return String(format: "%@ - %@", theArtist, track.displayInfo.title)
        }
        
        return track.displayInfo.title
    }
    
    private func createIndexTextCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> IndexCellView? {
     
        guard let cell = tableView.makeView(withIdentifier: .playQueue_index, owner: nil) as? IndexCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ row: Int, _ image: NSImage) -> IndexCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .playQueue_index, owner: nil) as? IndexCellView else {return nil}
            
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
        
        guard let cell = tableView.makeView(withIdentifier: .playQueue_duration, owner: nil) as? DurationCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.textField?.alignment = .center
        
        return cell
    }
    
//    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
//
//        guard tableView.numberOfRows > 0 else {return tableView.tableColumns[column].width}
//
//        let rowsRange: Range<Int> = 0..<tableView.numberOfRows
//        var widths: [CGFloat] = [0]
//
//        switch column {
//
//        case 1:
//
//            // Title
//            widths = rowsRange.compactMap {playQueue.trackAtIndex($0)?.displayInfo.title}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}
//
//        case 3:
//
//            // Artist
//            widths = rowsRange.compactMap {playQueue.trackAtIndex($0)?.groupingInfo.artist}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}
//
//        case 4:
//
//            // Album
//            widths = rowsRange.compactMap {playQueue.trackAtIndex($0)?.groupingInfo.album}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}
//
//        case 5:
//
//            // Genre
//            widths = rowsRange.compactMap {playQueue.trackAtIndex($0)?.groupingInfo.genre}.map{StringUtils.sizeOfString($0, Fonts.Playlist.trackNameFont).width}
//
//        default:
//
//            // Index / Duration
//            return tableView.tableColumns[column].maxWidth
//        }
//
//        return max(widths.max() ?? 0, tableView.tableColumns[column].width) + 10
//    }

}
