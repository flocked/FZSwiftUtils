//
//  Equatable+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Equatable {
    /**
     A Boolean value indicating whether the value is equatable to another value.

     - Parameter other: A value conforming to `Equatable`.
     - Returns: Returns `true` if the value is equal to the other value; or `false` if it isn't equal or if isn't the same `Equatable` type.
     */
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
    
    /**
     A Boolean value indicating whether two values are equal.
     
     - Parameters:
        - lhs: A value to compare.
        - rhs: Another value to compare.
     
     - Returns `true` if the values are equal; or `false` if the values aren't equal or the same `Equatable` type.
     */
    static func == (lhs: Self, other: any Equatable) -> Bool {
        lhs.isEqual(other)
    }
    
    /**
     A Boolean value indicating whether the value is equatable to any of the elements in the specified sequence.

     - Parameter elements: The elements to compare.
     - Returns: Returns `true` if the value is equal to any of the elemnts of the sequence.
     */
    func isEqual<S: Sequence<Self>>(toAny elements: S) -> Bool {
        elements.contains(self)
    }
}
