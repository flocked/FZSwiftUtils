//
//  Sequence+Identifable.swift
//  FZCollection
//
//  Created by Florian Zand on 03.05.22.
//

import Foundation

public extension Sequence where Element: Identifiable {
    /// An array of IDs of the elements.
    var ids: [Element.ID] {
        return compactMap { $0.id }
    }
    
    subscript(firstID id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    subscript(id id: Element.ID) -> Element? {
        self.first(where: {$0.id == id})
    }

    subscript<S: Sequence<Element.ID>>(ids ids: S) -> [Element] {
        filter { ids.contains($0.id) }
    }
}

public extension Collection where Element: Identifiable {
    /**
     Returns the first index of the specified element.
     - Parameters element: The element for returning the index.
     - Returns: The first index of the element, or nil if no index could be found.

     */
    func index(of element: Element) -> Self.Index? {
        return firstIndex(where: { $0.id == element.id })
    }

    /**
     Returns the indexes of the specified elements.
     - Parameters elements: The elements for returning the indexes.
     - Returns: An array of indexes for the specified elements.

     */
    func indexes<S: Sequence<Element>>(of elements: S) -> [Self.Index] {
        return elements.compactMap { self.index(of: $0) }
    }
}
