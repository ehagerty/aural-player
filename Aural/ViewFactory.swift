import Cocoa

/*
    Factory for instantiating views from XIBs
 */
struct ViewFactory {
    
    // Top-level sub-views (views displayed directly on the main window)
    
    private static let playerViewController: PlayerViewController = PlayerViewController()
    
//    private static let barModeNowPlayingViewController: BarModeNowPlayingViewController = BarModeNowPlayingViewController()
//
//    private static let barModePlayerViewController: BarModePlayerViewController = BarModePlayerViewController()
    
    // Sub-views for the different individual effects units displayed on the Effects panel
    fileprivate struct EffectsViews {
        
        fileprivate static let masterViewController: MasterViewController = MasterViewController()
        
        fileprivate static let eqViewController: EQViewController = EQViewController()
        
        fileprivate static let pitchViewController: PitchViewController = PitchViewController()
        
        fileprivate static let timeViewController: TimeViewController = TimeViewController()
        
        fileprivate static let reverbViewController: ReverbViewController = ReverbViewController()
        
        fileprivate static let delayViewController: DelayViewController = DelayViewController()
        
        fileprivate static let filterViewController: FilterViewController = FilterViewController()
        
        fileprivate static let recorderViewController: RecorderViewController = RecorderViewController()
    }
    
    // Sub-views for the different individual playlist views displayed in the playlist window's tab group
    fileprivate struct PlaylistViews {
        
        fileprivate static let tracksViewController: TracksPlaylistViewController = TracksPlaylistViewController()
        
        fileprivate static let artistsViewController: ArtistsPlaylistViewController = ArtistsPlaylistViewController()
        
        fileprivate static let albumsViewController: AlbumsPlaylistViewController = AlbumsPlaylistViewController()
        
        fileprivate static let genresViewController: GenresPlaylistViewController = GenresPlaylistViewController()
        
        fileprivate static let contextMenuController: PlaylistContextMenuController = PlaylistContextMenuController()
    }
    
    // Sub-views for the different individual playlist views displayed in the playlist window's tab group
    fileprivate struct PreferencesViews {
        
        fileprivate static let playlistPreferencesViewController: PlaylistPreferencesViewController = PlaylistPreferencesViewController()
        
        fileprivate static let playbackPreferencesViewController: PlaybackPreferencesViewController = PlaybackPreferencesViewController()
        
        fileprivate static let soundPreferencesViewController: SoundPreferencesViewController = SoundPreferencesViewController()
        
        fileprivate static let viewPreferencesViewController: ViewPreferencesViewController = ViewPreferencesViewController()
        
        fileprivate static let historyPreferencesViewController: HistoryPreferencesViewController = HistoryPreferencesViewController()
        
        fileprivate static let controlsPreferencesViewController: ControlsPreferencesViewController = ControlsPreferencesViewController()
    }
    
    fileprivate struct PopoverViews {
        
        // The view that displays detailed track information, when requested by the user
        fileprivate static var detailedTrackInfoPopover: PopoverViewDelegate = {
            return DetailedTrackInfoViewController.create()
        }()
        
        // The view that displays a brief info message when a track is added to or removed from Favorites
        fileprivate static var infoPopup: InfoPopupViewController = {
            return InfoPopupViewController.create()
        }()
        
//        fileprivate static var statusBarPopover: StatusBarPopoverViewController = {
//            return StatusBarPopoverViewController.create()
//        }()
    }
    
    // Sub-views for the different individual editor views
    fileprivate struct EditorViews {
        
        fileprivate static let bookmarksEditorViewController: BookmarksEditorViewController = BookmarksEditorViewController()
        
        fileprivate static let favoritesEditorViewController: FavoritesEditorViewController = FavoritesEditorViewController()
        
        fileprivate static let layoutsEditorViewController: LayoutsEditorViewController = LayoutsEditorViewController()
        
        fileprivate static let effectsPresetsEditorViewController: EffectsPresetsEditorViewController = EffectsPresetsEditorViewController()
        
        fileprivate static let masterPresetsEditorViewController: MasterPresetsEditorViewController = MasterPresetsEditorViewController()
        
        fileprivate static let eqPresetsEditorViewController: EQPresetsEditorViewController = EQPresetsEditorViewController()
        
        fileprivate static let pitchPresetsEditorViewController: PitchPresetsEditorViewController = PitchPresetsEditorViewController()
        
        fileprivate static let timePresetsEditorViewController: TimePresetsEditorViewController = TimePresetsEditorViewController()
        
        fileprivate static let reverbPresetsEditorViewController: ReverbPresetsEditorViewController = ReverbPresetsEditorViewController()
        
        fileprivate static let delayPresetsEditorViewController: DelayPresetsEditorViewController = DelayPresetsEditorViewController()
        
        fileprivate static let filterPresetsEditorViewController: FilterPresetsEditorViewController = FilterPresetsEditorViewController()
    }
    
    // Returns the view that displays the player
    static var playerView: NSView {
        return playerViewController.view
    }
    
    static var mainWindowMouseTrackingView: MouseTrackingView {
        return WindowFactory.mainWindow.contentView as! MouseTrackingView
    }
    
    // Returns the view that displays the Equalizer effects unit
    static var masterView: NSView {
        return EffectsViews.masterViewController.view
    }
    
    // Returns the view that displays the Equalizer effects unit
    static var eqView: NSView {
        return EffectsViews.eqViewController.view
    }
    
    // Returns the view that displays the Pitch effects unit
    static var pitchView: NSView {
        return EffectsViews.pitchViewController.view
    }
    
    // Returns the view that displays the Time effects unit
    static var timeView: NSView {
        return EffectsViews.timeViewController.view
    }
    
    // Returns the view that displays the Reverb effects unit
    static var reverbView: NSView {
        return EffectsViews.reverbViewController.view
    }
    
    // Returns the view that displays the Delay effects unit
    static var delayView: NSView {
        return EffectsViews.delayViewController.view
    }
    
    // Returns the view that displays the Filter effects unit
    static var filterView: NSView {
        return EffectsViews.filterViewController.view
    }
    
    // Returns the view that displays the Recorder unit
    static var recorderView: NSView {
        return EffectsViews.recorderViewController.view
    }
    
    // Returns the "Tracks" playlist view
    static var tracksView: NSView {
        return PlaylistViews.tracksViewController.view
    }
    
    // Returns the "Artists" playlist view
    static var artistsView: NSView {
        return PlaylistViews.artistsViewController.view
    }
    
    // Returns the "Albums" playlist view
    static var albumsView: NSView {
        return PlaylistViews.albumsViewController.view
    }
    
    // Returns the "Genres" playlist view
    static var genresView: NSView {
        return PlaylistViews.genresViewController.view
    }
    
    static var contextMenu: NSMenu {
        return PlaylistViews.contextMenuController.contextMenu
    }
    
    static var detailedTrackInfoPopover: PopoverViewDelegate {
        return PopoverViews.detailedTrackInfoPopover
    }
    
    static var infoPopup: InfoPopupProtocol {
        return PopoverViews.infoPopup
    }
    
    static var playlistPreferencesView: PreferencesViewProtocol {
        return PreferencesViews.playlistPreferencesViewController
    }
    
    static var playbackPreferencesView: PreferencesViewProtocol {
        return PreferencesViews.playbackPreferencesViewController
    }
    
    static var soundPreferencesView: PreferencesViewProtocol {
        return PreferencesViews.soundPreferencesViewController
    }
    
    static var viewPreferencesView: PreferencesViewProtocol {
        return PreferencesViews.viewPreferencesViewController
    }
    
    static var historyPreferencesView: PreferencesViewProtocol {
        return PreferencesViews.historyPreferencesViewController
    }
    
    static var controlsPreferencesView: PreferencesViewProtocol {
        return PreferencesViews.controlsPreferencesViewController
    }
    
//    static var StatusBarPopover() -> StatusBarPopoverViewController {
//        return PopoverViews.statusBarPopover
//    }
    
    // MARK: Accessors for Bar mode
    
//    static var BarModeNowPlayingView: NSView {
//        return barModeNowPlayingViewController.view
//    }
//
//    // Returns the view that displays the player
//    static var BarModePlayerView: NSView {
//        return barModePlayerViewController.view
//    }
    
    static var bookmarksEditorView: NSView {
        return EditorViews.bookmarksEditorViewController.view
    }
    
    static var favoritesEditorView: NSView {
        return EditorViews.favoritesEditorViewController.view
    }
    
    static var layoutsEditorView: NSView {
        return EditorViews.layoutsEditorViewController.view
    }
    
    static var effectsPresetsEditorView: NSView {
        return EditorViews.effectsPresetsEditorViewController.view
    }
    
    static var masterPresetsEditorView: NSView {
        return EditorViews.masterPresetsEditorViewController.view
    }
    
    static var eqPresetsEditorView: NSView {
        return EditorViews.eqPresetsEditorViewController.view
    }
    
    static var pitchPresetsEditorView: NSView {
        return EditorViews.pitchPresetsEditorViewController.view
    }
    
    static var timePresetsEditorView: NSView {
        return EditorViews.timePresetsEditorViewController.view
    }
    
    static var reverbPresetsEditorView: NSView {
        return EditorViews.reverbPresetsEditorViewController.view
    }
    
    static var delayPresetsEditorView: NSView {
        return EditorViews.delayPresetsEditorViewController.view
    }
    
    static var filterPresetsEditorView: NSView {
        return EditorViews.filterPresetsEditorViewController.view
    }
}
