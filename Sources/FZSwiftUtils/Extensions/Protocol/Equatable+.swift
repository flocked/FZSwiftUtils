//
//  File.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Equatable {
    /**
     Checks if the value is equal to another value.
     - Parameters other: A value conforming to Equatable.
     
     - Returns: Returns true if the value is equal to the other value; or false if it isn't equal or the same Comparable type.
     */
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }

    /**
     Checks if the value is equal to another value.
     - Parameters other: A value conforming to Equatable.
     
     - Returns: Returns true if the value is equal to the other value; or false if it isn't equal or the other value isn't the same Comparable type.
     */
    func isEqual(_ other: (any Equatable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}
