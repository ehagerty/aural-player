import Cocoa

class AuralViewController: NSViewController, NotificationSubscriber {
    
    override func viewDidLoad() {
        
        initializeUI()
        initializeSubscriptions()
    }
    
    func initializeUI() {}
    func initializeSubscriptions() {}
}

class LibraryTracksViewController: AuralViewController {
    
    @IBOutlet weak var libraryView: NSTableView!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    private let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "LibraryTracks"}
    
    private var selectedRows: IndexSet {libraryView.selectedRowIndexes}
    
    private var selectedRowsArr: [Int] {libraryView.selectedRowIndexes.toArray()}
    
    private var selectedRowCount: Int {libraryView.numberOfSelectedRows}
    
    private var atLeastOneSelectedRow: Bool {libraryView.numberOfSelectedRows > 0}
    
    private var rowCount: Int {libraryView.numberOfRows}
    
    private var atLeastOneRow: Bool {libraryView.numberOfRows > 0}
    
    private var lastRow: Int {rowCount - 1}
    
    override func initializeUI() {
        
        updateSummary()
        libraryView.enableDragDrop_files()
    }
    
    override func initializeSubscriptions() {
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .library_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .library_tracksRemoved, self.tracksRemoved(_:), queue: .main)
        
        Messenger.subscribe(self, .library_removeTracks, self.removeSelectedTracks)
    }
    
    func trackAdded(_ notification: LibraryTrackAddedNotification) {
        
        libraryView.noteNumberOfRowsChanged()
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
        
        if let firstSelectedRow = libraryView.selectedRowIndexes.min() {
            Messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow, delay: delay))
        }
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        let refreshIndexes: IndexSet = IndexSet(Set([notification.beginTrack, notification.endTrack].compactMap {$0}).compactMap {library.indexOfTrack($0)})
        //        let needToShowTrack: Bool = playQueueViewState.current == .tracks && preferences.showNewTrackInPlaylist
        let needToShowTrack: Bool = true
        
        if needToShowTrack {
            
            if let newTrack = notification.endTrack, let newTrackIndex = library.indexOfTrack(newTrack), newTrackIndex >= libraryView.numberOfRows {
                
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
            self.libraryView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: IndexSet(0..<self.libraryView.tableColumns.count))
        }
    }
    
    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.currentTrack, let playingTrackIndex = library.indexOfTrack(playingTrack) {
            selectTrack(playingTrackIndex)
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ index: Int) {
        
        if index >= 0 && index < rowCount {
            
            libraryView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            libraryView.scrollRowToVisible(index)
        }
    }
    
    private func clearSelection() {
        libraryView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
    }
    
    private func updateSummary() {
        
        let numTracks = library.size
        lblTracksSummary.stringValue = String(format: "%d track%@", numTracks, numTracks == 1 ? "" : "s")
    }
    
    private func removeSelectedTracks() {
        
        if atLeastOneSelectedRow {
            
            library.removeTracks(selectedRows)
            clearSelection()
        }
    }
    
    private func tracksRemoved(_ results: TrackRemovalResults) {
        
        let indexes = results.flatPlaylistResults
        guard !indexes.isEmpty else {return}
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        libraryView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        let firstRemovedRow = indexes.min()!
        let lastPlaylistRowAfterRemove = library.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playlist.
        if firstRemovedRow <= lastPlaylistRowAfterRemove {
            
            let refreshIndexes = IndexSet(firstRemovedRow...lastPlaylistRowAfterRemove)
            libraryView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: IndexSet(0..<self.libraryView.tableColumns.count))
        }
        
        updateSummary()
    }
    
    // MARK: Context menu handling -----------------------------------------------------------------
    
    private var selectedTracks: [Track] {
        libraryView.selectedRowIndexes.compactMap {self.library.trackAtIndex($0)}
    }
    
    @IBAction func playNow(_ sender: AnyObject) {
//        print("\nPLAY NOW")
        _ = playQueue.enqueueToPlayNow(selectedTracks)
    }
    
    @IBAction func playNext(_ sender: AnyObject) {
//        print("\nPLAY NEXT")
        _ = playQueue.enqueueToPlayNext(selectedTracks)
    }
    
    @IBAction func playLater(_ sender: AnyObject) {
//        print("\nPLAY LATER")
        _ = playQueue.enqueueToPlayLater(selectedTracks)
    }
}
