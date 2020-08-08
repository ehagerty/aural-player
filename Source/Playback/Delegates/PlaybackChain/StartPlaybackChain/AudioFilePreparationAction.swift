import Foundation

/*
    Prepares a track for playback:

    - delay (if defined in the request)
    - transcoding (if required)
    - reading audio metadata
 */
class AudioFilePreparationAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, InvalidTrackError.noRequestedTrack)
            return
        }
        
        let delayInfo = checkForDelayAndDefer(newTrack, context, chain)
        prepareTrackAndProceed(newTrack, context, chain, delayInfo.isWaiting, delayInfo.gapEndTime)
    }
    
    // If a delay is defined in the request params, defers chain execution
    func checkForDelayAndDefer(_ newTrack: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain) -> (isWaiting: Bool, gapEndTime: Date?) {
        
        if context.requestParams.allowDelay, let delay = context.delay {
            
            // Dispatch an async task that will continue chain execution after the delay
            
            let gapEndTime_dt: DispatchTime = .now() + delay
            let gapEndTime: Date = Date() + delay
            
            DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt, qos: .userInteractive) {
                
                // Perform this check to account for the possibility that the gap has been skipped
                // (e.g. user performs Play or Next/Previous track or Stop)
                if PlaybackRequestContext.isCurrent(context) {
                    
                    // Proceed with playback
                    // Need to call prepare again to ensure that preparation is completed before playback
                    // (It may not have completed when prepare() was called previously, before the gap completed
                    // ... esp. if the gap was very short)
                    self.prepareTrackAndProceed(newTrack, context, chain, false, nil)
                }
            }
            
            return (true, gapEndTime)
        }
        
        return (false, nil)
    }
    
    func prepareTrackAndProceed(_ track: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain, _ isWaiting: Bool, _ gapEndTime: Date?) {
        
//        track.prepareForPlayback()
//        
//        // Track preparation failed, terminate the chain.
//        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
//            
//            chain.terminate(context, preparationError)
//            return
//        }
//        
//        // Proceed if not waiting
//        if !isWaiting {
//            chain.proceed(context)
//            
//        } else if let theGapEndTime = gapEndTime {
//            transitionToWaitingState(context, theGapEndTime)
//        }
    }
    
    private func transitionToWaitingState(_ context: PlaybackRequestContext, _ gapEndTime: Date) {
        
        // Mark the current state as "waiting" before the requested track, and notify observers.
        player.waiting()
        
        Messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: context.requestedTrack, endState: .waiting, gapEndTime: gapEndTime))
        
        // Update the context to reflect this transition
        context.currentTrack = context.requestedTrack
        context.currentState = .waiting
        context.currentSeekPosition = 0
    }
}
