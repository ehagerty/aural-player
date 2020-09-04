import Cocoa

/*
    Window controller for the main application window.
 */
class MainWindowController: NSWindowController, NotificationSubscriber {
    
    // Main application window. Contains the Now Playing info box and player controls. Not resizable.
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var containerBox: NSBox!
    private lazy var playerViewController: PlayerViewController = PlayerViewController()
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnSettingsMenu: NSPopUpButton!
    
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    private var eventMonitor: Any?
    
    private var gestureHandler: GestureHandler!
    
    override var windowNibName: String? {return "MainWindow"}
    
    // MARK: Setup
    
    // One-time setup
    override func windowDidLoad() {
        
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        activateGestureHandler()
        initSubscriptions()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        addSubViews()
        
        [btnQuit, btnMinimize].forEach({$0?.tintFunction = {return Colors.viewControlButtonColor}})
        
        logoImage.tintFunction = {return Colors.appLogoColor}
        
        changeTextSize(PlayerViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
    }
    
    // Add the sub-views that make up the main window
    private func addSubViews() {
        containerBox.addSubview(playerViewController.view)
    }
    
    private func activateGestureHandler() {
        
        // Register a handler for trackpad/MagicMouse gestures
        gestureHandler = GestureHandler(theWindow)
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .swipe, .scrollWheel], handler: {(event: NSEvent) -> NSEvent? in
            return self.gestureHandler.handle(event) ? nil : event;
        });
    }
    
    private func initSubscriptions() {
        
        Messenger.subscribe(self, .player_changeTextSize, self.changeTextSize(_:))
        
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeAppLogoColor, self.changeAppLogoColor(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .changeViewControlButtonColor, self.changeViewControlButtonColor(_:))

        Messenger.subscribe(self, .windowManager_togglePlaylistWindow, self.togglePlaylistWindow)
        Messenger.subscribe(self, .windowManager_toggleEffectsWindow, self.toggleEffectsWindow)
        
        Messenger.subscribe(self, .windowManager_layoutChanged, self.windowLayoutChanged(_:))
    }
    
    // Shows/hides the playlist window (by delegating)
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylistWindow()
    }
    
    private func togglePlaylistWindow() {

//        WindowManager.togglePlaylist()
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffectsWindow()
    }
    
    private func toggleEffectsWindow() {
        
//        WindowManager.toggleEffects()
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
//        theWindow.miniaturize(self)
        print("\nMainWindow frame: \(theWindow.frame)")
    }
    
    private func changeTextSize(_ textSize: TextSize) {
        btnSettingsMenu.font = Fonts.Player.menuFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeAppLogoColor(scheme.general.appLogoColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color

        containerBox.fillColor = color
        containerBox.isTransparent = !color.isOpaque
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        
        [btnQuit, btnMinimize, settingsMenuIconItem].forEach({
            ($0 as? Tintable)?.reTint()
        })
    }
    
    private func changeAppLogoColor(_ color: NSColor) {
        logoImage.reTint()
    }
    
    // MARK: Message handling
    
    func windowLayoutChanged(_ notification: WindowLayoutChangedNotification) {
        
//        btnToggleEffects.onIf(notification.showingEffectsWindow)
//        btnTogglePlaylist.onIf(notification.showingPlaylistWindow)
    }
}
