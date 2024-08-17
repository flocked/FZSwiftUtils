//
//  Hasher+.swift
//
//
//  Created by Florian Zand on 17.08.24.
//

import Foundation

extension Hasher {
    /// Calculates the hash value for the specified `Hashable` types.
    public static func calculate(_ values: [any Hashable]) -> Int {
        var hasher = Hasher()
        values.forEach({hasher.combine($0)})
        return hasher.finalize()
    }
    
    /// Calculates the hash value for the specified `Hashable` types.
    public static func calculate(_ values: any Hashable...) -> Int {
        calculate(values)
    }
}
