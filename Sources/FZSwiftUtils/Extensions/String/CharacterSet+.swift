//
//  CharacterSet+.swift
//
//
//  Created by Florian Zand on 25.02.24.
//

import Foundation

extension CharacterSet {
    public static func + (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.union(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: CharacterSet) {
        lhs = lhs.union(rhs)
    }
    
    public static func - (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.subtracting(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: CharacterSet) {
        lhs = lhs.subtracting(rhs)
    }
}

extension Array where Element == CharacterSet {
    public var union: CharacterSet {
        reduce(into: CharacterSet()) { $0 += $1 }
    }
}
