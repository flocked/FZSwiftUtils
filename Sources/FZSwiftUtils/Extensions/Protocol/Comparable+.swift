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
    
    @_disfavoredOverload
    static func < (lhs: Self, other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs < other
    }

    @_disfavoredOverload
    static func < (lhs: Self, other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs < other
    }
    
    @_disfavoredOverload
    static func <= (lhs: Self, other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs <= other
    }

    @_disfavoredOverload
    static func <= (lhs: Self, other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs <= other
    }
    
    @_disfavoredOverload
    static func > (lhs: Self, other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs > other
    }

    @_disfavoredOverload
    static func > (lhs: Self, other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs > other
    }
    
    @_disfavoredOverload
    static func >= (lhs: Self, other: any Comparable) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs >= other
    }

    @_disfavoredOverload
    static func >= (lhs: Self, other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else { return false }
        return lhs >= other
    }
}

public extension Comparable {
    /**
     A Boolean value indicating whether the value is between the two specified values.

     Example usage:

     ```swift
     5.isBetween(3, 7) // true
     3.isBetween(3, 7, inclusive: false) // false
     7.isBetween(3, 7, inclusive: false) // false
     ```
     
     - Parameters:
       - lowerBound: One end of the range.
       - upperBound: The other end of the range.
       - inclusive: A Boolean indicating whether the comparison includes the endpoints.

     - Returns: `true` if the value is between the specified values.
     */
    func isBetween(_ lowerBound: Self, _ upperBound: Self, inclusive: Bool = true) -> Bool {
        let lower = Swift.min(lowerBound, upperBound)
        let upper = Swift.max(lowerBound, upperBound)
        return inclusive ? self >= lower && self <= upper : lower < self && self < upper
    }

    /**
     A Boolean value indicating whether the value is contained within the specified range.

     Example usage:

     ```swift
     7.isBetween(6...12) // true
     "c".isBetween("a"..."d") // true
     0.32.isBetween(0.31...0.33) // true
     ```

     - Parameter range: The range against which the value is checked to be included.
     - Returns: `true` if the value is inside the range, otherwise `false`.
     */
    func isBetween(_ range: ClosedRange<Self>) -> Bool {
        range.contains(self)
    }

    /**
     A Boolean value indicating whether the value is contained within the specified range.

     Example usage:

     ```swift
     7.isBetween(6..<12) // true
     "c".isBetween("a"..<"d") // true
     0.32.isBetween(0.31..<0.33) // true
     ```

     - Parameter range: The range against which the value is checked to be included.
     - Returns: `true` if the value is inside the range, otherwise `false`.
     */
    func isBetween(_ range: Range<Self>) -> Bool {
        range.contains(self)
    }

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
    
    /// A Boolean value indicating whether the value is within the specified tolerance.
    func isWithin(_ tolerance: Self) -> Bool where Self: AdditiveArithmetic {
        isBetween(self-tolerance, self+tolerance)
    }
}

extension Comparable {
    /// Returns the comparsion result to the specified other value.
    public func comparisonResult(to other: Self) -> ComparisonResult {
        self == other ? .orderedSame : self < other ? .orderedAscending : .orderedDescending
    }
}
