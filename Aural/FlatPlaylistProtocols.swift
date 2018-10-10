/*
    Set of protocols for CRUD operations performed on the flat playlist
 */
import Foundation

/*
    Contract for all read-only operations on the flat (Tracks) playlist
 */
protocol FlatPlaylistAccessorProtocol {
    
    // Retrieves all tracks
    func allTracks() -> [Track]
    
    // Returns the track at a given index. Returns nil if an invalid index is specified.
    func trackAtIndex(_ index: Int?) -> IndexedTrack?
    
    // Returns the size (i.e. total number of tracks) of the playlist
    func size() -> Int
    
    // Returns the total duration of the playlist tracks
    func totalDuration() -> Double
 
    // Determines the index of a given track, within the playlist. Returns nil if the track doesn't exist within the playlist.
    func indexOfTrack(_ track: Track) -> Int?
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    // Returns the display name for a track within the playlist
    func displayNameForTrack(_ track: Track) -> String
    
    func getGapBeforeTrack(_ track: Track) -> PlaybackGap?
    
    func getGapAfterTrack(_ track: Track) -> PlaybackGap?
}

/*
    Contract for all write/mutating operations on the flat (Tracks) playlist
 */
protocol FlatPlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns its index within the playlist.
    func addTrack(_ track: Track) -> Int
    
    // Removes track(s) with the given indexes. Returns the specific tracks that were removed.
    func removeTracks(_ indexes: IndexSet) -> [Track]
    
    // Removes the specific tracks from the playlist. Returns the indexes of the removed tracks.
    func removeTracks(_ tracks: [Track]) -> IndexSet
    
    func insertGapForTrack(_ index: Int, _ gap: PlaybackGap)
    
    func removeGapBeforeTrack(_ index: Int)
    
    func removeGapAfterTrack(_ index: Int)
    
    /*
        Moves the tracks at the specified indexes, up one index, in the playlist, if they can be moved (they are not already at the top). 
     
        Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Moves the tracks at the specified indexes, down one index, in the playlist, if they can be moved (they are not already at the bottom).
     
        Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Performs a drag and drop reordering operation on the playlist, from a set of source indexes to a destination drop index (either on or above the drop index). 
     
        Returns the set of new destination indexes for the reordered tracks.
     */
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}

protocol FlatPlaylistCRUDProtocol: FlatPlaylistAccessorProtocol, FlatPlaylistMutatorProtocol {}
