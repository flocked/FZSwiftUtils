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
     DateFormatter(components: .year, "-", .month, "-", .day, " ", .hour, ":", .minute)
     ```

     - Parameter components: The components of the date formatter.
     */
    convenience init(components: Component...) {
        self.init(components: components)
    }
    
    internal convenience init(components: [Component]) {
        self.init(components.compactMap({$0.format}).joined(separator: ""))
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
        public static var quartal = Component("QQ")
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

/*
public extension DateFormatter {
    /**
     Creates a date formatter with the specified components block.
     
     Example usage:
     
     ```swift
     // yyyy-mm-d
     DateFormatter({"\($0.year(.yyyy))-\($0.month(.mm))-\($0.day(.d))"})
     ```

     - Parameter components: The components of the date formatter.
     */
    convenience init(_ block: (DateFormatComponents.Type) -> String) {
        self.init(DateFormatComponents.build(block: block))
    }
    
    /// Model that contains available date format components.
    enum DateFormatComponents {
        /// Second.
        public static func second(_ second: Second) -> String { second.rawValue }
        
        /// Minute.
        public static func minute(_ minute: Minute) -> String { minute.rawValue }
        
        /// Hour.
        public static func hour(_ hour: Hour) -> String { hour.rawValue }
        
        /// Day.
        public static func day(_ day: Day) -> String { day.rawValue }
        
        /// Month.
        public static func month(_ month: Month) -> String { month.rawValue }
        
        /// Year.
        public static func year(_ year: Year) -> String { year.rawValue }
        
        /// Quartal.
        public static func quarter(_ quarter: Quarter) -> String { quarter.rawValue }
        
        /// Time zone.
        public static func timezone(_ timezone: Timezone) -> String { timezone.rawValue }

        static func build(block: (DateFormatComponents.Type) -> String) -> String {
            block(DateFormatComponents.self)
        }
        
        /// Available second formats.
        public enum Second: String {
            /// The seconds, with no padding for zeroes, e.g. `38` or `8`.
            case s

            /// The seconds with zero padding, e.g. `38` or `08`.
            case ss

            /// The milliseconds, e.g. `968`.
            case sss = "SSS"
        }

        /// Available minute formats.
        public enum Minute: String {
            /// The minute, with no padding for zeroes, e.g. `38` or `8`.
            case m

            /// The minute with zero padding,e.g. `38` or `08`.
            case mm
        }
        
        /// Available hour formats.
        public enum Hour: String {
            /// The 12-hour hour, e.g. `8`.
            case h

            /// The 12-hour hour padding with a zero if there is only 1 digit, e.g. `08`.
            case hh

            /// The 24-hour hour, e.g. `20`.
            case h24 = "H"

            /// The 24-hour hour padding with a zero if there is only 1 digit, e.g. `08`.
            case hh24 = "HH"

            /// AM / PM for 12-hour time formats.
            case a
        }
        
        /// Available day formats.
        public enum Day: String {
            /// The day of the month without padding, e.g. `4` or `14`. Will use `1` for `January 1st`.
            case d

            /// The day of the month, two digits, e.g. `04` or `14`. Will use `01` for `January 1st`.
            case dd

            /// The day of week in the month. Will use `3` for `3rd Tuesday in December`.
            case f = "F"

            /// The abbreviation for the day of the week, e.g. `Mon` or `Sun`.
            case e = "E"

            /// The wide name of the day of the week, e.g. `Monday` or `Sunday`.
            case eeee = "EEEE"

            /// The narrow day of week, e.g. `M` or `S`.
            case eeeee = "EEEEE"

            /// The short day of week, e.g. `Mo` or `Su`.
            case eeeeee = "EEEEEE"
        }
        
        public enum Month: String {
            /// The numeric month of the year, e.g. `1` or `11`. Will use `1` for `January`.
            case m = "M"

            /// The numeric month of the year with zero padding, e.g. `01` or `11`. Will use `01` for `January`.
            case mm = "MM"

            /// The shorthand name of the month, e.g. `Dec`.
            case mmm = "MMM"

            /// Full name of the month, e.g. `December`.
            case mmmm = "MMMM"

            /// Narrow name of the month, e.g. `D`.
            case mmmmm = "MMMMM"
        }
        
        /// Available year formats.
        public enum Year: String {
            /// Year without padding, e.g `2021` or `101`.
            case y

            /// Year, two digits (padding with a zero if necessary), e.g `21` or `01`.
            case yy

            /// Year, minimum of four digits (padding with zeros if necessary), e.g `2008` or `0101`
            case yyyy
        }
        
        /// Available quarter formats.
        public enum Quarter: String {
            /// The quarter of the year, e.g. `4`. Use QQ if you want zero padding.
            case q = "Q"

            /// The quarter of the year with zero padding, e.g. `04`
            case qq = "QQ"

            /// Quarter including "Q", e.g. `Q4`.
            case qqq = "QQQ"

            /// Quarter spelled out, e.g. `4th quarter`.
            case qqqq = "QQQQ"
        }

        /// Available zone formats.
        public enum Timezone: String {
            /// The 3 letter name of the time zone, e.g. `EET`. Falls back to `GMT-08:00` (hour offset) if the name is not known.
            case zzz

            /// The expanded time zone name, e.g. `Eastern European Time`. Falls back to `GMT-08:00` (hour offset) if name is not known.
            case zzzz

            /// RFC 822 GMT format, e.g. `+0300`. Can also match a literal Z for Zulu (UTC) time.
            case zAbbreviation = "Z"

            /// Time zone with abbreviation and offset, e.g. `GMT+03:00`.
            case zzzzAbbreviation = "ZZZZ"

            /// ISO 8601 time zone format, e.g. `+03:00`.
            case zzzzzAbbreviation = "ZZZZZ"
        }
    }
}
*/
