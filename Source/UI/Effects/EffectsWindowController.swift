/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController, NSOutlineViewDataSource, NSOutlineViewDelegate, NotificationSubscriber {

    @IBOutlet weak var fxUnitsListView: NSOutlineView!

    // The constituent sub-views, one for each effects unit

    private let eqViewController: EQViewController = EQViewController()
    private let pitchViewController: PitchViewController = PitchViewController()
    private let timeViewController: TimeViewController = TimeViewController()
    private let reverbViewController: ReverbViewController = ReverbViewController()
    private let delayViewController: DelayViewController = DelayViewController()
    private let filterViewController: FilterViewController = FilterViewController()

    @IBOutlet weak var fxTabView: NSTabView!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let preferences: ViewPreferences = ObjectGraph.preferencesDelegate.preferences.viewPreferences

    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    override var windowNibName: String? {return "Effects"}

    override func windowDidLoad() {
        
        // Initialize all sub-views
        addSubViews()

        theWindow.isMovableByWindowBackground = true
        theWindow.delegate = WindowManager.windowDelegate

        EffectsViewState.initialize(ObjectGraph.appState.ui.effects)
        
        changeTextSize(EffectsViewState.textSize)
        Messenger.publish(.fx_changeTextSize, payload: EffectsViewState.textSize)
        
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
        
        fxUnitsListView.selectRow(0)
    }

    private func addSubViews() {

        fxTabView.tabViewItem(at: 0).view?.addSubview(eqViewController.view)
        fxTabView.tabViewItem(at: 1).view?.addSubview(pitchViewController.view)
        fxTabView.tabViewItem(at: 2).view?.addSubview(timeViewController.view)
        fxTabView.tabViewItem(at: 3).view?.addSubview(reverbViewController.view)
        fxTabView.tabViewItem(at: 4).view?.addSubview(delayViewController.view)
        fxTabView.tabViewItem(at: 5).view?.addSubview(filterViewController.view)
    }

    private func initSubscriptions() {

        Messenger.subscribe(self, .fx_unitStateChanged, self.stateChanged)
        
        // MARK: Commands ----------------------------------------------------------------------------------------
        
        Messenger.subscribe(self, .fx_showFXUnitTab, self.showTab(_:))
        
        Messenger.subscribe(self, .fx_changeTextSize, self.changeTextSize)
        
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeViewControlButtonColor, self.changeViewControlButtonColor(_:))
        
        Messenger.subscribe(self, .fx_changeActiveUnitStateColor, self.changeActiveUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeBypassedUnitStateColor, self.changeBypassedUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeSuppressedUnitStateColor, self.changeSuppressedUnitStateColor(_:))
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        Messenger.publish(.windowManager_toggleEffectsWindow)
    }
    
    private func changeTextSize(_ textSize: TextSize) {
//        viewMenuButton.font = Fonts.Effects.menuFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        
//        [btnClose, viewMenuIconItem].forEach({
//            ($0 as? Tintable)?.reTint()
//        })
    }
    
    private func changeActiveUnitStateColor(_ color: NSColor) {
        
//        fxTabViewButtons.forEach({
//
//            if $0.unitState == .active {
//                $0.reTint()
//            }
//        })
    }
    
    private func changeBypassedUnitStateColor(_ color: NSColor) {
        
//        fxTabViewButtons.forEach({
//
//            if $0.unitState == .bypassed {
//                $0.reTint()
//            }
//        })
    }
    
    private func changeSuppressedUnitStateColor(_ color: NSColor) {
        
//        fxTabViewButtons.forEach({
//
//            if $0.unitState == .suppressed {
//                $0.reTint()
//            }
//        })
    }
    
    // MARK: Message handling

    // Notification that an effect unit's state has changed (active/inactive)
    func stateChanged() {
    }
    
    func showTab(_ fxUnit: EffectsUnit) {
        fxUnitsListView.selectRow(fxUnit.rawValue - 1)
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return item == nil ? 6 : 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        guard item == nil else {return ""}
        
        switch index {
            
        case 0: return graph.eqUnit
            
        case 1: return graph.pitchUnit
            
        case 2: return graph.timeUnit
            
        case 3: return graph.reverbUnit
            
        case 4: return graph.delayUnit
            
        case 5: return graph.filterUnit
            
        default: return ""
            
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let unit = item as? FXUnitDelegateProtocol,
            let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("fxUnit"), owner: nil) as? EffectsUnitEditorCell else {return nil}
        
        cell.initializeForUnit(unit)
        return cell
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        if let outlineView = notification.object as? NSOutlineView {
            fxTabView.selectTabViewItem(at: outlineView.selectedRow)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 38
    }
}
