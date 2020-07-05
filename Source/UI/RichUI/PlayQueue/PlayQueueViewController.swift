import Cocoa

class PlayQueueViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var playQueueView: NSTableView!
    
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "PlayQueue"}
    
    private var selectedRows: IndexSet {playQueueView.selectedRowIndexes}
    
    private var selectedRowsArr: [Int] {playQueueView.selectedRowIndexes.toArray()}
    
    private var selectedRowCount: Int {playQueueView.numberOfSelectedRows}
    
    private var rowCount: Int {playQueueView.numberOfRows}
    
    private var atLeastOneRow: Bool {playQueueView.numberOfRows > 0}
    
    private var lastRow: Int {rowCount - 1}
    
    override func viewDidLoad() {
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .playlist_trackAdded, self.trackAdded(_:), queue: .main)
    }
    
    func trackAdded(_ notification: TrackAddedNotification) {
        playQueueView.insertRows(at: IndexSet(integer: notification.trackIndex), withAnimation: .slideDown)
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
        
        let refreshIndexes: IndexSet = IndexSet(Set([notification.beginTrack, notification.endTrack].compactMap {$0}).compactMap {playlist.indexOfTrack($0)})
//        let needToShowTrack: Bool = playQueueViewState.current == .tracks && preferences.showNewTrackInPlaylist
        let needToShowTrack: Bool = true

        if needToShowTrack {

            if let newTrack = notification.endTrack, let newTrackIndex = playlist.indexOfTrack(newTrack), newTrackIndex >= playQueueView.numberOfRows {

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
            self.playQueueView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: IndexSet(0..<self.playQueueView.tableColumns.count))
        }
    }
    
    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.currentTrack, let playingTrackIndex = playlist.indexOfTrack(playingTrack) {
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
}
