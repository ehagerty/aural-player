import Foundation

class WindowLayoutPersistentState: PersistentStateProtocol {
    
    var showEffects: Bool?
    var showPlaylist: Bool?
    
    var mainWindowOrigin: NSPoint?
    var effectsWindowOrigin: NSPoint?
    var playlistWindowFrame: NSRect?
    
    var userLayouts: [UserWindowLayoutPersistentState]?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.showPlaylist = map.boolValue(forKey: "showPlaylist")
        self.showEffects = map.boolValue(forKey: "showEffects")
        
        self.mainWindowOrigin = map.nsPointValue(forKey: "mainWindowOrigin")
        self.effectsWindowOrigin = map.nsPointValue(forKey: "effectsWindowOrigin")
        self.playlistWindowFrame = map.nsRectValue(forKey: "playlistWindowFrame")
        
        self.userLayouts = map.arrayValue(forKey: "userLayouts", ofType: UserWindowLayoutPersistentState.self)
    }
}

class UserWindowLayoutPersistentState: PersistentStateProtocol {
    
    let name: String
    let showEffects: Bool
    let showPlaylist: Bool
    
    let mainWindowOrigin: NSPoint
    let effectsWindowOrigin: NSPoint?
    let playlistWindowFrame: NSRect?
    
    init(_ name: String, _ showEffects: Bool, _ showPlaylist: Bool, _ mainWindowOrigin: NSPoint, _ effectsWindowOrigin: NSPoint?, _ playlistWindowFrame: NSRect?) {
        
        self.name = name
        self.showEffects = showEffects
        self.showPlaylist = showPlaylist
        self.mainWindowOrigin = mainWindowOrigin
        self.effectsWindowOrigin = effectsWindowOrigin
        self.playlistWindowFrame = playlistWindowFrame
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.nonEmptyStringValue(forKey: "name"),
              let showPlaylist = map.boolValue(forKey: "showPlaylist"),
              let showEffects = map.boolValue(forKey: "showEffects"),
              let mainWindowOrigin = map.nsPointValue(forKey: "mainWindowOrigin") else {return nil}
        
        self.name = name
        self.showPlaylist = showPlaylist
        self.showEffects = showEffects
        
        self.mainWindowOrigin = mainWindowOrigin
        
        if showPlaylist {
            
            guard let playlistWindowFrame = map.nsRectValue(forKey: "playlistWindowFrame") else {return nil}
            self.playlistWindowFrame = playlistWindowFrame
        }
        
        if showEffects {
            
            guard let effectsWindowOrigin = map.nsPointValue(forKey: "effectsWindowOrigin") else {return nil}
            self.effectsWindowOrigin = effectsWindowOrigin
        }
    }
}

extension WindowLayoutState {
    
    static func initialize(_ persistentState: WindowLayoutPersistentState) {
        
        Self.showPlaylist = persistentState.showPlaylist ?? WindowLayoutDefaults.showPlaylist
        Self.showEffects = persistentState.showEffects ?? WindowLayoutDefaults.showEffects
        
        Self.mainWindowOrigin = persistentState.mainWindowOrigin ?? WindowLayoutDefaults.mainWindowOrigin
        Self.playlistWindowFrame = persistentState.playlistWindowFrame ?? WindowLayoutDefaults.playlistWindowFrame
        Self.effectsWindowOrigin = persistentState.effectsWindowOrigin ?? WindowLayoutDefaults.effectsWindowOrigin
        
        var userLayouts: [WindowLayout] = []
        
        for layout in persistentState.userLayouts ?? [] {
            
            userLayouts.append(WindowLayout(layout.name, layout.showEffects, layout.showPlaylist, layout.mainWindowOrigin, layout.effectsWindowOrigin, layout.playlistWindowFrame, false))
        }
        
        WindowLayouts.loadUserDefinedLayouts(userLayouts)
    }
    
    static var persistentState: WindowLayoutPersistentState {
        
        let uiState = WindowLayoutPersistentState()
        
        if let windowManager = WindowManager.instance {
            
            uiState.showEffects = windowManager.isShowingEffects
            uiState.showPlaylist = windowManager.isShowingPlaylist
            
            uiState.mainWindowOrigin = windowManager.mainWindowFrame.origin
            uiState.effectsWindowOrigin = windowManager.effectsWindow?.origin
            uiState.playlistWindowFrame = windowManager.playlistWindow?.frame
            
        } else {
            
            uiState.showEffects = WindowLayoutState.showEffects
            uiState.showPlaylist = WindowLayoutState.showPlaylist
            
            uiState.mainWindowOrigin = WindowLayoutState.mainWindowOrigin
            uiState.effectsWindowOrigin = WindowLayoutState.effectsWindowOrigin
            uiState.playlistWindowFrame = WindowLayoutState.playlistWindowFrame
        }

        uiState.userLayouts = WindowLayouts.userDefinedLayouts.map {UserWindowLayoutPersistentState($0.name, $0.showEffects, $0.showPlaylist, $0.mainWindowOrigin, $0.effectsWindowOrigin, $0.playlistWindowFrame)}
        
        return uiState
    }
}
