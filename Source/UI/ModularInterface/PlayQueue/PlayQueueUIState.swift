import Cocoa

struct DisplayedTableColumn {
    
    let id: String
    let width: CGFloat
}

class PlayQueueUIState {
    
    static var view: PlayQueueView = .list
    static var tableViewColumns: [DisplayedTableColumn] = []
    
    static func initialize(fromPersistentState state: PlayQueueUIPersistentState) {
        
        view = PlayQueueView(rawValue: state.view) ?? .list
        tableViewColumns = state.tableViewColumns
    }
    
    static var persistentState: PlayQueueUIPersistentState {
        
        let state = PlayQueueUIPersistentState()
        
        state.view = view.rawValue
        state.tableViewColumns = tableViewColumns
        
        return state
    }
}

class PlayQueueUIPersistentState: PersistentState {
    
    var view: String = "list"
    var tableViewColumns: [DisplayedTableColumn] = []
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlayQueueUIPersistentState()
        
        if let view = map["view"] as? String {
            state.view = view
        }
        
        if let columnDicts = map["tableViewColumns"] as? [NSDictionary] {
            
            for columnDict in columnDicts {
                
                if let id = columnDict["id"] as? String, let width = columnDict["width"] as? NSNumber {
                    state.tableViewColumns.append(DisplayedTableColumn(id: id, width: width.cgFloat))
                }
            }
        }
        
        return state
    }
}

enum PlayQueueView: String {
    
    case list, table
}
