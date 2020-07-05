import Foundation

struct FileSystemItem {
    
    let url: URL
    var children: [FileSystemItem] = []
    
    init(url: URL) {
        
        self.url = url
        self.children = loadChildren(url)
    }
    
    private func loadChildren(_ dir: URL) -> [FileSystemItem] {
        
        if !dir.hasDirectoryPath {return []}
        
        if let contents = FileSystemUtils.getContentsOfDirectory(dir) {
            return contents.map {FileSystemItem(url: $0)}
        }
        
        return []
    }
    
    var isDirectory: Bool {url.hasDirectoryPath}
    
//    static func fromRootDir(_ dir: URL) -> FileSystemItem {
//
//        if let contents = FileSystemUtils.getContentsOfDirectory(dir) {
//            let children: [FileSystemItem] = contents.map {child in
//
//                let contents = child.hasDirectoryPath ? FileSystemUtils.getContentsOfDirectory(dir) ?? [] : []
//                return FileSystemItem(url: child, children: contents)
//            }
//        }
//
//        return FileSystemItem(url: dir, children: [])
//    }
}
