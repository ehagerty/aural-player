/*
    A collection of constants for use by the UI
*/
import Cocoa

struct UIConstants {
    
    // Playlist view column identifiers
    static let playlistIndexColumnID: String = "cid_Index"
    static let playlistNameColumnID: String = "cid_Name"
    static let playlistDurationColumnID: String = "cid_Duration"
    
    static let chapterIndexColumnID: String = "cid_chapterIndex"
    static let chapterTitleColumnID: String = "cid_chapterTitle"
    static let chapterStartTimeColumnID: String = "cid_chapterStartTime"
    static let chapterDurationColumnID: String = "cid_chapterDuration"
    
    // Track info view column identifiers (popover)
    static let trackInfoKeyColumnID: String = "cid_TrackInfoKey"
    static let trackInfoValueColumnID: String = "cid_TrackInfoValue"
    
    // Index set used to reload specific playlist rows
    static let flatPlaylistViewColumnIndexes: IndexSet = IndexSet([0, 1, 2])
    
    static let bookmarkNameColumnID: String = "cid_BookmarkName"
    static let bookmarkTrackColumnID: String = "cid_BookmarkTrack"
    static let bookmarkStartPositionColumnID: String = "cid_BookmarkStartPosition"
    static let bookmarkEndPositionColumnID: String = "cid_BookmarkEndPosition"
    
    static let favoriteNameColumnID: String = "cid_FavoriteName"
    
    static let filterBandsFreqColumnID: String = "cid_Frequencies"
    static let filterBandsTypeColumnID: String = "cid_Type"
    
    static let audioUnitSwitchColumnID: String = "cid_AudioUnitSwitch"
    static let audioUnitNameColumnID: String = "cid_AudioUnitName"
    static let audioUnitEditColumnID: String = "cid_AudioUnitEdit"
    
    // Angles used to fill gradients
    static let verticalGradientDegrees: CGFloat = -90.0
    static let horizontalGradientDegrees: CGFloat = -180.0
    
    // Recorder timer interval (milliseconds)
    static let recorderTimerIntervalMillis: Int = 500
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    static let favoritesPopupAutoHideIntervalSeconds: TimeInterval = 1.5
    
    // Maximum time gap between scroll events for them to be considered as being part of the same scroll session
    static let scrollSessionMaxTimeGapSeconds: TimeInterval = (1.0/6)
    
    static let offState: NSControl.StateValue = NSControl.StateValue(rawValue: 0)
    static let onState: NSControl.StateValue = NSControl.StateValue(rawValue: 1)
}
