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

     - Parameter other: A value conforming to `Comparable`.
     - Returns: Returns `true` if the value is less than the other value; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    func isLessThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return self < other
    }

    /**
     A Boolean value indicating whether the value is less or equal to another value.

     - Parameter other: A value conforming to `Comparable`.
     - Returns: Returns `true` if the value is less than or equal to the other value; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    func isLessThanOrEqual(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return self <= other
    }
    
    /**
     A Boolean value indicating whether the value is more than another value.

     - Parameter other: A value conforming to `Comparable`.
     - Returns: Returns `true` if the value is more than the other value; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    func isMoreThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return self > other
    }

    /**
     A Boolean value indicating whether the value is more or equal to another value.

     - Parameter other: A value conforming to `Comparable`.
     - Returns: Returns `true` if the value is more than or equal to the other value; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    func isMoreThanOrEqual(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return self >= other
    }

    /**
     A Boolean value indicating whether the value of the first argument is less than that of the second argument.
     
     - Parameters:
        - lhs: A value to compare.
        - rhs: Another value to compare.
     
     - Returns `true` if the first valus is less than the second; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    static func < (lhs: Self, rhs: any Comparable) -> Bool {
        lhs.isLessThan(rhs)
    }
    
    /**
     A Boolean value indicating whether the value of the first argument is less than or equal to that of the second argument.
     
     - Parameters:
        - lhs: A value to compare.
        - rhs: Another value to compare.
     
     - Returns `true` if the first valus is less than or equal to the second; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    static func <= (lhs: Self, rhs: any Comparable) -> Bool {
        lhs.isLessThanOrEqual(rhs)
    }
    
    /**
     A Boolean value indicating whether the value of the first argument is more than that of the second argument.
     
     - Parameters:
        - lhs: A value to compare.
        - rhs: Another value to compare.
     
     - Returns `true` if the first valus is more than the second; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    static func > (lhs: Self, rhs: any Comparable) -> Bool {
        lhs.isMoreThan(rhs)
    }
    
    /**
     A Boolean value indicating whether the value of the first argument is more than or equal to that of the second argument.
     
     - Parameters:
        - lhs: A value to compare.
        - rhs: Another value to compare.
     
     - Returns `true` if the first valus is more than or equal to the second; or `false` if it isn't or if the values aren't the same `Comparable` type.
     */
    static func >= (lhs: Self, rhs: any Comparable) -> Bool {
        lhs.isMoreThanOrEqual(rhs)
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
