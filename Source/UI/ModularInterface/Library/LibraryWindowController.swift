import Cocoa

/*
    Window controller for the playlist window.
 */
class LibraryWindowController: NSWindowController, NSTabViewDelegate, NotificationSubscriber {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var playlistContainerBox: NSBox!
    
    @IBOutlet weak var tabButtonsBox: NSBox!
    @IBOutlet weak var btnTracksTab: NSButton!
    @IBOutlet weak var btnArtistsTab: NSButton!
    @IBOutlet weak var btnAlbumsTab: NSButton!
    @IBOutlet weak var btnGenresTab: NSButton!
    
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var controlButtonsSuperview: NSView!
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var viewMenuIconItem: TintedIconMenuItem!
    
    // The different playlist views
    private lazy var tracksViewController: LibraryTracksViewController = LibraryTracksViewController()
    private lazy var tracksView: NSView = tracksViewController.view
//    private lazy var artistsView: NSView = ViewFactory.artistsView
//    private lazy var albumsView: NSView = ViewFactory.albumsView
//    private lazy var genresView: NSView = ViewFactory.genresView
    
    @IBOutlet weak var contextMenu: NSMenu!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    // Spinner that shows progress when tracks are being added to the playlist
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var viewMenuButton: NSPopUpButton!
    
    // Search dialog
    private lazy var playlistSearchDialog: ModalDialogDelegate = WindowFactory.playlistSearchDialog
    
    // Sort dialog
    private lazy var playlistSortDialog: ModalDialogDelegate = WindowFactory.playlistSortDialog
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    // For gesture handling
    private var eventMonitor: Any?
    
    // Delegate that relays CRUD actions to the playlist
    private let library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let playlistPreferences: PlaylistPreferences = ObjectGraph.preferences.playlistPreferences
    
    private var theWindow: SnappingWindow {self.window! as! SnappingWindow}
    
    private lazy var fileOpenDialog = DialogsAndAlerts.openDialog
    private lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    override var windowNibName: String? {return "Library"}
    
    private var childContainerBoxes: [NSBox] = []
    private var viewControlButtons: [Tintable] = []
    private var functionButtons: [TintedImageButton] = []
    private var tabButtons: [NSButton] = []

    override func windowDidLoad() {
        
        theWindow.isMovableByWindowBackground = true
//        theWindow.delegate = WindowManager.windowDelegate
        
        btnClose.tintFunction = {return Colors.viewControlButtonColor}
        
        setUpTabGroup()
        
        childContainerBoxes = [playlistContainerBox, tabButtonsBox, controlsBox]
        viewControlButtons = [btnClose, viewMenuIconItem].compactMap {$0 as? Tintable}
        functionButtons = controlButtonsSuperview.subviews.compactMap {$0 as? TintedImageButton}
        tabButtons = [btnTracksTab, btnArtistsTab, btnAlbumsTab, btnGenresTab]

        changeTextSize(PlaylistViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    // Initialize all the tab views (and select the one preferred by the user)
    private func setUpTabGroup() {
        
//        tabGroup.addViewsForTabs([tracksView, artistsView, albumsView, genresView])
//        [1, 2, 3, 0].forEach({tabGroup.selectTabViewItem(at: $0)})
        
        tabGroup.addViewsForTabs([tracksView])
        [0].forEach({tabGroup.selectTabViewItem(at: $0)})
        
        tracksView.anchorToView(tabGroup.tabViewItem(at: 0).view!)
        
//        if playlistPreferences.viewOnStartup.option == .specific {
//            tabGroup.selectTabViewItem(at: playlistPreferences.viewOnStartup.viewIndex)
//
//        } else {    // Remember the view from the last app launch
//            tabGroup.selectTabViewItem(at: PlaylistViewState.current.index)
//        }
        
        tabGroup.delegate = self
    }
    
    private func initSubscriptions() {
        
        // Set up an input handler to handle scrolling and gestures
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.swipe], handler: {(event: NSEvent) -> NSEvent? in
            
            LibraryGestureHandler.handle(event)
            return event
        });
        
        Messenger.subscribeAsync(self, .playlist_startedAddingTracks, self.startedAddingTracks, queue: .main)
        Messenger.subscribeAsync(self, .playlist_doneAddingTracks, self.doneAddingTracks, queue: .main)
        
        Messenger.subscribeAsync(self, .playlist_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .playlist_tracksNotAdded, self.tracksNotAdded(_:), queue: .main)
        
        // MARK: Commands -------------------------------------------------------------------------------------
        
        Messenger.subscribe(self, .library_addTracks, self.addTracks)
        Messenger.subscribe(self, .library_clear, self.clearLibrary)
        
        Messenger.subscribe(self, .playlist_search, self.search)
        Messenger.subscribe(self, .playlist_sort, self.sort)
        
        Messenger.subscribe(self, .playlist_previousView, self.previousView)
        Messenger.subscribe(self, .playlist_nextView, self.nextView)
        
        Messenger.subscribe(self, .playlist_changeTextSize, self.changeTextSize(_:))
        
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        
        Messenger.subscribe(self, .changeViewControlButtonColor, self.changeViewControlButtonColor(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        
        Messenger.subscribe(self, .changeTabButtonTextColor, self.changeTabButtonTextColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonColor, self.changeSelectedTabButtonColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonTextColor, self.changeSelectedTabButtonTextColor(_:))
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        Messenger.publish(.windowManager_togglePlaylistWindow)
    }
    
    private func checkIfLibraryIsBeingModified() -> Bool {
        
        let libraryBeingModified = library.isBeingModified
        
        if libraryBeingModified {
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
        }
        
        return libraryBeingModified
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        if !checkIfLibraryIsBeingModified() {
            addTracks()
        }
    }
    
    private func addTracks() {
        
        if fileOpenDialog.runModal() == NSApplication.ModalResponse.OK {
            library.addFiles(fileOpenDialog.urls)
        }
    }
    
    // When a track add operation starts, the progress spinner needs to be initialized
    func startedAddingTracks() {
        
        progressSpinner.doubleValue = 0
        progressSpinner.show()
        progressSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the progress spinner needs to be de-initialized
    func doneAddingTracks() {
        
        progressSpinner.stopAnimation(self)
        progressSpinner.hide()
    }
    
    // Handles an error when tracks could not be added to the playlist
    func tracksNotAdded(_ errors: [DisplayableError]) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            _ = UIUtils.showAlert(DialogsAndAlerts.tracksNotAddedAlertWithErrors(errors))
        }
    }
    
    // Handles a notification that a single track has been added to the playlist
    func trackAdded(_ notification: PlaylistTrackAddedNotification) {
        
        // Update spinner with current progress, if tracks are being added
        progressSpinner.doubleValue = notification.addOperationProgress.percentage
    }

    // Removes selected items from the current playlist view. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        guard !checkIfLibraryIsBeingModified() else {return}
        
        Messenger.publish(.library_removeTracks, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    // Removes all items from the playlist
    @IBAction func clearLibraryAction(_ sender: AnyObject) {
        
        if !checkIfLibraryIsBeingModified() {
            clearLibrary()
        }
    }
    
    private func clearLibrary() {
        
        library.clear()
        
        // Tell all playlist views to refresh themselves
        Messenger.publish(.library_refresh, payload: PlaylistViewSelector.allViews)
    }
    
    // Moves any selected playlist items up one row in the library. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        if !checkIfLibraryIsBeingModified() {
            Messenger.publish(.playlist_moveTracksUp, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    // Moves any selected playlist items down one row in the library. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        if !checkIfLibraryIsBeingModified() {
            Messenger.publish(.playlist_moveTracksDown, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    private func nextView() {
        PlaylistViewState.current == .genres ? tabGroup.selectFirstTabViewItem(self) : tabGroup.selectNextTabViewItem(self)
    }
    
    private func previousView() {
        PlaylistViewState.current == .tracks ? tabGroup.selectLastTabViewItem(self) : tabGroup.selectPreviousTabViewItem(self)
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func searchAction(_ sender: AnyObject) {
        search()
    }
    
    private func search() {
        _ = playlistSearchDialog.showDialog()
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func sortAction(_ sender: AnyObject) {
        
        if !checkIfLibraryIsBeingModified() {
            sort()
        }
    }
    
    private func sort() {
        _ = playlistSortDialog.showDialog()
    }
    
    // MARK: Playlist window actions
    
    // Scrolls the playlist view to the top
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_scrollToTop, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    // Scrolls the playlist view to the bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_scrollToBottom, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func pageUpAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_pageUp, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func pageDownAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_pageDown, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    private func changeTextSize(_ textSize: TextSize) {
        
        redrawTabButtons()
        viewMenuButton.font = Fonts.Playlist.menuFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
     
        for box in childContainerBoxes {
            
            box.fillColor = color
            box.isTransparent = !color.isOpaque
        }
        
        redrawTabButtons()
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        viewControlButtons.forEach {$0.reTint()}
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        functionButtons.forEach {$0.reTint()}
    }
    
    private func redrawTabButtons() {
        tabButtons.forEach {$0.redraw()}
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        redrawSelectedTabButton()
    }
    
    private func changeTabButtonTextColor(_ color: NSColor) {
        redrawTabButtons()
    }
    
    private func changeSelectedTabButtonTextColor(_ color: NSColor) {
        redrawSelectedTabButton()
    }
    
    private func redrawSelectedTabButton() {
        (tabGroup.selectedTabViewItem as? AuralTabViewItem)?.tabButton.redraw()
    }
}
