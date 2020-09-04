import Cocoa

class WindowLayout {
    
    var name: String
    let systemDefined: Bool
    
    var mainWindow: LayoutWindow
    var windows: [LayoutWindow] = []
    
    init(_ name: String, _ systemDefined: Bool, mainWindow: LayoutWindow) {
        
        self.name = name
        self.systemDefined = systemDefined
        self.mainWindow = mainWindow
    }
    
    func withWindow(_ window: NSWindow) {
        windows.append(LayoutWindow(window))
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let mainWindow: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "wid_main")
    static let playQueueWindow: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "wid_playQueue")
    static let libraryWindow: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "wid_library")
    static let soundWindow: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "wid_sound")
}

class LayoutWindow {
    
    let id: String
    
    let frame: NSRect
    let screenRelativeOrigin: NSPoint
    
    convenience init(_ window: NSWindow) {
        self.init(id: window.identifier!.rawValue, frame: window.frame)
    }
    
    init(id: String, frame: NSRect) {
        
        self.id = id
        self.frame = frame
        
        // Compute frame of window relative to its containing screen.
        let screenContainingWindow: NSScreen = NSScreen.screens.first(where: {$0.frame.contains(frame.origin)}) ?? NSScreen.screens[0]
        let screenFrame = screenContainingWindow.frame
        self.screenRelativeOrigin = NSPoint(x: frame.minX - screenFrame.minX, y: frame.minY - screenFrame.minY)
    }
    
    init(id: String, frame: NSRect, screenRelativeOrigin: NSPoint) {
        
        self.id = id
        self.frame = frame
        self.screenRelativeOrigin = screenRelativeOrigin
    }
}
