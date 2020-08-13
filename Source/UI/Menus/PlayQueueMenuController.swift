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
    
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private lazy var gapsEditor: ModalDialogDelegate = WindowFactory.gapsEditorDialog
    private lazy var delayedPlaybackEditor: ModalDialogDelegate = WindowFactory.delayedPlaybackEditorDialog
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    func menuNeedsUpdate(_ menu: NSMenu) {

        let showingModalComponent = WindowManager.isShowingModalComponent
        
//        if WindowManager.isChaptersListWindowKey {
//
//            // If the chapters list window is key, most playlist menu items need to be disabled
//            menu.items.forEach({$0.disable()})
//
//            // Allow playing of selected item (chapter) if the chapters list is not modal (i.e. performing a search) and an item is selected
//            let hasPlayableChapter: Bool = !showingModalComponent && PlaylistViewState.hasSelectedChapter
//
//            playSelectedItemMenuItem.enableIf(hasPlayableChapter)
//            theMenu.enableIf(hasPlayableChapter)
//
//            // Since all items but one have been disabled, nothing further to do
//            return
//
//        } else {
//
//            // Re-enabled items that may have been disabled before
//            menu.items.forEach({$0.enable()})
//        }
//
//        theMenu.enableIf(WindowManager.isShowingPlaylist)
//        if theMenu.isDisabled {return}
        
        // TODO: Revisit the below item enabling code (esp. the ones relying on no modal window). How to display modal windows so as to avoid
        // this dirty logic ???
        
//        let playlistSize = playlist.size
//        let playlistNotEmpty = playlistSize > 0
        
        let numSelectedRows = PlaylistViewState.selectedItemCount
        let atLeastOneItemSelected = numSelectedRows > 0
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one playlist item to be selected
        
        [removeSelectedItemsMenuItem].forEach({$0?.enableIf(!showingModalComponent && atLeastOneItemSelected)})
        
//        [previousViewMenuItem, nextViewMenuItem].forEach({$0?.enableIf(!showingModalComponent)})
//
//        playSelectedItemMenuItem.enableIf(!showingModalComponent && numSelectedRows == 1)
//
//        if numSelectedRows == 1 && selectedTrack == playbackInfo.transcodingTrack {
//            playSelectedItemMenuItem.disable()
//        }
//
//        // These menu items require 1 - the playlist to be visible, and 2 - at least one track in the playlist
//        [searchPlayQueueMenuItem, sortPlayQueueMenuItem, scrollToTopMenuItem, scrollToBottomMenuItem, pageUpMenuItem, pageDownMenuItem, savePlayQueueMenuItem, clearPlayQueueMenuItem, invertSelectionMenuItem].forEach({$0?.enableIf(playlistNotEmpty)})
//
//        // At least 2 tracks needed for these functions, and at least one track selected
//        [moveItemsToTopMenuItem, moveItemsToBottomMenuItem, cropSelectionMenuItem].forEach({$0?.enableIf(playlistSize > 1 && atLeastOneItemSelected)})
//
//        clearSelectionMenuItem.enableIf(playlistNotEmpty && atLeastOneItemSelected)
    }
    
//    func menuWillOpen(_ menu: NSMenu) {
//        if theMenu.isDisabled {return}
//    }
    
    // Assumes only one item selected, and that it's a track
    private var selectedTrack: Track? {
        
        if let selItem = PlaylistViewState.selectedItem {
            
            if selItem.type == .index, let index = selItem.index {
                return playlist.trackAtIndex(index)
            }
            
            return selItem.track
        }
        
        return nil
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        
//        if !checkIfPlayQueueIsBeingModified() {
//            Messenger.publish(.playlist_addTracks)
//        }
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        
        Messenger.publish(.library_removeTracks)

//        if !checkIfPlayQueueIsBeingModified() {
//            
//        }
    }
//
//    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
//    @IBAction func savePlayQueueAction(_ sender: Any) {
//        Messenger.publish(.playlist_savePlayQueue)
//    }
//
//    // Removes all items from the playlist
//    @IBAction func clearPlayQueueAction(_ sender: Any) {
//
//        if !checkIfPlayQueueIsBeingModified() {
//            Messenger.publish(.playlist_clearPlayQueue)
//        }
//    }
//
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
        
        let playlistBeingModified = playlist.isBeingModified
        
        if playlistBeingModified {
            alertDialog.showAlert(.error, "PlayQueue not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
        }
        
        return playlistBeingModified
    }

}
