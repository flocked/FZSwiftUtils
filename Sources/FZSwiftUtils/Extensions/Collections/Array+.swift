//
//  Array+.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

import Foundation

extension Array {
    
    public static func +=(lhs: inout [Element], rhs: Element?) {
        if let rhs = rhs {
            lhs.append(rhs)
        }
    }

    public static func +(lhs: [Element], rhs: Element?) -> [Element]  {
        var copy = lhs
        if let rhs = rhs {
            copy.append(rhs)
        }
        return copy
    }

    public static func +(lhs: Element?, rhs: [Element]) -> [Element] {
        var copy = rhs
        if let lhs = lhs {
            copy.insert(lhs, at: 0)
        }
        return copy
    }
}