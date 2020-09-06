import Foundation

/*
 Encapsulates UI state
 */
class UIState: PersistentState {
    
    var windowLayout: WindowLayoutState = WindowLayoutState()
    var colorSchemes: ColorSchemesState = ColorSchemesState()
    var player: PlayerUIState = PlayerUIState()
    var playlist: PlaylistUIState = PlaylistUIState()
    var playQueue: PlayQueueUIPersistentState = PlayQueueUIPersistentState()
    var effects: EffectsUIState = EffectsUIState()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = UIState()
        
        if let windowLayoutMap = map["windowLayout"] as? NSDictionary {
            state.windowLayout = WindowLayoutState.deserialize(windowLayoutMap) as! WindowLayoutState
        }
        
        if let colorSchemesMap = map["colorSchemes"] as? NSDictionary,
            let colorSchemes = ColorSchemesState.deserialize(colorSchemesMap) as? ColorSchemesState {
            
            state.colorSchemes = colorSchemes
        }
        
        if let playerMap = map["player"] as? NSDictionary {
            state.player = PlayerUIState.deserialize(playerMap) as! PlayerUIState
        }
        
        if let effectsMap = map["effects"] as? NSDictionary {
            state.effects = EffectsUIState.deserialize(effectsMap) as! EffectsUIState
        }
        
        if let playlistMap = map["playlist"] as? NSDictionary {
            state.playlist = PlaylistUIState.deserialize(playlistMap) as! PlaylistUIState
        }
        
        if let playQueueMap = map["playQueue"] as? NSDictionary,
            let playQueueState = PlayQueueUIPersistentState.deserialize(playQueueMap) as? PlayQueueUIPersistentState {
            
            state.playQueue = playQueueState
        }
        
        return state
    }
}

class PlaylistUIState: PersistentState {
    
    var textSize: TextSize = .normal
    var view: String = "Tracks"
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistUIState()
        state.textSize = mapEnum(map, "textSize", TextSize.normal)
        
        if let viewName = map["view"] as? String {
            state.view = viewName
        }
        
        return state
    }
}

class EffectsUIState: PersistentState {
    
    var textSize: TextSize = .normal
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = EffectsUIState()
        state.textSize = mapEnum(map, "textSize", TextSize.normal)
        
        return state
    }
}

class PlayerUIState: PersistentState {
    
    var viewType: PlayerViewType = .defaultView
    
    var showAlbumArt: Bool = true
    var showArtist: Bool = true
    var showAlbum: Bool = true
    var showCurrentChapter: Bool = true
    
    var showTrackInfo: Bool = true
    var showSequenceInfo: Bool = true
    
    var showPlayingTrackFunctions: Bool = true
    var showControls: Bool = true
    var showTimeElapsedRemaining: Bool = true
    
    var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
    
    var textSize: TextSize = .normal
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlayerUIState()
        
        state.viewType = mapEnum(map, "viewType", PlayerViewType.defaultView)
        
        state.showAlbumArt = mapDirectly(map, "showAlbumArt", true)
        state.showArtist = mapDirectly(map, "showArtist", true)
        state.showAlbum = mapDirectly(map, "showAlbum", true)
        state.showCurrentChapter = mapDirectly(map, "showCurrentChapter", true)
        
        state.showTrackInfo = mapDirectly(map, "showTrackInfo", true)
        state.showSequenceInfo = mapDirectly(map, "showSequenceInfo", true)
        
        state.showControls = mapDirectly(map, "showControls", true)
        state.showTimeElapsedRemaining = mapDirectly(map, "showTimeElapsedRemaining", true)
        state.showPlayingTrackFunctions = mapDirectly(map, "showPlayingTrackFunctions", true)
        
        state.timeElapsedDisplayType = mapEnum(map, "timeElapsedDisplayType", TimeElapsedDisplayType.formatted)
        state.timeRemainingDisplayType = mapEnum(map, "timeRemainingDisplayType", TimeRemainingDisplayType.formatted)
        
        state.textSize = mapEnum(map, "textSize", TextSize.normal)
        
        return state
    }
}

class WindowLayoutState: PersistentState {
    
    var rememberedLayout: WindowLayout?
    var userLayouts: [WindowLayout] = [WindowLayout]()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = WindowLayoutState()

        if let rememberedLayoutDict = map["rememberedLayout"] as? NSDictionary {
            state.rememberedLayout = deserializeLayout(from: rememberedLayoutDict, havingName: "_rememberedModularInterfaceWindowLayout_", isSystemDefined: true)
        }
        
        if let userLayouts = map["userLayouts"] as? [NSDictionary] {
            
            for layout in userLayouts {
                
                if let layoutName = layout["name"] as? String, let newLayout = deserializeLayout(from: layout, havingName: layoutName, isSystemDefined: false) {
                    state.userLayouts.append(newLayout)
                }
            }
        }
        
        return state
    }
    
    private static func deserializeLayout(from layoutDict: NSDictionary, havingName name: String, isSystemDefined: Bool) -> WindowLayout? {
        
        if let mainWindowDict = layoutDict["mainWindow"] as? NSDictionary, let mainWindow = deserializeWindow(from: mainWindowDict),
            let childWindowDicts = layoutDict["childWindows"] as? [NSDictionary] {
            
            let childWindows = childWindowDicts.compactMap {deserializeWindow(from: $0)}
            return WindowLayout(name, isSystemDefined, mainWindow: mainWindow).withChildWindows(childWindows)
        }
        
        return nil
    }
    
    private static func deserializeWindow(from windowDict: NSDictionary) -> LayoutWindow? {
        
        if let id = windowDict["id"] as? String, let frameDict = windowDict["frame"] as? NSDictionary, let frame = mapNSRect(frameDict) {
            return LayoutWindow(id: id, frame: frame)
        }
        
        return nil
    }
}

extension PlayerViewState {
    
    static func initialize(_ appState: PlayerUIState) {
        
        viewType = appState.viewType
        
        showAlbumArt = appState.showAlbumArt
        showArtist = appState.showArtist
        showAlbum = appState.showAlbum
        showCurrentChapter = appState.showCurrentChapter
        
        showTrackInfo = appState.showTrackInfo
        showSequenceInfo = appState.showSequenceInfo
        
        showPlayingTrackFunctions = appState.showPlayingTrackFunctions
        showControls = appState.showControls
        showTimeElapsedRemaining = appState.showTimeElapsedRemaining
        
        timeElapsedDisplayType = appState.timeElapsedDisplayType
        timeRemainingDisplayType = appState.timeRemainingDisplayType
        
        textSize = appState.textSize
    }
    
    static var persistentState: PlayerUIState {
        
        let state = PlayerUIState()
        
        state.viewType = viewType
        
        state.showAlbumArt = showAlbumArt
        state.showArtist = showArtist
        state.showAlbum = showAlbum
        state.showCurrentChapter = showCurrentChapter
        
        state.showTrackInfo = showTrackInfo
        state.showSequenceInfo = showSequenceInfo
        
        state.showPlayingTrackFunctions = showPlayingTrackFunctions
        state.showControls = showControls
        state.showTimeElapsedRemaining = showTimeElapsedRemaining
        
        state.timeElapsedDisplayType = timeElapsedDisplayType
        state.timeRemainingDisplayType = timeRemainingDisplayType
        
        state.textSize = textSize
        
        return state
    }
}

extension EffectsViewState {
    
    static func initialize(_ appState: EffectsUIState) {
        textSize = appState.textSize
    }
    
    static var persistentState: EffectsUIState {
        
        let state = EffectsUIState()
        state.textSize = textSize
        
        return state
    }
}

extension PlaylistViewState {
    
    static func initialize(_ appState: PlaylistUIState) {
        
        textSize = appState.textSize
        current = PlaylistType(rawValue: appState.view.lowercased()) ?? .tracks
    }
    
    static var persistentState: PlaylistUIState {
        
        let state = PlaylistUIState()
        
        state.textSize = textSize
        state.view = current.rawValue.capitalizingFirstLetter()
        
        return state
    }
}
