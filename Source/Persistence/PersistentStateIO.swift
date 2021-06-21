/*
    Handles persistence to/from disk for application state.
*/
import AVFoundation

class PersistentStateIO {
    
    static let persistentStateFile: URL = AppConstants.FilesAndPaths.persistentStateFile
    
    static func save(_ state: PersistentAppState) {
        
        AppConstants.FilesAndPaths.baseDir.createDirectory()
        
        let jsonObject = JSONMapper.map(state)
        
        do {
            
            try JSONSerialization.writeObject(jsonObject, toFile: persistentStateFile, failSilently: true)
            
        } catch let error as NSError {
           NSLog("Error saving app state config file: %@", error.description)
        }
    }
    
    static func load() -> PersistentAppState? {
        
        guard let inputStream = InputStream(url: persistentStateFile) else {return nil}
            
        inputStream.open()
        defer {inputStream.close()}
        
        do {
            
            let data = try JSONSerialization.jsonObject(with: inputStream, options: JSONSerialization.ReadingOptions())
            
            if let dictionary = data as? NSDictionary {
                return PersistentAppState(dictionary)
            }
            
        } catch let error as NSError {
            NSLog("Error loading app state config file: %@", error.description)
        }
        
        return nil
    }
}
