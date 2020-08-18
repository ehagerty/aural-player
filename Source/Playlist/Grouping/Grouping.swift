import Foundation

class Grouping<K, T> where K: Hashable, T: PlayableItem {
    
    private(set) var groups: [Group<K, T>] = []
    private var groupsMap: [K: Group<K, T>] = [:]
    
    func keyForItem(_ item: T) -> K {
        fatalError("The function 'keyForItem(item: T)' is supposed to be overriden by a subclass.")
    }
    
    func add(item: T) {
        
        // Determine the group this track belongs in (the group may not already exist)
        if let group = getGroup(for: item) {
            _ = group.addItem(item)
        }
        
        // Group doesn't exist, create it.
        let newGroupAndIndex = createGroup(for: item)
        let newGroup = newGroupAndIndex.group
        _ = newGroup.addItem(item)
    }
    
    private func getGroup(for item: T) -> Group<K, T>? {
        return groupsMap[keyForItem(item)]
    }
    
    private func createGroup(for item: T) -> (group: Group<K, T>, groupIndex: Int) {
        
        let groupId = keyForItem(item)
        let newGroup = Group<K, T>.init(id: groupId)
        groupsMap[groupId] = newGroup
        let groupIndex = groups.addItem(newGroup)
        
        return (newGroup, groupIndex)
    }
}
