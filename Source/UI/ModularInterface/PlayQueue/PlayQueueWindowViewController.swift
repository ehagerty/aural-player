import Cocoa

class PlayQueueWindowViewController: NSWindowController, NotificationSubscriber {
    
    override var windowNibName: String? {return "PlayQueue"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var scroller: NSScroller!
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var viewMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var playQueueView: NSTableView!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    
    private let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private var selectedRows: IndexSet {playQueueView.selectedRowIndexes}
    
    private var selectedRowsArr: [Int] {playQueueView.selectedRowIndexes.toArray()}
    
    private var selectedRowCount: Int {playQueueView.numberOfSelectedRows}
    
    private var atLeastOneSelectedRow: Bool {playQueueView.numberOfSelectedRows > 0}
    
    private var rowCount: Int {playQueueView.numberOfRows}
    
    private var atLeastOneRow: Bool {playQueueView.numberOfRows > 0}
    
    private var lastRow: Int {rowCount - 1}
    
    private let allColumns: IndexSet = [0, 1, 2]
    
    private lazy var fileOpenDialog = DialogsAndAlerts.openDialog
    
    private var viewControlButtons: [Tintable] = []
    private var functionButtons: [TintedImageButton] = []
    
    override func windowDidLoad() {
        
        playQueueView.enableDragDrop_reorderingAndFiles()
        
        viewControlButtons = [btnClose, viewMenuIconItem]
        
        changeTextSize(PlaylistViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        
        Messenger.subscribeAsync(self, .playQueue_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .playQueue_tracksAdded, self.tracksAdded(_:), queue: .main)
        
        // Only respond if the playing track was updated
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        
        Messenger.subscribe(self, .playQueue_addTracks, self.addTracks)
        Messenger.subscribe(self, .playQueue_removeTracks, self.removeSelectedTracks)
        Messenger.subscribe(self, .playQueue_clear, self.clear)
        
        Messenger.subscribe(self, .playQueue_moveTracksUp, self.moveTracksUp)
        Messenger.subscribe(self, .playQueue_moveTracksDown, self.moveTracksDown)
        Messenger.subscribe(self, .playQueue_moveTracksToTop, self.moveTracksToTop)
        Messenger.subscribe(self, .playQueue_moveTracksToBottom, self.moveTracksToBottom)
        
        updateSummary()
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the play queue.
    func addTracks() {
        
        if fileOpenDialog.runModal() == NSApplication.ModalResponse.OK {
            playQueue.addTracks(from: fileOpenDialog.urls)
        }
    }
    
    // NOTE - Assumes track was added at the end of the queue.
    func trackAdded(_ notification: PlayQueueTrackAddedNotification) {
        
        playQueueView.noteNumberOfRowsChanged()
        updateSummary()
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
        
        updateSummary()
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
    
    private func clearSelection() {
        playQueueView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
    }
    
    private func updateSummary() {
        
        let numTracks = playQueue.size
        lblTracksSummary.stringValue = String(format: "%d track%@", numTracks, numTracks == 1 ? "" : "s")
    }
    
    private func removeSelectedTracks() {
        
        let selectedRows = self.selectedRows
        
        // Ensure at least one selected row
        guard let firstRemovedRow = selectedRows.min() else {return}
        
        _ = playQueue.removeTracks(selectedRows)
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        playQueueView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        let lastPlaylistRowAfterRemove = playQueue.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playQueue.
        if firstRemovedRow <= lastPlaylistRowAfterRemove {
            
            // Refresh only the index column for all these rows
            let refreshIndexes = IndexSet(firstRemovedRow...lastPlaylistRowAfterRemove)
            playQueueView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: allColumns)
        }
        
        updateSummary()
        clearSelection()
    }
    
    func clear() {
        
        playQueue.clear()
        playQueueView.reloadData()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksUp() {
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        let results = playQueue.moveTracksUp(selectedRows)
        
        moveAndReloadItems(results.sorted(by: TrackMoveResult.compareAscending))
        playQueueView.scrollRowToVisible(selectedRows.min()!)
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksDown() {
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        let results = playQueue.moveTracksDown(selectedRows)
        
        moveAndReloadItems(results.sorted(by: TrackMoveResult.compareDescending))
        playQueueView.scrollRowToVisible(selectedRows.min()!)
    }
    
    // Rearranges tracks within the view that have been reordered
    private func moveAndReloadItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playQueueView.moveRow(at: result.sourceIndex, to: result.destinationIndex)
            playQueueView.reloadData(forRowIndexes: IndexSet([result.sourceIndex, result.destinationIndex]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksToTop() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = selectedRows.count
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        let results = playQueue.moveTracksToTop(selectedRows)
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: TrackMoveResult.compareAscending))
        
        // Refresh the relevant rows
        playQueueView.reloadData(forRowIndexes: IndexSet(0...selectedRows.max()!), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        
        // Select all the same rows but now at the top
        playQueueView.scrollRowToVisible(0)
        playQueueView.selectRowIndexes(IndexSet(0..<selectedRowCount), byExtendingSelection: false)
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksToBottom() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = selectedRows.count
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        let results = playQueue.moveTracksToBottom(selectedRows)
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: TrackMoveResult.compareDescending))
        
        // Refresh the relevant rows
        playQueueView.reloadData(forRowIndexes: IndexSet(selectedRows.min()!...lastRow), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        
        // Select all the same items but now at the bottom
        let firstSelectedRow = lastRow - selectedRowCount + 1
        playQueueView.scrollRowToVisible(lastRow)
        playQueueView.selectRowIndexes(IndexSet(firstSelectedRow...lastRow), byExtendingSelection: false)
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playQueueView.removeRows(at: IndexSet(integer: result.sourceIndex), withAnimation: result.movedUp ? .slideUp : .slideDown)
            playQueueView.insertRows(at: IndexSet(integer: result.destinationIndex), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
//        window?.close()
    }
    
    // MARK: Appearance
    
    private func changeTextSize(_ textSize: TextSize) {
        
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        scroller.redraw()
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
        
        playQueueView.enclosingScrollView?.backgroundColor = color
        playQueueView.backgroundColor = color
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        viewControlButtons.forEach {$0.reTint()}
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        functionButtons.forEach {$0.reTint()}
    }
}
