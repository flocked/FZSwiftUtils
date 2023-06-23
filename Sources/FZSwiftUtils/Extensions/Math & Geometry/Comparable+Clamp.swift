//
//  Number+Clamp.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension Comparable {
    /**
     Clamps the value to the specified closed range.
     
     - Parameters:
        - range: The closed range to clamp the value to.
     
     - Returns: The clamped value.
     */
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(self, range.upperBound))
    }

    /**
     Clamps the value to the specified closed range.
     
     - Parameters:
        - range: The closed range to clamp the value to.
     */
    mutating func clamp(to range: ClosedRange<Self>) {
        self = clamped(to: range)
    }
}

public extension Comparable where Self: ExpressibleByIntegerLiteral {
    /**
     Clamps the value to a maximum value. It uses 0 as minimum value.
     
     - Parameters:
        - maxValue: The maximum value to clamp the value to.
     
     - Returns: The clamped value.
     */
    func clamped(max maxValue: Self) -> Self {
        clamped(to: 0 ... maxValue)
    }

    /**
     Clamps the value to a maximum value. It uses 0 as minimum value.
     
     - Parameters:
        - maxValue: The maximum value to clamp the value to.
     */
    mutating func clamp(max maxValue: Self) {
        self = clamped(to: 0 ... maxValue)
    }
}
