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
    func difference<C: Collection<Element>>(to other: C) -> (removed: [Element], added: [Element], changed: [Element], unchanged: [Element]) where C.Index: BinaryInteger {
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
