//
//  CharacterSet+.swift
//
//
//  Created by Florian Zand on 25.02.24.
//

import Foundation

extension CharacterSet: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral {
    public init(stringLiteral value: String) {
        self = .init(charactersIn: value)
    }
    
    /// A Boolean value indicating whether the character set contains the other character set.
    public func contains(_ other: CharacterSet) -> Bool {
        self - other != self
    }
    
    /// A Boolean value indicating whether the character set contains the other character sets.
    public func contains(_ others: [CharacterSet]) -> Bool {
        contains(others.union)
    }
        
    public static func + (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.union(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: CharacterSet) {
        lhs = lhs + rhs
    }
    
    public static func - (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.subtracting(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: CharacterSet) {
        lhs = lhs - rhs
    }
}

extension Array where Element == CharacterSet {
    public var union: CharacterSet {
        reduce(into: CharacterSet()) { $0 += $1 }
    }
}
