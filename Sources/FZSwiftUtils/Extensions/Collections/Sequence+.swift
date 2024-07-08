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

     - Parameter predicate: A closure that takes an element of the collection as its argument and returns a Boolean value indicating whether the element is a match.

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


public extension Sequence where Element: AdditiveArithmetic {
    /// The total sum value of all values in the sequence. If the sequence is empty, it returns `zero`.
    func sum() -> Self.Element {
        reduce(.zero, +)
    }
}

public extension Sequence where Element: Equatable {
    /**
     A Boolean value indicating whether the sequence contains any of the given elements.

     - Parameter elements: The elements to find in the sequence.
     - Returns: `true` if any of the elements was found in the sequence; otherwise, `false`.
     */
    func contains<S>(any elements: S) -> Bool where S: Sequence, Element == S.Element {
        elements.contains(where: { contains($0) })
    }
    
    /**
     A Boolean value indicating whether the sequence contains all given elements.

     - Parameters:
        - elements: The elements to find in the sequence.
        - inSameOrder: A Boolean value indicating whether the elements to find need to appear in the same order.
     - Returns: `true` if all elements were found in the sequence; otherwise, `false`.
     */
    func contains<S: Sequence<Element>>(all elements: S, inSameOrder: Bool = false) -> Bool {
        if !inSameOrder {
            return !elements.contains(where: { !contains($0) })
        } else {
            return elements.allSatisfy(AnyIterator(makeIterator()).contains)
        }
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

public extension Sequence {
    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    func grouped<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [Key: [Element]] {
        try Dictionary(grouping: self, by: keyForValue)
    }

    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    func grouped<Key>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }

    /// Splits the collection by the specified keypath and values that are returned for each keypath.
    func split<Key>(by keyPath: KeyPath<Element, Key>) -> [(key: Key, values: [Element])] where Key: Equatable {
        split(by: { $0[keyPath: keyPath] })
    }

    /// Splits the collection by the key returned from the specified closure and values that are returned for each key.
    func split<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [(key: Key, values: [Element])] where Key: Equatable {
        var output: [(key: Key, values: [Element])] = []
        for value in self {
            let key = try keyForValue(value)
            if let index = output.firstIndex(where: { $0.key == key }) {
                output[index].values.append(value)
            } else {
                output.append((key, [value]))
            }
        }
        return output
    }
}

public extension Sequence where Element: OptionalProtocol {
    /// Returns an array of all non optional elements of the collection.
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


public extension Sequence where Element: RawRepresentable {
    /// An array of corresponding values of the raw type.
    func rawValues() -> [Element.RawValue] {
        compactMap(\.rawValue)
    }
}

public extension Sequence where Element: RawRepresentable, Element.RawValue: Equatable {
    /**
     Returns the first element of the collection that satisfies the  raw value.

     - Parameter rawValue: The raw value.

     - Returns: The first element of the collection that matches the raw value.
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
