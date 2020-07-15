import Cocoa

class AuralWindowController: NSWindowController, NotificationSubscriber {
    
    override func windowDidLoad() {
        
        initializeWindow()
        initializeSubscriptions()
    }
    
    func initializeWindow() {}
    
    func initializeSubscriptions() {}
}

class EffectsPanelController: AuralWindowController {
    
    @IBOutlet weak var fxUnitsListView: NSOutlineView!
    @IBOutlet weak var fxUnitsTabView: NSTabView!
    
    @IBOutlet weak var unitsMenu: NSMenu!
    
    override var windowNibName: String? {"EffectsPanel"}
    
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    var unitVCs: [FXUnitViewController] = []
    
    @IBAction func addEQUnitAction(_ sender: AnyObject) {
        
//        let eqUnit = graph.addEQUnit()
//        fxUnitsListView.insertItems(at: IndexSet(integer: fxUnitsListView.numberOfRows), inParent: nil, withAnimation: .effectFade)
//        
//        let newTab = NSTabViewItem()
//        let vc = EQViewController(unit: eqUnit)
//        unitVCs.append(vc)
//        
//        fxUnitsTabView.addTabViewItem(newTab)
//        newTab.view?.addSubview(vc.view)
//        
//        fxUnitsTabView.selectTabViewItem(newTab)
    }
    
    @IBAction func showUnitsMenuAction(_ sender: AnyObject) {
        unitsMenu.popUp(positioning: unitsMenu.item(at: 0), at: NSEvent.mouseLocation, in: nil)
    }
}
