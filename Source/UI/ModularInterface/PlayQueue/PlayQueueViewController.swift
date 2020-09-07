import Cocoa

class PlayQueueViewController: AuralViewController {
    
    override var nibName: String? {return "PlayQueueListView"}
    
    @IBOutlet weak var playQueueView: NSTableView!
    @IBOutlet weak var scroller: NSScroller!
    
    private let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    var selectedRows: IndexSet {playQueueView.selectedRowIndexes}
    
    var selectedRowsArr: [Int] {playQueueView.selectedRowIndexes.toArray()}
    
    var selectedRowCount: Int {playQueueView.numberOfSelectedRows}
    
    var atLeastOneSelectedRow: Bool {playQueueView.numberOfSelectedRows > 0}
    
    var rowCount: Int {playQueueView.numberOfRows}
    
    var atLeastOneRow: Bool {playQueueView.numberOfRows > 0}
    
    var lastRow: Int {rowCount - 1}
    
    var allColumns: IndexSet {playQueueView.columnIndexes(in: playQueueView.visibleRect)}
    
    override func initializeUI() {
        
        playQueueView.enableDragDrop_reorderingAndFiles()
        
        changeTextSize(PlaylistViewState.textSize)
        doApplyColorScheme(ColorSchemes.systemScheme, false)
    }
    
    override func initializeSubscriptions() {
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        
        Messenger.subscribeAsync(self, .playQueue_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .playQueue_tracksAdded, self.tracksAdded(_:), queue: .main)
        
        // Only respond if the playing track was updated
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        
        Messenger.subscribe(self, .playlist_changeTextSize, self.changeTextSize(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
    }

    // NOTE - Assumes track was added at the end of the queue.
    func trackAdded(_ notification: PlayQueueTrackAddedNotification) {
        playQueueView.noteNumberOfRowsChanged()
    }
    
    func tracksAdded(_ notification: PlayQueueTracksAddedNotification) {
        
        let numRowsBeforeAdd = self.rowCount
        
        if numRowsBeforeAdd == 0 {
            playQueueView.reloadData()
            
        } else {
            
            playQueueView.noteNumberOfRowsChanged()
            
            // No need to refresh if tracks were added at the end of the queue
            if let minRefreshIndex = notification.trackIndices.min(), minRefreshIndex < numRowsBeforeAdd {
                playQueueView.reloadData(forRowIndexes: IndexSet(minRefreshIndex..<playQueue.size), columnIndexes: allColumns)
            }
        }
    }
    
    // Plays the track selected within the playlist, if there is one. If multiple tracks are selected, the first one will be chosen.
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
        playSelectedTrackWithDelay()
    }
    
    func playSelectedTrack() {
        playSelectedTrackWithDelay()
    }
    
    func playSelectedTrackWithDelay(_ delay: Double? = nil) {
        
        if let firstSelectedRow = playQueueView.selectedRowIndexes.min() {
            Messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow, delay: delay))
        }
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        let refreshIndexes: IndexSet = IndexSet(Set([notification.beginTrack, notification.endTrack].compactMap {$0}).compactMap {playQueue.indexOfTrack($0)})
        //        let needToShowTrack: Bool = playQueueViewState.current == .tracks && preferences.showNewTrackInPlaylist
        let needToShowTrack: Bool = true
        
        if needToShowTrack {
            
            if let newTrack = notification.endTrack, let newTrackIndex = playQueue.indexOfTrack(newTrack), newTrackIndex >= rowCount {
                
                // This means the track is in the playlist but has not yet been added to the playlist view (Bookmark/Recently played/Favorite item), and will be added shortly (this is a race condition). So, dispatch an async delayed handler to show the track in the playlist, after it is expected to be added.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.showPlayingTrack()
                })
                
            } else {
                notification.endTrack != nil ? showPlayingTrack() : clearSelection()
            }
        }
        //
        //        // If this is not done async, the row view could get garbled.
        //        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        //        // Gaps may have been removed, so row heights need to be updated too
        DispatchQueue.main.async {
            self.playQueueView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: self.allColumns)
        }
    }
    
    private func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        //        print("\nUpdated track:", notification.updatedTrack.title, notification.updatedFields)
        playQueueView.reloadData(forRowIndexes: [playQueue.indexOfTrack(notification.updatedTrack)!], columnIndexes: allColumns)
    }
    
    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.currentTrack, let playingTrackIndex = playQueue.indexOfTrack(playingTrack) {
            selectTrack(playingTrackIndex)
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ index: Int) {
        
        if index >= 0 && index < rowCount {
            
            playQueueView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            playQueueView.scrollRowToVisible(index)
        }
    }
    
    func tracksRemoved(fromRows removedRows: IndexSet) {
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        playQueueView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        let lastPlaylistRowAfterRemove = playQueue.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playQueue.
        if let firstRemovedRow = removedRows.min(), firstRemovedRow <= lastPlaylistRowAfterRemove {
            
            let refreshIndexes = IndexSet(firstRemovedRow...lastPlaylistRowAfterRemove)
            playQueueView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: allColumns)
        }
        
        clearSelection()
    }
    
    func clear() {
        
        playQueue.clear()
        playQueueView.reloadData()
    }
    
    func refreshTableView() {
        playQueueView.reloadData()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func tracksMovedUp(results: [TrackMoveResult]) {
        
        moveAndReloadItems(results.sorted(by: TrackMoveResult.compareAscending))
        playQueueView.scrollRowToVisible(results.map{$0.destinationIndex}.min()!)
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func tracksMovedDown(results: [TrackMoveResult]) {
        
        moveAndReloadItems(results.sorted(by: TrackMoveResult.compareDescending))
        playQueueView.scrollRowToVisible(results.map{$0.destinationIndex}.min()!)
    }
    
    // Rearranges tracks within the view that have been reordered
    private func moveAndReloadItems(_ results: [TrackMoveResult]) {
        
        var rowsToRefresh: Set<Int> = Set()
        
        for result in results {
            
            playQueueView.moveRow(at: result.sourceIndex, to: result.destinationIndex)
            rowsToRefresh.insert(result.sourceIndex)
            rowsToRefresh.insert(result.destinationIndex)
        }
        
        playQueueView.reloadData(forRowIndexes: IndexSet(rowsToRefresh), columnIndexes: allColumns)
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func tracksMovedToTop(results: [TrackMoveResult]) {
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: TrackMoveResult.compareAscending))
        
        let maxSourceIndex = results.map{$0.sourceIndex}.max()!
        
        // Refresh the relevant rows
        playQueueView.reloadData(forRowIndexes: IndexSet(0...maxSourceIndex), columnIndexes: allColumns)
        
        if view.isVisibleOnScreen {
            
            // Select all the same rows but now at the top
            playQueueView.scrollRowToVisible(0)
            playQueueView.selectRowIndexes(IndexSet(results.map{$0.destinationIndex}), byExtendingSelection: false)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func tracksMovedToBottom(results: [TrackMoveResult]) {
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: TrackMoveResult.compareDescending))
        
        let minSourceIndex = results.map{$0.sourceIndex}.min()!
        
        // Refresh the relevant rows
        playQueueView.reloadData(forRowIndexes: IndexSet(minSourceIndex...lastRow), columnIndexes: allColumns)
        
        if view.isVisibleOnScreen {
            
            // Select all the same items but now at the bottom
            playQueueView.scrollRowToVisible(lastRow)
            playQueueView.selectRowIndexes(IndexSet(results.map{$0.destinationIndex}), byExtendingSelection: false)
        }
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playQueueView.removeRows(at: IndexSet(integer: result.sourceIndex), withAnimation: result.movedUp ? .slideUp : .slideDown)
            playQueueView.insertRows(at: IndexSet(integer: result.destinationIndex), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    func clearSelection() {
        playQueueView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
    }
    
    func invertSelection() {
        playQueueView.selectRowIndexes(invertedSelection, byExtendingSelection: false)
    }
    
    var invertedSelection: IndexSet {
        IndexSet((0..<rowCount).filter {!selectedRows.contains($0)})
    }
    
    func scrollToTop() {
        
        if atLeastOneRow {
            playQueueView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    func scrollToBottom() {
        
        if atLeastOneRow {
            playQueueView.scrollRowToVisible(lastRow)
        }
    }
    
    func pageUp() {
        
        if atLeastOneRow {
            playQueueView.pageUp()
        }
    }
    
    func pageDown() {
        
        if atLeastOneRow {
            playQueueView.pageDown()
        }
    }
    
    // MARK: Appearance
    
    private func changeTextSize(_ textSize: TextSize) {
        
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        playQueueView.enclosingScrollView?.backgroundColor = color
        playQueueView.backgroundColor = color
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        doApplyColorScheme(scheme)
    }
    
    private func doApplyColorScheme(_ scheme: ColorScheme, _ mustReloadRows: Bool = true) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        scroller.redraw()
        
        if mustReloadRows {
            
            let selRows = self.selectedRows
            playQueueView.reloadData()
            playQueueView.selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    private var allRows: IndexSet {
        return IndexSet(integersIn: 0..<playQueueView.numberOfRows)
    }
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        playQueueView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet([1]))
    }
    
    private func changeIndexDurationTextColor(_ color: NSColor) {
        playQueueView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet([0, 2]))
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        playQueueView.reloadData(forRowIndexes: playQueueView.selectedRowIndexes, columnIndexes: IndexSet([1]))
    }
    
    private func changeIndexDurationSelectedTextColor(_ color: NSColor) {
        playQueueView.reloadData(forRowIndexes: playQueueView.selectedRowIndexes, columnIndexes: IndexSet([0, 2]))
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        
        // Note down the selected rows, clear the selection, and re-select the originally selected rows (to trigger a repaint of the selection boxes)
        let selRows = self.selectedRows
        
        if !selRows.isEmpty {
            
            clearSelection()
            playQueueView.selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingTrack = self.playbackInfo.currentTrack, let playingTrackIndex = self.playQueue.indexOfTrack(playingTrack) {
            playQueueView.reloadData(forRowIndexes: IndexSet([playingTrackIndex]), columnIndexes: IndexSet([0]))
        }
    }
}

class PlayQueueListViewController: PlayQueueViewController {
    override var nibName: String? {return "PlayQueueListView"}
}

class PlayQueueTableViewController: PlayQueueViewController {
    override var nibName: String? {return "PlayQueueTableView"}
}
