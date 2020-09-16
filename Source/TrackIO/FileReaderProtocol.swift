import Foundation

protocol FileReaderProtocol {
    
    func getPrimaryMetadata(for file: URL) -> PrimaryMetadata
    
    func getSecondaryMetadata(for file: URL) -> SecondaryMetadata
}
