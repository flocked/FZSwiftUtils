//
//  File.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation


public extension Comparable {
    /**
     Compares if the value is less than another value.
     - Parameters other: A value conforming to Comparable.
     
     - Returns: Returns true if the value is less than the other value; or false if it isn't less or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }

    /**
     Compares if the value is less than another value.
     - Parameters other: A value conforming to Comparable.
     
     - Returns: Returns true if the value is less than the other value; or false if it isn't less or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }
    
    /**
     Compares if the value is less or equal to another value.
     - Parameters other: A value conforming to Comparable.
     
     - Returns: Returns true if the value is less than or equal to the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self <= other
    }
    
    /**
     Compares if the value is less or equal to another value.
     - Parameters other: A value conforming to Comparable.
     
     - Returns: Returns true if the value is less than or equal to the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self <= other
    }

    static func < (lhs: Self, other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return lhs < other
    }

    static func < (lhs: Self, other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return lhs < other
    }
}

public extension PartialKeyPath {
    func isLessThan(_ keypath: PartialKeyPath<Root>) -> Bool {
        guard let b = keypath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThan(b)
    }
    
    func isLessThanOrEqual(_ keypath: PartialKeyPath<Root>) -> Bool {
        guard let b = keypath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThanOrEqual(b)
    }
}
