//
//  NumberFormatter+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import CoreGraphics
import Foundation

public extension NumberFormatter {
    
    /// The lowest number allowed as input by a text field with the formatter.
    var minimumValue: Double? {
        get { minimum?.doubleValue }
        set {
            if let newValue = newValue {
                minimum = NSNumber(newValue)
            } else {
                minimum = nil
            }
        }
    }
    
    /// The highest number allowed as input by a text field with the formatter.
    var maximumValue: Double? {
        get { maximum?.doubleValue }
        set {
            if let newValue = newValue {
                maximum = NSNumber(newValue)
            } else {
                maximum = nil
            }
        }
    }
    
    /**
     Creates an integer number formatter.

     - Parameters:
        - minValue: The lowest number allowed as input by a text field with the formatter.
        - maxValue: The highest number allowed as input by a text field with the formatter.
        - roundingMode: The rounding mode.
        - locale: The locale of the formatter.

     - Returns: A `NumberFormatter` instance configured for integer formatting.
     */
    static func integer(minValue: Int? = nil, maxValue: Int? = nil, roundingMode: RoundingMode = .halfEven, usesGroupingSeparator: Bool = false, locale: Locale = .current) -> NumberFormatter {
        NumberFormatter(style: .none, minValue: minValue != nil ? Double(minValue!) : nil, maxValue: maxValue != nil ? Double(maxValue!) : nil, roundingMode: roundingMode, usesGroupingSeparator: usesGroupingSeparator, locale: locale)
    }
    
    /**
     Creates a decimal number formatter.

     - Parameters:
        - minValue: The lowest number allowed as input by a text field with the formatter.
        - maxValue: The highest number allowed as input by a text field with the formatter.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.
        - roundingMode: The rounding mode.
        - usesGroupingSeparator: A Boolean value indicating whether to display a group separator.
        - locale: The locale of the formatter.

     - Returns: A `NumberFormatter` instance configured for decimal formatting.
     */
    static func decimal(minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil, roundingMode: RoundingMode = .halfEven, usesGroupingSeparator: Bool = false, locale: Locale = .current) -> NumberFormatter {
        NumberFormatter(style: .decimal, minValue: minValue, maxValue: maxValue, minFraction: minFraction, maxFraction: maxFraction, roundingMode: roundingMode, usesGroupingSeparator: usesGroupingSeparator, locale: locale)
    }
    
    /**
     Creates a percent number formatter.

     - Parameters:
        - minValue: The lowest number allowed as input by a text field with the formatter.
        - maxValue: The highest number allowed as input by a text field with the formatter.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.
        - roundingMode: The rounding mode.
        - usesGroupingSeparator: A Boolean value indicating whether to display a group separator.
        - locale: The locale of the formatter.

     - Returns: A `NumberFormatter` instance configured for percent formatting.
     */
    static func percent(minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil, roundingMode: RoundingMode = .halfEven, usesGroupingSeparator: Bool = false, locale: Locale = .current) -> NumberFormatter {
        NumberFormatter(style: .percent, minValue: minValue, maxValue: maxValue, minFraction: minFraction, maxFraction: maxFraction, roundingMode: roundingMode, usesGroupingSeparator: usesGroupingSeparator, locale: locale)
    }
    
    /**
     Creates a currency number formatter.

     - Parameters:
        - minValue: The lowest number allowed as input by a text field with the formatter.
        - maxValue: The highest number allowed as input by a text field with the formatter.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.
        - roundingMode: The rounding mode.
        - usesGroupingSeparator: A Boolean value indicating whether to display a group separator.
        - locale: The locale of the formatter.

     - Returns: A `NumberFormatter` instance configured for currency formatting.
     */
    static func currency(minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil, roundingMode: RoundingMode = .halfEven, usesGroupingSeparator: Bool = false, locale: Locale = .current) -> NumberFormatter {
        NumberFormatter(style: .currency, minValue: minValue, maxValue: maxValue, minFraction: minFraction, maxFraction: maxFraction, roundingMode: roundingMode, usesGroupingSeparator: usesGroupingSeparator, locale: locale)
    }
    
    /**
     Creates a currency number formatter with the specified style.

     - Parameters:
        - style: The formatting style.
        - minValue: The lowest number allowed as input by a text field with the formatter.
        - maxValue: The highest number allowed as input by a text field with the formatter.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.
        - roundingMode: The rounding mode.
        - usesGroupingSeparator: A Boolean value indicating whether to display a group separator.
        - locale: The locale of the formatter.

     - Returns: A `NumberFormatter` instance configured for currency formatting.
     */
    convenience init(style: Style, minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil, roundingMode: RoundingMode = .halfEven, usesGroupingSeparator: Bool = false, locale: Locale = .current) {
        self.init()
        self.locale = locale
        self.roundingMode = roundingMode
        self.usesGroupingSeparator = usesGroupingSeparator
        numberStyle = style
        minimumValue = minValue
        maximumValue = maxValue
        minimumFractionDigits = minFraction ?? 0
        maximumFractionDigits = maxFraction ?? 200000
        allowsFloats = true
        isLenient = true
        usesSignificantDigits = style != .none
    }

    /**
     Returns a string representation of the specified value value.

     - Parameter value: The value for the string representation.
     - Returns: The string representation of the specified value, or `nil` if the string doesn't contain a value.
     */
    func string(from value: Bool) -> String? { string(from: NSNumber(value: value)) }

    /**
     Returns a string representation of the specified value value.

     - Parameter value: The value for the string representation.
     - Returns: The string representation of the specified value, or `nil` if the string doesn't contain a value.
     */
    func string<Value>(from value: Value) -> String? where Value: BinaryInteger { string(from: NSNumber(value)) }

    /**
     Returns a string representation of the specified value value.

     - Parameter value: The value for the string representation.
     - Returns: The string representation of the specified value, or `nil` if the string doesn't contain a value.
     */
    func string<Value>(from value: Value) -> String? where Value: BinaryFloatingPoint { string(from: NSNumber(value)) }
}
