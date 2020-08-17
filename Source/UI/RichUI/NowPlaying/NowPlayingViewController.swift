import Cocoa

class NowPlayingViewController: NSViewController, NotificationSubscriber {
    
    override var nibName: String? {return "NowPlaying"}
    
    @IBOutlet weak var albumArtView: NSImageView!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblArtist: NSTextField!
    
    override func viewDidLoad() {
        
//        albumArtView.cornerRadius = 2
        
        // MARK: Notifications --------------------------------------------------------------
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed(_:))
        
        // MARK: Commands --------------------------------------------------------------
        
//        Messenger.subscribe(self, .applyColorScheme, playbackView.applyColorScheme(_:))
//        Messenger.subscribe(self, .changeFunctionButtonColor, playbackView.changeFunctionButtonColor(_:))
//        Messenger.subscribe(self, .changeToggleButtonOffStateColor, playbackView.changeToggleButtonOffStateColor(_:))
//
//        Messenger.subscribe(self, .player_changeTextSize, playbackView.changeTextSize(_:))
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: Track?) {
        
        if let track = newTrack {
            
            albumArtView.image = track.art?.image ?? Images.imgPlayingArt
            
            lblTitle.stringValue = track.title ?? track.defaultDisplayName
            
            let artist = track.artist
            let album = track.album
            
            if let theArtist = artist, let theAlbum = album {
                lblArtist.stringValue = "\(theArtist) -- \(theAlbum)"
                
            } else if let theArtist = artist {
                lblArtist.stringValue = theArtist
                
            } else if let theAlbum = album {
                lblArtist.stringValue = theAlbum
                
            } else {
                lblArtist.stringValue = ""
            }
            
        } else {  // No track
            
            albumArtView.image = Images.imgPlayingArt
            [lblTitle, lblArtist].forEach {$0?.stringValue = ""}
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        self.trackChanged(nil)
    }
 
    // MARK: Message handling ---------------------------------------------------------------------
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
    
    func changeTextSize(_ size: TextSize) {
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
    }
}
