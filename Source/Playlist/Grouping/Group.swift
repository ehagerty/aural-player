import Foundation

/*
    Represents a group of items categorized by a certain property of the items - such as artist, album, or genre
 */
class Group<K, T>: PlayableItem where K: Hashable, T: PlayableItem {
    
    let id: K
    
    // The items within this group
    private(set) var items: [T] = []
    
    // Total duration of all items in this group
    var duration: Double {
        items.reduce(0.0, {(totalSoFar: Double, item: T) -> Double in totalSoFar + item.duration})
    }
    
    init(id: K) {
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 2 Groups are equal if they are of the same type and have the same name.
    static func == (lhs: Group<K, T>, rhs: Group<K, T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Number of items
    var size: Int {items.count}

    func indexOfItem(_ item: T) -> Int? {
        return items.firstIndex(of: item)
    }

    func item(at index: Int) -> T? {
        return items.item(at: index)
    }

    func insertItem(_ item: T, at index: Int) {
        items.insert(item, at: index)
    }

    // Adds a track and returns the index of the new track
    func addItem(_ item: T) -> Int {
        return items.addItem(item)
    }

    // Removes a track at the given index, and returns the removed track
    func removeItem(at index: Int) -> T? {
        return items.removeItem(at: index)
    }

    func removeItems(_ itemsToRemove: [T]) -> IndexSet {
        return items.removeItems(itemsToRemove)
    }

    func moveItemsUp(_ itemsToMove: [T]) -> [Int: Int] {
        return items.moveItemsUp(itemsToMove)
    }

    // Moves items within this group, at the given indexes, up one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveItemsUp(from indices: IndexSet) -> [Int: Int] {
        return items.moveItemsUp(from: indices)
    }

    // Assume items can be moved
    func moveItemsToTop(from indices: IndexSet) -> [Int: Int] {
        return items.moveItemsToTop(from: indices)
    }

    func moveItemsToTop(_ itemsToMove: [T]) -> [Int: Int] {
        return items.moveItemsToTop(itemsToMove)
    }

    func moveItemsDown(_ itemsToMove: [T]) -> [Int: Int] {
        return items.moveItemsDown(itemsToMove)
    }

    // Moves items within this group, at the given indexes, down one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveItemsDown(from indices: IndexSet) -> [Int: Int] {
        return items.moveItemsDown(from: indices)
    }

    func moveItemsToBottom(_ itemsToMove: [T]) -> [Int: Int] {
        return items.moveItemsToBottom(itemsToMove)
    }

    func moveItemsToBottom(from indices: IndexSet) -> [Int: Int] {
        return items.moveItemsToBottom(from: indices)
    }

    func dragAndDropItems(from sourceIndices: IndexSet, to dropIndex: Int) -> [Int: Int] {
        return items.dragAndDropItems(sourceIndices, dropIndex)
    }
    
    // Sorts all items in this group, using the given strategy to compare items
    func sort(_ strategy: (T, T) -> Bool) {
        items.sort(by: strategy)
    }
}
