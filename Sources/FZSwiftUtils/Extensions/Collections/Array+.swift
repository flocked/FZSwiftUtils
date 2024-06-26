//
//  Array+.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

import Foundation

public extension Array {
    /// Adds the specified optional `Element`.
    static func += (lhs: inout [Element], rhs: Element?) {
        if let rhs = rhs {
            lhs.append(rhs)
        }
    }

    /// Adds the specified optional `Element`.
    static func + (lhs: [Element], rhs: Element?) -> [Element] {
        var copy = lhs
        if let rhs = rhs {
            copy.append(rhs)
        }
        return copy
    }

    static func + (lhs: Element?, rhs: [Element]) -> [Element] {
        var copy = rhs
        if let lhs = lhs {
            copy.insert(lhs, at: 0)
        }
        return copy
    }
}

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
