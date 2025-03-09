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
        compactMap(\.id)
    }

    /// The element with the specified identifier, or `nil` if the sequence doesn't contain an element with the identifier.
    subscript(id id: Element.ID) -> Element? {
        first(where: { $0.id == id })
    }

    /// The elements with the specified identifiers.
    subscript<S: Sequence<Element.ID>>(ids ids: S) -> [Element] {
        filter { ids.contains($0.id) }
    }
}

public extension RangeReplaceableCollection where Element: Identifiable {
    /// Removes all elements with the specified element identifier.
    mutating func remove(id: Element.ID) {
        removeAll(where: { $0.id == id })
    }
    
    /// Removes all elements with the specified element identifiers.
    mutating func remove<S: Sequence<Element.ID>>(ids: S) {
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
}

public extension Collection where Element: Identifiable {
    /**
     Returns the first index of the specified element.

     - Parameter element: The element for returning the index.
     - Returns: The first index of the element, or `nil` if the collection doesn't contain the element.
     */
    func firstIndex(of element: Element) -> Index? {
        firstIndex(where: { $0.id == element.id })
    }
    
    /**
     Returns the first index of the specified element identifier.

     - Parameter id: The element identifier for returning the index.
     - Returns: The first index of the elemen identifiert, or `nil` if the collection doesn't contain any element with the identifier.
     */
    func firstIndex(of id: Element.ID) -> Index? {
        firstIndex(where: { $0.id == id })
    }

    /**
     Returns the indexes of the specified elements.

     - Parameter elements: The elements for returning the indexes.
     - Returns: An array of indexes for the specified elements.
     */
    func indexes<S: Sequence<Element>>(of elements: S) -> [Index] {
        elements.compactMap { firstIndex(of: $0) }
    }
    
    /**
     Returns the indexes of the specified element identifiers.

     - Parameter ids: The element identifiers for returning the indexes.
     - Returns: An array of indexes for the specified element identifiers.
     */
    func indexes<S: Sequence<Element.ID>>(of ids: S) -> [Index] {
        ids.compactMap { firstIndex(of: $0) }
    }
}
