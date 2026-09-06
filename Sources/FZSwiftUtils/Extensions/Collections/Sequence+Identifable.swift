//
//  Sequence+Identifable.swift
//  
//
//  Created by Florian Zand on 03.05.22.
//

import Foundation

public extension Sequence where Element: Identifiable {
    /// An array of the element identifiers.
    var ids: [Element.ID] {
        map(\.id)
    }

    /// The element with the specified identifier, or `nil` if the sequence doesn't contain an element with the identifier.
    subscript(id id: Element.ID) -> Element? {
        first(where: { $0.id == id })
    }

    /// The elements with the specified identifiers.
    subscript<S: Sequence<Element.ID>>(ids ids: S) -> [Element] {
        let ids = Set(ids)
        return filter { ids.contains($0.id) }
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an object with the specified identifier.
    @_disfavoredOverload
    func contains(_ id: Element.ID) -> Bool {
        contains { $0.id == id }
    }
}

public extension RangeReplaceableCollection where Element: Identifiable {
    /// The element with the specified identifier, or `nil` if the collection doesn't contain an element with the identifier.
    subscript(id id: Element.ID) -> Element? {
        get { first(where: { $0.id == id }) }
        set {
            if let index = firstIndex(where: { $0.id == id }) {
                remove(at: index)
                if let newValue = newValue {
                    insert(newValue, at: index)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
    
    /// Removes all elements with the specified element identifier.
    mutating func remove(id: Element.ID) {
        removeAll(where: { $0.id == id })
    }
    
    /// Removes all elements with the specified element identifiers.
    mutating func remove<S: Sequence<Element.ID>>(ids: S) {
        let ids = Set(ids)
        removeAll(where: { ids.contains($0.id) })
    }
    
    /**
     Removes the first element with the specified element identifier.
     
     - Parameter id: The element identifier.
     
     - Returns: The removed element, or `nil` if there isn't any element with the specified identifier in the collection.
     */
    mutating func removeFirst(id: Element.ID) -> Element? {
        removeFirst(where: { $0.id == id })
    }
    
    /**
     Removes the last element with the specified element identifier.
     
     - Parameter id: The element identifier.
     
     - Returns: The removed element, or `nil` if there isn't any element with the specified identifier in the collection.
     */
    mutating func removeLast(id: Element.ID) -> Element? where Self: BidirectionalCollection {
        removeLast(where: { $0.id == id })
    }
}

/// The ordered differences between two collections of identifiable elements.
public struct IdentifiedDifference<ID: Hashable, Element: Equatable> {
    /// The elements that are no longer present in the other collection.
    public let removed: [Element]
    /// The elements that are newly present in the other collection.
    public let added: [Element]
    /// The elements whose identifiers match but whose values changed.
    public let changed: [(old: Element, new: Element)]
}

public extension Collection where Element: Identifiable & Equatable {
    /// Returns the ordered differences between this collection and another collection by comparing element identifiers.
    func differenceByID(to other: Self) -> IdentifiedDifference<Element.ID, Element> {
        let oldByID = keyed(by: \.id)
        let newByID = other.keyed(by: \.id)

        let removed = filter { newByID[$0.id] == nil }
        let added = other.filter { oldByID[$0.id] == nil }
        let changed = compactMap { oldElement -> (old: Element, new: Element)? in
            guard let newElement = newByID[oldElement.id], oldElement != newElement else {
                return nil
            }
            return (old: oldElement, new: newElement)
        }

        return .init(removed: removed, added: added, changed: changed)
    }
}

public extension Sequence where Element: AnyObject {
    /// The identifiers of the objects in the sequence.
    @_disfavoredOverload
    var ids: [ObjectIdentifier] {
        map(ObjectIdentifier.init)
    }
    
    /// Returns the object with the specified identifier, or `nil` if no matching object exists.
    subscript(id id: ObjectIdentifier) -> Element? {
        first { ObjectIdentifier($0) == id }
    }
    
    /// The elements with the specified identifiers.
    subscript<S: Sequence<ObjectIdentifier>>(ids ids: S) -> [Element] {
        let ids = Set(ids)
        return filter { ids.contains(ObjectIdentifier($0)) }
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an object with the specified identifier.
    @_disfavoredOverload
    func contains(_ id: ObjectIdentifier) -> Bool {
        contains { ObjectIdentifier($0) == id }
    }
}

public extension RangeReplaceableCollection where Element: AnyObject {
    /// The element with the specified identifier, or `nil` if the collection doesn't contain an element with the identifier.
    subscript(id id: ObjectIdentifier) -> Element? {
        get { first(where: { ObjectIdentifier($0) == id }) }
        set {
            if let index = firstIndex(where: { ObjectIdentifier($0) == id }) {
                remove(at: index)
                guard let newValue = newValue else { return }
                insert(newValue, at: index)
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
    
    /// Removes all elements with the specified element identifier.
    mutating func remove(id: ObjectIdentifier) {
        removeAll(where: { ObjectIdentifier($0) == id })
    }
    
    /// Removes all elements with the specified element identifiers.
    mutating func remove<S: Sequence<ObjectIdentifier>>(ids: S) {
        let ids = Set(ids)
        removeAll(where: { ids.contains(ObjectIdentifier($0)) })
    }
    
    /**
     Removes the first element with the specified element identifier.
     
     - Parameter id: The element identifier.
     
     - Returns: The removed element, or `nil` if there isn't any element with the specified identifier in the collection.
     */
    mutating func removeFirst(id: ObjectIdentifier) -> Element? {
        removeFirst(where: { ObjectIdentifier($0) == id })
    }
    
    /**
     Removes the last element with the specified element identifier.
     
     - Parameter id: The element identifier.
     
     - Returns: The removed element, or `nil` if there isn't any element with the specified identifier in the collection.
     */
    mutating func removeLast(id: ObjectIdentifier) -> Element? where Self: BidirectionalCollection {
        removeLast(where: { ObjectIdentifier($0) == id })
    }
}
