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

public extension Comparable {
    /**
     A Boolean value indicating whether the value is in the provided closed range.

     Example usage:
     
     ```swift
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
     7.isBetween(6..<12) // true
     "c".isBetween("a"..<"d") // true
     0.32.isBetween(0.31..<0.33) // true
     ```

     - Parameter range: The closed range against which the value is checked to be included.
     - Returns: Returns `true` if the value is in the provided range, otherwise `false`.
     */
    func isBetween(_ range: Range<Self>) -> Bool { range ~= self }
    
    /**
     A Boolean value indicating whether the value is greater than or equal to the lower bound of the partial range and extends infinitely in the positive direction.
     
     - Parameter range: The partial range from a lower bound to infinity.
     - Returns: `true` if the value is greater than or equal to the lower bound of the partial range, otherwise `false`.
     */
    func isBetween(_ range: PartialRangeFrom<Self>) -> Bool {
        range.lowerBound <= self
    }

    /**
     A Boolean value indicating whether the value is less than or equal to the upper bound of the partial range (inclusive of the upper bound).
     
     - Parameter range: The partial range through the upper bound.
     - Returns: `true` if the value is less than or equal to the upper bound of the partial range, otherwise `false`.
     */
    func isBetween(_ range: PartialRangeThrough<Self>) -> Bool {
        self <= range.upperBound
    }

    /**
     A Boolean value indicating whether the value is strictly less than the upper bound of the partial range (exclusive of the upper bound).
     
     - Parameter range: The partial range up to the upper bound.
     - Returns: `true` if the value is strictly less than the upper bound of the partial range, otherwise `false`.
     */
    func isBetween(_ range: PartialRangeUpTo<Self>) -> Bool {
        self < range.upperBound
    }
}

extension Comparable {
    /// Returns the comparsion result to the specified other value.
    public func comparisonResult(to other: Self) -> ComparisonResult {
        self == other ? .orderedSame : self < other ? .orderedAscending : .orderedDescending
    }
}
