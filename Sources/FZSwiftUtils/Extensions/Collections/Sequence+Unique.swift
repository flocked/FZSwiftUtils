//
//  Sequence+Unique.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

public extension Sequence {
    /// An array of unique elements.
    func uniqued() -> [Element] where Element: Equatable  {
        var elements: [Element] = []
        for element in self {
            if !elements.contains(element) {
                elements.append(element)
            }
        }
        return elements
    }
    
    /// An array of unique elements in the order they first appear.
    func uniqued() -> [Element] where Element: Hashable {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

public extension Sequence {
    /**
     An array of elements by filtering the keypath for unique values.

     - Parameter keyPath: The keypath for filtering the object.
     */
    func euniqued<T: Equatable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] })
    }
    
    /**
     An array of elements by filtering the keypath for unique values.

     - Parameter keyPath: The keypath for filtering the object.
     */
    func uniqued<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] })
    }

    /**
     An array of unique elements.

     - Parameter map: A mapping closure. map accepts an element of this sequence as its parameter and returns a value of the same or of a different type.
     */
    func uniqued<T: Equatable>(by keyForValue: (Element) throws -> T) rethrows -> [Element] {
        var uniqueElements: [T] = []
        var ordered: [Element] = []
        for element in self {
            let check = try keyForValue(element)
            if !uniqueElements.contains(check) {
                uniqueElements.append(check)
                ordered.append(element)
            }
        }
        return ordered
    }
    
    /**
     An array of unique elements.

     - Parameter map: A mapping closure. map accepts an element of this sequence as its parameter and returns a value of the same or of a different type.
     */
    func uniqued<T: Hashable>(by keyForValue: (Element) throws -> T) rethrows -> [Element] {
        var seen = Set<T>()
        return try filter { seen.insert(try keyForValue($0)).inserted }
    }
}

extension Sequence where Element: Hashable {
    /// An array of the elements that are duplicates.
    func duplicates() -> [Element] {
        Array(Dictionary(grouping: self, by: {$0}).filter {$1.count > 1}.keys)
    }
}

public extension Sequence where Element: Equatable {
    /**
     Returns a random element of the collection excluding any of the specified elements.

     - Parameter excluding: The elements excluded for the returned element.
     - Returns: A random element from the collection excluding any of the specified elements. If the collection is empty, the method returns `nil.
     */
    func randomElement<S: Sequence<Element>>(excluding: S) -> Element? {
        shuffled().first(where: { !excluding.contains($0) })
    }
}
