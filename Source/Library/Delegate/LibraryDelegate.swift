import Foundation

class LibraryDelegate: LibraryDelegateProtocol, NotificationSubscriber {
   
    var summary: (size: Int, totalDuration: Double) {library.summary}
    
    // The actual playlist
    private let library: LibraryProtocol
    
    // Persistent playlist state (used upon app startup)
    private let libraryState: LibraryState
    
    // User preferences (used for autoplay)
    private let preferences: Preferences
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()
    
    private var addSession: TrackAddSession<TrackAddResult>!
    
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    var isBeingModified: Bool {addSession != nil}
    
    var tracks: [Track] {library.tracks}
    
    var size: Int {library.size}
    
    var duration: Double {library.duration}
    
    init(_ library: LibraryProtocol, _ libraryState: LibraryState, _ preferences: Preferences) {
        
        self.library = library
        
        self.libraryState = libraryState
        self.preferences = preferences
        
        trackAddQueue.maxConcurrentOperationCount = concurrentAddOpCount
        trackAddQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        trackAddQueue.qualityOfService = .userInteractive
        
        trackUpdateQueue.maxConcurrentOperationCount = concurrentAddOpCount
        trackUpdateQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        trackUpdateQueue.qualityOfService = .utility
        
        // Subscribe to notifications
        Messenger.subscribe(self, .application_launched, self.appLaunched(_:))
        Messenger.subscribe(self, .application_reopened, self.appReopened(_:))
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return library.indexOfTrack(track)
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return library.trackAtIndex(index)
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return library.search(searchQuery)
    }
    
    func findTrackByFile(_ file: URL) -> Track? {
        return library.findTrackByFile(file)
    }
    
    func savePlaylist(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
    
    // MARK: Playlist mutation functions --------------------------------------------------
    
    func addFiles(_ files: [URL]) {
        addFiles_async(files)
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], _ userAction: Bool = true) {
        
        addSession = TrackAddSession<TrackAddResult>(files.count, .defaultOptions)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // ------------------ ADD --------------------
            
            Messenger.publish(.library_startedAddingTracks)
            
            self.collectTracks(files, false)
            self.addSessionTracks()
            
            // ------------------ NOTIFY ------------------
            
            let results = self.addSession.results
            
            if userAction {
                Messenger.publish(.history_itemsAdded, payload: self.addSession.addedItems)
            }
            
            Messenger.publish(.library_doneAddingTracks)
            
            // If errors > 0, send AsyncMessage to UI
            if self.addSession.errors.isNonEmpty {
                Messenger.publish(.library_tracksNotAdded, payload: self.addSession.errors)
            }
            
            self.addSession = nil
            
            // ------------------ UPDATE --------------------
            
            self.trackUpdateQueue.addOperations(results.map {result in BlockOperation {result.track.loadSecondaryMetadata()}},
                                                waitUntilFinished: false)
        }
    }
    
    /*
     Adds a bunch of files synchronously.
     
     The autoplayOptions argument encapsulates all autoplay options.
     
     The progress argument indicates current progress.
     */
    private func collectTracks(_ files: [URL], _ isRecursiveCall: Bool) {
        
        for file in files {
            
            // Playlists might contain broken file references
            if !FileSystemUtils.fileExists(file) {
                
                addSession.addError(FileNotFoundError(file))
                continue
            }
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
            let resolvedFile = resolvedFileInfo.resolvedURL
            
            if resolvedFileInfo.isDirectory {
                
                // Directory
                if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                expandDirectory(resolvedFile)
                
            } else {
                
                // Single file - playlist or track
                let fileExtension = resolvedFile.pathExtension.lowercased()
                
                if AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
                    // Playlist
                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                    expandPlaylist(resolvedFile)
                    
                } else if AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension),
                    !library.hasTrackForFile(resolvedFile) {
                    
                    // Track
                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                    addSession.tracks.append(Track(resolvedFile))
                }
            }
        }
    }
    
    // Expands a playlist into individual tracks
    private func expandPlaylist(_ playlistFile: URL) {
        
        if let loadedPlaylist = PlaylistIO.loadPlaylist(playlistFile) {
            
            addSession.totalTracks += loadedPlaylist.tracks.count - 1
            collectTracks(loadedPlaylist.tracks, true)
        }
    }
    
    // Expands a directory into individual tracks (and subdirectories)
    private func expandDirectory(_ dir: URL) {
        
        if let dirContents = FileSystemUtils.getContentsOfDirectory(dir) {
            
            addSession.totalTracks += dirContents.count - 1
            collectTracks(dirContents, true)
        }
    }
    
    private func addSessionTracks() {
        
        var firstBatchIndex: Int = 0
        while addSession.tracksProcessed < addSession.tracks.count {
            
            let remainingTracks = addSession.tracks.count - addSession.tracksProcessed
            let lastBatchIndex = firstBatchIndex + min(remainingTracks, concurrentAddOpCount) - 1
            
            let batch = firstBatchIndex...lastBatchIndex
            processBatch(batch)
            addSession.tracksProcessed += batch.count
            
            firstBatchIndex = lastBatchIndex + 1
        }
    }
    
    private func processBatch(_ batch: AddBatch) {
        
        let addSessionTracks: [Track] = batch.map({addSession.tracks[$0]})
        
        // Process all tracks in batch concurrently and wait until the entire batch finishes.
        trackAddQueue.addOperations(addSessionTracks.map {track in BlockOperation {track.loadPrimaryMetadata()}}, waitUntilFinished: true)
        
        for track in addSessionTracks {
            
            if track.isValidTrack, let result = self.library.addTrack(track) {
                
                addSession.tracksAdded.increment()
                addSession.results.append(TrackAddResult(track: track, flatPlaylistResult: result))

                let progress = TrackAddOperationProgress(tracksAdded: addSession.tracksAdded, totalTracks: addSession.totalTracks)
                Messenger.publish(LibraryTrackAddedNotification(trackIndex: result, addOperationProgress: progress))
                
            } else if !track.isValidTrack {
                addSession.errors.append(track.validationError as? DisplayableError ?? InvalidTrackError(track))
            }
        }
    }
    
    func findOrAddFile(_ file: URL) throws -> Track? {
        
        // If track exists, return it
        if let foundTrack = library.findTrackByFile(file) {
            return foundTrack
        }
        
        // Always resolve sym links and aliases before reading the file
        let resolvedFile = FileSystemUtils.resolveTruePath(file).resolvedURL
        
        // If track exists, return it
        if let foundTrack = library.findTrackByFile(resolvedFile) {
            return foundTrack
        }
        
        // Track doesn't exist yet, need to add it
        
        // If the file points to an invalid location, throw an error
        guard FileSystemUtils.fileExists(resolvedFile) else {throw FileNotFoundError(resolvedFile)}
        
        // Load display info
        let track = Track(resolvedFile)
//        TrackIO.loadPrimaryInfo(track)
        
        // Non-nil result indicates success
        guard let result = self.library.addTrack(track) else {return nil}
        
        let trackAddedNotification = LibraryTrackAddedNotification(trackIndex: result, addOperationProgress:
            TrackAddOperationProgress(tracksAdded: 1, totalTracks: 1))
        
        Messenger.publish(trackAddedNotification)
        Messenger.publish(.history_itemsAdded, payload: [resolvedFile])
        
//        TrackIO.loadSecondaryInfo(track)
        
        return track
    }
    
    // Performs autoplay, by delegating a playback request to the player
    private func autoplay(_ autoplayType: AutoplayCommandType, _ track: Track, _ interruptPlayback: Bool) {
        
        Messenger.publish(autoplayType == .playSpecificTrack ?
            AutoplayCommandNotification(type: .playSpecificTrack, interruptPlayback: interruptPlayback, candidateTrack: track) :
            AutoplayCommandNotification(type: .beginPlayback))
    }
    
    func removeTracks(_ indexes: IndexSet) {
        
        let tracks = library.removeTracks(indexes)
        let results: TrackRemovalResults = TrackRemovalResults(flatPlaylistResults: indexes, tracks: tracks)
        
        Messenger.publish(.library_tracksRemoved, payload: results)
    }
    
    func clear() {
        library.clear()
    }
    
    func sort(_ sort: Sort) {
        _ = library.sort(sort)
    }
    
    func sort(by comparator: (Track, Track) -> Bool) {
        library.sort(by: comparator)
    }
    
    // MARK: Message handling
    
    func appLaunched(_ filesToOpen: [URL]) {
        
        // Check if any launch parameters were specified
        if filesToOpen.isNonEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
            addFiles_async(filesToOpen, false)
            
        } else if preferences.playlistPreferences.playlistOnStartup == .rememberFromLastAppLaunch {
            
            // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
            addFiles_async(libraryState.tracks, false)
            
        } else if preferences.playlistPreferences.playlistOnStartup == .loadFile, let playlistFile: URL = preferences.playlistPreferences.playlistFile {
            
            addFiles_async([playlistFile], false)
            
        } else if preferences.playlistPreferences.playlistOnStartup == .loadFolder, let folder: URL = preferences.playlistPreferences.tracksFolder {
            
            addFiles_async([folder], false)
        }
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
        addFiles_async(notification.filesToOpen)
    }
}
