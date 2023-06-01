//
//  Equatable+.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Equatable {
    /**
     Returns a Boolean value indicating whether the value is equatable to another value.
     
     - Parameters other: A value conforming to Equatable.
     - Returns: Returns true if the value is equal to the other value; or false if it isn't equal or if isn't the same Equatable type.
     */
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }

    /**
     Returns a Boolean value indicating whether the value is equatable to another value.
     
     - Parameters other: A value conforming to Equatable.
     - Returns: Returns true if the value is equal to the other value; or false if it isn't equal or if isn't the same Equatable type.
     */
    func isEqual(_ other: (any Equatable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

public extension PartialKeyPath {
    /**
     Returns a Boolean value indicating whether the keypath's value is equatable to another keypath's value.
     
     - Parameters keyPath: The keypath for checking the equallity.
     - Returns: Returns true if the keypath's value is equal to the other keypath's value; or false if it isn't equal or if isn't the same Equatable type.
     */
    func isEqual(_ keyPath: PartialKeyPath<Root>) -> Bool {
        return self == keyPath
    }
}
