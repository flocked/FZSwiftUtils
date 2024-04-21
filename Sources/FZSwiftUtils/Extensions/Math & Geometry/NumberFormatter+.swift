//
//  NumberFormatter+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import CoreGraphics
import Foundation

public extension NumberFormatter {
    
    /// Creates an integer number formatter.
    static var integer: NumberFormatter {
        NumberFormatter(style: .none)
    }
    
    /// Creates a decimal number formatter.
    static var decimal: NumberFormatter {
        NumberFormatter(style: .decimal)
    }
    
    /// Creates a percent number formatter.
    static var percent: NumberFormatter {
        NumberFormatter(style: .percent)
    }
    
    /// Creates a currency number formatter.
    static var currency: NumberFormatter {
        NumberFormatter(style: .currency)
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
    
    /// The multiplier of the formatter.
    var multiplierValue: Double? {
        get { multiplier?.doubleValue }
        set {
            if let newValue = newValue {
                multiplier = NSNumber(newValue)
            } else {
                multiplier = nil
            }
        }
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
        
    /// Sets the number style.
    @discardableResult
    func style(_ style: Style) -> Self {
        numberStyle = style
        return self
    }
    
    /// Sets the locale.
    @discardableResult
    func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// Sets the rounding rule.
    @discardableResult
    func roundingRule(_ rule: RoundingMode) -> Self {
        roundingMode = rule
        return self
    }
    
    #if os(macOS)
    /// Sets the format.
    @discardableResult
    func format(_ format: String) -> Self {
        self.format = format
        return self
    }
    #endif
    
    /// Sets the format to display negative values.
    @discardableResult
    func negativeFormat(_ format: String?) -> Self {
        negativeFormat = format
        return self
    }
    
    /// Sets the format to display positive values.
    @discardableResult
    func positiveFormat(_ format: String?) -> Self {
        positiveFormat = format
        return self
    }
    
    /// Sets the minimum number allowed as input by a text field with the formatter.
    @discardableResult
    func minimum(_ value: Double?) -> Self {
        minimumValue = value
        return self
    }
    
    /// Sets the highest number allowed as input by a text field with the formatter.
    @discardableResult
    func maximum(_ value: Double?) -> Self {
        maximumValue = value
        return self
    }
    
    /// Sets the multiplier of the formatter.
    @discardableResult
    func multiplier(_ value: Double?) -> Self {
        multiplierValue = value
        return self
    }
    
    /// Sets the minimum number of digits after the decimal separator.
    @discardableResult
    func minFraction(_ value: Int) -> Self {
        minimumFractionDigits = value
        return self
    }
    
    /// Sets the maximum number of digits after the decimal separator.
    @discardableResult
    func maxFraction(_ value: Int) -> Self {
        maximumFractionDigits = value
        return self
    }
    
    /// Sets the range of digits after the decimal separator.
    @discardableResult
    func fractions(_ range: ClosedRange<Int>) -> Self {
        self.minFraction(range.lowerBound).maxFraction(range.upperBound)
    }
    
    /// Sets the minimum number of digits before the decimal separator.
    @discardableResult
    func minInteger(_ value: Int) -> Self {
        minimumIntegerDigits = value
        return self
    }
    
    /// Sets the maximum number of digits before the decimal separator.
    @discardableResult
    func maxInteger(_ value: Int) -> Self {
        maximumIntegerDigits = value
        return self
    }
    
    /// Sets the range of digits before the decimal separator.
    @discardableResult
    func integers(_ range: ClosedRange<Int>) -> Self {
         self.minInteger(range.lowerBound).maxInteger(range.upperBound)
    }
    
    @discardableResult
    func allowsFloats(_ allowsFloats: Bool) -> Self {
        self.allowsFloats = allowsFloats
        return self
    }
    
    @discardableResult
    func usesSignificantDigits(_ usesSignificantDigits: Bool) -> Self {
        self.usesSignificantDigits = usesSignificantDigits
        return self
    }
    
    /// Sets the Boolean value indicating whether the formatter will use heuristics to guess at the number which is intended by a string.
    @discardableResult
    func isLenient(_ isLenient: Bool) -> Self {
        self.isLenient = isLenient
        return self
    }
    
    /// Sets the Boolean value indicating whether to display a group separator.
    @discardableResult
    func usesGroupingSeparator(_ usesGroupingSeparator: Bool) -> Self {
        self.usesGroupingSeparator = usesGroupingSeparator
        return self
    }
    
    /// Sets the string used for a grouping separator.
    @discardableResult
    func groupingSeparator(_ seperator: String) -> Self {
        groupingSeparator = seperator
        return self
    }
    
    /// Sets the string used to represent a percent symbol.
    @discardableResult
    func percentSymbol(_ symbol: String) -> Self {
        percentSymbol = symbol
        return self
    }
    
    /// Sets the string used to represent a minus sign.
    @discardableResult
    func minusSign(_ sign: String) -> Self {
        minusSign = sign
        return self
    }
    
    /// Sets the string used to represent a plus sign.
    @discardableResult
    func plusSign(_ sign: String) -> Self {
        plusSign = sign
        return self
    }
    
    /// Sets the string used to represent a zero value.
    @discardableResult
    func zeroSymbol(_ symbol: String?) -> Self {
        zeroSymbol = symbol
        return self
    }
    
    /// Sets the string used to represent a `nil value.
    @discardableResult
    func nilSymbol(_ symbol: String) -> Self {
        nilSymbol = symbol
        return self
    }
    
    /// Sets the string used as a local currency symbol.
    @discardableResult
    func currencySymbol(_ symbol: String) -> Self {
        currencySymbol = symbol
        return self
    }
}
