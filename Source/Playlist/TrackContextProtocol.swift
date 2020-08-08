import Foundation

protocol TrackContextProtocol {
    
    init(for track: Track) throws
    
    func loadPrimaryMetadata()
    
    func loadSecondaryMetadata()
    
    func loadAllMetadata()
    
    func prepareForPlayback() throws
}
