import Cocoa

class RichUIWindowController: NSWindowController, NSSplitViewDelegate, NotificationSubscriber {
    
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBOutlet weak var playerBrowserSplitView: NSSplitView!
    @IBOutlet weak var browserTabView: NSTabView!
    
    private var theWindow: NSWindow {self.window!}
    override var windowNibName: String? {return "RichUI"}
    
    private lazy var playerController: RichUIPlayerViewController = RichUIPlayerViewController()
    
    private lazy var sidebarController: SidebarViewController = SidebarViewController()
    
    private lazy var playQueueController: PlayQueueViewController = PlayQueueViewController()
    private lazy var libraryTracksController: LibraryTracksViewController = LibraryTracksViewController()
    private lazy var fileSystemBrowserController: FileSystemBrowserViewController = FileSystemBrowserViewController()
    
    private var playQueueMenu: NSMenuItem!
    private var libraryMenu: NSMenuItem!
    
    override func windowDidLoad() {
        
        playerBrowserSplitView.delegate = self
        
        let sidebarView: NSView = sidebarController.view
        let containerView = splitView.arrangedSubviews[0]
        containerView.addSubview(sidebarView)
        sidebarView.anchorToView(sidebarView.superview!)
        
        let playerContainerView = playerBrowserSplitView.arrangedSubviews[0]
        
        let playerView = playerController.view
        playerContainerView.addSubview(playerView)
        playerView.anchorToView(playerView.superview!)
        
        let playQueueView: NSView = playQueueController.view
        browserTabView.tabViewItem(at: 0).view?.addSubview(playQueueView)
        playQueueView.anchorToView(playQueueView.superview!)
        
        let libraryTracksView: NSView = libraryTracksController.view
        browserTabView.tabViewItem(at: 1).view?.addSubview(libraryTracksView)
        libraryTracksView.anchorToView(libraryTracksView.superview!)
        
        let fileSystemBrowserView: NSView = fileSystemBrowserController.view
        browserTabView.tabViewItem(at: 2).view?.addSubview(fileSystemBrowserView)
        fileSystemBrowserView.anchorToView(fileSystemBrowserView.superview!)
        
        if let mainMenu = NSApplication.shared.mainMenu {
            
            self.playQueueMenu = mainMenu.item(withTitle: "Play Queue")
            self.libraryMenu = mainMenu.item(withTitle: "Library")
        }
        
        Messenger.subscribe(self, .browser_showTab, self.showBrowserTab(_:))
        
        showBrowserTab(1)
    }
    
    @IBAction func toggleSidebarAction(_ sender: AnyObject) {
        
        if let theView = splitView.arrangedSubviews.first {
            theView.isHidden.toggle()
        }
    }

    private func showBrowserTab(_ tabIndex: Int) {
        
        browserTabView.selectTabViewItem(at: tabIndex)
        
        switch tabIndex {
            
        case 0:
            
            playQueueMenu.show()
            libraryMenu.hide()
            
        case 1:
            
            playQueueMenu.hide()
            libraryMenu.show()
            
        default:
            
            return
        }
    }
    
    func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        return NSZeroRect
    }
}
