import Cocoa

class FileSystemBrowserViewDelegate: NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    let mainFont_13: NSFont = NSFont(name: "Play Regular", size: 13)!
    
    private var fsRoot: FileSystemItem!
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {

            fsRoot = FileSystemItem(url: URL(fileURLWithPath: "/Users/kven/Music/Grimes"))
            return fsRoot.children.count

        } else if let fsItem = item as? FileSystemItem {

            return fsItem.children.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            return fsRoot.children[index]
            
        } else if let fsItem = item as? FileSystemItem {
            
            return fsItem.children[index]
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item as? FileSystemItem)?.isDirectory ?? false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if tableColumn?.identifier.rawValue == "fileSystemBrowser_name", let fsItem = item as? FileSystemItem {
            return createNameCell(outlineView, fsItem)
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> FileSystemBrowserItemNameCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("fileSystemBrowser_name"), owner: nil)
            as? FileSystemBrowserItemNameCell else {return nil}
        
        cell.initializeForFile(item)
        cell.lblName.font = mainFont_13
        
        return cell
    }
    
    func outlineViewItemWillExpand(_ notification: Notification) {
        
        // TODO: Load folder contents (1 level deep) lazily
    }
}
