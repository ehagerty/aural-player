import Cocoa

fileprivate var screenVisibleFrame: NSRect {
    return NSScreen.main!.visibleFrame
}

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
        
        let preset = WindowLayoutPreset.fromDisplayName(layout.name)
        
        layout.mainWindow = preset.mainWindow
//        layout.effectsWindowOrigin = preset.effectsWindowOrigin
//        layout.playlistWindowFrame = preset.playlistWindowFrame
    }
    
    private var gapBetweenWindows: CGFloat {
        return CGFloat(ObjectGraph.preferencesDelegate.preferences.viewPreferences.windowGap)
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
    
    var mainWindow: LayoutWindow {
        
        switch self {
            
        case .tallStack:
            
            let origin = mainWindowOrigin
            let frame = NSRect(origin: origin, size: NSSize(width: Dimensions.mainWindowWidth, height: Dimensions.mainWindowHeight))
            return LayoutWindow(id: NSUserInterfaceItemIdentifier.mainWindow.rawValue, frame: frame)
            
        default:
            
            return LayoutWindow(id: "", frame: NSRect.zero)
        }
    }
    
    var mainWindowOrigin: NSPoint {

        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight

//        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
//        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight

//        let gap = gapBetweenWindows
//        let twoGaps = 2 * gap

        var x: CGFloat = 0
        var y: CGFloat = 0

        // Compute this only once
        let visibleFrame = screenVisibleFrame

        switch self {

        // Top left corner
        case .compact:

            x = visibleFrame.minX
            y = visibleFrame.maxY - mainWindowHeight

        case .tallStack:

            let xPadding = visibleFrame.width - mainWindowWidth
            x = visibleFrame.minX + (xPadding / 2)
            y = visibleFrame.maxY - mainWindowHeight
            
        default:
            
            x = 0
        }

//        case .horizontalFullStack:
//
//            let xPadding = visibleFrame.width - (mainWindowWidth + effectsWindowWidth + playlistWidth + twoGaps)
//
//            // Sometimes, xPadding is negative, never go to the left of minX
//            x = max(visibleFrame.minX + (xPadding / 2), visibleFrame.minX)
//
//            let yPadding = visibleFrame.height - mainWindowHeight
//            y = visibleFrame.minY + (yPadding / 2)
//
//        case .bigBottomPlaylist:
//
//            let xPadding = visibleFrame.width - (mainWindowWidth + gap + effectsWindowWidth)
//            x = visibleFrame.minX + (xPadding / 2)
//
//            let pHeight = playlistHeight
//            let yPadding = visibleFrame.height - (mainWindowHeight + gap + pHeight)
//            y = visibleFrame.minY + (yPadding / 2) + pHeight + gap
//
//        case .bigRightPlaylist:
//
//            let xPadding = visibleFrame.width - (mainWindowWidth + gap + playlistWidth)
//            x = visibleFrame.minX + (xPadding / 2)
//
//            let yPadding = visibleFrame.height - (mainWindowHeight + gap + effectsWindowHeight)
//            y = visibleFrame.minY + (yPadding / 2) + effectsWindowHeight + gap
//
//        case .verticalPlayerAndPlaylist:
//
//            let xPadding = visibleFrame.width - mainWindowWidth
//            x = visibleFrame.minX + (xPadding / 2)
//            y = visibleFrame.maxY - mainWindowHeight
//
//        case .horizontalPlayerAndPlaylist:
//
//            x = visibleFrame.minX
//
//            let yPadding = visibleFrame.height - mainWindowHeight
//            y = visibleFrame.minY + (yPadding / 2)
//        }

        return NSPoint(x: x, y: y)
    }
    
    var windows: [LayoutWindow] {
        
        switch self {
            
        case .tallStack:
            
            var origin = effectsWindowOrigin
            var size = NSSize(width: Dimensions.effectsWindowWidth, height: Dimensions.effectsWindowHeight)
            let soundWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.soundWindow.rawValue, frame: NSRect(origin: origin, size: size))
            
            origin = playQueueWindowOrigin
            size = NSSize(width: playQueueWidth, height: playQueueHeight)
            let playQueueWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.playQueueWindow.rawValue, frame: NSRect(origin: origin, size: size))
            
            return [soundWindow, playQueueWindow]
            
        default:
            
            return []
        }
    }
    
    var effectsWindowOrigin: NSPoint {

//        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight

        let gap = gapBetweenWindows

        let mwo = mainWindowOrigin
        var x: CGFloat = 0
        var y: CGFloat = 0

        switch self {

        case .tallStack:

            x = mwo.x
            y = mwo.y - gap - effectsWindowHeight

//        case .horizontalFullStack:
//
//            x = mwo.x + mainWindowWidth + gap
//            y = mwo.y
//
//        case .bigBottomPlaylist:
//
//            x = mwo.x + mainWindowWidth + gap
//            y = mwo.y
//
//        case .bigRightPlaylist:
//
//            x = mwo.x
//            y = mwo.y - gap - effectsWindowHeight

        default:

            x = 0
            y = 0
        }

        return NSPoint(x: x, y: y)
    }
    
    var playQueueHeight: CGFloat {

        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight

        let gap = gapBetweenWindows
        let twoGaps = 2 * gap

        // Compute this only once
        let visibleFrame = screenVisibleFrame

        switch self {

        case .tallStack:    return visibleFrame.height - (mainWindowHeight + effectsWindowHeight + twoGaps)

//        case .horizontalFullStack, .horizontalPlayerAndPlaylist:  return mainWindowHeight
//
//        case .bigRightPlaylist:   return mainWindowHeight + gap + effectsWindowHeight
//
//        case .verticalPlayerAndPlaylist:   return visibleFrame.height - (mainWindowHeight + gap)

        default:    return 500

        }
    }
    
    var playQueueWidth: CGFloat {

        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth

//        let gap = gapBetweenWindows
//        let twoGaps = 2 * gap
//        let minWidth = Dimensions.minPlaylistWidth

        // Compute this only once
//        let visibleFrame = screenVisibleFrame

        switch self {

        case .tallStack, .tallQueue, .tallQueueWithLibrary:    return mainWindowWidth

//        case .horizontalFullStack:    return max(visibleFrame.width - (mainWindowWidth + effectsWindowWidth + twoGaps), minWidth)
//
//        case .bigBottomPlaylist:    return mainWindowWidth + gap + effectsWindowWidth
//
//        case .bigRightPlaylist:   return mainWindowWidth
//
//        case .horizontalPlayerAndPlaylist: return visibleFrame.width - (mainWindowWidth + gap)

        default:    return 500

        }
    }
    
    var playQueueWindowOrigin: NSPoint {

//        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//
//        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
//        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
//
//        let gap = gapBetweenWindows
//        let twoGaps = 2 * gap
        let mwo = mainWindowOrigin

        var x: CGFloat = 0
        var y: CGFloat = 0

        // Compute this only once
        let visibleFrame = screenVisibleFrame

        switch self {

        case .tallStack:

            x = mwo.x
            y = visibleFrame.minY

//        case .horizontalFullStack:
//
//            x = mwo.x + mainWindowWidth + effectsWindowWidth + twoGaps
//            y = mwo.y
//
//        case .bigBottomPlaylist:
//
//            x = mwo.x
//            y = mwo.y - gap - playlistHeight
//
//        case .bigRightPlaylist:
//
//            x = mwo.x + mainWindowWidth + gap
//            y = mwo.y - gap - effectsWindowHeight
//
//        case .verticalPlayerAndPlaylist:
//
//            x = mwo.x
//            y = visibleFrame.minY
//
//        case .horizontalPlayerAndPlaylist:
//
//            x = mwo.x + mainWindowWidth + gap
//            y = mwo.y

        default:

            x = 0
            y = 0
        }

        return NSPoint(x: x, y: y)
    }
    
//    var playlistWindowFrame: NSRect {
//
//        let origin = playlistWindowOrigin
//        return NSRect(x: origin.x, y: origin.y, width: playlistWidth, height: playlistHeight)
//    }
}
