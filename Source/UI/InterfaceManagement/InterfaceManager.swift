import Foundation

class InterfaceManager {
    
    var currentInterface: InterfaceType = .unified
    var interfaces: [InterfaceType: InterfaceProtocol] = [:]
    
    let unifiedInterface: UnifiedInterface
    let modularInterface: ModularInterface
    
    init(_ appState: UIState, _ preferences: ViewPreferences) {
        
        self.unifiedInterface = UnifiedInterface()
        self.modularInterface = ModularInterface(appState.windowLayout, preferences)
        
        interfaces = [modularInterface.type: modularInterface, unifiedInterface.type: unifiedInterface]
    }
    
    func showInterface(type: InterfaceType) {
        
        interfaces[type]?.show()
        currentInterface = type
    }
}

enum InterfaceType {
    
    case modular
    case unified
}

protocol InterfaceProtocol {
    
    var type: InterfaceType {get}
    
    func show()
    
    func hide()
}
