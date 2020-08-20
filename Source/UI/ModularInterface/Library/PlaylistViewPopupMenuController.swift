import Cocoa

class PlaylistViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var toggleTableHeaderMenuItem: NSMenuItem!
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    private var textSizeMenuItems: [NSMenuItem] = []
    
    override func awakeFromNib() {
        textSizeMenuItems = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        toggleTableHeaderMenuItem.onIf(PlaylistViewState.isShowingTableHeader)
        
        textSizeMenuItems.forEach({$0.off()})
        
        switch PlaylistViewState.textSize {
            
        case .normal:   textSizeNormalMenuItem.on()
            
        case .larger:   textSizeLargerMenuItem.on()
            
        case .largest:  textSizeLargestMenuItem.on()
            
        }
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        if let size = TextSize(rawValue: sender.title.lowercased()), PlaylistViewState.textSize != size {
            
            PlaylistViewState.textSize = size
            Messenger.publish(.playlist_changeTextSize, payload: size)
        }
    }
    
    @IBAction func toggleTableHeaderAction(_ sender: NSMenuItem) {
        
        PlaylistViewState.isShowingTableHeader.toggle()
        Messenger.publish(.library_toggleTableHeader)
    }
}
