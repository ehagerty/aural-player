import Cocoa

class TuneBrowserWindowController: NSWindowController, NSMenuDelegate, NotificationSubscriber, Destroyable {
    
    override var windowNibName: String? {"TuneBrowser"}
    
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    @IBOutlet weak var browserViewDelegate: TuneBrowserViewDelegate!
    
    @IBOutlet weak var sidebarView: TuneBrowserOutlineView!
    
    @IBOutlet weak var pathControlWidget: NSPathControl! {
        
        didSet {
            pathControlWidget.url = fileSystem.rootURL
        }
    }
    
    private lazy var fileSystem: FileSystem = ObjectGraph.fileSystem
    
    // Delegate that relays CRUD actions to the playlist
    private lazy var playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    override func awakeFromNib() {
        
        var displayedColumnIds: [String] = TuneBrowserState.displayedColumns.map {$0.id}
        
        // Show default columns if none have been selected (eg. first time app is launched).
        if displayedColumnIds.isEmpty {
            displayedColumnIds = [NSUserInterfaceItemIdentifier.uid_tuneBrowserName.rawValue]
        }
        
        for column in browserView.tableColumns {
//            column.headerCell = LibraryTableHeaderCell(stringValue: column.headerCell.stringValue)
            column.isHidden = !displayedColumnIds.contains(column.identifier.rawValue)
        }
        
        for (index, columnId) in displayedColumnIds.enumerated() {
            
            let oldIndex = browserView.column(withIdentifier: NSUserInterfaceItemIdentifier(columnId))
            browserView.moveColumn(oldIndex, toColumn: index)
        }
        
        var windowFrame = self.window!.frame
        windowFrame.size = TuneBrowserState.windowSize
        self.window?.setFrame(windowFrame, display: true)
        
        for column in TuneBrowserState.displayedColumns {
            browserView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(column.id))?.width = column.width
        }
    }
    
    private func onAppExit(_ request: AppExitRequestNotification) {
        
        TuneBrowserState.windowSize = self.window!.frame.size
        
        TuneBrowserState.displayedColumns = browserView.tableColumns.filter {$0.isShown}.map {DisplayedTableColumn(id: $0.identifier.rawValue, width: $0.width)}
        
        request.acceptResponse(okToExit: true)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        for item in menu.items {
            
            if let id = item.identifier {
                item.onIf(browserView.tableColumn(withIdentifier: id)?.isShown ?? false)
            }
        }
    }
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        // TODO: Validation - Don't allow 0 columns to be shown.
        
        if let id = sender.identifier {
            browserView.tableColumn(withIdentifier: id)?.isHidden.toggle()
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        Messenger.subscribe(self, .tuneBrowser_sidebarSelectionChanged, self.sidebarSelectionChanged(_:),
                            filter: {[weak self] notif in self?.respondToSidebarSelectionChange ?? false})
        
        Messenger.subscribeAsync(self, .fileSystem_fileMetadataLoaded, self.fileMetadataLoaded(_:), queue: .main)
        
        Messenger.subscribe(self, .application_exitRequest, self.onAppExit(_:))
        
        TuneBrowserSidebarCategory.allCases.forEach {sidebarView.expandItem($0)}
        
        respondToSidebarSelectionChange = false
        selectMusicFolder()
        respondToSidebarSelectionChange = true
        
        fileSystem.root = FileSystemItem.create(forURL: AppConstants.FilesAndPaths.musicDir)
        pathControlWidget.url = tuneBrowserMusicFolderURL
    }
    
    private func selectMusicFolder() {
        
        let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
        let musicFolderRow = foldersRow + 1
        sidebarView.selectRow(musicFolderRow)
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    private func fileMetadataLoaded(_ notif: FileSystemFileMetadataLoadedNotification) {
        
        DispatchQueue.main.async {
            self.browserView.reloadItem(notif.file)
        }
        
        //        let itemIndex: Int = browserView.row(forItem: notif.file)
//        browserView.reloadData(forRowIndexes: IndexSet([itemIndex]), columnIndexes: )
    }
        
    @IBAction func openFolderAction(_ sender: Any) {
        
        if let item = browserView.item(atRow: browserView.selectedRow), let fsItem = item as? FileSystemItem, fsItem.isDirectory {
            
            let path = fsItem.url.path
            
            if !path.hasPrefix("/Volumes"), let volumeName = FileSystemUtils.primaryVolumeName {
                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
            } else {
                pathControlWidget.url = fsItem.url
            }
            
            fileSystem.root = fsItem
            browserView.reloadData()
            browserView.scrollRowToVisible(0)
            
            updateSidebarSelection()
        }
    }
    
    // If the folder currently shown by the browser corresponds to one of the folder shortcuts in the sidebar, select that
    // item in the sidebar.
    func updateSidebarSelection() {
        
        respondToSidebarSelectionChange = false
        
        print("Root: \(fileSystem.rootURL)")
        
        if let folder = TuneBrowserState.userFolder(forURL: fileSystem.rootURL) {
            sidebarView.selectRow(sidebarView.row(forItem: folder))
            
        } else if fileSystem.rootURL == AppConstants.FilesAndPaths.musicDir || fileSystem.rootURL == tuneBrowserMusicFolderURL {
            selectMusicFolder()
            
        } else {
            sidebarView.clearSelection()
        }
        
        respondToSidebarSelectionChange = true
    }
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        if let item = pathControlWidget.clickedPathItem, let url = item.url, url != pathControlWidget.url {
            
            var path = url.path
            
            if !path.hasPrefix("/Volumes"), let volumeName = FileSystemUtils.primaryVolumeName {
                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
            } else {
                pathControlWidget.url = url
            }
            
            // Remove /Volumes from URL before setting fileSystem.rootURL
            
            if let volumeName = FileSystemUtils.primaryVolumeName, path.hasPrefix("/Volumes/\(volumeName)") {
                path = path.replacingOccurrences(of: "/Volumes/\(volumeName)", with: "")
            }
            
            if path.hasSuffix("/") {
                fileSystem.rootURL = url
                
            } else {
                
                path += "/"
                fileSystem.rootURL = URL(fileURLWithPath: path)
            }
            
            browserView.reloadData()
            browserView.scrollRowToVisible(0)
            
            updateSidebarSelection()
        }
    }
    
    private var respondToSidebarSelectionChange: Bool = true
    
    private func sidebarSelectionChanged(_ selectedItem: TuneBrowserSidebarItem) {
        
        let path = selectedItem.url.path
        
        if !path.hasPrefix("/Volumes"), let volumeName = FileSystemUtils.primaryVolumeName {
            pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
        } else {
            pathControlWidget.url = selectedItem.url
        }
        
        fileSystem.root = FileSystemItem.create(forURL: selectedItem.url)
        browserView.reloadData()
        browserView.scrollRowToVisible(0)
    }
    
    @IBAction func addBrowserItemsToPlaylistAction(_ sender: Any) {
        doAddBrowserItemsToPlaylist()
    }
    
    // TODO: Clarify this use case (which items qualify for this) ?
    @IBAction func addBrowserItemsToPlaylistAndPlayAction(_ sender: Any) {
        doAddBrowserItemsToPlaylist(beginPlayback: true)
    }
    
    private func doAddBrowserItemsToPlaylist(beginPlayback: Bool? = nil) {
        
        let selIndexes = browserView.selectedRowIndexes
        let selItemURLs = selIndexes.compactMap {[weak browserView] in browserView?.item(atRow: $0) as? FileSystemItem}.map {$0.url}
        
        playlist.addFiles(selItemURLs, beginPlayback: beginPlayback)
    }
    
    @IBAction func addSidebarShortcutAction(_ sender: Any) {
        
        if let clickedItem: FileSystemItem = browserView.rightClickedItem as? FileSystemItem {
            
            TuneBrowserState.addUserFolder(forURL: clickedItem.url)
            
            sidebarView.insertItems(at: IndexSet(integer: TuneBrowserState.sidebarUserFolders.count),
                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .slideDown)
        }
    }
    
    @IBAction func removeSidebarShortcutAction(_ sender: Any) {
        
        if let clickedItem: TuneBrowserSidebarItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem,
           let removedItemIndex = TuneBrowserState.removeUserFolder(item: clickedItem) {
            
            let musicFolderRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders) + 1
            let selectedRow = sidebarView.selectedRow
            let selectedItemRemoved = selectedRow == (musicFolderRow + removedItemIndex + 1)
            
            sidebarView.removeItems(at: IndexSet([removedItemIndex + 1]),
                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .effectFade)
            
            if selectedItemRemoved {
                
                let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
                let musicFolderRow = foldersRow + 1
                sidebarView.selectRow(musicFolderRow)
            }
        }
    }
    
    @IBAction func showBrowserItemInFinderAction(_ sender: Any) {
        
        if let selItem = browserView.rightClickedItem as? FileSystemItem {
            FileSystemUtils.showFileInFinder(selItem.url)
        }
    }
    
    @IBAction func showSidebarShortcutInFinderAction(_ sender: Any) {
        
        if let selItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem {
            FileSystemUtils.showFileInFinder(selItem.url)
        }
    }
        
    @IBAction func closeAction(_ sender: Any) {
        self.window?.close()
    }
}
