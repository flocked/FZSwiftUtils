//
//  Comparable+.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

/*
 /**
  Returns a Boolean value indicating whether the keypath's value is equatable to another keypath's value.
  
  - Parameters other: A partial keypath
  - Returns: Returns true if the keypath's value is equal to the other keypath's value; or false if it isn't equal or if isn't the same Equatable type.
  */
 */

public extension Comparable {
    /**
     Returns a Boolean value indicating whether the value is less than another value.
     
     - Parameters other: A value conforming to Comparable.
     - Returns: Returns true if the value is less than the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }

    /**
     Returns a Boolean value indicating whether the value is less than another value.
     
     - Parameters other: A value conforming to Comparable.
     - Returns: Returns true if the value is less than the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }
    
    /**
     Returns a Boolean value indicating whether the value is less or equal to another value.
     
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
     Returns a Boolean value indicating whether the value is less or equal to another value.
     
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
    /**
     Returns a Boolean value indicating whether the keypath's value is less than another keypath's value.
     
     - Parameters keyPath: The keypath for comparing it's value.
     - Returns: Returns true if the keypath's value is less than the other keypath's value; or false if it isn't or if the other keypath's value isn't the same Comparable type.
     */
    func isLessThan(_ keyPath: PartialKeyPath<Root>) -> Bool {
        guard let b = keyPath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThan(b)
    }
    
    /**
     Returns a Boolean value indicating whether the keypath's value is less than or equal to another keypath's value.
     
     - Parameters keyPath: The keypath for comparing it's value.
     - Returns: Returns true if the keypath's value is less than or equal to the other keypath's value; or false if it isn't or if the other keypath's value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ keyPath: PartialKeyPath<Root>) -> Bool {
        guard let b = keyPath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThanOrEqual(b)
    }
}
