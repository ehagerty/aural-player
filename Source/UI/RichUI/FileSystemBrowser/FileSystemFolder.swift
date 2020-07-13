import Foundation

struct FileSystemItem {
    
    let url: URL
    var children: [FileSystemItem] = []
    
    var fileExtension: String {url.pathExtension.lowercased()}
    
    init(url: URL) {
        
        self.url = url
        self.children = loadChildren(url)
    }
    
    private func loadChildren(_ dir: URL) -> [FileSystemItem] {
        
        if !dir.hasDirectoryPath {return []}
        
        if let dirContents = FileSystemUtils.getContentsOfDirectory(dir) {
            return dirContents.map{FileSystemItem(url: $0)}.filter {$0.isTrack || $0.isPlaylist || $0.isDirectory}
        }
        
        return []
    }
    
    var isDirectory: Bool {url.hasDirectoryPath}
    
    var isPlaylist: Bool {AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension)}
    
    var isTrack: Bool {AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension)}
}
