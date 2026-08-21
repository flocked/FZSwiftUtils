//
//  DateComponentsFormatter+.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension DateComponentsFormatter {
    /// The calendrical components that the formatter is allowed to include in the output string.
    var allowedComponents: Components {
        get { .init(rawValue: allowedUnits.rawValue) }
        set { allowedUnits = .init(rawValue: newValue.rawValue) }
    }
    
    /// The calendrical components that can be used when formatting a duration.
    struct Components: OptionSet, Hashable, Codable {
        /// A value that indicates the formatter should automatically select the appropriate components.
        public static let `default`: Self = []
        /// The year component.
        public static let year = Self(rawValue: 4)
        /// The month component.
        public static let month = Self(rawValue: 8)
        /// The week-of-month component.
        public static let weekOfMonth = Self(rawValue: 4096)
        /// The day component.
        public static let day = Self(rawValue: 16)
        /// The hour component.
        public static let hour = Self(rawValue: 32)
        /// The minute component.
        public static let minute = Self(rawValue: 64)
        /// The second component.
        public static let second = Self(rawValue: 128)
        /// A value that allows the use of all supported calendar components.
        public static let all: Self = [.year, .month, .day, .hour, .minute, .second, .weekOfMonth]
  
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    /**
     The locale of the formatter.
     
     The property returns the locale of `calendar`.
     */
    var locale: Locale? {
        get { calendar?.locale }
        set {
            guard newValue != locale else { return }
            
            if var calendar = calendar {
                calendar.locale = newValue
                self.calendar = calendar
            } else if let newValue {
                var calendar = newValue.calendar
                calendar.locale = newValue
                self.calendar = calendar
            }
        }
    }
    
    /// Returns a formatted string for the specified time duration.
    func string(for timeDuration: TimeDuration) -> String? {
        string(from: timeDuration.seconds)
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
