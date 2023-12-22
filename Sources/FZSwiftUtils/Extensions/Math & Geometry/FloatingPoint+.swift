//
//  FloatingPoint+.swift
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
    /// Converts the value from degrees to radians.
    var degreesToRadians: Self {
        return Self.pi * self / 180.0
    }
    
    /// Converts the value from radians to degress.
    var radiansToDegrees: Self {
        return self * 180 / Self.pi
    }
    
    /// Returns the number of decimal places in the value.
    var placesCount: Int {
        let decimal = Decimal(Double(self))
        return max(-decimal.exponent, 0)
    }
}

public extension Float {
    /**
     Returns the scaled integral value of the value.
     
     The value is scaled based on the current device's screen scale.
     */
    var scaledIntegral: Self {
        #if os(macOS)
        let scale = Self(NSScreen.main?.backingScaleFactor ?? 1.0)
        #elseif os(iOS) || os(tvOS)
        let scale = Float(UIScreen.main.scale)
        #else
        let scale: Float = 1.0
        #endif
        return rounded(toNearest: 1.0/scale)
    }
}

public extension Double {
    /**
     Returns the scaled integral value of the value.
     
     The value is scaled based on the current device's screen scale.
     */
    var scaledIntegral: Self {
        #if os(macOS)
        let scale = Self(NSScreen.main?.backingScaleFactor ?? 1.0)
        #elseif os(iOS) || os(tvOS)
        let scale = UIScreen.main.scale
        #else
        let scale = 1.0
        #endif
        return rounded(toNearest: 1.0/scale)
    }
}

public extension CGFloat {
    /**
     Returns the scaled integral value of the `CGFloat`.
     
     The value is scaled based on the current device's screen scale.
     */
    var scaledIntegral: Self {
        #if os(macOS)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(iOS) || os(tvOS)
        let scale = UIScreen.main.scale
        #else
        let scale = 1.0
        #endif
        return rounded(toNearest: 1.0/scale)
    }
    
    /// Converts the value from degrees to radians.
    var degreesToRadians: CGFloat {
        return Self.pi * self / 180.0
    }
    
    /// Converts the value from radians to degress.
    var radiansToDegrees: CGFloat {
        return self * 180 / Self.pi
    }
    
    /// Returns the number of decimal places in the value.
    var placesCount: Int {
        let decimal = Decimal(Double(self))
        return Swift.max(-decimal.exponent, 0)
    }
    
    /**
     Creates a new instance from the given string.
     
     - Parameter description: An input string to convert to a `CGFloat` instance.
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

public extension BinaryFloatingPoint {
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     - Returns: The rounded value.
     */
    func rounded(_ rule: FloatingPointPlacesRoundingRule) -> Self {
        let divisor = Self(rule.divisor)
        return (self * divisor).rounded(rule.rounding) / divisor
    }

    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     */
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        let divisor = Self(rule.divisor)
        self = (self * divisor).rounded(rule.rounding) / divisor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
        - roundingFactor: The rounding factor.
        - rule: The rounding rule to apply. The default value is `up`.
     
     - Returns: The rounded value.
     */
    func rounded(toNearest roundingFactor: Self, _ rule: FloatingPointFactorRoundingRule = .up) -> Self {
        (self / roundingFactor).rounded(rule.rounding) * roundingFactor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
        - roundingFactor: The rounding factor.
        - rule: The rounding rule to apply. The default value is `up`.
     */
    mutating func round(toNearest roundingFactor: Self, _ rule: FloatingPointFactorRoundingRule = .up) {
        self = (self / roundingFactor).rounded(rule.rounding) * roundingFactor
    }
}

public extension CGFloat {
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     - Returns: The rounded value.
     */
    func rounded(_ rule: FloatingPointPlacesRoundingRule) -> Self {
        let divisor = Self(rule.divisor)
        return (self * divisor).rounded(rule.rounding) / divisor
    }

    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     */
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        let divisor = Self(rule.divisor)
        self = (self * divisor).rounded(rule.rounding) / divisor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
        - roundingFactor: The rounding factor.
        - rule: The rounding rule to apply. The default value is `up`.
     
     - Returns: The rounded value.
     */
    func rounded(toNearest roundingFactor: Self, _ rule: FloatingPointFactorRoundingRule = .up) -> Self {
        (self / roundingFactor).rounded(rule.rounding) * roundingFactor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
        - roundingFactor: The rounding factor.
        - rule: The rounding rule to apply. The default value is `up`.
     */
    mutating func round(toNearest roundingFactor: Self, _ rule: FloatingPointFactorRoundingRule = .up) {
        self = (self / roundingFactor).rounded(rule.rounding) * roundingFactor
    }
}

/// A rule for rounding a floating-point number to decimal places.
public enum FloatingPointPlacesRoundingRule {
    /**
     Round to the specified number of decimal places.

     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.66675).rounded(.toPlaces(2))
     // 0.67
     
     (0.66675).rounded(.toPlaces(4))
     // 0.6668
     ```
     */
    case toPlaces(Int)
    /**
     Round to the specified number of decimal places towards zero.

     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.66675).rounded(.toPlacesTowardZero(2))
     // 0.66
     
     (0.66675).rounded(.toPlacesTowardZero(4))
     // 0.6667
     ```
     */
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

/// A rule for rounding a floating-point number by a rounding factor.
public enum FloatingPointFactorRoundingRule {
    /**
     Round to the closest allowed value that is greater than or equal to the source.
     
     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.75).rounded(toNearest: 0.5, .up)
     // 1.0
     
     (0.5).rounded(toNearest: 0.2, .down)
     // 0.6
     ```
     */
    case up
    /**
     Round to the closest allowed value that is less than or equal to the source.
     
     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.75).rounded(toNearest: 0.5, .down)
     // 0.5
     
     (0.5).rounded(toNearest: 0.2, .down)
     // 0.4
     ```
     */
    case down
    
    var rounding: FloatingPointRoundingRule {
        switch self {
        case .up: return .toNearestOrAwayFromZero
        case .down: return .towardZero
        }
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
