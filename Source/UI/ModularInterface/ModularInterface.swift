import Cocoa

class ModularInterface: InterfaceProtocol {
    
    var type: InterfaceType {.modular}
    
    let preferences: ViewPreferences
    var layoutForNextLaunch: WindowLayout?
    
    init(_ appState: WindowLayoutState, _ preferences: ViewPreferences) {

        self.preferences = preferences
        self.layoutForNextLaunch = appState.rememberedLayout
    }
    
    // App's main window
    var mainWindowController: MainWindowController = MainWindowController()
    lazy var mainWindow: NSWindow = mainWindowController.window!
    
    private var playQueueWindowLoaded: Bool = false
    private lazy var playQueueWindowController: PlayQueueWindowController = PlayQueueWindowController()
    private lazy var playQueueWindow: NSWindow = {
        
        playQueueWindowLoaded = true
        return playQueueWindowController.window!
    }()
    
    private var libraryWindowLoaded: Bool = false
    private lazy var libraryWindowController: LibraryWindowController = LibraryWindowController()
    lazy var libraryWindow: NSWindow = {
        
        libraryWindowLoaded = true
        return libraryWindowController.window!
    }()
    
    // Load these optional windows only if/when needed
    private var soundWindowLoaded: Bool = false
    lazy var effectsWindowController: EffectsWindowController = EffectsWindowController()
    lazy var soundWindow: NSWindow = {
        
        soundWindowLoaded = true
        return effectsWindowController.window!
    }()
    
    // Load these optional windows only if/when needed
    private var visualizerWindowLoaded: Bool = false
    lazy var visualizerWindowController: VisualizerWindowController = VisualizerWindowController()
    lazy var visualizerWindow: NSWindow = {
        
        visualizerWindowLoaded = true
        return visualizerWindowController.window!
    }()
    
    // Helps with lazy loading of chapters list window
    private var chaptersListWindowLoaded: Bool = false
    
    var chaptersListWindow: NSWindow = WindowFactory.chaptersListWindow
    
    let windowDelegate: SnappingWindowDelegate = SnappingWindowDelegate()
    
    //    private var onTop: Bool = false
    
    // Each modal component, when it is loaded, will register itself here, which will enable tracking of modal dialogs / popovers
    private var modalComponentRegistry: [ModalComponentProtocol] = []
    
    func registerModalComponent(_ component: ModalComponentProtocol) {
        modalComponentRegistry.append(component)
    }
    
    var isShowingModalComponent: Bool {
        return modalComponentRegistry.contains(where: {$0.isModal}) || NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func show() {
    
        if preferences.layoutOnStartup.option == .specific {
            
            layout(preferences.layoutOnStartup.layoutName)
            
        } else {
            
            // Remember from last app launch
            if let rememberedLayout = layoutForNextLaunch, rememberedLayout.isApplicable {
                layout(rememberedLayout)
            } else {
                layout(WindowLayouts.defaultLayout)
            }
        }
        
        Messenger.publish(.modularInterface_initialLayoutCompleted)
    }
    
    func hide() {
        
    }
    
    func layout(_ name: String) {
        
        // TODO: Error or alert if not applicable.
        
        if let theLayout = WindowLayouts.layoutByName(name), theLayout.isApplicable {
            layout(theLayout)
        }
    }
    
    private func layout(_ layout: WindowLayout) {
        
        mainWindow.setFrameOrigin(layout.mainWindow.frame.origin)
        mainWindow.childWindows?.forEach {$0.hide()}
        
        for window in layout.childWindows {
            
            if let theWindow: NSWindow = mapWindowIdToWindow(window.id) {
            
                mainWindow.addChildWindow(theWindow, ordered: NSWindow.OrderingMode.below)
                theWindow.setFrame(window.frame, display: true)
                theWindow.show()
            }
        }

        mainWindow.setIsVisible(true)
    }
    
    func mapWindowIdToWindow(_ id: String) -> NSWindow? {
        
        switch id {
            
        case NSUserInterfaceItemIdentifier.soundWindow.rawValue:
            
            return soundWindow
            
        case NSUserInterfaceItemIdentifier.playQueueWindow.rawValue:
            
            return playQueueWindow
            
        case NSUserInterfaceItemIdentifier.libraryWindow.rawValue:
            
            return libraryWindow
            
        default:
            
            print("\nOther window: \(id)")
            return nil
        }
    }
    
    var currentWindowLayout: WindowLayout {
        
//        let effectsWindowOrigin = isShowingEffects ? effectsWindow.origin : nil
//        let playlistWindowFrame = isShowingLibrary ? libraryWindow.frame : nil
        
        return WindowLayout("_currentWindowLayout_", false, mainWindow: LayoutWindow(id: "", frame: mainWindow.frame))
    }
    
    var isShowingEffects: Bool {
        return soundWindowLoaded && soundWindow.isVisible
    }
    
    var isShowingLibrary: Bool {
        return libraryWindow.isVisible
    }
    
    var isShowingPlayQueue: Bool {
        return playQueueWindow.isVisible
    }
    
    var isShowingVisualizer: Bool {
        return visualizerWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isShowingChaptersList: Bool {
        return chaptersListWindowLoaded && chaptersListWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isChaptersListWindowKey: Bool {
        return isShowingChaptersList && chaptersListWindow == NSApp.keyWindow
    }
    
    var mainWindowFrame: NSRect {
        return mainWindow.frame
    }
    
    var effectsWindowFrame: NSRect {
        return soundWindow.frame
    }
    
    var playlistWindowFrame: NSRect {
        return libraryWindow.frame
    }
    
    // MARK ----------- View toggling code ----------------------------------------------------
    
    // Shows/hides the effects window
    func toggleEffects() {
        isShowingEffects ? hideEffects() : showEffects()
    }
    
    // Shows the effects window
    func showEffects() {
        
        mainWindow.addChildWindow(soundWindow, ordered: NSWindow.OrderingMode.above)
        soundWindow.show()
        soundWindow.orderFront(self)
    }
    
    // Hides the effects window
    private func hideEffects() {
        soundWindow.hide()
    }
    
    // Shows/hides the playlist window
    func toggleLibrary() {
        isShowingLibrary ? hideLibrary() : showLibrary()
    }
    
    // Shows the playlist window
    func showLibrary() {
        
        mainWindow.addChildWindow(libraryWindow, ordered: NSWindow.OrderingMode.above)
        libraryWindow.show()
        libraryWindow.orderFront(self)
    }
    
    // Hides the playlist window
    private func hideLibrary() {
        libraryWindow.hide()
    }
    
    func togglePlayQueue() {
        isShowingPlayQueue ? hidePlayQueue() : showPlayQueue()
    }
    
    private func hidePlayQueue() {
        playQueueWindow.hide()
    }
    
    private func showPlayQueue() {

        mainWindow.addChildWindow(playQueueWindow, ordered: NSWindow.OrderingMode.above)
        playQueueWindow.show()
        playQueueWindow.orderFront(self)
    }
    
    func toggleChaptersList() {
        isShowingChaptersList ? hideChaptersList() : showChaptersList()
    }
    
    func showChaptersList() {
        
        libraryWindow.addChildWindow(chaptersListWindow, ordered: NSWindow.OrderingMode.above)
        chaptersListWindow.makeKeyAndOrderFront(self)
        
        // This will happen only once after each app launch - the very first time the window is shown.
        // After that, the window will be restored to its previous on-screen location
        if !chaptersListWindowLoaded {
            
            UIUtils.centerDialogWRTWindow(chaptersListWindow, libraryWindow)
            chaptersListWindowLoaded = true
        }
    }
    
    func hideChaptersList() {
        
        if chaptersListWindowLoaded {
            chaptersListWindow.setIsVisible(false)
        }
    }
    
    func toggleVisualizer() {
        isShowingVisualizer ? hideVisualizer() : showVisualizer()
    }
    
    private func hideVisualizer() {
        visualizerWindowController.close()
    }
    
    private func showVisualizer() {

        mainWindow.addChildWindow(visualizerWindow, ordered: NSWindow.OrderingMode.above)
        visualizerWindowController.showWindow(self)
        visualizerWindow.orderFront(self)
    }
    
//    func addChildWindow(_ window: NSWindow) {
//        mainWindow.addChildWindow(window, ordered: .above)
//    }
    
    //    func toggleAlwaysOnTop() {
    //
    //        onTop = !onTop
    //        mainWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(onTop ? .floatingWindow : .normalWindow)))
    //    }
    
    // Adjusts both window frames to the given location and size (specified as co-ordinates)
    private func setWindowFrames(_ mainWindowX: CGFloat, _ mainWindowY: CGFloat, _ playlistX: CGFloat, _ playlistY: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        
        mainWindow.setFrameOrigin(NSPoint(x: mainWindowX, y: mainWindowY))
        
        var playlistFrame = libraryWindow.frame
        
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        playlistFrame.size = NSSize(width: width, height: height)
        libraryWindow.setFrame(playlistFrame, display: true)
    }
    
    // MARK ----------- Message handling ----------------------------------------------------
    
    var persistentState: ModularInterfaceState {
        
        let state = ModularInterfaceState()
        
        let layout = WindowLayout("_rememberedModularInterfaceWindowLayout_", true,
                                                           mainWindow: LayoutWindow(id: mainWindow.identifier!.rawValue, frame: mainWindow.frame))
        
        state.windowLayout.rememberedLayout = layout.withChildWindows(mainWindow.childWindows?.map {LayoutWindow($0)} ?? [])
        state.windowLayout.userLayouts = WindowLayouts.userDefinedLayouts
        
        return state
    }
    
    // MARK: NSWindowDelegate functions
    
    fileprivate func windowDidMove(_ notification: Notification) {
        
        // Only respond if movement was user-initiated (flag on window)
        if let movedWindow = notification.object as? SnappingWindow, movedWindow.userMovingWindow {
            
            var snapped = false
            
            if preferences.snapToWindows {
                
                // First check if window can be snapped to another app window
                for mate in getCandidateWindowsForSnap(movedWindow) {
                    
                    if mate.isVisible && UIUtils.checkForSnapToWindow(movedWindow, mate) {
                        
                        snapped = true
                        break
                    }
                }
            }
            
            // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
            if preferences.snapToScreen && !snapped {
                UIUtils.checkForSnapToVisibleFrame(movedWindow)
            }
        }
    }
    
    // Sorted by order of relevance
    private func getCandidateWindowsForSnap(_ movedWindow: SnappingWindow) -> [NSWindow] {
        
        if movedWindow === libraryWindow {
            return [mainWindow, soundWindow]
            
        } else if movedWindow === soundWindow {
            return [mainWindow, libraryWindow]
            
        } else if movedWindow === chaptersListWindow {
            return [libraryWindow, mainWindow, soundWindow]
        }
        
        // Main window
        return []
    }
}

class SnappingWindowDelegate: NSObject, NSWindowDelegate {
    
    func windowDidMove(_ notification: Notification) {
//        WindowManager.windowDidMove(notification)
    }
}

class ModularInterfaceState: PersistentState {
    
    var windowLayout: WindowLayoutState = WindowLayoutState()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = ModularInterfaceState()
        
        if let windowLayoutDict = map["windowLayout"] as? NSDictionary,
            let windowLayoutState = WindowLayoutState.deserialize(windowLayoutDict) as? WindowLayoutState {
            
            state.windowLayout = windowLayoutState
        }
        
        return state
    }
}

extension Notification.Name {
    
    // All windows have been laid out after app launch.
    static let modularInterface_initialLayoutCompleted: Notification.Name = Notification.Name("modularInterface_initialLayoutCompleted")
}
