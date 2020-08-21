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
    
    // Invokes the Open file dialog, to allow the user to add tracks/librarys to the app library
    @IBAction func addFilesAction(_ sender: Any) {
        
        if !checkIfLibraryIsBeingModified() {
            Messenger.publish(.library_addTracks)
        }
    }
    
    // Removes any selected library items from the library
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
    
    // MARK: Playback actions -----------------------------------------------------------------
    
    @IBAction func playNowAction(_ sender: AnyObject) {
        Messenger.publish(.library_playNow)
    }
    
    @IBAction func playNextAction(_ sender: AnyObject) {
        Messenger.publish(.library_playNext)
    }
    
    @IBAction func playLaterAction(_ sender: AnyObject) {
        Messenger.publish(.library_playLater)
    }
    
    // MARK: Actions related to track selection -----------------------------------------------------------------
    
    @IBAction func clearSelectionAction(_ sender: Any) {
        Messenger.publish(.library_clearSelection, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func invertSelectionAction(_ sender: Any) {
        Messenger.publish(.library_invertSelection, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        
        if !checkIfLibraryIsBeingModified() {
            Messenger.publish(.library_cropSelection, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    // MARK: View scrolling actions -----------------------------------------------------------------
    
    // Scrolls the current library view to the very top
    @IBAction func scrollToTopAction(_ sender: Any) {
        Messenger.publish(.library_scrollToTop, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    // Scrolls the current library view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: Any) {
        Messenger.publish(.library_scrollToBottom, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func pageUpAction(_ sender: Any) {
        Messenger.publish(.library_pageUp, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    @IBAction func pageDownAction(_ sender: Any) {
        Messenger.publish(.library_pageDown, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }

//    // Presents the search modal dialog to allow the user to search for library tracks
//    @IBAction func librarySearchAction(_ sender: Any) {
//        Messenger.publish(.library_search)
//    }
//
//    // Presents the sort modal dialog to allow the user to sort library tracks
//    @IBAction func librarySortAction(_ sender: Any) {
//
//        if !checkIfLibraryIsBeingModified() {
//            Messenger.publish(.library_sort)
//        }
//    }
//
//    // Plays the selected library item (track or group)
//    @IBAction func playSelectedItemAction(_ sender: Any) {
//
//        if WindowManager.isChaptersListWindowKey {
//            Messenger.publish(.chaptersList_playSelectedChapter)
//
//        } else {
//            Messenger.publish(.library_playSelectedItem, payload: LibraryViewSelector.forView(PlaylistViewState.current))
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
//        Messenger.publish(.library_clearSelection, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func invertSelectionAction(_ sender: Any) {
//        Messenger.publish(.library_invertSelection, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func cropSelectionAction(_ sender: Any) {
//
//        if !checkIfLibraryIsBeingModified() {
//            Messenger.publish(.library_cropSelection, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//        }
//    }
//
//    @IBAction func expandSelectedGroupsAction(_ sender: Any) {
//        Messenger.publish(.library_expandSelectedGroups, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func collapseSelectedItemsAction(_ sender: Any) {
//        Messenger.publish(.library_collapseSelectedItems, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func expandAllGroupsAction(_ sender: Any) {
//        Messenger.publish(.library_expandAllGroups, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func collapseAllGroupsAction(_ sender: Any) {
//        Messenger.publish(.library_collapseAllGroups, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    // Scrolls the current library view to the very top
//    @IBAction func scrollToTopAction(_ sender: Any) {
//        Messenger.publish(.library_scrollToTop, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    // Scrolls the current library view to the very bottom
//    @IBAction func scrollToBottomAction(_ sender: Any) {
//        Messenger.publish(.library_scrollToBottom, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func pageUpAction(_ sender: Any) {
//        Messenger.publish(.library_pageUp, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//    @IBAction func pageDownAction(_ sender: Any) {
//        Messenger.publish(.library_pageDown, payload: LibraryViewSelector.forView(PlaylistViewState.current))
//    }
//
//    @IBAction func previousLibraryViewAction(_ sender: Any) {
//        Messenger.publish(.library_previousView)
//    }
//
//    @IBAction func nextLibraryViewAction(_ sender: Any) {
//        Messenger.publish(.library_nextView)
//    }
    
    private func checkIfLibraryIsBeingModified() -> Bool {
        
        let libraryBeingModified = library.isBeingModified

        if libraryBeingModified {
            
            alertDialog.showAlert(.error, "Library not modified", "The library cannot be modified while tracks are being added", "Please wait till the library is done adding tracks ...")
        }

        return libraryBeingModified
    }

}
