import Foundation

class Grouping<K, T> where K: Hashable {
    
//    private(set) var groups: []
    
    func keyForItem(_ item: T) -> K {
        fatalError("The function 'keyForItem(item: T)' is supposed to be overriden by a subclass.")
    }
    
    func add(item: T) {
        
    }
}
