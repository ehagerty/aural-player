import Cocoa

class CustomColumnEditorDialogController: NSWindowController, NSWindowDelegate {
    
    override var windowNibName: String? {return "CustomColumnEditor"}
    
    @IBOutlet weak var lblFormat: NSTextField!
    @IBOutlet weak var lblExample: NSTextField!
    
    @IBOutlet weak var lblHeaderTitle: NSTextField!
    
    private var components: [ColumnFormatComponent] = []
    
    func showDialog() {
        
        if !self.isWindowLoaded {
            _ = self.window
        }
        
        lblHeaderTitle.stringValue = "<Custom Column>"
        components.removeAll()
        updateFormatDisplay()
        
        showWindow(self)
    }
    
    @IBAction func appendTitleFieldAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatMetadataField.title)
        updateFormatDisplay()
    }
    
    @IBAction func appendArtistFieldAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatMetadataField.artist)
        updateFormatDisplay()
    }
    
    @IBAction func appendAlbumFieldAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatMetadataField.album)
        updateFormatDisplay()
    }
    
    @IBAction func appendYearFieldAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatMetadataField.year)
        updateFormatDisplay()
    }
    
    @IBAction func appendDiscNumberFieldAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatMetadataField.discNumber)
        updateFormatDisplay()
    }
    
    @IBAction func appendTrackNumberFieldAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatMetadataField.trackNumber)
        updateFormatDisplay()
    }
    
    @IBAction func appendSpaceSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.space)
        updateFormatDisplay()
    }
    
    @IBAction func appendPeriodSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.period)
        updateFormatDisplay()
    }
    
    @IBAction func appendHyphenSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.hyphen)
        updateFormatDisplay()
    }
    
    @IBAction func appendUnderscoreSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.underscore)
        updateFormatDisplay()
    }
    
    @IBAction func appendOpenParenthesisSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.openParenthesis)
        updateFormatDisplay()
    }
    
    @IBAction func appendCloseParenthesisSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.closeParenthesis)
        updateFormatDisplay()
    }
    
    @IBAction func appendOpenBracketSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.openBracket)
        updateFormatDisplay()
    }
    
    @IBAction func appendCloseBracketSeparatorAction(_ sender: AnyObject) {
        
        components.append(ColumnFormatFieldSeparator.closeBracket)
        updateFormatDisplay()
    }
    
    @IBAction func deleteOneComponentAction(_ sender: AnyObject) {
        
        _ = components.removeLast()
        updateFormatDisplay()
    }
    
    @IBAction func clearFormatAction(_ sender: AnyObject) {
        
        components.removeAll()
        updateFormatDisplay()
    }
    
    private func updateFormatDisplay() {
        
        var formatString: String = ""
        var exampleString: String = ""
        
        for component in components {
            
            if let metadataField = component as? ColumnFormatMetadataField {
                
                formatString += "${\(metadataField.tokenString)}"
                
                switch metadataField {
                    
                case .title:
                    
                    exampleString += "Comfortably Numb"
                    
                case .artist:
                    
                    exampleString += "Pink Floyd"
                    
                case .album:
                    
                    exampleString += "The Wall"
                    
                case .discNumber:
                    
                    exampleString += "Disc 2 / 2"
                    
                case .trackNumber:
                    
                    exampleString += "Track 6 / 13"
                    
                case .year:
                    
                    exampleString += "1979"
                }
                
            } else if let separator = component as? ColumnFormatFieldSeparator {
                
                formatString += separator.value
                exampleString += separator.value
            }
        }
        
        lblFormat.stringValue = formatString
        lblExample.stringValue = exampleString
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        
        let column = CustomColumn(title: lblHeaderTitle.stringValue, formatComponents: components)
        Messenger.publish(LibraryCustomColumnAddCommandNotification(column: column))
        
        window!.close()
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        window!.close()
    }
}

protocol ColumnFormatComponent: CustomStringConvertible {
}

enum ColumnFormatMetadataField: String, ColumnFormatComponent {
    
    case title, artist, album, discNumber, trackNumber, year

    var description: String {rawValue.capitalized}
    
    func value(for track: Track) -> String? {
        
        switch self {
            
        case .title:
            
            return track.title ?? track.defaultDisplayName
            
        case .artist:
            
            return track.artist
            
        case .album:
            
            return track.album
            
        case .discNumber:
            
            return track.discNumber == nil ? nil : String(track.discNumber!)
            
        case .trackNumber:
            
            return track.trackNumber == nil ? nil : String(track.trackNumber!)
            
        case .year:
            
            // TODO
            return track.genre
        }
    }
    
    var tokenString: String {
        
        switch self {
            
        case .title:
            
            return "TITLE"
            
        case .artist:
            
            return "ARTIST"
            
        case .album:
            
            return "ALBUM"
            
        case .discNumber:
            
            return "DISC_NUMBER"
            
        case .trackNumber:
            
            return "TRACK_NUMBER"
            
        case .year:
            
            // TODO
            return "YEAR"
        }
    }
}

enum ColumnFormatFieldSeparator: String, ColumnFormatComponent {
    
    case space, period, hyphen, underscore, openParenthesis, closeParenthesis, openBracket, closeBracket
    
    var description: String {StringUtils.splitCamelCaseWord(self.rawValue, true)}
    
    var value: String {
        
        switch self {
            
        case .space:                    return " "
            
        case .period:                   return "."
            
        case .hyphen:                   return "-"
            
        case .underscore:               return "_"
            
        case .openParenthesis:          return "("
            
        case .closeParenthesis:         return ")"
            
        case .openBracket:              return "["
            
        case .closeBracket:             return "]"
            
        }
    }
}
