//
//  File.swift
//  
//
//  Created by Florian Zand on 23.08.22.
//

import Foundation

public extension Dictionary  {
    static func +(lhs: [Key:Value], rhs:[Key:Value]) -> [Key:Value] {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    static func +=(lhs: inout [Key:Value], rhs:[Key:Value]) {
        rhs.forEach {
            lhs[$0] = $1
        }
    }
}
