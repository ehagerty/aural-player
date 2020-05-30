import Foundation

class SetPlaybackDelayAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let playlist: PlaylistCRUDProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ player: PlayerProtocol, _ playlist: PlaylistCRUDProtocol) {
        
        self.player = player
        self.playlist = playlist
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        let params = context.requestParams
        
        if params.allowDelay, let newTrack = context.requestedTrack {
            
            if let delay = params.delay {

                // TODO: This gap stuff should not even be needed here !!!
                
                // An explicit delay is defined. It takes precedence over gaps.
                PlaybackGapContext.clear()
                PlaybackGapContext.addGap(PlaybackGap(delay, .beforeTrack), newTrack)
                
            } else {
                
                // TODO: Instead of using PlaybackGapContext, simply append (increment) gaps to the request context delay
                
                // No explicit delay is defined, check for a gap defined before the track (in the playlist).
                if let gapBefore = playlist.getGapBeforeTrack(newTrack) {

                    // The explicitly defined gap before the track takes precedence over the implicit gap
                    // defined by the playback preferences, so remove the implicit gap
                    PlaybackGapContext.addGap(gapBefore, newTrack)
                    PlaybackGapContext.removeImplicitGap()
                }
                
                if PlaybackGapContext.hasGaps() {
                    
                    // Check if any defined gaps were one-time gaps. If so, delete them
                    for (gap, track) in PlaybackGapContext.oneTimeGaps {
                        playlist.removeGapForTrack(track, gap.position)
                    }
                    
                    // Set the delay request parameter to the lengtth of the gap.
                    params.delay = PlaybackGapContext.gapLength
                }
            }
        }
        
        nextAction?.execute(context)
    }
}
