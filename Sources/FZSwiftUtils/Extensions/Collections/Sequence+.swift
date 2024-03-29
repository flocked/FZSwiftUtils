//
//  Sequence+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    /**
     Returns indexes of elements that satisfies the given predicate.

     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.

     - Returns: The indexes of the elements that satisfies the given predicate.
     */
    func indexes(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
        var indexes = IndexSet()
        for (index, element) in enumerated() {
            if try (predicate(element) == true) {
                indexes.insert(index)
            }
        }
        return indexes
    }
}

public extension Sequence where Element: Equatable {
    /**
     Returns indexes of the specified element.

     - Parameter element: The element to return it's indexes.

     - Returns: The indexes of the element.
     */
    func indexes(of element: Element) -> IndexSet {
        indexes(where: { $0 == element })
    }

    /**
     Returns indexes of the specified elements.

     - Parameter elements: The elements to return their indexes.

     - Returns: The indexes of the elements.
     */
    func indexes<S: Sequence<Element>>(for elements: S) -> IndexSet {
        indexes(where: { elements.contains($0) })
    }
}

public extension Sequence where Element: RawRepresentable {
    /// An array of corresponding values of the raw type.
    func rawValues() -> [Element.RawValue] {
        compactMap(\.rawValue)
    }
}

public extension Sequence where Element: RawRepresentable, Element.RawValue: Equatable {
    /**
     Returns the first element of the sequence that satisfies the  raw value.

     - Parameter rawValue: The raw value.

     - Returns: The first element of the sequence that matches the raw value.
     */
    func first(rawValue: Element.RawValue) -> Element? {
        first(where: { $0.rawValue == rawValue })
    }

    subscript(rawValue rawValue: Element.RawValue) -> [Element] {
        filter { $0.rawValue == rawValue }
    }

    subscript(firstRawValue rawValue: Element.RawValue) -> Element? {
        first(where: { $0.rawValue == rawValue })
    }
}

public extension Sequence where Element: Equatable {
    /**
     A Boolean value indicating whether the sequence contains any of the specified elements.

     - Parameter elements: The elements.
     - Returns: `true` if any of the elements exists in the sequence, or` false` if non exist in the sequence.
     */
    func contains<S: Sequence<Element>>(any elements: S) -> Bool {
        for element in elements {
            if contains(element) {
                return true
            }
        }
        return false
    }

    /**
     A Boolean value indicating whether the sequence contains all specified elements.

     - Parameter elements: The elements.
     - Returns: `true` if all elements exist in the sequence, or` false` if not.
     */
    func contains<S: Sequence<Element>>(all elements: S) -> Bool {
        for checkElement in elements {
            if contains(checkElement) == false {
                return false
            }
        }
        return true
    }
}

public extension Sequence where Element: OptionalProtocol {
    /// Returns an array of non optional elemenets.
    var nonNil: [Element.Wrapped] {
        compactMap(\.optional)
    }
}

public extension Sequence where Element: Hashable {
    /// The collection as `Set`.
    var asSet: Set<Element> {
        Set(self)
    }
}
