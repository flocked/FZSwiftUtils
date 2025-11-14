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

     - Parameter other: A value conforming to Equatable.
     - Returns: Returns `true` if the value is equal to the other value; or `false` if it isn't equal or if isn't the same Equatable type.
     */
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }

    /**
     A Boolean value indicating whether the value is equatable to another value.

     - Parameter other: A value conforming to Equatable.
     - Returns: Returns `true` if the value is equal to the other value; or `false` if it isn't equal or if isn't the same Equatable type.
     */
    func isEqual(_ other: (any Equatable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
    
    @_disfavoredOverload
    static func == (lhs: Self, rhs: any Equatable) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return lhs == rhs
    }
    
    @_disfavoredOverload
    static func == (lhs: Self, rhs: (any Equatable)?) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return lhs == rhs
    }
    
    @_disfavoredOverload
    static func != (lhs: Self, rhs: any Equatable) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return lhs != rhs
    }
    
    @_disfavoredOverload
    static func != (lhs: Self, rhs: (any Equatable)?) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return lhs != rhs
    }
}


public extension Equatable {
    /**
     A Boolean value indicating whether the value exists in the specified collection.
     
     - Parameter sequence: A sequence of elements to check.
     */
    func exists<S: Sequence<Self>>(in sequence: S) -> Bool {
        sequence.contains(self)
    }

    /**
     A Boolean value indicating whether the values for the specified key paths are equatable to the values of another object..

     - Parameter other: Another object of the same type.
     - Returns: Returns `true` if the values for the key paths are equal to the values of the other object; or `false` if they aren't equal.
     */
    func isEqual(_ other: Self, for keyPaths: [PartialKeyPath<Self>]) -> Bool {
        for keyPath in keyPaths {
            if let value = self[keyPath: keyPath] as? (any Equatable),
               let compareValue = other[keyPath: keyPath] as? (any Equatable), !value.isEqual(compareValue)
            {
                return false
            }
        }
        return true
    }
}
