//
//  Comparable+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Comparable {
    /**
     A Boolean value indicating whether the value is less than another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is less than the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }

    /**
     A Boolean value indicating whether the value is less than another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is less than the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }

    /**
     A Boolean value indicating whether the value is less or equal to another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is less than or equal to the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self <= other
    }

    /**
     A Boolean value indicating whether the value is less or equal to another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is less than or equal to the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self <= other
    }
    
    /**
     A Boolean value indicating whether the value is more than another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is more than the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isMoreThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self > other
    }

    /**
     A Boolean value indicating whether the value is more than another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is more than the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isMoreThan(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self > other
    }

    /**
     A Boolean value indicating whether the value is more or equal to another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is more than or equal to the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isMoreThanOrEqual(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self >= other
    }

    /**
     A Boolean value indicating whether the value is more or equal to another value.

     - Parameter other: A value conforming to Comparable.
     - Returns: Returns `true` if the value is more than or equal to the other value; or `false` if it isn't or if the other value isn't the same Comparable type.
     */
    func isMoreThanOrEqual(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self >= other
    }
    
    static func < (lhs: Self, other: any Comparable) -> Bool {
        lhs.isLessThan(other)
    }

    static func < (lhs: Self, other: (any Comparable)?) -> Bool {
        lhs.isLessThan(other)
    }
    
    static func <= (lhs: Self, other: any Comparable) -> Bool {
        lhs.isLessThanOrEqual(other)
    }

    static func <= (lhs: Self, other: (any Comparable)?) -> Bool {
        lhs.isLessThanOrEqual(other)
    }

    static func > (lhs: Self, other: any Comparable) -> Bool {
        lhs.isMoreThan(other)
    }

    static func > (lhs: Self, other: (any Comparable)?) -> Bool {
        lhs.isMoreThan(other)
    }
    
    static func >= (lhs: Self, other: any Comparable) -> Bool {
        lhs.isMoreThanOrEqual(other)
    }

    static func >= (lhs: Self, other: (any Comparable)?) -> Bool {
        lhs.isMoreThanOrEqual(other)
    }
}

public extension Comparable {
    /**
     A Boolean value indicating whether the value is in the provided closed range.

     Example usage:
     ```swift
     1.isBetween(5...7) // false
     7.isBetween(6...12) // true
     "c".isBetween("a"..."d") // true
     0.32.isBetween(0.31...0.33) // true
     ```

     - Parameter range: The range against which the value is checked to be included.
     - Returns: Returns `true` if the value is in the provided range, or `false` if it isn't.
     */
    func isBetween(_ range: ClosedRange<Self>) -> Bool { range ~= self }

    /**
     A Boolean value indicating whether the value is in the provided range.

     Example usage:
     ```swift
     1.isBetween(5..<7) // false
     7.isBetween(6..<12) // true
     "c".isBetween("a"..<"d") // true
     0.32.isBetween(0.31..<0.33) // true
     ```

     - Parameter range: The closed range against which the value is checked to be included.
     - Returns: Returns `true` if the value is in the provided range, or `false` if it isn't.
     */
    func isBetween(_ range: Range<Self>) -> Bool { range ~= self }
}

public extension PartialKeyPath {
    /**
     A Boolean value indicating whether the keypath's value is less than another keypath's value.

     - Parameter keyPath: The keypath for comparing it's value.
     - Returns: Returns `true` if the keypath's value is less than the other keypath's value; or `false` if it isn't or if the other keypath's value isn't the same Comparable type.
     */
    func isLessThan(_ keyPath: PartialKeyPath<Root>) -> Bool {
        guard let b = keyPath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThan(b)
    }

    /**
     A Boolean value indicating whether the keypath's value is less than or equal to another keypath's value.

     - Parameter keyPath: The keypath for comparing it's value.
     - Returns: Returns `true` if the keypath's value is less than or equal to the other keypath's value; or `false` if it isn't or if the other keypath's value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ keyPath: PartialKeyPath<Root>) -> Bool {
        guard let b = keyPath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThanOrEqual(b)
    }
}

/*
extension Optional: Comparable where Wrapped: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard let lhs = lhs else { return false }
        guard let rhs = rhs else { return false }
        return lhs < rhs
    }
}
*/
