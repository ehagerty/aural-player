import Foundation

class PlayQueue: PlayQueueProtocol, NotificationSubscriber {
    
    var tracks: [Track] = []
    
    // MARK: Accessor functions
    
    var size: Int {tracks.count}
    
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    let library: LibraryProtocol
    
    // The underlying linear sequence of tracks for the current playback scope
    let sequence: PlaybackSequence
    
    // Stores the currently playing track, if there is one
    private(set) var currentTrack: Track?
    
    private var persistentStateOnStartup: PlayQueueState?
    
    init(library: LibraryProtocol, persistentStateOnStartup: PlayQueueState) {
        
        self.library = library
        self.persistentStateOnStartup = persistentStateOnStartup
        
        self.tracks = []
        
        sequence = PlaybackSequence(persistentStateOnStartup.repeatMode, persistentStateOnStartup.shuffleMode)
        currentTrack = nil
        
        Messenger.subscribe(self, .library_doneAddingTracks, {
            
            // This should only be done once, the very first time tracks are added to the library (i.e. on app startup).
            if let persistentState = self.persistentStateOnStartup {
            
                self.tracks = persistentState.tracks.compactMap {file in
                    
                    if let trackInLibrary = self.library.findTrackByFile(file) {
                        return trackInLibrary
                    }
                    
                    let track = Track(file)
                    track.loadPrimaryMetadata()
                    
                    if !track.isValidTrack {
                        print("\(track.file.path) is not a valid track ! Error: \(String(describing: track.validationError))")
                    }
                    
                    return track.isValidTrack ? track : nil
                }
                
                if self.tracks.isNonEmpty {
                    Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: 0...self.tracks.lastIndex))
                }
                
                self.persistentStateOnStartup = nil
                Messenger.unsubscribe(self, .library_doneAddingTracks)
            }
        })
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return tracks.itemAtIndex(index)
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        return tracks.firstIndex(of: track)
    }
    
    var summary: (size: Int, totalDuration: Double) {(size, duration)}
    
    // MARK: Mutator functions ------------------------------------------------------------------------
    
    func enqueue(_ tracks: [Track]) -> ClosedRange<Int> {
        
        let indices = self.tracks.addItems(tracks)
        sequence.resize(size: size)
        return indices
    }
    
    func enqueueAtHead(_ tracks: [Track]) -> ClosedRange<Int> {
        
        self.tracks.insert(contentsOf: tracks, at: 0)
        
        if let playingTrackIndex = sequence.curTrackIndex {
            
            // The playing track has moved down n rows, where n is the size of the array of newly added tracks.
            sequence.resizeAndStart(size: size, withTrackIndex: playingTrackIndex + tracks.count)
            
        } else { // No playing track, just resize
            sequence.resize(size: size)
        }

        return 0...tracks.lastIndex
    }
    
    // TODO
    func enqueueAfterCurrentTrack(_ tracks: [Track]) -> ClosedRange<Int> {
        
        let insertionPoint = (sequence.curTrackIndex ?? -1) + 1
        self.tracks.insert(contentsOf: tracks, at: insertionPoint)
        sequence.resize(size: size)
        
        return insertionPoint...(insertionPoint + tracks.lastIndex)
    }
    
    func removeTracks(_ indexes: IndexSet) -> [Track] {
        
        let removedTracks = tracks.removeItems(indexes)
        
        if let playingTrackIndex = sequence.curTrackIndex {
            
            // Playing track removed
            if indexes.contains(playingTrackIndex) {
                
                currentTrack = nil
                sequence.resizeAndStart(size: size, withTrackIndex: nil)
                
            } else {
                
                // Compute how many tracks above (i.e. <) playingTrackIndex were removed ... this will determine the adjustment to the playing track index.
                let adjustment = indexes.filter {$0 < playingTrackIndex}.count
                sequence.resizeAndStart(size: size, withTrackIndex: playingTrackIndex - adjustment)
            }
            
        } else { // No playing track, just resize
            sequence.resize(size: size)
        }
        
        return removedTracks
    }
    
    func clear() {
        tracks.removeAll()
    }
    
    func moveTracksUp(_ indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {tracks.moveItemsUp(indices)}
    }
    
    func moveTracksDown(_ indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {tracks.moveItemsDown(indices)}
    }
    
    func moveTracksToTop(_ indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {tracks.moveItemsToTop(indices)}
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {tracks.moveItemsToBottom(indices)}
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> [TrackMoveResult] {
        return doMoveTracks {tracks.dragAndDropItems(sourceIndexes, dropIndex)}
    }
    
    private func doMoveTracks(_ moveOperation: () -> [Int: Int]) -> [TrackMoveResult] {
        
        let moveIndicesMap = moveOperation()
        
        // If the playing track was moved, update the index of the playing track within the sequence
        if let playingTrackIndex = sequence.curTrackIndex, let newPlayingTrackIndex = moveIndicesMap[playingTrackIndex] {
            sequence.start(withTrackIndex: newPlayingTrackIndex)
        }
        
        return moveIndicesMap.map {TrackMoveResult($0.key, $0.value)}
    }
    
    // MARK: Search ------------------------------------------------------------------------------------------------------
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        
        return SearchResults(tracks.compactMap {executeQuery($0, searchQuery)}.map {
            
            SearchResult(location: SearchResultLocation(trackIndex: -1, track: $0.track, groupInfo: nil),
                         match: ($0.matchedField, $0.matchedFieldValue))
        })
    }
    
    private func executeQuery(_ track: Track, _ query: SearchQuery) -> SearchQueryMatch? {
        
        // Check both the filename and the display name
        if query.fields.name {
            
//            let filename = track.fileSystemInfo.fileName
//            if query.compare(filename) {
//                return SearchQueryMatch(track: track, matchedField: "filename", matchedFieldValue: filename)
//            }
            
            let displayName = track.defaultDisplayName
            if query.compare(displayName) {
                return SearchQueryMatch(track: track, matchedField: "name", matchedFieldValue: displayName)
            }
        }
        
        // Compare title field if included in search
        if query.fields.title, let theTitle = track.title, query.compare(theTitle) {
            return SearchQueryMatch(track: track, matchedField: "title", matchedFieldValue: theTitle)
        }
        
        // Didn't match
        return nil
    }
    
    // MARK: Sequencing functions --------------------------------------------------------------------------------
    
    func begin() -> Track? {
        
        // Set the scope of the new sequence according to the playlist view type. For ex, if the "Artists" playlist view is selected, the new sequence will consist of all tracks in the "Artists" playlist, and the order of playback will be determined by the ordering within the Artists playlist (in addition to the repeat/shuffle modes).
        
        // Reset the sequence, with the size of the playlist
        sequence.resizeAndStart(size: size, withTrackIndex: nil)
        
        // Begin playing the subsequent track (first track determined by the sequence)
        return subsequent()
    }
    
    func end() {
        
        // Reset the sequence cursor (to indicate that no track is playing)
        sequence.end()
        currentTrack = nil
    }
    
    // MARK: Specific track selection functions -------------------------------------------------------------------------------------
    
    func select(_ index: Int) -> Track? {
        return startSequence(size, index)
    }
    
    // Helper function to select a track with a specific index within the current playback sequence
    private func startSequence(_ size: Int, _ trackIndex: Int) -> Track? {
        
        sequence.resizeAndStart(size: size, withTrackIndex: trackIndex)
        
        if let track = tracks.itemAtIndex(trackIndex) {
            
            currentTrack = track
            return track
        }
        
        return nil
    }
    
    func select(_ track: Track) -> Track? {
        return nil
    }
    
    func select(_ group: Group) -> Track? {
//
//        // Reset the sequence based on the group's size
//        sequence.resizeAndStart(size: group.size, withTrackIndex: nil)
//
//        // Begin playing the subsequent track (first track determined by the sequence)
//        return subsequent()
        return nil
    }
    
    // MARK: Sequence iteration functions -------------------------------------------------------------------------------------
    
    func subsequent() -> Track? {
        
        if let subsequentIndex = sequence.subsequent() {
            
            currentTrack = tracks.itemAtIndex(subsequentIndex)
            return currentTrack
        }
        
        currentTrack = nil
        return nil
    }
    
    func next() -> Track? {
        
        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        if let nextIndex = sequence.next(), let nextTrack = tracks.itemAtIndex(nextIndex) {
            
            currentTrack = nextTrack
            return nextTrack
        }
        
        return nil
    }
    
    func previous() -> Track? {
        
        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        if let previousIndex = sequence.previous(), let previousTrack = tracks.itemAtIndex(previousIndex) {
            
            currentTrack = previousTrack
            return previousTrack
        }
        
        return nil
    }
    
    func peekSubsequent() -> Track? {
        
        if let subsequentIndex = sequence.peekSubsequent() {
            return tracks.itemAtIndex(subsequentIndex)
        }
        
        return nil
    }
    
    func peekNext() -> Track? {
        
        if let nextIndex = sequence.peekNext(), let nextTrack = tracks.itemAtIndex(nextIndex) {
            return nextTrack
        }
        
        return nil
    }
    
    func peekPrevious() -> Track? {
        
        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        if let previousIndex = sequence.peekPrevious(), let previousTrack = tracks.itemAtIndex(previousIndex) {
            return previousTrack
        }
        
        return nil
    }
    
    // MARK: Repeat/Shuffle -------------------------------------------------------------------------------------
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.setRepeatMode(repeatMode)
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.setShuffleMode(shuffleMode)
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.toggleRepeatMode()
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.toggleShuffleMode()
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.repeatAndShuffleModes
    }
}
