/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
 */

import Foundation

class ObjectGraph {
    
    static var appState: AppState!
    static var preferences: Preferences!
    
    static var preferencesDelegate: PreferencesDelegate!
    
    private static var playlist: PlaylistCRUDProtocol!
    static var playlistAccessor: PlaylistAccessorProtocol! {return playlist}
    
    static var playlistDelegate: PlaylistDelegateProtocol!
    static var playlistAccessorDelegate: PlaylistAccessorDelegateProtocol! {return playlistDelegate}
    
    static var playQueue: PlayQueueProtocol!
    static var playQueueDelegate: PlayQueueDelegateProtocol!
    
    private static var library: LibraryProtocol!
    static var libraryDelegate: LibraryDelegateProtocol!
    
    private static var audioGraph: AudioGraphProtocol!
    static var audioGraphDelegate: AudioGraphDelegateProtocol!
    
    private static var player: PlayerProtocol!
    private static var avfScheduler: PlaybackSchedulerProtocol!
    private static var ffmpegScheduler: PlaybackSchedulerProtocol!
    private static var sequencer: SequencerProtocol!
    
    static var sampleConverter: SampleConverterProtocol!
    
    static var sequencerDelegate: SequencerDelegateProtocol!
    static var sequencerInfoDelegate: SequencerInfoDelegateProtocol! {return sequencerDelegate}
    
    static var playbackDelegate: PlaybackDelegateProtocol!
    static var playbackInfoDelegate: PlaybackInfoDelegateProtocol! {return playbackDelegate}
    
    private static var recorder: Recorder!
    static var recorderDelegate: RecorderDelegateProtocol!
    
    private static var history: History!
    static var historyDelegate: HistoryDelegateProtocol!
    
    private static var favorites: Favorites!
    static var favoritesDelegate: FavoritesDelegateProtocol!
    
    private static var bookmarks: Bookmarks!
    static var bookmarksDelegate: BookmarksDelegateProtocol!
    
    static var trackReader: TrackReader!
    
    static var mediaKeyHandler: MediaKeyHandler!
    
    static var interfaceManager: InterfaceManager!
    
    // Don't let any code invoke this initializer to create instances of ObjectGraph
    private init() {}
    
    // Performs all necessary object initialization
    static func initialize() {
        
        // Load persistent app state from disk
        // Use defaults if app state could not be loaded from disk
        appState = AppStateIO.load() ?? AppState.defaults
        
        // Preferences (and delegate)
        preferences = Preferences.instance
        preferencesDelegate = PreferencesDelegate(preferences)
        
        // Audio Graph (and delegate)
        audioGraph = AudioGraph(appState.audioGraph)
        
        // The new scheduler uses an AVFoundation API that is only available with macOS >= 10.13.
        // Instantiate the legacy scheduler if running on 10.12 Sierra or older systems.
        if #available(macOS 10.13, *) {
            avfScheduler = PlaybackScheduler(audioGraph.playerNode)
        } else {
            avfScheduler = LegacyPlaybackScheduler(audioGraph.playerNode)
        }

        sampleConverter = SampleConverter()
        ffmpegScheduler = FFmpegScheduler(playerNode: audioGraph.playerNode, sampleConverter: sampleConverter)
        
        // Player
        player = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)
        
        // Playlist
        let flatPlaylist = FlatPlaylist()
//        let artistsPlaylist = GroupingPlaylist(.artists)
//        let albumsPlaylist = GroupingPlaylist(.albums)
//        let genresPlaylist = GroupingPlaylist(.genres)
        
//        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        playlist = Playlist(flatPlaylist)
        
        // Sequencer and delegate
        let repeatMode = appState.playQueue.repeatMode
        let shuffleMode = appState.playQueue.shuffleMode
        let playlistType = PlaylistType(rawValue: appState.ui.playlist.view.lowercased()) ?? .tracks
        
        sequencer = Sequencer(playlist, repeatMode, shuffleMode, playlistType)
        sequencerDelegate = SequencerDelegate(sequencer)
        
        trackReader = TrackReader()
        
        mediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences)
        
        // Initialize utility classes.
        
        library = Library()
        libraryDelegate = LibraryDelegate(library, trackReader: trackReader, appState.library, preferences)
        
        playQueue = PlayQueue(library: library, persistentStateOnStartup: appState.playQueue)
        playQueueDelegate = PlayQueueDelegate(playQueue: playQueue, library: library, trackReader: trackReader, persistentStateOnStartup: appState.playQueue)
        
        let profiles = PlaybackProfiles()
        
        for profile in appState.playbackProfiles {
            profiles.add(profile.file, profile)
        }
        
        let startPlaybackChain = StartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences.playbackPreferences)
        let stopPlaybackChain = StopPlaybackChain(player, sequencer, profiles, preferences.playbackPreferences)
        let trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, playQueue, playlist, preferences.playbackPreferences)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(player, playQueue, profiles, preferences.playbackPreferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
        
        audioGraphDelegate = AudioGraphDelegate(audioGraph, playbackDelegate, preferences.soundPreferences, appState.audioGraph)
        
        // Playlist Delegate
        playlistDelegate = PlaylistDelegate(playlist, appState.playlist, preferences,
                                            [playbackDelegate as! PlaybackDelegate])
        
        // Recorder (and delegate)
        recorder = Recorder(audioGraph)
        recorderDelegate = RecorderDelegate(recorder)
        
        // History (and delegate)
        history = History(preferences.historyPreferences)
        historyDelegate = HistoryDelegate(history, playlistDelegate, playbackDelegate, appState.history)
        
        bookmarks = Bookmarks()
        bookmarksDelegate = BookmarksDelegate(bookmarks, playlistDelegate, playbackDelegate, appState.bookmarks)
        
        favorites = Favorites()
        favoritesDelegate = FavoritesDelegate(favorites, playlistDelegate, playbackDelegate, appState!.favorites)
        
        // UI-related utility classes
        
        UIUtils.initialize(preferences.viewPreferences)
        
        WindowLayouts.loadUserDefinedLayouts(appState.ui.windowLayout.userLayouts)
        ColorSchemes.initialize(appState.ui.colorSchemes)
        
        PlayerViewState.initialize(appState.ui.player)
        PlaylistViewState.initialize(appState.ui.playlist)
        EffectsViewState.initialize(appState.ui.effects)
        PlayQueueUIState.initialize(fromPersistentState: appState.ui.playQueue)
        
        interfaceManager = InterfaceManager(appState.ui, preferences.viewPreferences)
    }
    
    private static let tearDownOpQueue: OperationQueue = {

        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    
    // Called when app exits
    static func tearDown() {
        
        // Gather all pieces of app state into the appState object
        
        appState.audioGraph = (audioGraphDelegate as! AudioGraphDelegate).persistentState as! AudioGraphState
        appState.playlist = (playlist as! Playlist).persistentState as! PlaylistState
        appState.library = (library as! Library).persistentState as! LibraryState
        appState.playQueue = (playQueue as! PlayQueue).persistentState as! PlayQueueState
        appState.playbackProfiles = playbackDelegate.profiles.all()
        
        appState.ui = UIState()
        appState.ui.windowLayout = interfaceManager.modularInterface.persistentState.windowLayout
        appState.ui.colorSchemes = ColorSchemes.persistentState
        appState.ui.player = PlayerViewState.persistentState
        appState.ui.playlist = PlaylistViewState.persistentState
        appState.ui.effects = EffectsViewState.persistentState
        appState.ui.playQueue = PlayQueueUIState.persistentState
        
        appState.history = (historyDelegate as! HistoryDelegate).persistentState as! HistoryState
        appState.favorites = (favoritesDelegate as! FavoritesDelegate).persistentState
        appState.bookmarks = (bookmarksDelegate as! BookmarksDelegate).persistentState
        
        // App state persistence and shutting down the audio engine can be performed concurrently
        // on two background threads to save some time when exiting the app.
        
        // App state persistence to disk
        tearDownOpQueue.addOperation {
            AppStateIO.save(appState!)
        }

        // Tear down the audio engine
        tearDownOpQueue.addOperation {
            player.tearDown()
            audioGraph.tearDown()
        }

        // Wait for all concurrent operations to finish executing.
        tearDownOpQueue.waitUntilAllOperationsAreFinished()
    }
}
