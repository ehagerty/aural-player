import Cocoa

extension NSScreen {
    
    static var effectiveFrame: NSRect {
        
        let frames = NSScreen.screens.map {$0.frame}
        let maxX = frames.map {$0.maxX}.max()!
        let maxY = frames.map {$0.maxY}.max()!
        
        return NSRect(x: 0, y: 0, width: maxX, height: maxY)
    }
}

class WindowLayout {
    
    var name: String
    let systemDefined: Bool
    
    var mainWindow: LayoutWindow
    var childWindows: [LayoutWindow] = []
    
    private var allWindows: [LayoutWindow] {[mainWindow] + childWindows}
    
    var boundingBox: NSRect {
        
        let allFrames = allWindows.map {$0.frame}
        return allFrames.reduce(allFrames[0], {(unionSoFar: NSRect, rect: NSRect) -> NSRect in unionSoFar.union(rect)})
    }
    
    var isApplicable: Bool {NSScreen.effectiveFrame.contains(boundingBox)}
    
    init(_ name: String, _ systemDefined: Bool, mainWindow: LayoutWindow) {
        
        self.name = name
        self.systemDefined = systemDefined
        self.mainWindow = mainWindow
    }
    
    // Builder method
    func withChildWindow(_ window: NSWindow) -> WindowLayout {
        
        childWindows.append(LayoutWindow(window))
        return self
    }
    
    // Builder method
    func withChildWindows(_ windows: [LayoutWindow]) -> WindowLayout {
        
        childWindows.append(contentsOf: windows)
        return self
    }
    
    func withChildWindow(_ window: LayoutWindow) -> WindowLayout {
        
        childWindows.append(window)
        return self
    }
    
    static func fromPreset(_ preset: WindowLayoutPreset) -> WindowLayout {
        
        switch preset {
            
        case.tripleDecker:  return tripleDecker()
            
        default:    return tallStack()
            
        }
    }
    
    private static func tallStack() -> WindowLayout {
     
        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
        let soundWindowHeight: CGFloat = Dimensions.effectsWindowHeight
        
        let gap = CGFloat(ObjectGraph.preferences.viewPreferences.windowGap)
        
        let visibleFrame = screenVisibleFrame
        let xPadding = visibleFrame.width - mainWindowWidth
        let x = visibleFrame.minX + (xPadding / 2)
        
        let mainWindowY = visibleFrame.maxY - mainWindowHeight
        let mainWindowOrigin = NSPoint(x: x, y: mainWindowY)
        let mainWindowFrame: NSRect = NSRect(origin: mainWindowOrigin, size: Dimensions.mainWindowSize)
        let mainWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.mainWindow.rawValue, frame: mainWindowFrame)
        
        let soundWindowOrigin = NSPoint(x: x, y: mainWindowOrigin.y - gap - soundWindowHeight)
        let soundWindowFrame: NSRect = NSRect(origin: soundWindowOrigin, size: Dimensions.soundWindowSize)
        let soundWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.soundWindow.rawValue, frame: soundWindowFrame)
        
        let playQueueWindowOrigin = NSPoint(x: x, y: visibleFrame.minY)
        let playQueueWindowHeight = visibleFrame.height - (mainWindowHeight + soundWindowHeight + (2 * gap))
        let playQueueWindowFrame: NSRect = NSRect(origin: playQueueWindowOrigin, size: NSSize(width: mainWindowWidth, height: playQueueWindowHeight))
        let playQueueWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.playQueueWindow.rawValue, frame: playQueueWindowFrame)
        
        return WindowLayout(WindowLayoutPreset.tallStack.description, true, mainWindow: mainWindow)
            .withChildWindow(soundWindow)
            .withChildWindow(playQueueWindow)
    }
    
    private static func tripleDecker() -> WindowLayout {
     
        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
        
        let gap = CGFloat(ObjectGraph.preferences.viewPreferences.windowGap)
        let twoGaps = 2 * gap
        
        let visibleFrame = screenVisibleFrame
        let x = visibleFrame.centerX - mainWindowWidth
        
        let mainWindowY = visibleFrame.maxY - mainWindowHeight
        let mainWindowOrigin = NSPoint(x: x, y: mainWindowY)
        let mainWindowFrame: NSRect = NSRect(origin: mainWindowOrigin, size: Dimensions.mainWindowSize)
        let mainWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.mainWindow.rawValue, frame: mainWindowFrame)
        
        let soundWindowOrigin = NSPoint(x: x + mainWindowWidth + gap, y: mainWindowY)
        let soundWindowFrame: NSRect = NSRect(origin: soundWindowOrigin, size: Dimensions.soundWindowSize)
        let soundWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.soundWindow.rawValue, frame: soundWindowFrame)
        
        let playQueueWindowHeight = (visibleFrame.height - (mainWindowHeight + twoGaps)) / 2
        let playQueueWindowOrigin = NSPoint(x: x, y: playQueueWindowHeight + gap)
        let playQueueWindowFrame: NSRect = NSRect(origin: playQueueWindowOrigin, size: NSSize(width: mainWindowWidth + soundWindowFrame.width, height: playQueueWindowHeight))
        let playQueueWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.playQueueWindow.rawValue, frame: playQueueWindowFrame)
        
        let libraryWindowOrigin = NSPoint(x: x, y: visibleFrame.minY)
        let libraryWindowFrame: NSRect = NSRect(origin: libraryWindowOrigin, size: NSSize(width: playQueueWindowFrame.width, height: playQueueWindowHeight))
        let libraryWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.libraryWindow.rawValue, frame: libraryWindowFrame)
        
        return WindowLayout(WindowLayoutPreset.tripleDecker.description, true, mainWindow: mainWindow)
            .withChildWindow(soundWindow)
            .withChildWindow(playQueueWindow)
            .withChildWindow(libraryWindow)
    }
    
    private static func tripldddeDecker() -> WindowLayout {
     
        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
        
        let gap = CGFloat(ObjectGraph.preferences.viewPreferences.windowGap)
        let twoGaps = 2 * gap
        
        let visibleFrame = screenVisibleFrame
        let x = visibleFrame.centerX - mainWindowWidth
        
        let mainWindowY = visibleFrame.maxY - mainWindowHeight
        let mainWindowOrigin = NSPoint(x: x, y: mainWindowY)
        let mainWindowFrame: NSRect = NSRect(origin: mainWindowOrigin, size: Dimensions.mainWindowSize)
        let mainWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.mainWindow.rawValue, frame: mainWindowFrame)
        
        let soundWindowOrigin = NSPoint(x: x + mainWindowWidth + gap, y: mainWindowY)
        let soundWindowFrame: NSRect = NSRect(origin: soundWindowOrigin, size: Dimensions.soundWindowSize)
        let soundWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.soundWindow.rawValue, frame: soundWindowFrame)
        
        let playQueueWindowHeight = (visibleFrame.height - (mainWindowHeight + twoGaps)) / 2
        let playQueueWindowOrigin = NSPoint(x: x, y: playQueueWindowHeight + gap)
        let playQueueWindowFrame: NSRect = NSRect(origin: playQueueWindowOrigin, size: NSSize(width: mainWindowWidth + soundWindowFrame.width, height: playQueueWindowHeight))
        let playQueueWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.playQueueWindow.rawValue, frame: playQueueWindowFrame)
        
        let libraryWindowOrigin = NSPoint(x: x, y: visibleFrame.minY)
        let libraryWindowFrame: NSRect = NSRect(origin: libraryWindowOrigin, size: NSSize(width: playQueueWindowFrame.width, height: playQueueWindowHeight))
        let libraryWindow = LayoutWindow(id: NSUserInterfaceItemIdentifier.libraryWindow.rawValue, frame: libraryWindowFrame)
        
        return WindowLayout(WindowLayoutPreset.tripleDecker.description, true, mainWindow: mainWindow)
            .withChildWindow(soundWindow)
            .withChildWindow(playQueueWindow)
            .withChildWindow(libraryWindow)
    }
    
//    var mainWindow: LayoutWindow {
//
//            switch self {
//
//            case .tallStack:
//
//                let origin = mainWindowOrigin
//                let frame = NSRect(origin: origin, size: NSSize(width: Dimensions.mainWindowWidth, height: Dimensions.mainWindowHeight))
//                return LayoutWindow(id: NSUserInterfaceItemIdentifier.mainWindow.rawValue, frame: frame)
//
//            case .tripleDecker:
//
//                let origin = mainWindowOrigin
//                let frame = NSRect(origin: origin, size: NSSize(width: Dimensions.mainWindowWidth, height: Dimensions.mainWindowHeight))
//                return LayoutWindow(id: NSUserInterfaceItemIdentifier.mainWindow.rawValue, frame: frame)
//
//            default:
//
//                return LayoutWindow(id: "", frame: NSRect.zero)
//            }
//        }
//
//        var mainWindowOrigin: NSPoint {
//
//            let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//            let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
//
//    //        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
//    //        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
//
//    //        let gap = gapBetweenWindows
//    //        let twoGaps = 2 * gap
//
//            var x: CGFloat = 0
//            var y: CGFloat = 0
//
//            // Compute this only once
//            let visibleFrame = screenVisibleFrame
//
//            switch self {
//
//            // Top left corner
//            case .compact:
//
//                x = visibleFrame.minX
//                y = visibleFrame.maxY - mainWindowHeight
//
//            case .tallStack:
//
//                let xPadding = visibleFrame.width - mainWindowWidth
//                x = visibleFrame.minX + (xPadding / 2)
//                y = visibleFrame.maxY - mainWindowHeight
//
//            case .tripleDecker:
//
//                let centerX = visibleFrame.centerX
//                x = centerX - mainWindowWidth
//                y = visibleFrame.maxY - mainWindowHeight
//
//            default:
//
//                x = 0
//            }
//
//    //        case .horizontalFullStack:
//    //
//    //            let xPadding = visibleFrame.width - (mainWindowWidth + effectsWindowWidth + playlistWidth + twoGaps)
//    //
//    //            // Sometimes, xPadding is negative, never go to the left of minX
//    //            x = max(visibleFrame.minX + (xPadding / 2), visibleFrame.minX)
//    //
//    //            let yPadding = visibleFrame.height - mainWindowHeight
//    //            y = visibleFrame.minY + (yPadding / 2)
//    //
//    //        case .bigBottomPlaylist:
//    //
//    //            let xPadding = visibleFrame.width - (mainWindowWidth + gap + effectsWindowWidth)
//    //            x = visibleFrame.minX + (xPadding / 2)
//    //
//    //            let pHeight = playlistHeight
//    //            let yPadding = visibleFrame.height - (mainWindowHeight + gap + pHeight)
//    //            y = visibleFrame.minY + (yPadding / 2) + pHeight + gap
//    //
//    //        case .bigRightPlaylist:
//    //
//    //            let xPadding = visibleFrame.width - (mainWindowWidth + gap + playlistWidth)
//    //            x = visibleFrame.minX + (xPadding / 2)
//    //
//    //            let yPadding = visibleFrame.height - (mainWindowHeight + gap + effectsWindowHeight)
//    //            y = visibleFrame.minY + (yPadding / 2) + effectsWindowHeight + gap
//    //
//    //        case .verticalPlayerAndPlaylist:
//    //
//    //            let xPadding = visibleFrame.width - mainWindowWidth
//    //            x = visibleFrame.minX + (xPadding / 2)
//    //            y = visibleFrame.maxY - mainWindowHeight
//    //
//    //        case .horizontalPlayerAndPlaylist:
//    //
//    //            x = visibleFrame.minX
//    //
//    //            let yPadding = visibleFrame.height - mainWindowHeight
//    //            y = visibleFrame.minY + (yPadding / 2)
//    //        }
//
//            return NSPoint(x: x, y: y)
//        }
//
//        var soundWindow: LayoutWindow {
//
//            var origin: NSPoint
//            var size: NSSize
//
//            switch self {
//
//
//            }
//
//            let origin = effectsWindowOrigin
//            let size = NSSize(width: Dimensions.effectsWindowWidth, height: Dimensions.effectsWindowHeight)
//            return LayoutWindow(id: NSUserInterfaceItemIdentifier.soundWindow.rawValue, frame: NSRect(origin: origin, size: size))
//        }
//
//        var playQueueWindow: LayoutWindow {
//
//            let origin = playQueueWindowOrigin
//            let size = NSSize(width: playQueueWidth, height: playQueueHeight)
//            return LayoutWindow(id: NSUserInterfaceItemIdentifier.playQueueWindow.rawValue, frame: NSRect(origin: origin, size: size))
//        }
//
//        var libraryWindow: LayoutWindow {
//
//            let origin = libraryWindowOrigin
//            let size = NSSize(width: libraryWidth, height: libraryHeight)
//            return LayoutWindow(id: NSUserInterfaceItemIdentifier.libraryWindow.rawValue, frame: NSRect(origin: origin, size: size))
//        }
//
//        var windows: [LayoutWindow] {
//
//            switch self {
//
//            case .tallStack:
//
//                return [soundWindow, playQueueWindow]
//
//            case .tripleDecker:
//
//                return [soundWindow, playQueueWindow, libraryWindow]
//
//            default:
//
//                return []
//            }
//        }
//
//        var effectsWindowOrigin: NSPoint {
//
//            let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//            let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
//
//            let gap = gapBetweenWindows
//
//            let mwo = mainWindowOrigin
//            var x: CGFloat = 0
//            var y: CGFloat = 0
//
//            switch self {
//
//            case .tallStack:
//
//                x = mwo.x
//                y = mwo.y - gap - effectsWindowHeight
//
//            case .tripleDecker:
//
//                x = mwo.x + mainWindowWidth
//                y = mwo.y
//
//    //        case .horizontalFullStack:
//    //
//    //            x = mwo.x + mainWindowWidth + gap
//    //            y = mwo.y
//    //
//    //        case .bigBottomPlaylist:
//    //
//    //            x = mwo.x + mainWindowWidth + gap
//    //            y = mwo.y
//    //
//    //        case .bigRightPlaylist:
//    //
//    //            x = mwo.x
//    //            y = mwo.y - gap - effectsWindowHeight
//
//            default:
//
//                x = 0
//                y = 0
//            }
//
//            return NSPoint(x: x, y: y)
//        }
//
//        var playQueueHeight: CGFloat {
//
//            let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
//            let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
//
//            let gap = gapBetweenWindows
//            let twoGaps = 2 * gap
//
//            // Compute this only once
//            let visibleFrame = screenVisibleFrame
//
//            switch self {
//
//            case .tallStack:    return visibleFrame.height - (mainWindowHeight + effectsWindowHeight + twoGaps)
//
//            case .tripleDecker:
//
//                return (visibleFrame.height - (mainWindowHeight + twoGaps)) / 2
//
//    //        case .horizontalFullStack, .horizontalPlayerAndPlaylist:  return mainWindowHeight
//    //
//    //        case .bigRightPlaylist:   return mainWindowHeight + gap + effectsWindowHeight
//    //
//    //        case .verticalPlayerAndPlaylist:   return visibleFrame.height - (mainWindowHeight + gap)
//
//            default:    return 500
//
//            }
//        }
//
//        var playQueueWidth: CGFloat {
//
//            let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//            let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
//
//            let gap = gapBetweenWindows
//    //        let twoGaps = 2 * gap
//    //        let minWidth = Dimensions.minPlaylistWidth
//
//            // Compute this only once
//    //        let visibleFrame = screenVisibleFrame
//
//            switch self {
//
//            case .tallStack, .tallQueue, .tallQueueWithLibrary:    return mainWindowWidth
//
//            case .tripleDecker:    return mainWindowWidth + gap + effectsWindowWidth
//
//    //        case .horizontalFullStack:    return max(visibleFrame.width - (mainWindowWidth + effectsWindowWidth + twoGaps), minWidth)
//    //
//    //        case .bigBottomPlaylist:    return mainWindowWidth + gap + effectsWindowWidth
//    //
//    //        case .bigRightPlaylist:   return mainWindowWidth
//    //
//    //        case .horizontalPlayerAndPlaylist: return visibleFrame.width - (mainWindowWidth + gap)
//
//            default:    return 500
//
//            }
//        }
//
//        var playQueueWindowOrigin: NSPoint {
//
//    //        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//    //
//    //        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
//            let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
//    //        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
//    //
//            let gap = gapBetweenWindows
//            let twoGaps = 2 * gap
//            let mwo = mainWindowOrigin
//
//            var x: CGFloat = 0
//            var y: CGFloat = 0
//
//            // Compute this only once
//            let visibleFrame = screenVisibleFrame
//
//            switch self {
//
//            case .tallStack:
//
//                x = mwo.x
//                y = visibleFrame.minY
//
//            case .tripleDecker:
//
//                x = mwo.x
//                y = ((visibleFrame.height - (mainWindowHeight + twoGaps)) / 2) + gap
//
//    //        case .horizontalFullStack:
//    //
//    //            x = mwo.x + mainWindowWidth + effectsWindowWidth + twoGaps
//    //            y = mwo.y
//    //
//    //        case .bigBottomPlaylist:
//    //
//    //            x = mwo.x
//    //            y = mwo.y - gap - playlistHeight
//    //
//    //        case .bigRightPlaylist:
//    //
//    //            x = mwo.x + mainWindowWidth + gap
//    //            y = mwo.y - gap - effectsWindowHeight
//    //
//    //        case .verticalPlayerAndPlaylist:
//    //
//    //            x = mwo.x
//    //            y = visibleFrame.minY
//    //
//    //        case .horizontalPlayerAndPlaylist:
//    //
//    //            x = mwo.x + mainWindowWidth + gap
//    //            y = mwo.y
//
//            default:
//
//                x = 0
//                y = 0
//            }
//
//            return NSPoint(x: x, y: y)
//        }
//
//        var libraryHeight: CGFloat {
//
//            let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
//    //        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
//
//            let gap = gapBetweenWindows
//            let twoGaps = 2 * gap
//
//            // Compute this only once
//            let visibleFrame = screenVisibleFrame
//
//            switch self {
//
//            case .tripleDecker:
//
//                return (visibleFrame.height - (mainWindowHeight + twoGaps)) / 2
//
//                //        case .horizontalFullStack, .horizontalPlayerAndPlaylist:  return mainWindowHeight
//                //
//                //        case .bigRightPlaylist:   return mainWindowHeight + gap + effectsWindowHeight
//                //
//                //        case .verticalPlayerAndPlaylist:   return visibleFrame.height - (mainWindowHeight + gap)
//
//            default:    return 0
//
//            }
//        }
//
//        var libraryWidth: CGFloat {
//
//            let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//            let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
//
//            let gap = gapBetweenWindows
//            //        let twoGaps = 2 * gap
//            //        let minWidth = Dimensions.minPlaylistWidth
//
//            // Compute this only once
//            //        let visibleFrame = screenVisibleFrame
//
//            switch self {
//
//            case .tallQueueWithLibrary:    return mainWindowWidth
//
//            case .tripleDecker:    return mainWindowWidth + gap + effectsWindowWidth
//
//                //        case .horizontalFullStack:    return max(visibleFrame.width - (mainWindowWidth + effectsWindowWidth + twoGaps), minWidth)
//                //
//                //        case .bigBottomPlaylist:    return mainWindowWidth + gap + effectsWindowWidth
//                //
//                //        case .bigRightPlaylist:   return mainWindowWidth
//                //
//                //        case .horizontalPlayerAndPlaylist: return visibleFrame.width - (mainWindowWidth + gap)
//
//            default:    return 0
//
//            }
//        }
//
//        var libraryWindowOrigin: NSPoint {
//
//            //        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
//            //
//            //        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
//    //        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
//    //        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
//            //
//    //        let gap = gapBetweenWindows
//    //        let twoGaps = 2 * gap
//            let mwo = mainWindowOrigin
//
//            var x: CGFloat = 0
//            var y: CGFloat = 0
//
//            // Compute this only once
//    //        let visibleFrame = screenVisibleFrame
//
//            switch self {
//
//            case .tripleDecker:
//
//                x = mwo.x
//                y = 0
//
//                //        case .horizontalFullStack:
//                //
//                //            x = mwo.x + mainWindowWidth + effectsWindowWidth + twoGaps
//                //            y = mwo.y
//                //
//                //        case .bigBottomPlaylist:
//                //
//                //            x = mwo.x
//                //            y = mwo.y - gap - playlistHeight
//                //
//                //        case .bigRightPlaylist:
//                //
//                //            x = mwo.x + mainWindowWidth + gap
//                //            y = mwo.y - gap - effectsWindowHeight
//                //
//                //        case .verticalPlayerAndPlaylist:
//                //
//                //            x = mwo.x
//                //            y = visibleFrame.minY
//                //
//                //        case .horizontalPlayerAndPlaylist:
//                //
//                //            x = mwo.x + mainWindowWidth + gap
//                //            y = mwo.y
//
//            default:
//
//                x = 0
//                y = 0
//            }
//
//            return NSPoint(x: x, y: y)
//        }
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
    
    convenience init(_ window: NSWindow) {
        self.init(id: window.identifier!.rawValue, frame: window.frame)
    }
    
    init(id: String, frame: NSRect) {
        
        self.id = id
        self.frame = frame
    }
}

fileprivate var screenVisibleFrame: NSRect {
    return NSScreen.main!.visibleFrame
}
