import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by the library.

    // Signifies that the library has begun adding a set of tracks.
    static let library_startedAddingTracks = Notification.Name("library_startedAddingTracks")
    
    // Signifies that the library has finished adding a set of tracks.
    static let library_doneAddingTracks = Notification.Name("library_doneAddingTracks")
    
    // Signifies that a new track has been added to the library.
    static let library_trackAdded = Notification.Name("library_trackAdded")
    
    // Signifies that some chosen tracks could not be added to the library (i.e. an error condition).
    static let library_tracksNotAdded = Notification.Name("library_tracksNotAdded")
    
    // Signifies that some tracks have been removed from the library.
    static let library_tracksRemoved = Notification.Name("library_tracksRemoved")
    
    // MARK: Commands ----------------------------------------------------------------
    
    static let library_toggleTableHeader = Notification.Name("library_toggleTableHeader")
    static let library_addCustomColumn = Notification.Name("library_addCustomColumn")
    
    // Commands the library to display a file dialog to let the user add new tracks.
    static let library_addTracks = Notification.Name("library_addTracks")
    static let library_removeTracks = Notification.Name("library_removeTracks")
    static let library_clear = Notification.Name("library_clear")
    
    // Commands a library to refresh its list view (eg. in response to tracks being added/removed/updated).
    static let library_refresh = Notification.Name("library_refresh")
    
    static let library_playNow = Notification.Name("library_playNow")
    static let library_playNext = Notification.Name("library_playNext")
    static let library_playLater = Notification.Name("library_playLater")
}

// Indicates that a new track has been added to the playlist, and that the UI should refresh itself to show the new information.
struct LibraryTrackAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .library_trackAdded
    
    // The index of the newly added track
    let trackIndex: Int
    
    // The current progress of the track add operation (See TrackAddOperationProgress)
    let addOperationProgress: TrackAddOperationProgress
}

// Indicates that a new track has been added to the playlist, and that the UI should refresh itself to show the new information.
struct LibraryCustomColumnAddCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .library_addCustomColumn
    
    let column: CustomColumn
}
