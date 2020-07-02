import Foundation

enum SidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    case library = "Library"
    case history = "History"
    case playlists = "Playlists"
    
    var description: String {rawValue}
}

struct SidebarItem {
    
    let displayName: String
}
