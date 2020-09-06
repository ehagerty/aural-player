import Cocoa

class PlayQueueWindowController: NSWindowController, NSTabViewDelegate, NotificationSubscriber {
    
    override var windowNibName: String? {return "PlayQueue"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var viewMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var btnListView: NSButton!
    @IBOutlet weak var btnTableView: NSButton!
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    private lazy var listViewController: PlayQueueListViewController = PlayQueueListViewController()
    private lazy var listView: NSView = listViewController.view
    
    private lazy var tableViewController: PlayQueueTableViewController = PlayQueueTableViewController()
    private lazy var tableView: NSView = tableViewController.view
    
    private var viewControllers: [PlayQueueViewController] = []
    private var currentViewController: PlayQueueViewController {tabView.selectedIndex == 0 ? listViewController : tableViewController}
    
    private let playQueue: PlayQueueDelegateProtocol = ObjectGraph.playQueueDelegate
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private lazy var fileOpenDialog = DialogsAndAlerts.openDialog
    
    private var viewControlButtons: [Tintable] = []
    private var functionButtons: [TintedImageButton] = []
    
    override func windowDidLoad() {
        
        viewControlButtons = [btnClose, viewMenuIconItem]
        viewControllers = [listViewController, tableViewController]
        
        changeTextSize(PlaylistViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        tabView.addViewsForTabs([listView, tableView])
        listView.anchorToView(tabView.tabViewItem(at: 0).view!)
        tableView.anchorToView(tabView.tabViewItem(at: 1).view!)
        
        (PlayQueueUIState.view == .list ? [1, 0] : [0, 1]).forEach({tabView.selectTabViewItem(at: $0)})
        
        Messenger.subscribeAsync(self, .playQueue_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .playQueue_tracksAdded, self.tracksAdded(_:), queue: .main)
        
        // Only respond if the playing track was updated
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        
        Messenger.subscribe(self, .playQueue_addTracks, self.addTracks)
        
        Messenger.subscribe(self, .playQueue_exportAsPlaylistFile, self.exportToPlaylist)
        Messenger.subscribe(self, .playQueue_clear, self.clear)
        
        Messenger.subscribe(self, .playlist_changeTextSize, self.changeTextSize(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        
        Messenger.subscribe(self, .application_exitRequest, self.onAppExit(_:))
        
        updateSummary()
    }
    
    private func onAppExit(_ request: AppExitRequestNotification) {
        
        PlayQueueUIState.view = tabView.selectedIndex == 0 ? .list : .table
        request.acceptResponse(okToExit: true)
    }

    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addTracksAction(_ sender: AnyObject) {
        addTracks()
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the play queue.
    func addTracks() {
        
        if fileOpenDialog.runModal() == NSApplication.ModalResponse.OK {
            playQueue.addTracks(from: fileOpenDialog.urls)
        }
    }
    
    // NOTE - Assumes track was added at the end of the queue.
    func trackAdded(_ notification: PlayQueueTrackAddedNotification) {
        updateSummary()
    }
    
    func tracksAdded(_ notification: PlayQueueTracksAddedNotification) {
        updateSummary()
    }
    
    private func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        updateSummary()
    }
   
    private func updateSummary() {
        
        let summary = playQueue.summary
        let numTracks = summary.size
        
        lblTracksSummary.stringValue = String(format: "%d track%@", numTracks, numTracks == 1 ? "" : "s")
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(summary.totalDuration)
    }
    
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        let selectedRows = currentViewController.selectedRows
        
        if !selectedRows.isEmpty {
            
            _ = playQueue.removeTracks(selectedRows)
            
            viewControllers.forEach {$0.tracksRemoved(fromRows: selectedRows)}
            updateSummary()
        }
    }
    
    @IBAction func exportToPlaylistAction(_ sender: AnyObject) {
        exportToPlaylist()
    }
    
    private func exportToPlaylist() {
        
        //        if playlist.isBeingModified {
        //
        //            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
        //            return
        //        }
        
        // Make sure there is at least one track to save
        if playQueue.size > 0 {
            
            let dialog = DialogsAndAlerts.savePlaylistDialog
            if dialog.runModal() == NSApplication.ModalResponse.OK, let file = dialog.url {
                playQueue.export(to: file)
            }
        }
    }
    
    @IBAction func clearAction(_ sender: AnyObject) {
        clear()
    }
    
    func clear() {
        
        playQueue.clear()
        viewControllers.forEach {$0.refreshTableView()}
        updateSummary()
    }
    
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        let rowCount = currentViewController.rowCount
        let selectedRows = currentViewController.selectedRows
        let selectedRowCount = selectedRows.count
        
        if rowCount > 1 && (1..<rowCount).contains(selectedRowCount) {
            
            let results = playQueue.moveTracksUp(selectedRows)
            if !results.isEmpty {
                viewControllers.forEach {$0.tracksMovedUp(results: results)}
            }
        }
    }
    
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        let rowCount = currentViewController.rowCount
        let selectedRows = currentViewController.selectedRows
        let selectedRowCount = selectedRows.count
        
        if rowCount > 1 && (1..<rowCount).contains(selectedRowCount) {
            
            let results = playQueue.moveTracksDown(selectedRows)
            if !results.isEmpty {
                viewControllers.forEach {$0.tracksMovedDown(results: results)}
            }
        }
    }
  
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        window?.close()
    }
    
    // MARK: Appearance
    
    private func changeTextSize(_ textSize: TextSize) {
        
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        rootContainerBox.fillColor = color
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        viewControlButtons.forEach {$0.reTint()}
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        functionButtons.forEach {$0.reTint()}
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
    }
}
