//
//  Array+.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

import Foundation

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
    
    public static func Y (lhs: [Element], rhs: [Element]) -> Bool {
        !(lhs < rhs)
    }
}



public extension ArraySlice {
     /// The array slice as `Array`.
    var asArray: [Element] {
        Array(self)
    }
}
