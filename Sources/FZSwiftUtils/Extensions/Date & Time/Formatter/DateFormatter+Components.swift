//
//  DateFormatter+Components.swift
//
//
//  Copyright © 2021 Yurii Lysytsia. All rights reserved.
//

import Foundation

public extension DateFormatter {
    /**
     Creates a date formatter with the specified components.
     
     Example usage:
     
     ```swift
     // yyyy-MM-dd HH:mm
     DateFormatter("\(.year)-\(.month)-\(.day) \(.hour):\(.minute)")
     ```

     - Parameter format: The date format.
     */
    convenience init(_ format: DateFormat) {
        self.init(format.description)
    }
}

/**
 A date format to be used with `DateFormatter`.
 
 The date format can be expressed as String and with ``DateComponent``.
 
 Example usage:
 
 ```swift
 // yyyy-MM-dd HH:mm
 "\(.year)-\(.month)-\(.day) \(.hour):\(.minute)"
 ```
 */
public struct DateFormat: Equatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
    public let format: String
    
    public init(stringLiteral value: String) {
        format = value
    }
    
    public init(stringInterpolation: StringInterpolation) {
        format = stringInterpolation.parts.joined()
    }
    
    public var description: String {
        format
    }
    
    public static func += (lhs: inout DateFormat, rhs: DateFormat) {
            lhs.format + rhs.format
    }
    
    public static func + (lhs: DateFormat, rhs: DateFormat) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    public struct StringInterpolation: StringInterpolationProtocol {
        var parts: [String] = []

        public init(literalCapacity: Int, interpolationCount: Int) {}

        public mutating func appendLiteral(_ literal: String) {
            parts.append(literal)
        }

        public mutating func appendInterpolation(_ naming: DateComponent) {
            parts.append(naming.format)
        }
    }
}

extension DateFormat {
    /// Date component of a date format.
    public struct DateComponent: CustomStringConvertible {
        /// The format of the component.
        public let format: String
        
        public var description: String { format }
        
        /// Milisecond (e.g. `123`).
        public static var millisecond = Self("SSS")
        /// Second with a zero if there is only 1 digit (e.g. `05`).
        public static var second = Self("ss")
        /// Second (e.g. `33`).
        public static var secondShort = Self("s")

        /// Minute with a zero if there is only 1 digit (e.g. `09`).
        public static var minute = Self("mm")
        /// Minute (e.g. `9`).
        public static var minuteShort = Self("m")

        /// 12-hour with a zero if there is only 1 digit (e.g. `09`).
        public static var hour12 = Self("hh")
        /// 12-hour (e.g. `9`).
        public static var hour12Short = Self("h")
        /// 24-hour with a zero if there is only 1 digit (e.g. `09`).
        public static var hour24 = Self("HH")
        /// 24-hour (e.g. `22`).
        public static var hour24Short = Self("H")
        /// AM / PM for 12-hour time formats (e.g. `PM`)
        public static var amPM = Self("a")

        /// Day with a zero if there is only 1 digit (e.g. `05`).
        public static var day = Self("dd")
        /// Day (e.g. `5`).
        public static var dayShort = Self("d")
        /// Day of week in the month (e.g. `5`).
        public static var weekday = Self("F")
        /// Name of the day of the week (e.g. `Tuesday`).
        public static var weekdayName = Self("EEEE")
        /// Single character name of the day of the week (e.g. `T`).
        public static var weekdayNameSingle = Self("EEEEE")
        /// Short name of the day of the week (e.g. `Tue`).
        public static var weekdayNameShort = Self("E")
        
        /// Month with a zero if there is only 1 digit (e.g. `09`).
        public static var month = Self("MM")
        /// Month (e.g. `9`).
        public static var monthShort = Self("M")
        /// Name of the month (e.g. `December`).
        public static var monthName = Self("MMMM")
        /// Single character name of the month (e.g. `D`).
        public static var monthNameSingle = Self("MMMMM")
        /// Short name of the month (e.g. `Dec`).
        public static var monthNameShort = Self("MMM")

        /// Year with four digits (e.g. `2024`).
        public static var year = Self("yyyy")
        /// Year (e.g. `24`).
        public static var yearShort = Self("yy")
                
        /// Quarter of the year (e.g. `04`)
        public static var quarter = Self("QQ")
        /// Quarter of the year (e.g. `4`)
        public static var quarterShort = Self("Q")
        /// Quarter of the year including `Q` (e.g. `Q4`)
        public static var quarterWithQ = Self("QQQ")
        /// Quarter of the year spelled out (e.g. `4th quarter`)
        public static var quarterSpelledOut = Self("QQQQ")
        
        /// Name of the time zone (e.g. `Central Standard Time`).
        public static var timezone = Self("zzzz")
        /// 3 letter name of the time zone (e.g. `GMT`).
        public static var timezoneShort = Self("zzz")
        /// 3 letter name of the time zone including offset (e.g. `CST-06:00`).
        public static var timezoneWithOffset = Self("ZZZZ")
        /// ISO 8601 time zone (e.g. `-06:00`).
        public static var iso8601 = Self("ZZZZZ")
        /// RFC 822 GMT time zone. Can also match a literal Z for Zulu (UTC) time (e.g. `-0600`).
        public static var rfs022 = Self("Z")
        
        init(_ value: String) {
            self.format = value
        }
    }
}
