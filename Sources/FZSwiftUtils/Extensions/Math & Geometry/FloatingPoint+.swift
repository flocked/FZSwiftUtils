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
        Self.pi * self / 180.0
    }
    
    /// Converts the value from radians to degress.
    var radiansToDegrees: Self {
        self * 180 / Self.pi
    }
    
    /// Returns the number of decimal places in the value.
    var placesCount: Int {
        let decimal = Decimal(Double(self))
        return max(-decimal.exponent, 0)
    }
    
    /**
     Returns the scaled integral value of the value.
     
     The value is scaled based on the current device's screen scale.
     */
    var scaledIntegral: Self {
#if os(macOS)
        let scale = Self(NSScreen.main?.backingScaleFactor ?? 1.0)
#elseif os(iOS) || os(tvOS)
        let scale = Self(UIScreen.main.scale)
#else
        let scale: Self = 1.0
#endif
        return rounded(toMultiple: 1.0 / scale)
    }
    
#if os(macOS)
    /**
     Returns the scaled integral value of the value for the specified screen.
     
     The value is scaled based on the screen scale.
     
     - Parameter screen: The screen for the scale factor.
     */
    func scaledIntegral(for screen: NSScreen) -> Self {
        rounded(toMultiple: 1.0 / Self(screen.backingScaleFactor))
    }
#endif
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
        return rounded(toMultiple: 1.0 / scale)
    }
    
#if os(macOS)
    /**
     Returns the scaled integral value of the value for the specified screen.
     
     The value is scaled based on the screen scale.
     
     - Parameter screen: The screen for the scale factor.
     */
    func scaledIntegral(for screen: NSScreen) -> Self {
        rounded(toMultiple: 1.0 / screen.backingScaleFactor)
    }
#endif
    
    /// Converts the value from degrees to radians.
    var degreesToRadians: CGFloat {
        Self.pi * self / 180.0
    }
    
    /// Converts the value from radians to degress.
    var radiansToDegrees: CGFloat {
        self * 180 / Self.pi
    }
    
    /// Returns the number of decimal places in the value.
    var placesCount: Int {
        let decimal = Decimal(Double(self))
        return Swift.max(-decimal.exponent, 0)
    }
    
    /**
     Creates a new instance from the given string.
     
     - Parameter text: An input string to convert to a `CGFloat` instance.
     - Returns: The value of the text, or `nil` if the string doesn't contain a numeric value.
     */
    init?<S>(_ text: S) where S: StringProtocol {
        if let value = Double(text) {
            self = value
        } else {
            return nil
        }
    }
}

extension BinaryInteger {
    /// Returns the number of digits
    public var digitCount: Int {
        numberOfDigits(in: self)
    }
    
    // private recursive method for counting digits
    private func numberOfDigits(in number: Self) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number / 10)
        }
    }
}

extension BinaryFloatingPoint where Self.RawSignificand : FixedWidthInteger {
    /**
     Returns a random value within the a range of `0.0` and the specified value.
     
     Use this method to generate a floating-point value within a specific range. This example creates three new values in the range `0.0 ... 20.0`.
     
     ```swift
     for _ in 1...3 {
     print(Double.random(max: 20.0))
     }
     // Prints "18.1900709259179"
     // Prints "14.2286325689993"
     // Prints "13.1485686260762"
     ```
     
     The `random()` static method chooses a random value from a continuous uniform distribution in range, and then converts that value to the nearest representable value in this type. Depending on the size and span of range, some concrete values may be represented more frequently than others.
     This method is equivalent to calling `random(in:using:)`, passing in the system’s default random generator.
     
     - Parameter max: The maximum value of the range.
     - Returns: A random value within the bounds of range.
     */
    public static func random(max: Self) -> Self {
        Self.random(in: 0...max)
    }
}

extension Int {
    /**
     Returns a random value within a range of `0` and the specified value.
     
     Use this method to generate an integer within a specific range. This example creates three new values in the range `0...100`.
     
     ```swift
     for _ in 1...3 {
     print(Int.random(max: 100))
     }
     // Prints "53"
     // Prints "64"
     // Prints "5"
     ```
     
     This method is equivalent to calling `random(in:using:)`, passing in the system’s default random generator.
     
     - Parameter max: The maximum value of the range.
     - Returns: A random value within the bounds of range.
     */
    public static func random(max: Int) -> Int {
        Int.random(in: 0...max)
    }
}

extension BinaryFloatingPoint where Self: LosslessStringConvertible {
    /**
     String representation of the value.
     
     - Parameters:
        - minPlaces: The minimum amount of digits after the decimal separator.
        - maxPlaces: The maximum amount of digits after the decimal separator.
        - groupingSeparator: A Boolean value indicating whether the string should contain grouping separators.
     */
    public func string(minPlaces: Int = 1, maxPlaces: Int? = nil, groupingSeparator: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minPlaces.clamped(min: 0)
        formatter.maximumFractionDigits = maxPlaces ?? -1
        formatter.usesGroupingSeparator = groupingSeparator
        return formatter.string(for: self) ?? String(self)
    }
    
    /**
     String representation of the value.
     
     - Parameters:
        - places: The amount of digits after the decimal separator.
        - groupingSeparator: A Boolean value indicating whether the string should contain grouping separators.
     */
    public func string(places: Int, groupingSeparator: Bool = false) -> String {
        return string(minPlaces: places, maxPlaces: places, groupingSeparator: groupingSeparator)
    }    
}
