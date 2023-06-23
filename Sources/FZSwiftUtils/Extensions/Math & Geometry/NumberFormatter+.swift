//
//  NumberFormatter+.swift
//  FZCollection
//
//  Created by Florian Zand on 06.06.22.
//

import CoreGraphics
import Foundation

public extension NumberFormatter {
    /**
     Creates a `NumberFormatter` instance configured for decimal formatting.
     
     - Parameters:
        - min: The minimum number of fraction digits to display. The default value is `0`.
        - max: The maximum number of fraction digits to display. The default value is `0`.
     
     - Returns: A `NumberFormatter` instance configured for decimal formatting.
     */
    static func decimal(min: Int = 0, max: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter(minFractionDigits: min, maxFractionDigits: max)
        formatter.numberStyle = .decimal
        return formatter
    }

    /**
     Creates a `NumberFormatter` instance configured for percent formatting.
     
     - Parameters:
        - min: The minimum number of fraction digits to display. The default value is `0`.
        - max: The maximum number of fraction digits to display. The default value is `0`.
     
     - Returns: A `NumberFormatter` instance configured for percent formatting.
     */
    static func percent(min: Int = 0, max: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter(minFractionDigits: min, maxFractionDigits: max)
        formatter.numberStyle = .percent
        return formatter
    }

    /**
     Creates a `NumberFormatter` instance with the specified minimum fraction digits.
     
     - Parameter minFractionDigits: The minimum number of fraction digits to display.
     */
    convenience init(minFractionDigits: Int) {
        self.init()
        minimumFractionDigits = minFractionDigits
    }

    /**
     Creates a `NumberFormatter` instance with the specified maximum fraction digits.
     
     - Parameter maxFractionDigits: The maximum number of fraction digits to display.
     */
    convenience init(maxFractionDigits: Int) {
        self.init()
        maximumFractionDigits = maxFractionDigits
    }

    /**
     Creates a `NumberFormatter` instance with the specified minimum and maximum fraction digits.
     
     - Parameters:
        - minFractionDigits: The minimum number of fraction digits to display.
        - maxFractionDigits: The maximum number of fraction digits to display.
     */
    convenience init(minFractionDigits: Int, maxFractionDigits: Int) {
        self.init()
        minimumFractionDigits = minFractionDigits
        maximumFractionDigits = maxFractionDigits
    }
    
    static func forInteger(with format: String = "#,###", numberOfDigits: Int = 0, locale: Locale? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale ?? Locale.current
        formatter.positiveFormat = format
        formatter.negativeFormat = "-\(format)"
        formatter.minimumIntegerDigits = numberOfDigits
        formatter.usesGroupingSeparator = false
        return formatter
    }

    static func forFloatingPoint(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale ?? Locale.current
        formatter.maximumFractionDigits = numberOfDigits
        formatter.positiveFormat = format
        formatter.negativeFormat = "-\(format)"

        return formatter
    }

    /// Returns a string representation of the specified value value.
    func string(from value: Double) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: Float) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: CChar) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: Bool) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: Int) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: Int16) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: Int32) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: Int64) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: UInt) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: UInt16) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: UInt32) -> String? { string(from: NSNumber(value: value)) }
    /// Returns a string representation of the specified value value.
    func string(from value: UInt64) -> String? { string(from: NSNumber(value: value)) }
}

public extension Int {
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
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

public extension Double {
    /**
     Returns a localized string representation of the double value using the specified format, number of digits, and locale.
     
     - Parameters:
        - format: The format string used to format the number. The default value is `"#.#"`.
        - numberOfDigits: The number of digits to display. The default value is `1`.
        - locale: The locale to use for formatting the number. The default value is `nil`, which uses the current locale.
     
     - Returns: A localized string representation of the double value.
     */
    func localizedString(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> String {
        let formatter = NumberFormatter.forFloatingPoint(with: format, numberOfDigits: numberOfDigits, locale: locale)
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

public extension Float {
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
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
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
        return Double(self).localizedString(with: format, numberOfDigits: numberOfDigits, locale: locale)
    }
}
