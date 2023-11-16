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

public extension Float {
    /**
     Returns the scaled integral value of the `Float`.
     
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
        return floor(self * scale) / scale
    }
}

public extension Double {
    /**
     Returns the scaled integral value of the `Double`.
     
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
        return floor(self * scale) / scale
    }
}

public extension BinaryFloatingPoint {
    /// Converts the value from degrees to radians.
    var degreesToRadians: Self {
        return Self.pi * self / 180.0
    }
    
    /// Converts the value from radians to degress.
    var radiansToDegrees: Self {
        return self * 180 / Self.pi
    }
}

public extension CGFloat {
    /// Converts the value from degrees to radians.
    var degreesToRadians: CGFloat {
        return Self.pi * self / 180.0
    }
    
    /// Converts the value from radians to degress.
    var radiansToDegrees: CGFloat {
        return self * 180 / Self.pi
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

public extension CGFloat {
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
        return Swift.max(-decimal.exponent, 0)
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

public extension BinaryInteger {
    /**
     Returns the advanced value for the specified option and range.
     - Parameters:
        - type: The advance type.
        - range: The range of values.
     
     - The advanced value.
     */
    func advanced(by type: AdvanceOption, in range: ClosedRange<Self>) -> Self {
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
                index = Self(Int.random(in: Int(range.lowerBound)...Int(range.upperBound)))
            case .first:
                index = range.lowerBound
            case .last:
                index = range.upperBound
            }
            return index
        }
}
