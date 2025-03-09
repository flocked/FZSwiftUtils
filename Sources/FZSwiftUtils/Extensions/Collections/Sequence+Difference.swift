//
//  Sequence+Difference.swift
//
//
//  Created by Florian Zand on 19.07.23.
//

import Foundation

public extension Sequence where Element: Equatable {
    /**
     Returns the difference needed to produce this collection’s ordered elements from the given collection.

     - Parameter other: The other collection to compare.
     - Returns: The difference needed to produce this collection’s ordered elements from the given collection.
     */
    func difference<C: Collection<Element>>(to other: C) -> (removed: [Element], added: [Element], unchanged: [Element]) {
        var removed: [Element] = []
        var unchanged: [Element] = []
        for element in self {
            if other.contains(element) {
                unchanged.append(element)
            } else {
                removed.append(element)
            }
        }

        let added = other.filter { contains($0) == false }
        return (removed, added, unchanged)
    }
    
    /**
     Returns the difference needed to produce this collection’s ordered elements from the given collection.

     - Parameter other: The other collection to compare.
     - Returns: The difference needed to produce this collection’s ordered elements from the given collection.
     */
    func differenceIndexed<C: Collection<Element>>(to other: C) -> (removed: [Element], added: [Element], changed: [Element], unchanged: [Element]) where C.Index: BinaryInteger {
        var removed: [Element] = []
        var changed: [Element] = []
        var unchanged: [Element] = []
        for (index, element) in enumerated() {
            if let otherIndex = other.firstIndex(of: element) {
                if index == otherIndex {
                    unchanged.append(element)
                } else {
                    changed.append(element)
                }
            } else {
                removed.append(element)
            }
        }

        let added = other.filter { contains($0) == false }
        return (removed, added, changed, unchanged)
    }
}

public extension Sequence where Element: Hashable {
    /**
     Returns the difference needed to produce this collection’s ordered elements from the given collection.

     - Parameter other: The other collection to compare.
     - Returns: The difference needed to produce this collection’s ordered elements from the given collection.
     */
    func difference<C: Sequence>(to other: C) -> (removed: [Element], added: [Element], unchanged: [Element]) where C.Element == Element {
        let selfSet = Set(self)
        let otherSet = Set(other)

        let removed = selfSet.subtracting(otherSet)
        let added = otherSet.subtracting(selfSet)
        let unchanged = selfSet.intersection(otherSet)

        let removedOrdered = filter { removed.contains($0) }
        let unchangedOrdered = filter { unchanged.contains($0) }
        let addedOrdered = other.filter { added.contains($0) }

        return (removedOrdered, addedOrdered, unchangedOrdered)
    }
    
    /**
     Returns the difference needed to produce this collection’s ordered elements from the given collection.

     - Parameter other: The other collection to compare.
     - Returns: The difference needed to produce this collection’s ordered elements from the given collection.
     */
    func differenceIndexed<C: Collection<Element>>(to other: C) -> (removed: [Element], added: [Element], changed: [Element], unchanged: [Element]) where C.Index: BinaryInteger {
        let otherSet = Set(other)
        let indexMap = Dictionary(uniqueKeysWithValues: other.enumerated().map { ($1, $0) })

        var removed: [Element] = []
        var changed: [Element] = []
        var unchanged: [Element] = []

        for (index, element) in enumerated() {
            if let otherIndex = indexMap[element] {
                if index == otherIndex {
                    unchanged.append(element)
                } else {
                    changed.append(element)
                }
            } else {
                removed.append(element)
            }
        }

        let selfSet = Set(self)
        let added = other.filter { !selfSet.contains($0) }

        return (removed, added, changed, unchanged)
    }
}
