//
//  DateFormatter+.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension DateFormatter {
    /**
     Creates a `DateFormatter` with the specified date format.

     - Parameter format: The date format string to use for the `DateFormatter`.

     - Returns: A `DateFormatter` object with the specified date format.
     */
    convenience init(_ format: String) {
        self.init()
        dateFormat = format
    }
    
    /**
     Creates a `DateFormatter` with the specified components.
     
     Example usage:
     
     ```swift
     // yyyy-MM-dd HH:mm
     DateFormatter(.year, "-", .month, "-", .day, " ", .hour, ":", .minute)
     ```

     - Parameter components: The components of the date formatter.
     */
    convenience init(_ components: Component...) {
        self.init(components.compactMap({$0.format}).joined(separator: ""))
    }
    

    /// /// The date formatter used for parsing ISO8601 dates, i.e. "2021-02-25T05:34:47+00:00".
    static var iso8601: DateFormatter {
        let formatter = DateFormatter("yyyy-MM-dd'T'HH:mm:ssZ")
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }

    /// The date formatter used for parsing Zulu dates, i.e. "2021-02-03T20:19:55.317Z".
    static var zulu: DateFormatter {
        let formatter = DateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }

    /// Date component.
    struct Component: ExpressibleByStringLiteral, CustomStringConvertible {
        /// The format of the component.
        public let format: String
        
        public var description: String { format }
        
        /// Milisecond (e.g. `123`).
        public static var millisecond = Component("SSS")
        /// Second with a zero if there is only 1 digit (e.g. `05`).
        public static var second = Component("ss")
        /// Second (e.g. `33`).
        public static var secondShort = Component("s")

        /// Minute with a zero if there is only 1 digit (e.g. `09`).
        public static var minute = Component("mm")
        /// Minute (e.g. `9`).
        public static var minuteShort = Component("m")

        /// 12-hour with a zero if there is only 1 digit (e.g. `09`).
        public static var hour12 = Component("hh")
        /// 12-hour (e.g. `9`).
        public static var hour12Short = Component("h")
        /// 24-hour with a zero if there is only 1 digit (e.g. `09`).
        public static var hour24 = Component("HH")
        /// 24-hour (e.g. `22`).
        public static var hour24Short = Component("H")
        /// AM / PM for 12-hour time formats (e.g. `PM`)
        public static var amPM = Component("a")

        /// Day with a zero if there is only 1 digit (e.g. `05`).
        public static var day = Component("d")
        /// Day (e.g. `5`).
        public static var dayShort = Component("dd")
        /// Day of week in the month (e.g. `5`).
        public static var weekday = Component("F")
        /// Name of the day of the week (e.g. `Tuesday`).
        public static var weekdayName = Component("EEEE")
        /// Single character name of the day of the week (e.g. `T`).
        public static var weekdayNameSingle = Component("EEEEE")
        /// Short name of the day of the week (e.g. `Tue`).
        public static var weekdayNameShort = Component("E")
        
        /// Month with a zero if there is only 1 digit (e.g. `09`).
        public static var month = Component("MM")
        /// Month (e.g. `9`).
        public static var monthShort = Component("M")
        /// Name of the month (e.g. `December`).
        public static var monthName = Component("MMMM")
        /// Single character name of the month (e.g. `D`).
        public static var monthNameSingle = Component("MMMMM")
        /// Short name of the month (e.g. `Dec`).
        public static var monthNameShort = Component("MMM")

        /// Year with four digits (e.g. `2024`).
        public static var year = Component("yyyy")
        /// Year (e.g. `24`).
        public static var yearShort = Component("yy")
        
        /// Quarter of the year (e.g. `04`)
        public static var quartal = Component("Q")
        /// Quarter of the year (e.g. `4`)
        public static var quartalShort = Component("Q")
        /// Quarter of the year including `Q` (e.g. `Q4`)
        public static var quartalQ = Component("QQQ")
        /// Quarter of the year spelled out (e.g. `4th quarter`)
        public static var quartalSpelled = Component("QQQQ")
        
        /// Name of the time zone (e.g. `Central Standard Time`).
        public static var timezone = Component("zzzz")
        /// 3 letter name of the time zone (e.g. `GMT`).
        public static var timezoneShort = Component("zzz")
        /// 3 letter name of the time zone including offset (e.g. `CST-06:00`).
        public static var timezoneOffset = Component("ZZZZ")
        /// ISO 8601 time zone (e.g. `-06:00`).
        public static var iso8601 = Component("ZZZZZ")
        /// RFC 822 GMT time zone. Can also match a literal Z for Zulu (UTC) time (e.g. `-0600`).
        public static var rfs022 = Component("Z")

        /// Creates a component from the specified string.
        public init(stringLiteral value: String) {
            self.format = value
        }
        
        init(_ value: String) {
            self.format = value
        }

        public static func +(lhs: Self, rhs: Self) -> Self {
            Component(lhs.format + rhs.format)
        }
    }
}


public extension DateComponentsFormatter {
    /**
     An array of allowed calendar components for formatting.
     */
    var allowedComponents: [Calendar.Component] {
        get { allowedUnits.components }
        set {
            var unit: NSCalendar.Unit = []
            newValue.compactMap(\.nsUnit).forEach { unit.insert($0) }
            allowedUnits = unit
        }
    }
}
