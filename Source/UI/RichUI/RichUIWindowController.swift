import Cocoa

class RichUIWindowController: NSWindowController {
    
    @IBOutlet weak var trackInfoBox: NSBox!
    @IBOutlet weak var playerBox: NSBox!
    
    private var theWindow: NSWindow {self.window!}
    
    override var windowNibName: String? {return "RichUI"}
    
    private lazy var trackInfoController: RichUITrackInfoViewController = RichUITrackInfoViewController()
    private lazy var playerController: RichUIPlayerViewController = RichUIPlayerViewController()
    
    override func windowDidLoad() {

        let trackInfoView = trackInfoController.view
        trackInfoView.frame.size.width = trackInfoBox.width
        
        trackInfoBox.addSubview(trackInfoView)
        playerBox.addSubview(playerController.view)
    }
}
