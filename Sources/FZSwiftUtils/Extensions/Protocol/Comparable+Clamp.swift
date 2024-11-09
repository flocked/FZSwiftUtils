//
//  Comparable+Clamp.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension Comparable {
    /**
     Clamps the value to the specified closed range.

     - Parameter range: The closed range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }
    
    /**
     Clamps the value to the specified range.

     - Parameter range: The closed range to clamp the value to.
     - Returns: The clamped value.
     */

    func clamped(to range: Range<Self>) -> Self where Self: BinaryInteger {
        max(range.lowerBound, min(self, range.upperBound-1))
    }

    /**
     Clamps the value to the specified partial range.

     - Parameter range: The partial range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: PartialRangeFrom<Self>) -> Self {
        max(range.lowerBound, self)
    }

    /**
     Clamps the value to the specified partial range.

     - Parameter range: The partial range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        min(range.upperBound, self)
    }
    
    /**
     Clamps the value to a minimum value.

     - Parameter minValue: The minimum value to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(min minValue: Self) -> Self {
        max(minValue, self)
    }
    
    /**
     Clamps the value to a maximum value.

     - Parameter maxValue: The maximum value to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(max maxValue: Self) -> Self {
        min(maxValue, self)
    }

    /**
     Clamps the value to the specified closed range.

     - Parameter range: The closed range to clamp the value to.
     */
    mutating func clamp(to range: ClosedRange<Self>) {
        self = clamped(to: range)
    }

    /**
     Clamps the value to specified partial range.

     - Parameter range: The partial range to clamp the value to.
     */
    mutating func clamp(to range: PartialRangeFrom<Self>) {
        self = max(range.lowerBound, self)
    }

    /**
     Clamps the value to specified partial range.

     - Parameter range: The partial range to clamp the value to.
     */
    mutating func clamp(to range: PartialRangeUpTo<Self>) {
        self = min(range.upperBound, self)
    }
    
    /**
     Clamps the value to a minimum value.

     - Parameter minValue: The minimum value to clamp the value to.
     */
    mutating func clamp(min minValue: Self) {
        self = max(minValue, self)
    }
    
    /**
     Clamps the value to a maximum value.

     - Parameter maxValue: The maximum value to clamp the value to.
     */
    mutating func clamp(max maxValue: Self) {
        self = min(maxValue, self)
    }
}
