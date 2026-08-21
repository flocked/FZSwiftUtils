//
//  Number+String.swift
//
//
//  Created by Florian Zand on 31.07.23.
//

import Foundation

public extension BinaryInteger {
    /// The value as `String`.
    var string: String {
        String(self)
    }
    
    /**
     Returns a string representing of the value in the specified base.
     
     - Parameters:
        - radix: The base to use for the string representation. radix must be at least 2 and at most 36.
        - uppercase: Pass `true` to use uppercase letters to represent numerals greater than 9, or `false` to use lowercase letters.
     
     The following example converts the maximal Int value to a string and prints its length:
     
     ```swift
     let max = String(Int.max)
     print("\(max) has \(max.count) digits.")
     // Prints "9223372036854775807 has 19 digits."
     ```
     
     Numerals greater than 9 are represented as Roman letters. These letters start with `"A"` if `uppercase` is `true`; otherwise, with `"a"`.
     
     ```swift
     let v = 999_999
     print(String(v, radix: 2))
     // Prints "11110100001000111111"

     print(String(v, radix: 16))
     // Prints "f423f"
     print(String(v, radix: 16, uppercase: true))
     // Prints "F423F"
     ```
     */
    func string(radix: Int = 10, uppercase: Bool = false) -> String {
        String(self, radix: radix, uppercase: uppercase)
    }
    
    /**
     Returns a localized string representation of the value.

     - Parameters:
        - locale: The locale to use when formatting the value.
        - usesGroupingSeparator: A Boolean value indicating whether the formatter uses grouping separators.
        - minimumIntegerDigits: The minimum number of digits to display before the decimal separator.
     */
    func localizedString(locale: Locale = .current, usesGroupingSeparator: Bool = true, minimumIntegerDigits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.locale = locale
        formatter.minimumIntegerDigits = minimumIntegerDigits
        formatter.usesGroupingSeparator = usesGroupingSeparator
        return formatter.string(for: self) ?? String(self)
    }
}


public extension BinaryFloatingPoint {
    /// The value as `String`.
    var string: String {
        localizedString()
    }
    
    /**
     Returns a localized string representation of the value with the specified locale.
     
     - Parameter locale: The locale of the string.
     - Returns: A localized string representation of the value.
     */
    func localizedString(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        
        return NumberFormatter.decimal.locale(locale).string(for: self) ?? String(Double(self))
    }
}

public extension NSNumber {
    /// The value as Integer string.
    var intString: String {
        Int(truncating: self).localizedString()
    }

    /// The value as Float string.
    var string: String {
        Float(truncating: self).localizedString()
    }
}

/// A number type that can be used converted to and get from `NSNumber`.
public protocol NSNumberConvertable: Comparable {
    static var zero: Self { get }
}

extension Int: NSNumberConvertable { }
extension Int8: NSNumberConvertable { }
extension Int16: NSNumberConvertable { }
extension Int32: NSNumberConvertable { }
extension Int64: NSNumberConvertable { }
extension UInt: NSNumberConvertable { }
extension UInt8: NSNumberConvertable { }
extension UInt16: NSNumberConvertable { }
extension UInt32: NSNumberConvertable { }
extension UInt64: NSNumberConvertable { }
extension Double: NSNumberConvertable { }
extension Float: NSNumberConvertable { }
extension CGFloat: NSNumberConvertable { }
