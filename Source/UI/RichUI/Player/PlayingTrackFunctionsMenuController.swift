import Cocoa

class PlayingTrackFunctionsMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playingTrackFunctionsMenu: NSMenu!
    
    @IBAction func playingTrackFunctionsAction(_ sender: AnyObject) {
        playingTrackFunctionsMenu.popUp(positioning: playingTrackFunctionsMenu.item(at: 0), at: NSEvent.mouseLocation, in: nil)
    }
}
