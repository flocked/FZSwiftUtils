//
//  Sequence+Unique.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

public extension Sequence {
    /**
    Returns the elements of the sequence with duplicate elements removed.

     - Parameter keepLast: A Boolean value indicating whether to keep the last occurrence of a duplicate element instead of the first.
     */
    func uniqued(keepLast: Bool = false) -> [Element] where Element: Equatable {
        uniqued(by: { $0 }, keepLast: keepLast)
    }
    
    /**
    Returns the elements of the sequence with duplicate elements removed.

     - Parameter keepLast: A Boolean value indicating whether to keep the last occurrence of a duplicate element instead of the first.
     */
    func uniqued(keepLast: Bool = false) -> [Element] where Element: Hashable {
        uniqued(by: { $0 }, keepLast: keepLast)
    }
    
    /**
     Returns the elements of the sequence with duplicate objects removed.

     - Parameter keepLast: A Boolean value indicating whether to keep the last occurrence of a duplicate object instead of the first.
     */
    @_disfavoredOverload
    func uniqued(keepLast: Bool = false) -> [Element] where Element: AnyObject {
        uniqued(by: { $0 }, keepLast: keepLast)
    }
}

public extension Sequence {
    /**
     Returns the elements of the sequence with duplicate values for the specified key path removed.

     - Parameters:
       - keyPath: The key path used to determine uniqueness.
       - keepLast: A Boolean value indicating whether to keep the last occurrence instead of the first.
     */
    func uniqued<T: Equatable>(by keyPath: KeyPath<Element, T>, keepLast: Bool = false) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] }, keepLast: keepLast)
    }
    
    /**
     Returns the elements of the sequence with duplicate values produced by the specified closure removed.

     - Parameters:
       - keyForValue: A closure that returns the value used to determine uniqueness for an element.
       - keepLast: A Boolean value indicating whether to keep the last occurrence instead of the first.
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
     Returns the elements of the sequence with duplicate values for the specified key path removed.

     - Parameters:
       - keyPath: The key path used to determine uniqueness.
       - keepLast: A Boolean value indicating whether to keep the last occurrence instead of the first.
     */
    func uniqued<T: Hashable>(by keyPath: KeyPath<Element, T>, keepLast: Bool = false) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] }, keepLast: keepLast)
    }
    
    /**
     Returns the elements of the sequence with duplicate values produced by the specified closure removed.

     - Parameters:
       - keyForValue: A closure that returns the value used to determine uniqueness for an element.
       - keepLast: A Boolean value indicating whether to keep the last occurrence instead of the first.
     */
    func uniqued<T: Hashable>(by keyForValue: (Element) throws -> T, keepLast: Bool = false) rethrows -> [Element] {
        var seen = Set<T>()
        if !keepLast {
            return try filter { seen.insert(try keyForValue($0)).inserted }
        }
        return try reversed().filter { seen.insert(try keyForValue($0)).inserted }.reversed()
    }
    
    
    /**
     Returns the elements of the sequence with duplicate object identities for the specified key path removed.

     - Parameters:
       - keyPath: The key path to the object whose identity is used to determine uniqueness.
       - keepLast: A Boolean value indicating whether to keep the last occurrence instead of the first.
     */
    @_disfavoredOverload
    func uniqued<T: AnyObject>(by keyPath: KeyPath<Element, T>, keepLast: Bool = false) -> [Element] {
        uniqued(by: { $0[keyPath: keyPath] }, keepLast: keepLast)
    }
    
    /**
     Returns the elements of the sequence with duplicate object identities produced by the specified closure removed.

     - Parameters:
       - keyForValue: A closure that returns the object whose identity is used to determine uniqueness for an element.
       - keepLast: A Boolean value indicating whether to keep the last occurrence instead of the first.
     */
    @_disfavoredOverload
    func uniqued<T: AnyObject>(by keyForValue: (Element) throws -> T, keepLast: Bool = false) rethrows -> [Element] {
        var seen = Set<ObjectIdentifier>()
        if !keepLast {
            return try filter { seen.insert(ObjectIdentifier(try keyForValue($0))).inserted }
        }
        return try reversed().filter { seen.insert(ObjectIdentifier(try keyForValue($0))).inserted }.reversed()
    }
}

public extension Sequence {
    /// Returns the elements that appear more than once, in the order they first appear as duplicates.
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

    /// Returns the elements that appear more than once, in the order they first appear as duplicates.
    func duplicates() -> [Element] where Element: Hashable {
        var seen = Set<Element>()
        var duplicates = Set<Element>()
        var result: [Element] = []
        for element in self {
            guard !seen.insert(element).inserted, duplicates.insert(element).inserted else { continue }
            result.append(element)
        }
        return result
    }
    
    /// Returns the elements that appear more than once, in the order they first appear as duplicates.
    @_disfavoredOverload
    func duplicates() -> [Element] where Element: AnyObject {
        var seen = Set<ObjectIdentifier>()
        var duplicates = Set<ObjectIdentifier>()
        var result: [Element] = []
        for element in self {
            let id = ObjectIdentifier(element)
            guard !seen.insert(id).inserted, duplicates.insert(id).inserted else { continue }
            result.append(element)
        }
        return result
    }
}
