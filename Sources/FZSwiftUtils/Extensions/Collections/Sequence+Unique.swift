//
//  Sequence+Unique.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

public extension Sequence where Element: Equatable {
    /// An array of unique elements.
    func uniqued() -> [Element] {
        var elements: [Element] = []
        for element in self {
            if !elements.contains(element) {
                elements.append(element)
            }
        }
        return elements
    }
}

public extension Sequence {
    /**
     An array of elements by filtering the keypath for unique values.

     - Parameter keyPath: The keypath for filtering the object.
     */
    func uniqued<T: Equatable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] })
    }
    
    /**
     An array of elements by filtering the keypath for unique values.

     - Parameter keyPath: The keypath for filtering the object.
     */
    func uniqued<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] })
    }

    /**
     An array of unique elements.

     - Parameter map: A mapping closure. map accepts an element of this sequence as its parameter and returns a value of the same or of a different type.
     */
    func uniqued<T: Equatable>(by map: (Element) -> T) -> [Element] {
        var uniqueElements: [T] = []
        var ordered: [Element] = []
        for element in self {
            let check = map(element)
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
    func uniqued<T: Comparable>(by map: (Element) -> T) -> [Element] {
        let elements = reduce(into: [(index: Int, element: Element, compare: T)]()) {
            $0 += ($0.count, $1, map($1))
        }.sorted(by: \.compare)
        return elements.reduce(into: [(index: Int, element: Element, compare: T)]()) {
            if $0.last?.compare != $1.compare {
                $0.append($1)
            }
        }.sorted(by: \.index).compactMap({$0.element})
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
    func randomElement(excluding: [Element]) -> Element? {
        filter { !excluding.contains($0) }.randomElement()
    }
}
