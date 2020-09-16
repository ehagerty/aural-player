import Foundation

protocol FileReaderProtocol {
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata
    
    func getSecondaryMetadata(for file: URL) -> SecondaryMetadata
}
