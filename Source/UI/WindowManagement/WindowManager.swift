import Cocoa

protocol Destroyable {
    
    func destroy()
    
    static func destroy()
}

extension Destroyable {
    
    func destroy() {}
    
    static func destroy() {}
}

class WindowManager: NSObject, NSWindowDelegate, Destroyable {
    
    private static var _instance: WindowManager?
    
    static var instance: WindowManager! {_instance}
    
    static func createInstance(preferences: ViewPreferences) -> WindowManager {
        
        _instance = WindowManager(preferences: preferences)
        return instance
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    private let preferences: ViewPreferences
    
    // App's main window
    private let mainWindowController: MainWindowController
    let mainWindow: NSWindow
    
    // Load these optional windows only if/when needed
    private var effectsWindowLoader: LazyWindowLoader<EffectsWindowController> = LazyWindowLoader()
    private lazy var _effectsWindow: NSWindow = {[weak self] in
        
        effectsWindowLoader.window.delegate = self
        return effectsWindowLoader.window
    }()
    
    var effectsWindow: NSWindow? {effectsWindowLoader.windowLoaded ? _effectsWindow : nil}
    var effectsWindowLoaded: Bool {effectsWindowLoader.windowLoaded}

    private var playlistWindowLoader: LazyWindowLoader<PlaylistWindowController> = LazyWindowLoader()
    private lazy var _playlistWindow: NSWindow = {[weak self] in
        
        playlistWindowLoader.window.delegate = self
        return playlistWindowLoader.window
    }()
    
    var playlistWindow: NSWindow? {playlistWindowLoader.windowLoaded ? _playlistWindow : nil}
    var playlistWindowLoaded: Bool {playlistWindowLoader.windowLoaded}

    private lazy var chaptersListWindowLoader: LazyWindowLoader<ChaptersListWindowController> = LazyWindowLoader()
    private lazy var _chaptersListWindow: NSWindow = {[weak self] in
        
        chaptersListWindowLoader.window.delegate = self
        return chaptersListWindowLoader.window
    }()
    var chaptersListWindow: NSWindow? {chaptersListWindowLoader.windowLoaded ? _chaptersListWindow : nil}
    
    private lazy var visualizerWindowLoader: LazyWindowLoader<VisualizerWindowController> = LazyWindowLoader()
    private lazy var _visualizerWindow: NSWindow = visualizerWindowLoader.window
    
    var visualizerWindow: NSWindow? {visualizerWindowLoader.windowLoaded ? _visualizerWindow : nil}
    
    private lazy var tuneBrowserWindowLoader: LazyWindowLoader<TuneBrowserWindowController> = LazyWindowLoader()
    private lazy var _tuneBrowserWindow: NSWindow = tuneBrowserWindowLoader.window
    
//    private var onTop: Bool = false
    
    // Each modal component, when it is loaded, will register itself here, which will enable tracking of modal dialogs / popovers
    private var modalComponentRegistry: [ModalComponentProtocol] = []
    
    init(preferences: ViewPreferences) {
        
        self.preferences = preferences
        
        self.mainWindowController = MainWindowController()
        self.mainWindow = mainWindowController.window!
        
        super.init()
        self.mainWindow.delegate = self
    }
    
    func registerModalComponent(_ component: ModalComponentProtocol) {
        modalComponentRegistry.append(component)
    }
    
    var isShowingModalComponent: Bool {
        return modalComponentRegistry.contains(where: {$0.isModal}) || NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func loadWindows() {
        
        if preferences.layoutOnStartup.option == .specific {
            
            layout(preferences.layoutOnStartup.layoutName)
            
        } else {
            
            // Remember from last app launch
            mainWindow.setFrameOrigin(WindowLayoutState.mainWindowOrigin)
            mainWindow.show()
            
            if WindowLayoutState.showEffects {
                
                mainWindow.addChildWindow(_effectsWindow, ordered: NSWindow.OrderingMode.below)
                
                if let effectsWindowOrigin = WindowLayoutState.effectsWindowOrigin {
                    
                    _effectsWindow.setFrameOrigin(effectsWindowOrigin)
                    _effectsWindow.show()
                    
                } else {
                    defaultLayout()
                }
            }
            
            if WindowLayoutState.showPlaylist {
                
                mainWindow.addChildWindow(_playlistWindow, ordered: NSWindow.OrderingMode.below)
                
                if let playlistWindowFrame = WindowLayoutState.playlistWindowFrame {
                    
                    _playlistWindow.setFrame(playlistWindowFrame, display: true)
                    _playlistWindow.show()
                    
                } else {
                    defaultLayout()
                }
            }
            
            mainWindow.makeKeyAndOrderFront(self)
            Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: WindowLayoutState.showPlaylist, showingEffectsWindow: WindowLayoutState.showEffects))
        }
    }
    
    func destroy() {
        
        // Before destroying this instance, transfer its state info to WindowLayoutState.
        
        WindowLayoutState.showEffects = isShowingEffects
        WindowLayoutState.showPlaylist = isShowingPlaylist
        
        WindowLayoutState.mainWindowOrigin = mainWindow.origin
        WindowLayoutState.playlistWindowFrame = playlistWindow?.frame
        WindowLayoutState.effectsWindowOrigin = effectsWindow?.origin
        
        for window in mainWindow.childWindows ?? [] {
            mainWindow.removeChildWindow(window)
        }
        
        ([mainWindowController, effectsWindowLoader, playlistWindowLoader, chaptersListWindowLoader, visualizerWindowLoader] as? [Destroyable])?.forEach {
            $0.destroy()
        }
    }
    
    // Revert to default layout if app state is corrupted
    private func defaultLayout() {
        layout(WindowLayouts.defaultLayout)
    }
    
    func layout(_ layout: WindowLayout) {
        
        mainWindow.setFrameOrigin(layout.mainWindowOrigin)
        
        if layout.showEffects {
            
            mainWindow.addChildWindow(_effectsWindow, ordered: NSWindow.OrderingMode.below)
            _effectsWindow.setFrameOrigin(layout.effectsWindowOrigin!)
            _effectsWindow.show()
            
        } else {
            hideEffects()
        }
        
        if layout.showPlaylist {
            
            mainWindow.addChildWindow(_playlistWindow, ordered: NSWindow.OrderingMode.below)
            _playlistWindow.setFrame(layout.playlistWindowFrame!, display: true)
            _playlistWindow.show()
            
        } else {
            hidePlaylist()
        }
        
        Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: layout.showPlaylist, showingEffectsWindow: layout.showEffects))
    }
    
    var currentWindowLayout: WindowLayout {
        
        let effectsWindowOrigin = isShowingEffects ? _effectsWindow.origin : nil
        let playlistWindowFrame = isShowingPlaylist ? _playlistWindow.frame : nil
        
        return WindowLayout("_currentWindowLayout_", isShowingEffects, isShowingPlaylist, mainWindow.origin, effectsWindowOrigin, playlistWindowFrame, false)
    }
    
    func layout(_ name: String) {
        layout(WindowLayouts.layoutByName(name)!)
    }
    
    var isShowingEffects: Bool {
        return effectsWindowLoaded && _effectsWindow.isVisible
    }
    
    var isShowingPlaylist: Bool {
        return playlistWindowLoaded && _playlistWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isShowingChaptersList: Bool {
        return chaptersListWindowLoader.windowLoaded && _chaptersListWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isChaptersListWindowKey: Bool {
        return isShowingChaptersList && _chaptersListWindow == NSApp.keyWindow
    }
    
    var isShowingVisualizer: Bool {
        return visualizerWindowLoader.windowLoaded && _visualizerWindow.isVisible
    }
    
    var isShowingTuneBrowser: Bool {
        return tuneBrowserWindowLoader.windowLoaded && _tuneBrowserWindow.isVisible
    }
    
    var mainWindowFrame: NSRect {
        return mainWindow.frame
    }
    
    // MARK ----------- View toggling code ----------------------------------------------------
    
    // Shows/hides the effects window
    func toggleEffects() {
        isShowingEffects ? hideEffects() : showEffects()
    }
    
    // Shows the effects window
    private func showEffects() {
        
        mainWindow.addChildWindow(_effectsWindow, ordered: NSWindow.OrderingMode.above)
        _effectsWindow.show()
        _effectsWindow.orderFront(self)
    }
    
    // Hides the effects window
    private func hideEffects() {
        
        if effectsWindowLoaded {
            _effectsWindow.hide()
        }
    }
    
    // Shows/hides the playlist window
    func togglePlaylist() {
        isShowingPlaylist ? hidePlaylist() : showPlaylist()
    }
    
    // Shows the playlist window
    private func showPlaylist() {
        
        mainWindow.addChildWindow(_playlistWindow, ordered: NSWindow.OrderingMode.above)
        _playlistWindow.show()
        _playlistWindow.orderFront(self)
    }
    
    // Hides the playlist window
    private func hidePlaylist() {
        
        if playlistWindowLoaded {
            _playlistWindow.hide()
        }
    }
    
    func toggleChaptersList() {
        isShowingChaptersList ? hideChaptersList() : showChaptersList()
    }
    
    func showChaptersList() {
        
        let shouldCenterChaptersListWindow = !chaptersListWindowLoader.windowLoaded
        
        mainWindow.addChildWindow(_chaptersListWindow, ordered: NSWindow.OrderingMode.above)
        _chaptersListWindow.makeKeyAndOrderFront(self)
        
        // This will happen only once after each app launch - the very first time the window is shown.
        // After that, the window will be restored to its previous on-screen location
        if shouldCenterChaptersListWindow && playlistWindowLoaded {
            UIUtils.centerDialogWRTWindow(_chaptersListWindow, _playlistWindow)
        }
    }
    
    func hideChaptersList() {
        
        if chaptersListWindowLoader.windowLoaded {
            _chaptersListWindow.hide()
        }
    }
    
    func toggleVisualizer() {
        isShowingVisualizer ? hideVisualizer() : showVisualizer()
    }
    
    private func showVisualizer() {
        
        mainWindow.addChildWindow(_visualizerWindow, ordered: NSWindow.OrderingMode.above)
        visualizerWindowLoader.controller.showWindow(self)
    }
    
    private func hideVisualizer() {
        visualizerWindowLoader.controller.close()
    }
    
    func toggleTuneBrowser() {
        isShowingTuneBrowser ? hideTuneBrowser() : showTuneBrowser()
    }
    
    private func showTuneBrowser() {
        
        mainWindow.addChildWindow(_tuneBrowserWindow, ordered: NSWindow.OrderingMode.above)
        _tuneBrowserWindow.makeKeyAndOrderFront(self)
    }
    
    private func hideTuneBrowser() {
        
        if tuneBrowserWindowLoader.windowLoaded {
            _tuneBrowserWindow.hide()
        }
    }
    
    func addChildWindow(_ window: NSWindow) {
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    //    func toggleAlwaysOnTop() {
    //
    //        onTop = !onTop
    //        mainWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(onTop ? .floatingWindow : .normalWindow)))
    //    }
    
    // MARK: NSWindowDelegate functions
    
    func windowDidMove(_ notification: Notification) {
        
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
        
        if isShowingPlaylist && movedWindow === _playlistWindow {
            return isShowingEffects ? [mainWindow, _effectsWindow] : [mainWindow]
            
        } else if isShowingEffects && movedWindow === _effectsWindow {
            return isShowingPlaylist ? [mainWindow, _playlistWindow] : [mainWindow]
            
        } else if isShowingChaptersList && movedWindow === _chaptersListWindow {
            
            var candidates: [NSWindow] = [mainWindow]
            
            if isShowingEffects {candidates.append(_effectsWindow)}
            if isShowingPlaylist {candidates.append(_playlistWindow)}
            
            return candidates
        }
        
        // Main window
        return []
    }
}

class WindowLayoutState {
    
    static var showEffects: Bool = WindowLayoutDefaults.showEffects
    static var showPlaylist: Bool = WindowLayoutDefaults.showPlaylist
    
    static var mainWindowOrigin: NSPoint = WindowLayoutDefaults.mainWindowOrigin
    static var effectsWindowOrigin: NSPoint? = WindowLayoutDefaults.effectsWindowOrigin
    static var playlistWindowFrame: NSRect? = WindowLayoutDefaults.playlistWindowFrame
}

class WindowLayoutDefaults {
    
    static let showEffects: Bool = true
    static let showPlaylist: Bool = true
    
    static let mainWindowOrigin: NSPoint = NSPoint.zero
    static let effectsWindowOrigin: NSPoint? = nil
    static let playlistWindowFrame: NSRect? = nil
}

// Convenient accessor for information about the current appearance settings for the app's main windows.
class WindowAppearanceState {
    static var cornerRadius: CGFloat = WindowAppearanceStateDefaults.cornerRadius
}

class WindowAppearanceStateDefaults {
    static let cornerRadius: CGFloat = 3
}

// A snapshot of WindowAppearanceState
struct WindowAppearance {
    let cornerRadius: CGFloat
}
