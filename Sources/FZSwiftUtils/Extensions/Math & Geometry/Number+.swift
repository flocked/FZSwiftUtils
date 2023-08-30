//
//  Number+.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public extension BinaryFloatingPoint {
    /**
     Interpolates a value from one range to another range.
     
     - Parameters:
        - from: The source range.
        - to: The target range.
     
     - Returns: The interpolated value within the target range.
     */
    func interpolated(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        let positionInRange = (self - from.lowerBound) / (from.upperBound - from.lowerBound)
        return (positionInRange * (to.upperBound - to.lowerBound)) + to.lowerBound
    }
}

public extension CGFloat {
    init?(_ value: StringLiteralType) {
        if let doubleValue = Double(value) {
            self = CGFloat(doubleValue)
        } else {
            return nil
        }
    }
}

public extension CGFloat {
    /**
     Returns the scaled integral value of the CGFloat.
     The value is scaled based on the current device's screen scale.
     
     - Returns: The scaled integral value of the CGFloat.
     */
    var scaledIntegral: Self {
        #if os(macOS)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(iOS)
        let scale = UIScreen.main.scale
        #endif
        return floor(self * scale) / scale
    }
}

public extension CGFloat {
    /**
     Converts the value from degrees to radians.
     
     - Returns: The value converted to radians.
     */
    func degreesToRadians() -> CGFloat {
        return CGFloat(CGFloat.pi) * self / 180.0
    }
}

public extension BinaryFloatingPoint {
    /**
     Converts the value from degrees to radians.
     
     - Returns: The value converted to radians.
     */
    func degreesToRadians() -> Self {
        return Self.pi * self / 180.0
    }
}

public extension Int {
    enum NextValueType {
        case next
        case previous
        case nextLooping
        case previousLooping
        case random
        case first
        case last
    }

    func next(in range: ClosedRange<Self>) -> Self {
        return advanced(by: .next, in: range)
    }

    func nextLooped(in range: ClosedRange<Self>) -> Self {
        return advanced(by: .nextLooping, in: range)
    }

    func previous(in range: ClosedRange<Self>) -> Self {
        return advanced(by: .previous, in: range)
    }

    func previousLooped(in range: ClosedRange<Self>) -> Self {
        return advanced(by: .previousLooping, in: range)
    }

    func advanced(by type: NextValueType, in range: ClosedRange<Self>) -> Self {
        var index = self
        switch type {
        case .next:
            index = index + 1
            if index > range.upperBound {
                index = range.upperBound
            }
        case .previous:
            index = index - 1
            if index < range.lowerBound {
                index = range.lowerBound
            }
        case .nextLooping:
            index = index + 1
            if index > range.upperBound {
                index = range.lowerBound
            }
        case .previousLooping:
            index = index - 1
            if index < range.lowerBound {
                index = range.upperBound
            }
        case .random:
            index = Int.random(in: range)
        case .first:
            index = range.lowerBound
        case .last:
            index = range.upperBound
        }
        return index
    }
}

/// Floating point rounding rules for decimal places.
public enum FloatingPointPlacesRoundingRule {
    /// Rounds the value to the specified number of decimal places.
    case toPlaces(Int)
    /// Rounds the value to the specified number of decimal places towards zero.
    case toPlacesTowardZero(Int)
    internal var places: Int {
        switch self {
        case let .toPlaces(value), let .toPlacesTowardZero(value):
            return value
        }
    }

    internal var divisor: Double {
        return pow(10.0, Double(places))
    }

    internal var rounding: FloatingPointRoundingRule {
        switch self {
        case .toPlaces:
            return .toNearestOrAwayFromZero
        case .toPlacesTowardZero:
            return .towardZero
        }
    }
}

public extension BinaryFloatingPoint {
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameters:
        - rule: The rounding rule to apply.
     
     - Returns: The rounded value.
     */
    func rounded(_ rule: FloatingPointPlacesRoundingRule) -> Self {
        let divisor = Self(rule.divisor)
        return (self * divisor).rounded(rule.rounding) / divisor
    }

    /**
     Rounds the value using the specified rounding rule.
     
     - Parameters:
        - rule: The rounding rule to apply.
     
     - Returns: The rounded value.
     */
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        let divisor = Self(rule.divisor)
        self = (self * divisor).rounded(rule.rounding) / divisor
    }

    /**
     Returns the number of decimal places in the value.
     
     - Returns: The count of decimal places.
     */
    var placesCount: Int {
        let decimal = Decimal(Double(self))
        return max(-decimal.exponent, 0)
    }
}
