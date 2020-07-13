import Cocoa

class FileSystemBrowserViewController: NSViewController, NSMenuDelegate, NotificationSubscriber {
    
    @IBOutlet weak var fsBrowserView: NSOutlineView!
    
    private lazy var library: LibraryDelegateProtocol = ObjectGraph.libraryDelegate
    
    override var nibName: String? {return "FileSystemBrowser"}
    
    @IBAction func addItemsToLibraryAction(_ sender: AnyObject) {
        
        let items = fsBrowserView.selectedRowIndexes.compactMap {fsBrowserView.item(atRow: $0) as? FileSystemItem}
        let files = items.map {$0.url}
        
        library.addFiles(files)
    }
}
