import Cocoa

class EffectsEditorViewDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
//    private let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
//    
//    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        return item == nil ? graph.units.count : 0
//    }
//    
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//        return item == nil ? graph.units[index] : ""
//    }
//    
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        return false
//    }
//    
//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//        
//        guard let unit = item as? FXUnitDelegateProtocol, let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("fxUnit"), owner: nil)
//            as? EffectsUnitEditorCell else {return nil}
//        
//        cell.initializeForUnit(unit)
//        return cell
//    }
}
