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
        rounded(toMultiple: 1.0 / Self(window.screen?.backingScaleFactor ?? window.backingScaleFactor))
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

public extension BinaryFloatingPoint {
    /**
     Returns a value clamped to a maximum proportional change from a previous value.

     - Parameters:
       - previousValue: The previous displayed or accepted value.
       - maxChangeRatio: The maximum proportional change allowed.
     - Returns: A value constrained to the allowed range.
     */
    func clampedJitter(relativeTo previousValue: Self?, maxChangeRatio: Self) -> Self {
        guard let previousValue else { return self }
        guard previousValue.isFinite, isFinite, maxChangeRatio >= 0 else {
            return self
        }
        let lowerBound = previousValue * (1 - maxChangeRatio)
        let upperBound = previousValue * (1 + maxChangeRatio)
        return min(max(self, lowerBound), upperBound)
    }

    /**
     Returns an exponentially smoothed value relative to a previous value.

     - Parameters:
       - previousValue: The previous displayed or accepted value.
       - alpha: The smoothing factor. Lower values produce smoother output [`0...1`].
     - Returns: An exponentially smoothed value.
     */
    func exponentiallySmoothed(relativeTo previousValue: Self?, alpha: Self) -> Self {
        guard let previousValue else { return self }
        guard previousValue.isFinite, isFinite, alpha >= 0, alpha <= 1 else {
            return self
        }
        return alpha * self + (1 - alpha) * previousValue
    }

    /**
     Returns a value using exponential smoothing followed by jitter clamping.

     Exponential smoothing is applied first, then the result is constrained to a maximum proportional change from the previous value.

     - Parameters:
        - previousValue: The previous displayed or accepted value.
        - alpha: The smoothing factor. Lower values produce smoother output [`0...1`].
        - maxChangeRatio: The maximum proportional change allowed.
     - Returns: A smoothed and clamped value.
     */
    func hybridSmoothed(relativeTo previousValue: Self?, alpha: Self, maxChangeRatio: Self) -> Self {
        self
            .exponentiallySmoothed(relativeTo: previousValue, alpha: alpha)
            .clampedJitter(relativeTo: previousValue, maxChangeRatio: maxChangeRatio)
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

public extension FloatingPoint {
    /**
     Returns the non-negative remainder of this value divided by the given value using truncating division.

     - Parameter other: The value to use when dividing this value.
     - Returns: The non-negative remainder of this value divided by `other` using truncating division.
     
     Example usage:

     ```swift
     5.0.positiveRemainder(dividingBy: 3.0) // 2.0
     5.0.positiveRemainder(dividingBy: -3.0) // 2.0
     -5.0.positiveRemainder(dividingBy: 3.0) // 1.0
     -5.0.positiveRemainder(dividingBy: -3.0) // 1.0
     ```
     */
    func positiveRemainder(dividingBy divisor: Self) -> Self {
        let divisor = abs(divisor)
        let remainder = truncatingRemainder(dividingBy: divisor)
        return remainder >= 0 ? remainder : remainder + divisor
    }
    
    /**
     Returns the remainder of this value divided by the given value using flooring division.
     
     - Parameter other: The value to use when dividing this value.
     - Returns: The remainder of this value divided by `other` using flooring division. The result takes the sign of the `other`.
     
     Example usage:
     
     ```swift
     5.0.flooredRemainder(dividingBy: 3.0)   // 2.0
     5.0.flooredRemainder(dividingBy: -3.0)  // -1.0
     -5.0.flooredRemainder(dividingBy: 3.0)  // 1.0
     -5.0.flooredRemainder(dividingBy: -3.0) // -2.0
     ```
     */
    func flooredRemainder(dividingBy divisor: Self) -> Self {
        guard divisor != 0 else { return 0 }
        let remainder = truncatingRemainder(dividingBy: divisor)
        if remainder == 0 {
            return 0
        }
        if (remainder < 0) != (divisor < 0) {
            return remainder + divisor
        }
        return remainder
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
    func scaledIntegral(for screen: UIScreen) -> [Element] {
        map({ $0.scaledIntegral(for: screen) })
    }
    #endif
}

public extension Collection where Element: BinaryFloatingPoint {
    /**
     Returns a new array with values considered statistical outliers removed.

     Values are compared against the median of the collection using relative ratios.
     A value is retained only if its ratio to the median falls within the specified bounds.

     The ratio is calculated as `value / median`.

     Values are kept when `lowerRatio <= ratio <= upperRatio`.

     If the collection contains fewer than `minimumSampleCount` elements, or if the median is less than or equal to zero, the original values are returned unchanged.

     - Parameters:
       - lowerRatio: The minimum allowed ratio relative to the median.
       - upperRatio: The maximum allowed ratio relative to the median.
       - minimumSampleCount: The minimum number of elements required before filtering is applied.
     - Returns: An array containing only values within the allowed ratio range relative to the median.
     */
    func removingOutliers(lowerRatio: Element = 0.25, upperRatio: Element = 4.0, minimumSampleCount: Int = 4) -> [Element] {
        guard count >= minimumSampleCount else { return Array(self) }

        let sorted = sorted()
        let median = sorted[sorted.count / 2]

        guard median > 0 else { return Array(self) }

        return filter { value in
            let ratio = value / median
            return ratio >= lowerRatio && ratio <= upperRatio
        }
    }

    /**
     Returns a score between `0` and `1` representing how consistent the values are.

     Lower variance produces scores closer to `1`, while highly variable values produce scores closer to `0`.

     The score is derived from the coefficient of variation, calculated as `standardDeviation / mean`.

     The final score is calculated as `1 - (coefficientOfVariation * sensitivity)` and clamped to `0 ... 1`.

     - Parameters:
       - defaultScore: The score returned when there are fewer than two samples.
       - sensitivity: A multiplier controlling how aggressively variance reduces the score.
     - Returns: A value clamped to the range `0 ... 1`.
     */
    func stabilityScore(defaultScore: Element = 0.2, sensitivity: Element = 1) -> Element {
        guard count >= 2 else {
            return Swift.max(.zero, Swift.min(1, defaultScore))
        }

        let sampleCount = Element(count)

        let mean = reduce(.zero, +) / sampleCount

        guard mean > .zero else {
            return .zero
        }

        let variance = reduce(.zero) { partialResult, value in
            let difference = value - mean
            return partialResult + difference * difference
        } / sampleCount

        let standardDeviation = variance.squareRoot()
        let coefficientOfVariation = standardDeviation / mean
        let score = 1 - (coefficientOfVariation * sensitivity)
        return Swift.max(.zero, Swift.min(1, score))
    }
}

#if os(macOS)
extension NSView {
    var backingScaleFactor: CGFloat {
        window?.screen?.backingScaleFactor ?? window?.backingScaleFactor ?? NSApp.backingScaleFactor
    }
}

extension NSApplication {
    var backingScaleFactor: CGFloat {
        (keyWindow ?? mainWindow ?? windows.first(where: { $0.isVisible }))?.backingScaleFactor ?? (NSScreen.main ?? .screens.first)?.backingScaleFactor ?? 1.0
    }
}
#endif
