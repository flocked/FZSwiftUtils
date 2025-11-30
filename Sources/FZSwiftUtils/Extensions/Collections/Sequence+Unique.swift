//
//  Sequence+Unique.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

public extension Sequence {
    /**
     Returns an array containing the unique elements of the sequence.

     By default, the first occurrence of each element is kept. If `keepLast` is `true`, the last occurrence becomes the one that is preserved.

     - Parameter keepLast: If `false`, the first occurrence of each element is kept; otherwise the last occurrence is kept.
     - Returns: An array containing the unique elements of the sequence in their original order.
     */
    func uniqued(keepLast: Bool = false) -> [Element] where Element: Equatable {
        uniqued(by: { $0 }, keepLast: keepLast)
    }
    
    /**
     Returns an array containing the unique elements of the sequence.

     By default, the first occurrence of each element is kept. If `keepLast` is `true`, the last occurrence becomes the one that is preserved.

     - Parameter keepLast: If `false`, the first occurrence of each element is kept; otherwise the last occurrence is kept.
     - Returns: An array containing the unique elements of the sequence in their original order.
     */
    func uniqued(keepLast: Bool = false) -> [Element] where Element: Hashable {
        uniqued(by: { $0 }, keepLast: keepLast)
    }
}

public extension Sequence {
    /**
     Returns an array of elements with duplicates removed based the property at the specified key path.

     - Parameters:
        - keyPath: The key path to the property used to determine uniqueness.
        - keepLast: If `false`, the first occurrence of each property is kept; otherwise the last occurrence is kept.
     - Returns: An array containing the elements of the sequence with unique values for the specified property in their original order.
     */
    func uniqued<T: Equatable>(by keyPath: KeyPath<Element, T>, keepLast: Bool = false) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] }, keepLast: keepLast)
    }
    
    /**
     Returns an array of elements with duplicates removed based the property at the specified key path.

     - Parameters:
        - keyPath: The key path to the property used to determine uniqueness.
        - keepLast: If `false`, the first occurrence of each property is kept; otherwise the last occurrence is kept.
     - Returns: An array containing the elements of the sequence with unique values for the specified property in their original order.
     */
    func uniqued<T: Hashable>(by keyPath: KeyPath<Element, T>, keepLast: Bool = false) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] }, keepLast: keepLast)
    }
    
    /**
     Returns an array of elements with duplicates removed based the value returned by the specified closure.

     - Parameters:
        - keyPath: A closure returning the value used for uniqueness.
        - keyForValue: If `false`, the first occurrence of each property is kept; otherwise the last occurrence is kept.
     - Returns: An array containing the elements of the sequence with unique values returned by the specified closure in their original order.
     */
    func uniqued<T: Equatable>(by keyForValue: (Element) throws -> T, keepLast: Bool = false) rethrows -> [Element] {
        var uniqueElements: [T] = []
        var ordered: [Element] = []
        for element in (keepLast ? reversed() : self) as any Sequence<Element> {
            let check = try keyForValue(element)
            if !uniqueElements.contains(check) {
                uniqueElements.append(check)
                ordered.append(element)
            }
        }
        return keepLast ? ordered.reversed() : ordered
    }
    
    /**
     Returns an array of elements with duplicates removed based the value returned by the specified closure.

     - Parameters:
        - keyPath: A closure returning the value used for uniqueness.
        - keyForValue: If `false`, the first occurrence of each property is kept; otherwise the last occurrence is kept.
     - Returns: An array containing the elements of the sequence with unique values returned by the specified closure in their original order.
     */
    func uniqued<T: Hashable>(by keyForValue: (Element) throws -> T, keepLast: Bool = false) rethrows -> [Element] {
        var seen = Set<T>()
        if !keepLast {
            return try filter { seen.insert(try keyForValue($0)).inserted }
        }
        var result: [Element] = []
        for element in reversed() {
            let key = try keyForValue(element)
            if seen.insert(key).inserted { result.append(element) }
        }
        return result.reversed()
    }
}

public extension Sequence {
    /// Returns the elements that appear more than once, in the order they appear.
    func duplicates() -> [Element] where Element: Equatable {
        var seen: [Element] = []
        var duplicates: [Element] = []
        for element in self {
            if seen.contains(element) {
                if !duplicates.contains(element) { duplicates.append(element) }
            } else {
                seen.append(element)
            }
        }
        return duplicates
    }

    /// Returns the elements that appear more than once, in the order they appear.
    func duplicates() -> [Element] where Element: Hashable {
        var seen = Set<Element>()
        var duplicatesSet = Set<Element>()
        var result: [Element] = []
        for element in self {
            if !seen.insert(element).inserted, duplicatesSet.insert(element).inserted {
                result.append(element)
            }
        }
        return result
    }
}
