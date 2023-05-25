//
//  Number+Clamp.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(self, range.upperBound))
    }
    
    mutating func clamp(to range: ClosedRange<Self>) {
        self = self.clamped(to: range)
    }
}

public extension Comparable where Self: ExpressibleByIntegerLiteral {
    func clamped(max maxValue: Self) -> Self {
        self.clamped(to: 0...maxValue)
    }
    
    mutating func clamp(max maxValue: Self) {
        self = clamped(to: 0...maxValue)
    }
}
