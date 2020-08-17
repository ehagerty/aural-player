import Cocoa

class PlayQueueMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var theMenu: NSMenuItem!
    
    @IBOutlet weak var playSelectedItemMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveItemsUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsToBottomMenuItem: NSMenuItem!
    @IBOutlet weak var removeSelectedItemsMenuItem: NSMenuItem!
    
    @IBOutlet weak var clearSelectionMenuItem: NSMenuItem!
    @IBOutlet weak var invertSelectionMenuItem: NSMenuItem!
    @IBOutlet weak var cropSelectionMenuItem: NSMenuItem!
    
    @IBOutlet weak var savePlayQueueMenuItem: NSMenuItem!
    @IBOutlet weak var clearPlayQueueMenuItem: NSMenuItem!
    
    @IBOutlet weak var searchPlayQueueMenuItem: NSMenuItem!
    @IBOutlet weak var sortPlayQueueMenuItem: NSMenuItem!
    
    @IBOutlet weak var scrollToTopMenuItem: NSMenuItem!
    @IBOutlet weak var scrollToBottomMenuItem: NSMenuItem!
    @IBOutlet weak var pageUpMenuItem: NSMenuItem!
    @IBOutlet weak var pageDownMenuItem: NSMenuItem!
    @IBOutlet weak var previousViewMenuItem: NSMenuItem!
    @IBOutlet weak var nextViewMenuItem: NSMenuItem!
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private lazy var gapsEditor: ModalDialogDelegate = WindowFactory.gapsEditorDialog
    private lazy var delayedPlaybackEditor: ModalDialogDelegate = WindowFactory.delayedPlaybackEditorDialog
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    func menuNeedsUpdate(_ menu: NSMenu) {
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_addTracks)
        }
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func exportPlayQueueAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_exportAsPlaylistFile)
        }
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_removeTracks)
        }
    }
    
    @IBAction func clearPlayQueueAction(_ sender: Any) {

        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_clear)
        }
    }

    // Moves any selected playlist items up one row in the playlist
    @IBAction func moveItemsUpAction(_ sender: Any) {

        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_moveTracksUp)
        }
    }

    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToTopAction(_ sender: Any) {

        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_moveTracksToTop)
        }
    }

    // Moves any selected playlist items down one row in the playlist
    @IBAction func moveItemsDownAction(_ sender: Any) {

        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_moveTracksDown)
        }
    }

    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToBottomAction(_ sender: Any) {

        if !checkIfPlayQueueIsBeingModified() {
            Messenger.publish(.playQueue_moveTracksToBottom)
        }
    }
//
//    @IBAction func insertGapsAction(_ sender: NSMenuItem) {
//
//        guard !checkIfPlayQueueIsBeingModified() else {return}
//
//        // Sender's tag is gap duration in seconds
//        let tag = sender.tag
//
//        if tag != 0 {
//
//            // Negative tag value indicates .beforeTrack, positive value indicates .afterTrack
//            let gapPosn: PlaybackGapPosition = tag < 0 ? .beforeTrack: .afterTrack
//            let gap = PlaybackGap(Double(abs(tag)), gapPosn)
//
//            let gapBefore = gapPosn == .beforeTrack ? gap : nil
//            let gapAfter = gapPosn == .afterTrack ? gap : nil
//
//            Messenger.publish(InsertPlaybackGapsCommandNotification(gapBeforeTrack: gapBefore, gapAfterTrack: gapAfter,
//                                                                    viewSelector: PlayQueueViewSelector.forView(PlaylistViewState.current)))
//
//        } else {
//
//            gapsEditor.setDataForKey("gaps", nil)
//            _ = gapsEditor.showDialog()
//        }
//    }
//
//    @IBAction func editGapsAction(_ sender: NSMenuItem) {
//
//        if !checkIfPlayQueueIsBeingModified(), let track = selectedTrack {
//
//            let gaps = playlist.getGapsAroundTrack(track)
//
//            gapsEditor.setDataForKey("gaps", gaps)
//            _ = gapsEditor.showDialog()
//        }
//    }
//
//    @IBAction func removeGapsAction(_ sender: NSMenuItem) {
//
//        if !checkIfPlayQueueIsBeingModified() {
//            Messenger.publish(.playlist_removeGaps, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//        }
//    }
//
//    // Presents the search modal dialog to allow the user to search for playlist tracks
//    @IBAction func playlistSearchAction(_ sender: Any) {
//        Messenger.publish(.playlist_search)
//    }
//
//    // Presents the sort modal dialog to allow the user to sort playlist tracks
//    @IBAction func playlistSortAction(_ sender: Any) {
//
//        if !checkIfPlayQueueIsBeingModified() {
//            Messenger.publish(.playlist_sort)
//        }
//    }
//
//    // Plays the selected playlist item (track or group)
//    @IBAction func playSelectedItemAction(_ sender: Any) {
//
//        if WindowManager.isChaptersListWindowKey {
//            Messenger.publish(.chaptersList_playSelectedChapter)
//
//        } else {
//            Messenger.publish(.playlist_playSelectedItem, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//        }
//    }
//
//    @IBAction func playSelectedItemAfterDelayAction(_ sender: NSMenuItem) {
//
//        let delay = sender.tag
//
//        if delay == 0 {
//
//            // Custom delay ... show dialog
//            _ = delayedPlaybackEditor.showDialog()
//
//        } else {
//
//            Messenger.publish(DelayedPlaybackCommandNotification(delay: Double(delay),
//                                                                 viewSelector: PlayQueueViewSelector.forView(PlaylistViewState.current)))
//        }
//    }
//
//    @IBAction func clearSelectionAction(_ sender: Any) {
//        Messenger.publish(.playlist_clearSelection, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func invertSelectionAction(_ sender: Any) {
//        Messenger.publish(.playlist_invertSelection, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func cropSelectionAction(_ sender: Any) {
//
//        if !checkIfPlayQueueIsBeingModified() {
//            Messenger.publish(.playlist_cropSelection, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//        }
//    }
//
//    @IBAction func expandSelectedGroupsAction(_ sender: Any) {
//        Messenger.publish(.playlist_expandSelectedGroups, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func collapseSelectedItemsAction(_ sender: Any) {
//        Messenger.publish(.playlist_collapseSelectedItems, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func expandAllGroupsAction(_ sender: Any) {
//        Messenger.publish(.playlist_expandAllGroups, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func collapseAllGroupsAction(_ sender: Any) {
//        Messenger.publish(.playlist_collapseAllGroups, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    // Scrolls the current playlist view to the very top
//    @IBAction func scrollToTopAction(_ sender: Any) {
//        Messenger.publish(.playlist_scrollToTop, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    // Scrolls the current playlist view to the very bottom
//    @IBAction func scrollToBottomAction(_ sender: Any) {
//        Messenger.publish(.playlist_scrollToBottom, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func pageUpAction(_ sender: Any) {
//        Messenger.publish(.playlist_pageUp, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//    @IBAction func pageDownAction(_ sender: Any) {
//        Messenger.publish(.playlist_pageDown, payload: PlayQueueViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func previousPlayQueueViewAction(_ sender: Any) {
//        Messenger.publish(.playlist_previousView)
//    }
//
//    @IBAction func nextPlayQueueViewAction(_ sender: Any) {
//        Messenger.publish(.playlist_nextView)
//    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
//        let playlistBeingModified = playlist.isBeingModified
//
//        if playlistBeingModified {
//            alertDialog.showAlert(.error, "PlayQueue not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
//        }
//
//        return playlistBeingModified
        return false
    }

}
