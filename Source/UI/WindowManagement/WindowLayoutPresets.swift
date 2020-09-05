import Cocoa

enum WindowLayoutPreset: String, CaseIterable {
    
    case tallStack
    case tallStackWithLibrary
    
    case tallQueue
    case tallQueueWithLibrary
    
    case wideTopStack
    case wideBottomStack
    
    case wideTopQueue
    case wideBottomQueue
    
    case compact
    
    case rightQueue
    
    case twoByTwoGrid
    
    case tripleDecker
    
    case libraryBrowsing
    
    // Converts a user-friendly display name to an instance of WindowLayoutPreset
    static func fromDisplayName(_ displayName: String) -> WindowLayoutPreset {
        return WindowLayoutPreset(rawValue: StringUtils.camelCase(displayName)) ?? .tallStack
    }
    
    // Recomputes the layout (useful when the window gap preference changes)
    static func recompute(_ layout: WindowLayout) {
        
//        let preset = WindowLayoutPreset.fromDisplayName(layout.name)
//        
//        layout.mainWindow = preset.mainWindow
//        layout.effectsWindowOrigin = preset.effectsWindowOrigin
//        layout.playlistWindowFrame = preset.playlistWindowFrame
    }
    
    var description: String {
        
        switch self {
            
        case .tallStack: return "Tall stack"
            
        case .tallStackWithLibrary: return "Tall stack (with Library)"
            
        case .tallQueue:    return "Tall queue"
            
        case .tallQueueWithLibrary: return "Tall queue (with Library)"
            
        case .wideTopStack: return "Wide stack (top)"
            
        case .wideBottomStack: return "Wide stack (bottom)"
            
        case .wideTopQueue: return "Wide queue (top)"
            
        case .wideBottomQueue: return "Wide queue (bottom)"
            
        case .compact: return "Compact"
            
        case .rightQueue: return "Queue on the right"
            
        case .twoByTwoGrid: return "2 x 2 grid"
            
        case .tripleDecker: return "Triple decker"
            
        case .libraryBrowsing: return "Library browsing"
            
        }
    }
    
    
    
//    var playlistWindowFrame: NSRect {
//
//        let origin = playlistWindowOrigin
//        return NSRect(x: origin.x, y: origin.y, width: playlistWidth, height: playlistHeight)
//    }
}
