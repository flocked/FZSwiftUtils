//
//  Sequence+Identifable.swift
//  
//
//  Created by Florian Zand on 03.05.22.
//

import Foundation

public extension Sequence where Element: Identifiable {
    /// An array of IDs of the elements.
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

public extension Collection where Element: Identifiable {
    /**
     Returns the first index of the specified element.

     - Parameter element: The element for returning the index.
     - Returns: The first index of the element, or `nil` if the collection doesn't contain the element.
     */
    func index(of element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }

    /**
     Returns the indexes of the specified elements.

     - Parameter elements: The elements for returning the indexes.
     - Returns: An array of indexes for the specified elements.
     */
    func indexes<S: Sequence<Element>>(of elements: S) -> [Self.Index] {
        elements.compactMap { index(of: $0) }
    }
}
