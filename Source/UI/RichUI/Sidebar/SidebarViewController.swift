import Cocoa

class SidebarViewController: AuralViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var sidebarView: NSOutlineView!
    
    override var nibName: String? {return "Sidebar"}
    
    let mainFont_14: NSFont = NSFont(name: "Play Regular", size: 13)!
    
    let playQueueItem: SidebarItem = SidebarItem(displayName: "Play Queue")
    
    let categories: [SidebarCategory] = SidebarCategory.allCases
    
    let libraryItems: [SidebarItem] = ["Tracks", "File System", "Favorites", "Bookmarks"].map {SidebarItem(displayName: $0)}
    let historyItems: [SidebarItem] = ["Recently Added", "Recently Played"].map {SidebarItem(displayName: $0)}
    let playlistsItems: [SidebarItem] = ["Biosphere Tranquility", "Nature Sounds"].map {SidebarItem(displayName: $0)}
    
    override func initializeUI() {
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return (item as? SidebarItem)?.displayName == playQueueItem.displayName ? 30 : 24
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return categories.count + 1
            
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
        return item is SidebarCategory || (item as? SidebarItem)?.displayName == playQueueItem.displayName
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            return index == 0 ? playQueueItem : categories[index - 1]
            
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
            
            if selectedItem.displayName == playQueueItem.displayName {
                Messenger.publish(.browser_showTab, payload: 0)
            } else {
                Messenger.publish(.browser_showTab, payload: selectedItem.displayName == "Tracks" ? 1 : 2)
            }
        }
    }
}
