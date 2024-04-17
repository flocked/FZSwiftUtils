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
        localizedString()
    }
    
    /**
     Returns a localized string representation of the integer with the specified locale.

     - Parameter locale: The locale of the string
     - Returns: A localized string representation of the integer value.
     */
    func localizedString(locale: Locale = .current) -> String {
        NumberFormatter.integer.locale(locale).string(for: self) ?? String(self)
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
        NumberFormatter.decimal.locale(locale).string(for: self) ?? String(Double(self))
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
