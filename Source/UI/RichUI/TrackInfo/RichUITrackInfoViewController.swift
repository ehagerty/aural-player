import Cocoa

class RichUITrackInfoViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var albumArtView: NSImageView!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblArtist: NSTextField!
    @IBOutlet weak var lblAlbum: NSTextField!
    
    override var nibName: String? {return "RichUITrackInfo"}
    
    override func viewDidLoad() {
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if let track = notification.endTrack {
            
            albumArtView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
            
            lblTitle.stringValue = track.displayInfo.title
            lblArtist.stringValue = track.groupingInfo.artist ?? ""
            lblAlbum.stringValue = track.groupingInfo.album ?? ""
        }
    }
}
