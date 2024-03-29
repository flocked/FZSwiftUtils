//
//  NumberFormatter+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import CoreGraphics
import Foundation

public extension NumberFormatter {
    
    /// The lowest number allowed as input by the receiver.
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
    
    /// The highest number allowed as input by the receiver.
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
        - minValue: The minimum number.
        - maxValue: The maximum number.

     - Returns: A `NumberFormatter` instance configured for integer formatting.
     */
    static func integer(minValue: Int? = nil, maxValue: Int? = nil) -> NumberFormatter {
        NumberFormatter(style: .none, minValue: minValue != nil ? Double(minValue!) : nil, maxValue: maxValue != nil ? Double(maxValue!) : nil)
    }
    
    /**
     Creates a decimal number formatter.

     - Parameters:
        - minValue: The minimum number.
        - maxValue: The maximum number.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.

     - Returns: A `NumberFormatter` instance configured for decimal formatting.
     */
    static func decimal(minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil) -> NumberFormatter {
        NumberFormatter(style: .decimal, minValue: minValue, maxValue: maxValue, minFraction: minFraction, maxFraction: maxFraction)
    }
    
    /**
     Creates a percent number formatter.

     - Parameters:
        - minValue: The minimum number.
        - maxValue: The maximum number.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.

     - Returns: A `NumberFormatter` instance configured for percent formatting.
     */
    static func percent(minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil) -> NumberFormatter {
        NumberFormatter(style: .percent, minValue: minValue, maxValue: maxValue, minFraction: minFraction, maxFraction: maxFraction)
    }
    
    /**
     Creates a currency number formatter.

     - Parameters:
        - minValue: The minimum number.
        - maxValue: The maximum number.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.

     - Returns: A `NumberFormatter` instance configured for currency formatting.
     */
    static func currency(minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil) -> NumberFormatter {
        NumberFormatter(style: .currency, minValue: minValue, maxValue: maxValue, minFraction: minFraction, maxFraction: maxFraction)
    }
    
    /**
     Creates a currency number formatter with the specified style.

     - Parameters:
        - minValue: The formatting style.
        - minValue: The minimum number.
        - maxValue: The maximum number.
        - minFraction: The minimum number of digits after the decimal separator.
        - maxFraction: The maximum number of digits after the decimal separator.

     - Returns: A `NumberFormatter` instance configured for currency formatting.
     */
    convenience init(style: Style, minValue: Double? = nil, maxValue: Double? = nil, minFraction: Int? = nil, maxFraction: Int? = nil) {
        self.init()
        self.numberStyle = style
        minimumValue = minValue
        maximumValue = maxValue
        minimumFractionDigits = minFraction ?? 0
        maximumFractionDigits = maxFraction ?? 200000
        allowsFloats = true
        isLenient = true
    }

    /**
     Creates a number formatter for an integer value with the specified format, number of digits and locale.

     - Parameters:
        - format: The format string used to format the number. The default value is `"#,###"`.
        - numberOfDigits: The number of digits to display. The default value is `0`.
        - locale: The locale to use for formatting the number. The default value is `nil`, which uses the current locale.
     */
    static func forInteger(with format: String = "#,###", numberOfDigits: Int = 0, locale: Locale? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale ?? Locale.current
        formatter.positiveFormat = format
        formatter.negativeFormat = "-\(format)"
        formatter.minimumIntegerDigits = numberOfDigits
        formatter.usesGroupingSeparator = false
        return formatter
    }

    /**
     Creates a number formatter for a floating point value with the specified format, number of digits and locale.

     - Parameters:
        - format: The format string used to format the number. The default value is `"#,###"`.
        - numberOfDigits: The number of digits to display. The default value is `1`.
        - locale: The locale to use for formatting the number. The default value is `nil`, which uses the current locale.
     */
    static func forFloatingPoint(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale ?? Locale.current
        formatter.maximumFractionDigits = numberOfDigits
        formatter.positiveFormat = format
        formatter.negativeFormat = "-\(format)"

        return formatter
    }

    /**
     Returns a string representation of the specified value value.

     - Parameter value: The value for the string representation.
     - Returns: The string representation of the specified value, or `nil` if the string doesn't contain a value.
     */
    func string(from value: CChar) -> String? { string(from: NSNumber(value: value)) }

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

public extension BinaryInteger {
    /**
     Returns a localized string representation of the integer value using the specified format, number of digits, and locale.

     - Parameters:
        - format: The format string used to format the number. The default value is `"#,###"`.
        - numberOfDigits: The number of digits to display. The default value is `0`.
        - locale: The locale to use for formatting the number. The default value is `nil`, which uses the current locale.

     - Returns: A localized string representation of the integer value.
     */
    func localizedString(with format: String = "#,###", numberOfDigits: Int = 0, locale: Locale? = nil) -> String {
        let formatter = NumberFormatter.forInteger(with: format, numberOfDigits: numberOfDigits, locale: locale)
        return formatter.string(from: NSNumber(self)) ?? "\(self)"
    }
}

public extension BinaryFloatingPoint {
    /**
     Returns a localized string representation of the float value using the specified format, number of digits, and locale.

     - Parameters:
        - format: The format string used to format the number. The default value is `"#.#"`.
        - numberOfDigits: The number of digits to display. The default value is `1`.
        - locale: The locale to use for formatting the number. The default value is `nil`, which uses the current locale.

     - Returns: A localized string representation of the float value.
     */
    func localizedString(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> String {
        let formatter = NumberFormatter.forFloatingPoint(with: format, numberOfDigits: numberOfDigits, locale: locale)
        return formatter.string(from: NSNumber(self)) ?? "\(self)"
    }
}

public extension CGFloat {
    /**
     Returns a localized string representation of the CGFloat value using the specified format, number of digits, and locale.

     - Parameters:
        - format: The format string used to format the number. The default value is `"#.#"`.
        - numberOfDigits: The number of digits to display. The default value is `1`.
        - locale: The locale to use for formatting the number. The default value is `nil`, which uses the current locale.

     - Returns: A localized string representation of the CGFloat value.
     */
    func localizedString(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> String {
        let formatter = NumberFormatter.forFloatingPoint(with: format, numberOfDigits: numberOfDigits, locale: locale)
        return formatter.string(from: NSNumber(self)) ?? "\(self)"
    }
}
