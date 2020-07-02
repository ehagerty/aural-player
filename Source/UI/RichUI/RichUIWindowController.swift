import Cocoa

class RichUIWindowController: NSWindowController {
    
    @IBOutlet weak var albumArtView: NSImageView!
    
    private var theWindow: NSWindow {self.window!}
    
    override var windowNibName: String? {return "RichUI"}
    
    override func windowDidLoad() {
//        albumArtView.cornerRadius = 3
    }
}
