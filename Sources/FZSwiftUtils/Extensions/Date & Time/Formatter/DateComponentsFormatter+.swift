//
//  DateComponentsFormatter+.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension DateComponentsFormatter {
    /// The allowed calendar components for formatting.
    var allowedComponents: [Calendar.Component] {
        get { allowedUnits.components }
        set { allowedUnits = NSCalendar.Unit(newValue.compactMap(\.nsUnit)) }
    }
    
    /**
     The locale of the formatter.
     
     The property returns the locale of `calendar`.
     */
    var locale: Locale {
        get { calendar?.locale ?? .current }
        set {
            guard newValue != locale else { return }
            calendar = calendar ?? .current
            calendar?.locale = newValue
        }
    }
    
    /**
     Returns a localized string based on the specified date components, style option and locale.
     
     Use this convenience method to format a string using the default formatter values, with the exception of the unitsStyle value.
     
     - Parameters:
        - components: The value to format.
        - unitsStyle: The style for the resulting units. Use this parameter to specify whether you want to the resulting string to use an abbreviated or more spelled out format.
        - locale: The locale of the string.
     
     - Returns: A string containing the localized date and time information.
     */
    class func localizedString(from components: DateComponents, unitsStyle: DateComponentsFormatter.UnitsStyle, locale: Locale) -> String? {
        if locale == .current {
            return localizedString(from: components, unitsStyle: unitsStyle)
        }
        let formatter = DateComponentsFormatter()
        formatter.locale = locale
        formatter.unitsStyle = unitsStyle
        return formatter.string(from: components)
    }
}
