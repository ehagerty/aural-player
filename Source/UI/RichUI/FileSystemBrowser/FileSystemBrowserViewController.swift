import Cocoa

class FileSystemBrowserViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var fsBrowserView: NSOutlineView!
    
    override var nibName: String? {return "FileSystemBrowser"}
}
