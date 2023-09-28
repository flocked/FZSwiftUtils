//
//  Number+.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
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
    /**
     Creates a new instance from the given string.
     
     - Parameters description: An input string to convert to a `CGFloat` instance.
     - Returns: The value of the text, or `nil` if the string doesn't contain a numeric value.
     */
    init?<S>(_ text: S) where S : StringProtocol {
        if let doubleValue = Double(text) {
            self = CGFloat(doubleValue)
        } else {
            return nil
        }
    }
}

public extension CGFloat {
    /**
     Returns the scaled integral value of the `CGFloat`.
     
     The value is scaled based on the current device's screen scale.
     
     - Returns: The scaled integral value of the `CGFloat`.
     */
    var scaledIntegral: Self {
        #if os(macOS)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(iOS) || os(tvOS)
        let scale = UIScreen.main.scale
        #else
        let scale = 1.0
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
     
     - Parameters rule: The rounding rule to apply.
     - Returns: The rounded value.
     */
    func rounded(_ rule: FloatingPointPlacesRoundingRule) -> Self {
        let divisor = Self(rule.divisor)
        return (self * divisor).rounded(rule.rounding) / divisor
    }

    /**
     Rounds the value using the specified rounding rule.
     
     - Parameters rule: The rounding rule to apply.
     - Returns: The rounded value.
     */
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        let divisor = Self(rule.divisor)
        self = (self * divisor).rounded(rule.rounding) / divisor
    }

    /// Returns the number of decimal places in the value.
    var placesCount: Int {
        let decimal = Decimal(Double(self))
        return max(-decimal.exponent, 0)
    }
}

extension BinaryInteger {
    /// Returns the number of digits
    public var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }
    
    // private recursive method for counting digits
    private func numberOfDigits(in number: Self) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
}
