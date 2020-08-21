import Cocoa

class LibraryMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var theMenu: NSMenuItem!
    
//    @IBOutlet weak var playSelectedItemMenuItem: NSMenuItem!

    @IBOutlet weak var clearLibraryMenuItem: NSMenuItem!
    @IBOutlet weak var removeSelectedItemsMenuItem: NSMenuItem!
    
//    @IBOutlet weak var clearSelectionMenuItem: NSMenuItem!
//    @IBOutlet weak var invertSelectionMenuItem: NSMenuItem!
//    @IBOutlet weak var cropSelectionMenuItem: NSMenuItem!
//
//    @IBOutlet weak var searchLibraryMenuItem: NSMenuItem!
//    @IBOutlet weak var sortLibraryMenuItem: NSMenuItem!
//
//    @IBOutlet weak var scrollToTopMenuItem: NSMenuItem!
//    @IBOutlet weak var scrollToBottomMenuItem: NSMenuItem!
//    @IBOutlet weak var pageUpMenuItem: NSMenuItem!
//    @IBOutlet weak var pageDownMenuItem: NSMenuItem!
//    @IBOutlet weak var previousViewMenuItem: NSMenuItem!
//    @IBOutlet weak var nextViewMenuItem: NSMenuItem!
    
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private lazy var gapsEditor: ModalDialogDelegate = WindowFactory.gapsEditorDialog
    private lazy var delayedPlaybackEditor: ModalDialogDelegate = WindowFactory.delayedPlaybackEditorDialog
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    func menuNeedsUpdate(_ menu: NSMenu) {
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        
        if !checkIfLibraryIsBeingModified() {
            Messenger.publish(.library_addTracks)
        }
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        
        if !checkIfLibraryIsBeingModified() {
            Messenger.publish(.library_removeTracks)
        }
    }
    
    @IBAction func clearLibraryAction(_ sender: Any) {

        if !checkIfLibraryIsBeingModified() {
            Messenger.publish(.library_clear)
        }
    }

//    // Presents the search modal dialog to allow the user to search for playlist tracks
//    @IBAction func playlistSearchAction(_ sender: Any) {
//        Messenger.publish(.playlist_search)
//    }
//
//    // Presents the sort modal dialog to allow the user to sort playlist tracks
//    @IBAction func playlistSortAction(_ sender: Any) {
//
//        if !checkIfLibraryIsBeingModified() {
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
//            Messenger.publish(.playlist_playSelectedItem, payload: LibraryViewSelector.forView(PlaylistViewState.current))
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
//                                                                 viewSelector: LibraryViewSelector.forView(PlaylistViewState.current)))
//        }
//    }
//
//    @IBAction func clearSelectionAction(_ sender: Any) {
//        Messenger.publish(.playlist_clearSelection, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func invertSelectionAction(_ sender: Any) {
//        Messenger.publish(.playlist_invertSelection, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func cropSelectionAction(_ sender: Any) {
//
//        if !checkIfLibraryIsBeingModified() {
//            Messenger.publish(.playlist_cropSelection, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//        }
//    }
//
//    @IBAction func expandSelectedGroupsAction(_ sender: Any) {
//        Messenger.publish(.playlist_expandSelectedGroups, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func collapseSelectedItemsAction(_ sender: Any) {
//        Messenger.publish(.playlist_collapseSelectedItems, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func expandAllGroupsAction(_ sender: Any) {
//        Messenger.publish(.playlist_expandAllGroups, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func collapseAllGroupsAction(_ sender: Any) {
//        Messenger.publish(.playlist_collapseAllGroups, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    // Scrolls the current playlist view to the very top
//    @IBAction func scrollToTopAction(_ sender: Any) {
//        Messenger.publish(.playlist_scrollToTop, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    // Scrolls the current playlist view to the very bottom
//    @IBAction func scrollToBottomAction(_ sender: Any) {
//        Messenger.publish(.playlist_scrollToBottom, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func pageUpAction(_ sender: Any) {
//        Messenger.publish(.playlist_pageUp, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//    @IBAction func pageDownAction(_ sender: Any) {
//        Messenger.publish(.playlist_pageDown, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func previousLibraryViewAction(_ sender: Any) {
//        Messenger.publish(.playlist_previousView)
//    }
//
//    @IBAction func nextLibraryViewAction(_ sender: Any) {
//        Messenger.publish(.playlist_nextView)
//    }
    
    private func checkIfLibraryIsBeingModified() -> Bool {
        
        let libraryBeingModified = library.isBeingModified

        if libraryBeingModified {
            
            alertDialog.showAlert(.error, "Library not modified", "The library cannot be modified while tracks are being added", "Please wait till the library is done adding tracks ...")
        }

        return libraryBeingModified
    }

}
