import Cocoa

class RichUIWindowController: NSWindowController {
    
    @IBOutlet weak var playerBox: NSBox!
    
    @IBOutlet weak var splitView: NSSplitView!
    
    private var theWindow: NSWindow {self.window!}
    
    override var windowNibName: String? {return "RichUI"}
    
    private lazy var playerController: RichUIPlayerViewController = RichUIPlayerViewController()
    
    private lazy var sidebarController: SidebarViewController = SidebarViewController()
    private lazy var playQueueController: PlayQueueViewController = PlayQueueViewController()
    
    override func windowDidLoad() {

        let playerView = playerController.view
        playerBox.addSubview(playerView)
        playerView.anchorToView(playerView.superview!)
        
        let sidebarView: NSView = sidebarController.view
        let containerView = splitView.arrangedSubviews[0]
        containerView.addSubview(sidebarView)
        sidebarView.anchorToView(sidebarView.superview!)
        
        let playQueueView: NSView = playQueueController.view
        let playQueueContainerView = splitView.arrangedSubviews[1]
        playQueueContainerView.addSubview(playQueueView)
        playQueueView.anchorToView(playQueueView.superview!)
    }
}
