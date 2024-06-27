//
//  Array+.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

import Foundation

public extension Array where Element: Hashable {
    /// Set with the elements of the array.
    var asSet: Set<Element> {
        Set(self)
    }
}

extension Array: Comparable where Element: Comparable {
    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        for (leftElement, rightElement) in zip(lhs, rhs) {
            if leftElement < rightElement {
                return true
            } else if leftElement > rightElement {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}

public extension ArraySlice {
    /// Array with the elements of the array slice.
    var asArray: [Element] {
        Array(self)
    }
}

public extension ArraySlice where Element: Hashable {
    /// Set with the elements of the array slice.
    var asSet: Set<Element> {
        Set(self)
    }
}
