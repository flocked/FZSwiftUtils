//
//  Hasher+.swift
//
//
//  Created by Florian Zand on 17.08.24.
//

import Foundation

extension Hasher {
    /**
     Computes a hash value for the specified `Hashable` elements.
     
     Example usage:
     ```swift
     let hashValue = Hasher.hash([1, "String", 3.7])
     ```

     - Parameter elements: A sequence of elements that conform to `Hashable`.
     - Returns: The hash value for the `elements`.
     */
    public static func hash<S: Sequence>(_ elements: S) -> Int where S.Element == any Hashable {
        var hasher = Hasher()
        elements.forEach { hasher.combine($0) }
        return hasher.finalize()
    }
    
    /**
     Computes a hash value for the specified `Hashable` elements.

     Example usage:
     ```swift
     let hashValue = Hasher.hash(1, "String", 3.7)
     ```

     - Parameter elements: A variadic list of elements that conform to `Hashable`.
     - Returns: The hash value for the `elements`.
     */
    @_disfavoredOverload
    public static func hash(_ elements: any Hashable...) -> Int {
        var hasher = Hasher()
        elements.forEach { hasher.combine($0) }
        return hasher.finalize()
    }
}
