import Cocoa

class PlayQueueTableViewDataSource: PlayQueueViewDataSource {
    
    // MARK: Sorting ------------------------------------------------------------------------------------------------------
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        guard let sortDescriptor = tableView.sortDescriptors.first, let key = sortDescriptor.key else {return}
        let ascending = sortDescriptor.ascending
        
        let tracksSort: TracksSort = TracksSort()
        let sort: Sort = Sort().withTracksSort(tracksSort)
        
        switch key {
            
        case "title":
            
            // TODO: Title sort should also take into consideration defaultDisplayName (in SortComparator)
            _ = tracksSort.withFields(.title)
            
        case "artistTitle":
            
            _ = tracksSort.withFields(.artistTitle)
            
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

        playQueue.sort(sort)
        Messenger.publish(.playQueue_sorted)
    }
}
