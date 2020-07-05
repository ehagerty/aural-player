import Cocoa

class SidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    override var nibName: String? {return "Sidebar"}
    
    let mainFont_14: NSFont = NSFont(name: "Play Regular", size: 14)!
    
    let categories: [SidebarCategory] = SidebarCategory.allCases
    
    let libraryItems: [SidebarItem] = ["Play Queue", "File System", "Favorites", "Bookmarks"].map {SidebarItem(displayName: $0)}
    let historyItems: [SidebarItem] = ["Recently Added", "Recently Played"].map {SidebarItem(displayName: $0)}
    let playlistsItems: [SidebarItem] = ["Biosphere Tranquility", "Nature Sounds"].map {SidebarItem(displayName: $0)}
    
    override func viewDidLoad() {
        categories.forEach {outlineView.expandItem($0)}
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 25
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return categories.count
            
        } else if let sidebarCat = item as? SidebarCategory {
            
            switch sidebarCat {
                
            case .library:
                
                return libraryItems.count
                
            case .history:
                
                return historyItems.count
                
            case .playlists:
                
                return playlistsItems.count
            }
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is SidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            return categories[index]
            
        } else if item as? SidebarCategory == .library {
            
            return libraryItems[index]
            
        } else if item as? SidebarCategory == .history {
            
            return historyItems[index]
            
        } else if item as? SidebarCategory == .playlists {
            
            return playlistsItems[index]
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is SidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let category = item as? SidebarCategory {
            return createNameCell(outlineView, category.description)
            
        } else if let sidebarItem = item as? SidebarItem {
            return createNameCell(outlineView, sidebarItem.displayName)
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ text: String) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("name"), owner: nil)
            as? NSTableCellView else {return nil}
        
        cell.imageView?.image = nil

        cell.textField?.stringValue = text
        cell.textField?.font = mainFont_14
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return !(item is SidebarCategory)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return item as? SidebarCategory == .playlists
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard let outlineView = notification.object as? NSOutlineView else {return}
            
        if let selectedItem = outlineView.item(atRow: outlineView.selectedRow) as? SidebarItem {
//            print(selectedItem.displayName)
        }
    }
}
