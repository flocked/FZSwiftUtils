//
//  DateFormatter+DateFormat.swift
//
//
//  Copyright © 2021 Yurii Lysytsia. All rights reserved.
//

import Foundation

public extension DateFormatter {
    /**
     Creates a date formatter with the specified components.
     
     Construct a date format using a string and ``DateFormat/DateComponent``.
     
     Example usage:
     
     ```swift
     // "04/05/25"
     DateFormatter("\(.day)/\(.month)/\(.yearShort)")
     
     // "2025-05-04 18:42"
     DateFormatter("\(.year)-\(.month)-\(.day) \(.hour24):\(.minute)")
     
     // "Sunday, May 4"
     DateFormatter("\(.weekdayName), \(.monthName) \(.dayShort)")

     // "Q2 2025"
     DateFormatter("\(.quarterWithQ) \(.year)")

     // "18:42:15.123"
     DateFormatter("\(.hour24):\(.minute):\(.second).\( .millisecond )")
     ```

     - Parameter format: The date format.
     */
    convenience init(_ format: DateFormat) {
        self.init(format.description)
    }
    
    /**
     Sets the date format string.
     
     Construct a date format using a string and ``DateFormat/DateComponent``.
     
     Example usage:
     
     ```swift
     // "04/05/25"
     DateFormatter("\(.day)/\(.month)/\(.yearShort)")
     
     // "2025-05-04 18:42"
     DateFormatter("\(.year)-\(.month)-\(.day) \(.hour24):\(.minute)")
     
     // "Sunday, May 4"
     DateFormatter("\(.weekdayName), \(.monthName) \(.dayShort)")

     // "Q2 2025"
     DateFormatter("\(.quarterWithQ) \(.year)")

     // "18:42:15.123"
     DateFormatter("\(.hour24):\(.minute):\(.second).\(.millisecond)")
     ```
     */
    func format(_ format: DateFormat) -> Self {
        self.format(format.description)
    }
}

public extension Date {
    /// Creates a date from the specific formatted string and date format.
    init?(_ string: String, format: DateFormat, locale: Locale = .current) {
        guard let date = DateFormatter(format).locale(locale).date(from: string) else { return nil }
        self = date
    }
    
    /// Generates a locale-aware string representation of a date using the specified date format and locale.
    func formatter(_ format: DateFormat, locale: Locale = .current) -> String {
        DateFormatter(format).string(from: self)
    }
}

/**
 A date format to be used with `DateFormatter`.
 
 The date format can be expressed as String and with ``DateComponent``.
 
 Example usage:
 
 ```swift
 // "04/05/25"
 DateFormatter("\(.day)/\(.month)/\(.yearShort)")
 
 // "2025-05-04 18:42"
 DateFormatter("\(.year)-\(.month)-\(.day) \(.hour24):\(.minute)")
 
 // "Sunday, May 4"
 DateFormatter("\(.weekdayName), \(.monthName) \(.dayShort)")

 // "Q2 2025"
 DateFormatter("\(.quarterWithQ) \(.year)")

 // "18:42:15.123"
 DateFormatter("\(.hour24):\(.minute):\(.second).\(.millisecond)")
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
    
    /// The date components of the format.
    public func components() -> [DateComponent] {
        var extracted: [String] = []
        var currentIndex = format.startIndex
        var inLiteral = false

        while currentIndex < format.endIndex {
            let currentChar = format[currentIndex]
            if currentChar == "'" {
                inLiteral.toggle()
                currentIndex = format.index(after: currentIndex)
                continue
            }
            if inLiteral {
                currentIndex = format.index(after: currentIndex)
                continue
            }
            var foundMatch = false
            for symbol in Self.componentFormats {
                if let range = format.range(of: symbol, options: [.anchored], range: currentIndex..<format.endIndex) {
                    extracted.append(symbol)
                    currentIndex = range.upperBound
                    foundMatch = true
                    break
                }
            }
            if !foundMatch {
                currentIndex = format.index(after: currentIndex)
            }
        }
        return extracted.map({.init($0)})
    }
    
    static let componentFormats = [
        "EEEEEE", "eeeeee", "cccccc", "MMMMM", "LLLLL", "GGGGG", "YYYYY", "yyyyy",
        "QQQQ", "qqqq", "VVVV", "ZZZZZ", "zzzz", "vvvv", "GGGG", "EEEE", "eeee", "cccc",
        "LLLL", "MMMM", "QQQ", "qqq", "YYYY", "yyyy", "ZZZZ", "DDD", "ZZZ", "zzz",
        "HH", "KK", "LLL", "MMM", "QQ", "SS", "WW", "ccccc", "eeeee", "EEE", "ccc", "eee",
        "GGG", "LL", "MM", "aa", "bb", "dd", "hh", "jj", "kk", "mm", "qq", "ss", "vv",
        "wW", "yy", "YY", "c", "d", "D", "e", "E", "F", "G", "H", "h", "J", "j", "K", "k",
        "L", "M", "m", "O", "Q", "q", "S", "s", "u", "V", "v", "W", "w", "X", "x", "Y", "y",
        "Z", "z", "A", "B"
    ]
        
    public static func += (lhs: inout DateFormat, rhs: DateFormat) {
        lhs = .init(stringLiteral: lhs.format + rhs.format)
    }
    
    public static func + (lhs: DateFormat, rhs: DateFormat) -> Self {
        .init(stringLiteral: lhs.format + rhs.format)
    }
    
    public static func += (lhs: inout DateFormat, rhs: DateFormat.DateComponent) {
        lhs = .init(stringLiteral: lhs.format + rhs.format)
    }
    
    public static func + (lhs: DateFormat, rhs: DateFormat.DateComponent) -> Self {
        .init(stringLiteral: lhs.format + rhs.format)
    }
    
    public static func += (lhs: inout DateFormat, rhs: String) {
        lhs = .init(stringLiteral: lhs.format + rhs)
    }
    
    public static func + (lhs: DateFormat, rhs: String) -> Self {
        .init(stringLiteral: lhs.format + rhs)
    }
    
    public struct StringInterpolation: StringInterpolationProtocol {
        var parts: [String] = []
        
        public init(literalCapacity: Int, interpolationCount: Int) {}
        
        public mutating func appendLiteral(_ literal: String) {
            guard literal != "" else { return }
            parts.append("'\(literal)'")
        }
        
        public mutating func appendInterpolation(_ naming: DateComponent) {
            parts.append(naming.format)
        }
    }
}

extension DateFormat {
    /// Date component of a date format.
    public struct DateComponent: CustomStringConvertible {
        
        /// Three-digit milisecond (e.g. `123`).
        public static let millisecond = Self("SSS")
        /// Two-digit milisecond (e.g. `12`).
        public static let millisecondTwo = Self("SS")
        /// Single-digit milisecond (e.g. `1`).
        public static let millisecondShort = Self("S")
        
        /// Two-digit second, zero-padded if necessary (e.g. `01`, `18`).
        public static let second = Self("ss")
        /// Second (e.g. `1`, `18`).
        public static let secondShort = Self("s")
        
        /// Two-digit minute, zero-padded if necessary (e.g. `01`, `18`).
        public static let minute = Self("mm")
        /// Minute (e.g. `1`, `18`).
        public static let minuteShort = Self("m")
        
        /// AM or PM marker.
        public static let amPM = Self("a")
        /// Two-digit numeric 12-hour, zero-padded if necessary (e.g. `09`, `11`).
        public static let hour12 = Self.hour12(hourCycle: .oneBased)
        /// 12-hour (e.g. `9`, `11`).
        public static let hour12Short = Self.hour12Short(hourCycle: .oneBased)
        /// Two-digit numeric 24-hour, zero-padded if necessary (e.g. `09`, `22`).
        public static let hour24 = Self.hour12(hourCycle: .oneBased)
        /// 24-hour (e.g. `9`, `22`).
        public static let hour24Short = Self.hour12Short(hourCycle: .oneBased)
        
        /// Two-digit numeric 12-hour, zero-padded if necessary (e.g. `09`, `11`).
        public static func hour12(hourCycle: ClockHourCycle) -> Self {
            Self(hourCycle == .oneBased ? "hh": "kk")
        }
        /// 12-hour (e.g. `9`, `11`).
        public static func hour12Short(hourCycle: ClockHourCycle) -> Self {
            Self(hourCycle == .oneBased ? "h": "k")
        }
        /// Two-digit numeric 24-hour, zero-padded if necessary (e.g. `09`, `22`).
        public static func hour24(hourCycle: ClockHourCycle) -> Self {
            Self(hourCycle == .oneBased ? "HH": "KK")
        }
        /// 24-hour (e.g. `9`, `22`).
        public static func hour24Short(hourCycle: ClockHourCycle) -> Self {
            Self(hourCycle == .oneBased ? "H": "K")
        }
        
        /// Two-digit day, zero-padded if necessary (e.g. `01`, `18`).
        public static let day = Self("dd")
        /// Day (e.g. `1`, `18`).
        public static let dayShort = Self("d")
        /// Three-digit day of year, zero-padded if necessary (e.g. `005`, `124`).
        public static let dayOfYear = Self("DDD")
        /// Day of year (e.g. `5`, `124`).
        public static let dayOfYearShort = Self("D")
        
        /// Day of week in the month (e.g. `5`).
        public static let weekday = Self("F")
        /// Name of the day of the week (e.g. `Tuesday`).
        public static let weekdayName = Self("EEEE")
        /// Short name of the day of the week (e.g. `Tue`).
        public static let weekdayNameShort = Self("E")
        /// Single character name of the day of the week (e.g. `T`).
        public static let weekdayNameSingle = Self("EEEEE")
        /// Two characters name of the day of the week (e.g. `Tu`).
        public static let weekdayNameTwo = Self("EEEEEE")
        
        /// Two-digit month, zero-padded if necessary (e.g. `02`, `11`).
        public static let month = Self("MM")
        /// Month (e.g. `2`, `11`).
        public static let monthShort = Self("M")
        /// Month name (e.g. `December`).
        public static let monthName = Self("MMMM")
        /// Short month name (e.g. `Dec`).
        public static let monthNameShort = Self("MMM")
        /// Single character month name (e.g. `D`).
        public static let monthNameSingle = Self("MMMMM")
                
        /// Four-digit year (e.g. `2024`).
        public static let year = Self("yyyy")
        /// Two-digit year (e.g. `24`).
        public static let yearShort = Self("yy")
        
        /// Two-digit quarter of the year (e.g. `04`).
        public static let quarter = Self("QQ")
        /// Single-digit quarter of the year (e.g. `4`).
        public static let quarterShort = Self("Q")
        /// Quarter of the year including `Q` (e.g. `Q4`)
        public static let quarterWithQ = Self("QQQ")
        /// Quarter of the year spelled out (e.g. `4th quarter`)
        public static let quarterSpelledOut = Self("QQQQ")
        
        /// Name of the time zone (e.g. `Central Standard Time`).
        public static let timezone = Self("zzzz")
        /// Short name of the time zone (e.g. `GMT`).
        public static let timezoneShort = Self("zzz")
        /// Short name of the time zone including offset (e.g. `CST-06:00`).
        public static let timezoneWithOffset = Self("ZZZZ")
        /// ISO 8601 time zone (e.g. `-06:00`).
        public static let timezoneISO8601 = Self("ZZZZZ")
        /// RFC 822 GMT time zone. Can also match a literal Z for Zulu (UTC) time (e.g. `-0600`).
        public static let timezoneRFS022 = Self("Z")
        
        /// The start of a clock representation for the format of a hour.
        public enum ClockHourCycle {
            /// Clock starts at one.
            case oneBased
            /// Clock starts at zero.
            case zeroBased
        }
        
        init(_ value: String) {
            self.format = value
        }
        
        /// The format of the component.
        public let format: String
        
        public var description: String {
            format
        }
    }
}

/*
extension DateFormat.DateComponent {
    public enum Month: String {
        /// Abbreviated month name. For example, Sep.
        case abbreviated = "MMM"
        /// Wide month name. For example, September.
        case wide = "MMMM"
        /// Narrow month name. For example, S.
        case narrow = "MMMMM"
        /// Numeric month. For example, 9, 12.
        case defaultDigits = "M"
        /// Two-digit numeric month, zero-padded if necessary. For example, 09, 12.
        case twoDigits = "MM"
    }
    
    public enum Week: String {
        /// Numeric week of the month. For example, 1, 4.
        case weekOfMonth = "MMMMM"
        /// Numeric week. For example, 1, 18.
        case defaultDigits = "M"
        /// Two-digit numeric week, zero-padded if necessary. For example, 01, 18.
        case twoDigits = "MM"
    }
    
    public enum Weekday: String {
        /// Abbreviated weekday name. For example, Tue.
        case abbreviated = "E"
        /// Wide weekday name. For example, Tuesday.
        case wide = "EEEE"
        /// Narrow weekday name. For example, T.
        case narrow = "EEEEE"
        /// Short weekday name. For example, Tu.
        case short = "EEEEEE"
        /// Local numeric one-digit day of week. The value depends on the local starting day of the week. For example, this is 2 if Sunday is the first day of the week.
        case oneDigit = "F"
        /// Local numeric two-digit day of week, zero-padded if necessary. The value depends on the local starting day of the week. For example, this is 02 if Sunday is the first day of the week.
        case twoDigits = "FF"
    }
    
    /// A type that specifies a format for the hour in a date format style.
    public struct Hour {
        public let rawValue: String
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Creates a custom format style portraying the minimum number of digits that represents the hour.
        public static func defaultsDigits(_ clock: Clock, hourCycle: HourCycle = .oneBased) -> Self {
            switch (clock, hourCycle) {
            case (.twelveHour, .oneBased): return Self("h")
            case (.twelveHour, .zeroBased): return Self("k")
            case (.twentyFourHour, .oneBased): return Self("H")
            case (.twentyFourHour, .zeroBased): return Self("K")
            }
        }
        
        /// Creates a custom format style portraying two digits that represent the hour.
        public static func twoDigits(_ clock: Clock, hourCycle: HourCycle = .oneBased) -> Self {
            switch (clock, hourCycle) {
            case (.twelveHour, .oneBased): return Self("hh")
            case (.twelveHour, .zeroBased): return Self("kk")
            case (.twentyFourHour, .oneBased): return Self("HH")
            case (.twentyFourHour, .zeroBased): return Self("KK")
            }
        }
        
        /// A type that specifies a clock representation for the format of an hour.
        public enum Clock {
            /// A clock that portrays the hour using a 12-hour clock.
            case twelveHour
            /// A clock that portrays the hour using a 24-hour clock.
            case twentyFourHour
        }
        
        /// A type that specifies the start of a clock representation for the format of a hour.
        public enum HourCycle {
            /// A hour cycle indicating a clock that starts at one.
            case oneBased
            /// A hour cycle indicating a clock that starts at zero.
            case zeroBased
        }
    }
}
*/
