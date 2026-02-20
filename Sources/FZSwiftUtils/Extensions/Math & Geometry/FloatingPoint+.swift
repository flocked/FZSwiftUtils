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
     
     The value is scaled based on the screen's backing scale factor.
     
     - Parameter screen: The screen for the scale factor.
     */
    func scaledIntegral(for screen: NSScreen) -> Self {
        rounded(toMultiple: 1.0 / Self(screen.backingScaleFactor))
    }
    
    /**
     Returns the scaled integral value of the value for the specified view.
     
     The value is scaled based on the view's window backing scale factor.
     
     - Parameter view: The view for the scale factor.
     */
    func scaledIntegral(for view: NSView) -> Self {
        rounded(toMultiple: 1.0 / Self(view.backingScaleFactor))
    }
    
    /**
     Returns the scaled integral value of the value for the specified window.
     
     The value is scaled based on the window's backing scale factor.
     
     - Parameter window: The window for the scale factor.
     */
    func scaledIntegral(for window: NSWindow) -> Self {
        rounded(toMultiple: 1.0 / Self(window.backingScaleFactor))
    }
    
    /**
     Returns the scaled integral value of the value for the specified application.
     
     The value is scaled based on either the key, main or first visible window, or else the main screen and it's backing scale factor.
     
     - Parameter application: The application for the scale factor.
     */
    func scaledIntegral(for application: NSApplication) -> Self {
        rounded(toMultiple: 1.0 / Self(application.backingScaleFactor))
    }
    #elseif os(iOS) || os(tvOS)
    /**
     Returns the scaled integral value of the value for the specified screen.
     
     The value is scaled based on the screen's backing scale factor.
     
     - Parameter screen: The screen for the scale factor.
     */
    func scaledIntegral(for screen: UIScreen) -> Self {
        rounded(toMultiple: 1.0 / Self(screen.scale))
    }
    #endif

    /**
     Returns the fractional remainder of the value after dividing by the given divisor.
     
     If the value is negative, the result is `0.0`.

     For example:
     ```swift
     210.0.fractionalRemainder(dividingBy: 100.0) // returns 0.1
     95.0.fractionalRemainder(dividingBy: 100.0)  // returns 0.95
     ```

     - Parameter other: The value to use when dividing this value.
     - Returns: A normalized fractional remainder between `0.0` and `1.0`.
     */
    func fractionalRemainder(dividingBy other: Self) -> Self {
        max(truncatingRemainder(dividingBy: other), 0) / other
    }
    
    /**
     The number of decimal digits in the integer part of the number.
     
     This counts the digits before the decimal point. For example:
     
     ```swift
     let x = 123.456
     print(x.integerDigits) // 3
     ```
     */
    var integerDigits: Int {
        String(Int(abs(self))).count
    }
    
    /**
     The number of decimal digits in the fractional part of the number.
     
     This counts the digits after the decimal point, up to a maximum of `20` digits to prevent infinite loops with repeating fractions. For example:
     
     ```swift
     let x = 123.456
     print(x.fractionalDigits) // 3
     ```
     */
    var fractionalDigits: Int {
        let decimalValue = Decimal(Double(self))
        let integerPart = Decimal(NSDecimalNumber(decimal: decimalValue).intValue)
        var fraction = abs(decimalValue - integerPart)
        var count = 0
        while fraction != 0 {
            fraction *= 10
            fraction -= Decimal(NSDecimalNumber(decimal: fraction).intValue)
            count += 1
            if count > 20 { break }
        }
        return count
    }
}

public extension BinaryFloatingPoint where RawSignificand : FixedWidthInteger {
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
    static func random(max: Self) -> Self {
        random(in: 0...max)
    }
    
    /**
     Generates an array of random, progressively increasing values within a given range.

     Each value is based on an evenly spaced step within the range, with an optional `variation` that allows each value to randomly deviate around its base position.

     - Parameters:
        - range: The range in which to create a random value. range must be finite and non-empty.
        - amount: The number of values to generate.
        - variation: Controls how much each value can vary from its evenly spaced position. Valid range is `0.0` to `1.0`.
       
     - Returns: An array of increasing random values within the range.
     */
    static func random(in range: ClosedRange<Self>, amount: Int, variation: Self = 0.4) -> [Self] {
        guard amount > 1 else { return [] }
        let step = (range.upperBound - range.lowerBound) / Self(amount - 1)
        let variation = max(0.0, min(variation, 1.0))
        return (0..<amount).map { i in
            let base = range.lowerBound + Self(i) * step
            let jitter = random(in: -(step * variation)...(step * variation))
            return min(max(base + jitter, range.lowerBound), range.upperBound)
        }.sorted()
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

public extension Sequence where Element: BinaryFloatingPoint {
    /**
     Returns the scaled integral value of the elements in the sequence.
     
     The elements are scaled based on the current device’s screen scale.
     */
    var scaledIntegral: [Element] {
        map({ $0.scaledIntegral })
    }
    
    #if os(macOS)
    /**
     Returns the scaled integral value of the elements in the sequence for the specified screen.
     
     The elements are scaled based on the screen's backing scale factor.
     
     - Parameter screen: The screen for the scale factor.
     */
    func scaledIntegral(for screen: NSScreen) -> [Element] {
        map({ $0.scaledIntegral(for: screen) })
    }
    
    /**
     Returns the scaled integral value of the elements in the sequence for the specified window.
     
     The elements are scaled based on the window's backing scale factor.
     
     - Parameter window: The window for the scale factor.
     */
    func scaledIntegral(for window: NSWindow) -> [Element] {
        map({ $0.scaledIntegral(for: window) })
    }
    
    /**
     Returns the scaled integral value of the elements in the sequence for the specified view.
     
     The elements are scaled based on the view’s window backing scale factor.
     
     - Parameter view: The view for the scale factor.
     */
    func scaledIntegral(for view: NSView) -> [Element] {
        map({ $0.scaledIntegral(for: view) })
    }
    
    /**
     Returns the scaled integral value of the elements in the sequence for the specified application.
     
     The elements are scaled based on either the key, main or first visible window, or else the main screen and it’s backing scale factor.
     
     - Parameter application: The application for the scale factor.
     */
    func scaledIntegral(for application: NSApplication) -> [Element] {
        map({ $0.scaledIntegral(for: application) })
    }
    #elseif os(iOS) || os(tvOS)
    /**
     Returns the scaled integral value of the elements in the sequence for the specified screen.
     
     The elements are scaled based on the screen's backing scale factor.
     
     - Parameter screen: The screen for the scale factor.
     */
    func scaledIntegral(for screen: UIScreen) -> Self {
        map({ $0.scaledIntegral(for: screen) })
    }
    #endif
}

#if os(macOS)
fileprivate extension NSView {
    var backingScaleFactor: CGFloat {
        window?.backingScaleFactor ?? NSApp.backingScaleFactor
    }
}

fileprivate extension NSApplication {
    var backingScaleFactor: CGFloat {
        (keyWindow ?? mainWindow ?? windows.first(where: { $0.isVisible }))?.backingScaleFactor ?? (NSScreen.main ?? .screens.first)?.backingScaleFactor ?? 1.0
    }
}
#endif
