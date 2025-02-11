import Foundation

/*
    Encapsulates an audio output device (remembered device)
 */
class AudioDevicePersistentState: PersistentStateProtocol {
    
    let name: String
    let uid: String
    
    init(name: String, uid: String) {
        
        self.name = name
        self.uid = uid
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.stringValue(forKey: "name"),
              let uid = map.stringValue(forKey: "uid") else {return nil}
        
        self.name = name
        self.uid = uid
    }
}
