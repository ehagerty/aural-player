import Cocoa

class PlayQueueTrackArtCell: NSTableCellView {
    
    @IBInspectable @IBOutlet weak var imgArt: NSImageView!
    
    var art: NSImage? {
        
        get {imgArt.image}
        
        set(newValue) {
            imgArt.image = newValue
            imgArt.cornerRadius = 2
        }
    }
}

class PlayQueueTrackInfoCell: NSTableCellView {
    
    @IBInspectable @IBOutlet weak var lblName: NSTextField!
    
    @IBInspectable @IBOutlet weak var lblTitle: NSTextField!
    @IBInspectable @IBOutlet weak var lblArtistAlbum: NSTextField!
    
    var titleFont: NSFont {
        
        get {lblTitle.font!}
        
        set(newValue) {
            
            lblName.font = newValue
            lblName.textColor = Colors.Constants.white90Percent
            
            lblTitle.font = newValue
            lblTitle.textColor = Colors.Constants.white90Percent
        }
    }
    
    var artistAlbumFont: NSFont {
        
        get {lblArtistAlbum.font!}
        
        set(newValue) {
            lblArtistAlbum.font = newValue
            lblArtistAlbum.textColor = Colors.Constants.white70Percent
        }
    }
    
    func initializeForTrack(_ track: Track) {
        
        let artist = track.groupingInfo.artist
        let album = track.groupingInfo.album
        
        if let theArtist = artist, let theAlbum = album {
            
            lblName.stringValue = ""
            lblTitle.stringValue = track.displayInfo.title
            lblArtistAlbum.stringValue = "\(theArtist) -- \(theAlbum)"
            
        } else if let theArtist = artist {
            
            lblName.stringValue = ""
            lblTitle.stringValue = track.displayInfo.title
            lblArtistAlbum.stringValue = theArtist
            
        } else if let theAlbum = album {
            
            lblName.stringValue = ""
            lblTitle.stringValue = track.displayInfo.title
            lblArtistAlbum.stringValue = theAlbum
            
        } else {
            
            // No artist, no album
            lblName.stringValue = track.displayInfo.title
            lblTitle.stringValue = ""
            lblArtistAlbum.stringValue = ""
        }
    }
}
