//
//  TimeDuration.swift
//
//
//  Created by Florian Zand on 10.03.23.
//

import AVKit
import Foundation

/// A structure representing a time duration.
public struct TimeDuration: Hashable, Sendable, Codable {
    /**
     Initializes a new `TimeDuration` instance with the specified duration in seconds.

     - Parameter seconds: The duration in seconds.
     */
    public init(_ seconds: Double) {
        self.seconds = seconds
    }

    #if os(macOS) || os(iOS) || os(tvOS)
    /**
     Initializes a new `TimeDuration` instance with the specified `CMTime`.

     - Parameter time: The `CMTime` to use for the duration.
     */
    public init(_ time: CMTime) {
        seconds = time.seconds
    }
    #endif

    /**
     Initializes a new time duration with the interval between the two specified dates.

     - Parameters:
     - date: The first date.
     - another: The second date.
     */
    public init(from date: Date, to another: Date) {
        if date <= another {
            let interval = date.timeIntervalSince(another)
            seconds = (interval >= 0.0) ? interval : 0
        } else {
            let interval = another.timeIntervalSince(date)
            seconds = (interval >= 0.0) ? interval : 0
        }
    }

    /**
     Initializes a new `TimeDuration` with the specified values.

     - Parameters:
       - nanoseconds: The nanoseconds of the duration.
       - microseconds: The microseconds of the duration.
       - milliseconds: The milliseconds of the duration.
       - seconds: The seconds of the duration.
       - minutes: The minutes of the duration.
       - hours: The hours of the duration.
       - days: The days of the duration.
       - weeks: The weeks of the duration.
       - months: The months of the duration, using the average length of a month (`~30.436875` days).
       - years: The years of the duration, using the average length of a year (`~365.2425` days).
     */
    public init(nanoseconds: Double = 0, microseconds: Double = 0, milliseconds: Double = 0, seconds: Double = 0, minutes: Double = 0, hours: Double = 0, days: Double = 0, weeks: Double = 0, months: Double = 0, years: Double = 0) {
        self.seconds = seconds
        self.seconds += (milliseconds / 1_000)
        self.seconds += (microseconds / 1_000_000)
        self.seconds += (nanoseconds / 1_000_000_000)
        self.seconds += self.seconds(for: minutes, .minute)
        self.seconds += self.seconds(for: hours, .hour)
        self.seconds += self.seconds(for: days, .day)
        self.seconds += self.seconds(for: weeks, .week)
        self.seconds += self.seconds(for: months, .month)
        self.seconds += self.seconds(for: years, .year)
    }

    /**
     Initializes a new `TimeDuration` instance with the duration between the start and end dates of the specified `DateInterval`.

     - Parameter dateInterval: The `DateInterval` to calculate the duration from.
     */
    public init(dateInterval: DateInterval) {
        seconds = dateInterval.start.timeIntervalSince(dateInterval.end)
    }
    
    /// The duration in nanoseconds.
    public var nanoseconds: Double {
        get { value(for: .nanosecond) }
        set { seconds = seconds(for: newValue, .nanosecond) }
    }
    
    /// The duration in microseconds.
    public var microseconds: Double {
        get { value(for: .microsecond) }
        set { seconds = seconds(for: newValue, .microsecond) }
    }
    
    /// The duration in milliseconds.
    public var milliseconds: Double {
        get { value(for: .millisecond) }
        set { seconds = seconds(for: newValue, .millisecond) }
    }

    /// The duration in seconds.
    public var seconds: Double {
        didSet { seconds = seconds.clamped(min: 0.0) }
    }

    /// The duration in minutes.
    public var minutes: Double {
        get { value(for: .minute) }
        set { seconds = seconds(for: newValue, .minute) }
    }

    /// The duration in hours.
    public var hours: Double {
        get { value(for: .hour) }
        set { seconds = seconds(for: newValue, .hour) }
    }

    /// The duration in days.
    public var days: Double {
        get { value(for: .day) }
        set { seconds = seconds(for: newValue, .day) }
    }

    /// The duration in weeks.
    public var weeks: Double {
        get { value(for: .week) }
        set { seconds = seconds(for: newValue, .week) }
    }

    /// The duration in months, using the average length of a month (`~30.436875` days).
    public var months: Double {
        get { value(for: .month) }
        set { seconds = seconds(for: newValue, .month) }
    }

    /// The duration in years, using the average length of a year (`~365.2425` days).
    public var years: Double {
        get { value(for: .year) }
        set { seconds = seconds(for: newValue, .year) }
    }

    /**
     Returns the start date based on the given end date and the current duration.

     - Parameter end: The end date from which to calculate the start date.
     - Returns: The calculated start date.
     */
    public func startDate(end: Date) -> Date {
        end.adding(-Int(seconds), to: .second)
    }

    /**
     Returns the end date based on the given start date and the current duration.

     - Parameter start: The start date from which to calculate the end date.
     - Returns: The calculated end date.
     */
    public func endDate(start: Date) -> Date {
        DateInterval(start: start, duration: seconds).end
    }

    /// Returns a `TimeDuration`  with zero seconds.
    public static var zero: TimeDuration {
        TimeDuration(0.0)
    }

    private func value(for unit: Unit) -> Double {
        unit.value(for: seconds)
    }

    private func seconds(for value: Double, _ unit: Unit) -> Double {
        unit.seconds(for: value)
    }
}

public extension TimeDuration {
    /// Returns a time duration with the specified nanoseconds.
    static func nanoseconds(_ value: Double) -> Self { Self(nanoseconds: value) }
    
    /// Returns a time duration with the specified microseconds.
    static func microseconds(_ value: Double) -> Self { Self(microseconds: value) }

    /// Returns a time duration with the specified milliseconds.
    static func milliseconds(_ value: Double) -> Self { Self(milliseconds: value) }

    /// Returns a time duration with the specified seconds.
    static func seconds(_ value: Double) -> Self { Self(seconds: value) }

    /// Returns a time duration with the specified minutes.
    static func minutes(_ value: Double) -> Self { Self(minutes: value) }

    /// Returns a time duration with the specified hours.
    static func hours(_ value: Double) -> Self { Self(hours: value) }

    /// Returns a time duration with the specified days.
    static func days(_ value: Double) -> Self { Self(days: value) }

    /// Returns a time duration with the specified weeks.
    static func weeks(_ value: Double) -> Self { Self(weeks: value) }

    /// Returns a time duration with the specified months, using the average length of a month (`~30.436875` days).
    static func months(_ value: Double) -> Self { Self(months: value) }

    /// Returns a time duration with the specified years, using the average length of a year (`~365.2425` days).
    static func years(_ value: Double) -> Self { Self(years: value) }
}

extension TimeDuration: RawRepresentable {
    /**
     Initializes a new `TimeDuration` instance with the specified duration in seconds.

     - Parameter seconds: The duration in seconds.
     */
    public init(rawValue: Double) {
        self.seconds = rawValue
    }
    
    /// The duration in seconds.
    public var rawValue: Double { seconds }
}

public extension DateInterval {
    /// The time duration.
    var timeDuration: TimeDuration {
        TimeDuration(duration)
    }

    /// Initializes an interval with the specified start date and duration.
    init(start: Date, duration: TimeDuration) {
        self.init(start: start, duration: duration.seconds)
    }
}

public extension Date {
    /**
     Returns the interval between this date and another given date.

     - Parameter another: The date with which to compare this one.
     - Returns: The interval between this date and the another date. If this date is earlier than the other date, the return value is a time duration with 0 seconds.
     */
    func timeDurationSince(_ another: Date) -> TimeDuration {
        TimeDuration(timeIntervalSince(another))
    }

    /// Creates a new date value by adding a time duration to this date.
    static func + (lhs: Date, rhs: TimeDuration) -> Date {
        lhs.addingTimeInterval(rhs.seconds)
    }

    /// Adds a time duration to this date.
    static func += (lhs: inout Date, rhs: TimeDuration) {
        lhs.addTimeInterval(rhs.seconds)
    }

    /// Creates a new date value by subtracting a time duration to this date.
    static func - (lhs: Date, rhs: TimeDuration) -> Date {
        lhs.addingTimeInterval(-rhs.seconds)
    }

    /// Subtracts a time duration to this date.
    static func -= (lhs: inout Date, rhs: TimeDuration) {
        lhs.addTimeInterval(-rhs.seconds)
    }
}

extension TimeDuration: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        seconds = Double(value)
    }
}

extension TimeDuration: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        seconds = value
    }
}

public extension TimeDuration {
    ///  Enumeration representing different duration time units.
    enum Unit: Int, CaseIterable {
        /// Nanosecond
        case nanosecond
        /// Microsecond
        case microsecond
        /// Millisecond
        case millisecond
        /// Second
        case second
        /// Minute
        case minute
        /// Hour
        case hour
        /// Day
        case day
        /// Week
        case week
        /// Month
        case month
        /// Year
        case year

        private var secondsPerUnit: Double {
            switch self {
            case .nanosecond:   return 1e-9
            case .microsecond:  return 1e-6
            case .millisecond:  return 1e-3
            case .second: return 1
            case .minute: return 60
            case .hour: return 3600
            case .day: return 86400
            case .week: return 604800
            case .month: return 2629746
            case .year: return 31557600
            }
        }

        func value(for seconds: Double) -> Double {
            seconds / secondsPerUnit
        }

        func seconds(for value: Double) -> Double {
            value * secondsPerUnit
        }

        func convert(_ value: Double, to target: Unit) -> Double {
            target.value(for: seconds(for: value))
        }

        var calendarComponent: Calendar.Component {
            switch self {
            case .nanosecond: return .second
            case .microsecond: return .second
            case .millisecond: return .second
            case .second: return .second
            case .minute: return .minute
            case .hour: return .hour
            case .day: return .day
            case .week: return .weekOfMonth
            case .month: return .month
            case .year: return .year
            }
        }
    }

    /// The time duration units.
    struct Units: OptionSet {
        /// Nanosecond
        public static let nanosecond = Self(rawValue: 1 << 0)
        /// Microsecond
        public static let microsecond = Self(rawValue: 1 << 1)
        /// Millisecond
        public static let millisecond = Self(rawValue: 1 << 2)
        /// Second
        public static let second = Self(rawValue: 1 << 3)
        /// Minute
        public static let minute = Self(rawValue: 1 << 4)
        /// Hour
        public static let hour = Self(rawValue: 1 << 5)
        /// Day
        public static let day = Self(rawValue: 1 << 6)
        /// Week
        public static let week = Self(rawValue: 1 << 7)
        /// Month
        public static let month = Self(rawValue: 1 << 8)
        /// Year
        public static let year = Self(rawValue: 1 << 9)

        /// All used units.
        public static let all = Self(rawValue: 1 << 10)
        /// All used units compact.
        public static let allCompact = Self(rawValue: 1 << 11)
        /// All used units detailed.
        public static let allDetailed: Self = [.second, .minute, .hour, .hour, .day, .week, .month, .year]

        public let rawValue: Int
        
        /// Creates a units structure with the specified raw value.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Creates a units structure with the specified time duration unit.
        public init(unit: Unit) {
            rawValue = Self.allCases.first(where: { $0.unit == unit })?.rawValue ?? 1 << 2
        }

        static let allCases: [Self] = [.nanosecond, microsecond, .millisecond, .second, .minute, .hour, .day, .week, .month, .year]
        var unit: Unit? {
            switch self {
            case .nanosecond: return .nanosecond
            case .microsecond: return .microsecond
            case .millisecond: return .millisecond
            case .second: return .second
            case .minute: return .minute
            case .hour: return .hour
            case .day: return .day
            case .week: return .week
            case .month: return .month
            case .year: return .year
            default: return nil
            }
        }

        func units(for duration: TimeDuration) -> [TimeDuration.Unit] {
            var units = Self.allCases.compactMap { contains($0) ? $0.unit : nil }
            if self == .allDetailed { units += elements().compactMap(\.unit) }
            if contains(.all) { units += duration.preferredUnits(compact: false) }
            if contains(.allCompact) { units += duration.preferredUnits(compact: true) }
            units = units.uniqued()
            return units
        }
    }
}

extension TimeDuration: CustomStringConvertible {
    /// A string representation of the time duration.
    public var description: String {
        string()
    }

    /**
     A string representation of the time duration including the units.

     Example usage:

     ```swift
     let duration = TimeDuration(seconds: 1, minutes: 2, hours: 3)
     duration.string // "3 hours, 2 minutes, 1 second"
     ```
     */
    var string: String {
        string(allowedUnits: .all)
    }

    /**
     A compact string representation of the time duration.

     Example usage:

     ```swift
     let duration = TimeDuration(seconds: 1, minutes: 2, hours: 3)
     duration.stringCompact // "3hrs 2min"
     ```
     */
    public var stringCompact: String {
        string(allowedUnits: .allCompact, style: .brief)
    }

    /**
     Returns a string representation of the time duration using the specified time unit and style.

     Example usage:

     ```swift
     let duration = TimeDuration(seconds: 1, minutes: 2, hours: 3)

     // full
     duration.string(for: .second, style: .full) // "10.921 seconds"

     // brief
     duration.string(for: .second, style: .brief) // "10.921secs"

     // short
     duration.string(for: .second, style: .short) // "10.921 secs"

     // abbreviated
     duration.string(for: .second, style: .abbreviated) // "10.921s"

     // positional
     duration.string(for: .second, style: .positional) // "10.921"

     // spellOut
     duration.string(for: .second, style: .spellOut) // "ten thousand nine hundred twenty-one seconds"
     ```

     - Parameters:
        - unit: The unit to use for formatting the time duration.
        - style: The formatting style. The default value is `full`.
        - locale: The language of the string.

     - Returns: A string representation of the time duration.
     */
    public func string(for unit: Unit, style: DateComponentsFormatter.UnitsStyle = .full, locale: Locale = .current) -> String {
        string(allowedUnits: .init(unit: unit), style: style, locale: locale)
    }

    /**
     Returns a string representation of the time duration using the specified allowed time units and style.

     Example usage:

     ```swift
     let duration = TimeDuration(seconds: 1, minutes: 2, hours: 3)

     // "182min 1sec"
     duration.string(allowedUnits: [.minute, .second], style: .brief)

     // "3 hours, 2 minutes, 1 second"
     duration.string(allowedUnits: .all, style: .full)
     ```

     - Parameters:
        - allowedUnits: The allowed units for formatting the time duration. The default value is `all`.
        - style: The formatting style. The default value is `full`.
        - locale: The language of the string.

     - Returns: A string representation of the time duration.
     */
    public func string(allowedUnits: Units = .all, style: DateComponentsFormatter.UnitsStyle = .full, locale: Locale = .current) -> String {
        let allowedUnits = allowedUnits.units(for: self)
        let formatter = DateComponentsFormatter()
        formatter.allowedComponents = allowedUnits.compactMap(\.calendarComponent).uniqued()
        formatter.unitsStyle = style
        formatter.locale = locale
        return formatter.string(from: seconds)!
    }

    /**
     Returns a string representation of the time duration using the specified allowed time units and style.

     Example usage:

     ```swift
     let duration = TimeDuration(seconds: 1, minutes: 2, hours: 3)

     // "182min 1sec"
     duration.relativeString(allowedUnits: [.minute, .second], style: .brief)

     // "3 hours, 2 minutes, 1 second"
     duration.string(allowedUnits: .all, style: .full)
     ```

     - Parameters:
        - inPast: A Boolean value indicating whether the duration should be interpreted as occurring in the past (e.g. "2 hours ago") or in the future (e.g "in 2 hours").
        - dateTimeStyle: The style to use when describing a relative date, for example “yesterday” or “1 day ago”.
        - unitsStyle: The unit style (e.g. “1 day ago” or “one day ago”).
        - locale: The language of the string.

     - Returns: A string representation of the time duration.
     */
    public func relativeString(inPast: Bool = false, dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle = .numeric, unitsStyle: RelativeDateTimeFormatter.UnitsStyle  = .full, locale: Locale = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = dateTimeStyle
        formatter.unitsStyle = unitsStyle
        formatter.locale = locale
        return formatter.localizedString(fromTimeInterval: seconds)
    }

    public enum TimeCodeFormat: Int, Hashable {
        /// Hours, minutes, and seconds (`3:23:45`).
        case hoursMinutesSeconds
        /// Minutes, and seconds (`23:45` or `235:45`).
        case minutesSeconds
        /// Seconds (`31` or `23545`).
        case seconds
        /// Always displays hours with at least two digits, minutes and seconds (`01:23:45` or `04:33:10`).
        case full
        /// Always displays hours (with one or more digits), minutes and seconds (`2:23:45` or `1:33:10`).
        case fullCompact
        /// Always displays minutes and seconds and if needed hours (`23:45` or `4:33:10`).
        case compact
        /// Displays only the necessary units (`44`, `23:45` or `4:33:10`).
        case short
    }

    /**
     A timecode string representation of the duration (e.g. "03:50:32").

     - Parameters:
       - format: The time code format determinating which units are used.
       - omitLeadingZeroInFirstUnit: A Boolean value indicating whether to omit the leading zero of the first unit if possible. e.g. "4:55:20" instead of "04:55:20".
       - subsecondsPrecision: Number of digits to include after the separator for fractional seconds. Set to `0` to hide fractional seconds.
       - separator: The string used to separate hours, minutes, and seconds.
       - subsecondSeparator: The string used to separate the seconds and fractional seconds.

     - Returns: A formatted string representing the timecode.
     */
    public func timecodeString(format: TimeCodeFormat = .compact, omitLeadingZeroInFirstUnit: Bool = true, subsecondsPrecision: Int = 0, separator: String = ":", subsecondSeparator: String = ",") -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        let showHours = format == .hoursMinutesSeconds || (format == .short && hours > 0) || (format == .compact && hours > 0)
        let showMinutes = format == .hoursMinutesSeconds || format == .compact || format == .minutesSeconds || (format == .short && (showHours || minutes > 0))
        let showSeconds = format == .seconds || format == .compact || showMinutes || showHours || format == .short

        return timecodeString(showHours: showHours, showMinutes: showMinutes, showSeconds: showSeconds, omitLeadingZeroInFirstUnit: omitLeadingZeroInFirstUnit, subsecondsPrecision: subsecondsPrecision, separator: separator, subsecondSeparator: subsecondSeparator)
    }
    
    /**
     A timecode string representation of the duration (e.g. "03:50:32").

     - Parameters:
        - showHours: Whether to include the hours component in the output.
        - showMinutes: Whether to include the minutes component in the output.
        - showSeconds: Whether to include the seconds component in the output.
        - omitLeadingZeroInFirstUnit: A Boolean value indicating whether to omit the leading zero of the first unit if possible. e.g. "4:55:20" instead of "04:55:20".
        - subsecondsPrecision: Number of digits to include after the separator for fractional seconds. Set to `0` to hide fractional seconds.
        - separator: The string used to separate hours, minutes, and seconds.
        - subsecondSeparator: The string used to separate the seconds and fractional seconds.

     - Returns: A formatted string representing the timecode.

     ```swift
     let duration = .seconds(13832.44)

     // "03:50:32"
     duration.timecodeString()
     // "03:50:32,44"
     duration.timecodeString(subsecondsPrecision: 2)
     // "230:32"
     duration.timecodeString(showHours: false)
     // "13832"
     duration.timecodeString(showHours: false, showMinutes: false)
     ```
     */
    public func timecodeString(showHours: Bool, showMinutes: Bool, showSeconds: Bool, omitLeadingZeroInFirstUnit: Bool = true, subsecondsPrecision: Int = 0, separator: String = ":", subsecondSeparator: String = ",") -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        let subseconds = seconds - Double(totalSeconds)

        func convert(_ value: Int, omitLeadingZero: Bool) -> String {
            omitLeadingZero && value < 10 ? "\(value)" : String(format: "%02d", value)
        }

        var components: [String] = []

        if showHours {
            components += convert(hours, omitLeadingZero: omitLeadingZeroInFirstUnit)
        }

        if showMinutes {
            let minutesValue = showHours ? minutes : (minutes + hours * 60)
            components += convert(minutesValue, omitLeadingZero: !showHours && omitLeadingZeroInFirstUnit)
        }

        if showSeconds {
            let secondsValue = (!showHours && !showMinutes) ? (secs + minutes * 60 + hours * 3600) : secs
            components += convert(secondsValue, omitLeadingZero: !showHours && !showMinutes && omitLeadingZeroInFirstUnit)
        }

        var timecode = components.joined(separator: separator)

        if subsecondsPrecision > 0 {
            let factor = pow(10.0, Double(subsecondsPrecision))
            let fractional = Int((subseconds * factor).rounded())
            let formatted = String(format: "%0*d", subsecondsPrecision, fractional)
            timecode += subsecondSeparator + formatted
        }
        return timecode
    }

    func allCurrentUnits() -> [Unit] {
        var units: [Unit] = []
        if years >= 1 { units.append(.year) }
        if months >= 1 { units.append(.month) }
        if weeks >= 1 { units.append(.week) }
        if days >= 1 { units.append(.day) }
        if hours >= 1 { units.append(.hour) }
        if minutes >= 1 { units.append(.minute) }
        units.append(.second)
        return units
    }

    func preferredUnits(compact: Bool = true) -> [Unit] {
        let currentUnits = allCurrentUnits()
        if compact == false, currentUnits.count >= 3 {
            return Array(currentUnits[0 ..< 3])
        } else if currentUnits.count >= 2 {
            return Array(currentUnits[0 ..< 2])
        } else {
            return [.second]
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension TimeDuration: DurationProtocol {}

extension TimeDuration: Comparable, AdditiveArithmetic {
    /// Adds the two time durations.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.seconds + rhs.seconds)
    }

    /// Subtracts the two time durations.
    public static func - (lhs: Self, rhs: Self) -> Self {
        var seconds = lhs.seconds - rhs.seconds
        if seconds < 0 { seconds = 0 }
        return Self(seconds)
    }

    /// A Boolean value indicating whether the first time duration is smaller than the second time duration.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds < rhs.seconds
    }

    /// A Boolean value indicating whether the first time duration is larger than the second time duration.
    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds > rhs.seconds
    }

    /// Returns the quotient of dividing the first time duration by the second, rounded to a representable value.
    public static func / (lhs: TimeDuration, rhs: Int) -> TimeDuration {
        TimeDuration(lhs.seconds / Double(rhs))
    }

    /// Multiplies the time duration and produces their product, rounding to a representable value.
    public static func * (lhs: TimeDuration, rhs: Int) -> TimeDuration {
        TimeDuration(lhs.seconds * Double(rhs))
    }

    /// Returns the quotient of dividing the first time duration by the second, rounded to a representable value.
    public static func / (lhs: TimeDuration, rhs: TimeDuration) -> Double {
        lhs.seconds / rhs.seconds
    }
}

extension DispatchTime {
    public static func + (lhs: Self, rhs: TimeDuration) -> Self {
        lhs + rhs.seconds
    }

    public static func += (lhs: inout Self, rhs: TimeDuration) {
        lhs = lhs + rhs
    }
}


public extension Collection where Element == TimeDuration {
    /**
     The average duration of all durations in the collection.

     - Returns: A `TimeDuration` instance representing the average duration. If the collection is empty, it returns `zerp`.
     */
    func average() -> TimeDuration {
        TimeDuration(map({$0.seconds}).average())
    }
}

public extension Timer {
    /**
     Initializes a timer for the specified date and time interval with the specified block.

     - Parameters:
        - fire: The time at which the timer should first fire.
        - interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
        - block: A block to be executed when the timer fires. The block takes a single Timer parameter and has no return value.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
    @_disfavoredOverload
    convenience init(fire: Date, interval: TimeDuration, repeats: Bool, block: @escaping ((Timer) -> Void)) {
        self.init(fire: fire, interval: interval.seconds, repeats: repeats, block: block)
    }

    /**
      Initializes a timer using the specified object and selector.

      - Parameters:
         - fire: The time at which the timer should first fire.
         - interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
         -  target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to this object until it (the timer) is invalidated.
         - selector: The message to send to target when the timer fires.
     The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument). The timer passes itself as the argument, thus the method would adopt the following pattern:
         - userInfo: Custom user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be `nil.
         - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.

      - Returns:A new Timer object, configured according to the specified parameters.
      */
    @_disfavoredOverload
    convenience init(fireAt date: Date, interval: TimeDuration, target: Any, selector: Selector, userInfo: Any?, repeats: Bool) {
        self.init(fireAt: date, interval: interval.seconds, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
    }

    /**
     Initializes a timer object with the specified time interval and block.

     - Parameters:
        - interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
        - block: A block to be executed when the timer fires. The block takes a single Timer parameter and has no return value.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
    @_disfavoredOverload
    convenience init(timeInterval interval: TimeDuration, repeats: Bool, block: @escaping ((Timer) -> Void)) {
        self.init(timeInterval: interval.seconds, repeats: repeats, block: block)
    }

    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters:
        - interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
        - target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
        - selector: The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument).
        - userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be `nil.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
    @_disfavoredOverload
    convenience init(timeInterval interval: TimeDuration, target: Any, selector: Selector, userInfo: Any?, repeats: Bool) {
        self.init(timeInterval: interval.seconds, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
    }

    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters:
        - interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
        - block: A block to be executed when the timer fires. The block takes a single Timer parameter and has no return value.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
    @discardableResult
    @_disfavoredOverload
    static func scheduledTimer(withTimeInterval interval: TimeDuration, repeats: Bool, block: @escaping ((Timer) -> Void)) -> Timer {
        scheduledTimer(withTimeInterval: interval.seconds, repeats: repeats, block: block)
    }

    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters:
        - interval: The interval between firings of the timer. If interval is equal to `0.0` seconds, this method chooses the nonnegative value of `0.0001` seconds instead.
        - target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
        - selector: The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument).
        - userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be `nil`.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
    @_disfavoredOverload
    static func scheduledTimer(timeInterval interval: TimeDuration, target: Any, selector: Selector, userInfo: Any?, repeats: Bool) -> Timer {
        scheduledTimer(timeInterval: interval.seconds, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
    }
}

extension TimeDuration: ReferenceConvertible {

    /// The Objective-C type for the time duration.
    public typealias ReferenceType = __TimeDuration

    public var debugDescription: String {
        description
    }

    public func _bridgeToObjectiveC() -> __TimeDuration {
        return __TimeDuration(seconds: seconds)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __TimeDuration, result: inout TimeDuration?) {
        result = TimeDuration(source.seconds)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __TimeDuration, result: inout TimeDuration?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __TimeDuration?) -> TimeDuration {
        if let source = source {
            var result: TimeDuration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return .zero
    }
}

/// The Objective-C type for `TimeDuration`.
public class __TimeDuration: NSObject, NSCopying {
    let seconds: Double

    init(seconds: Double) {
        self.seconds = seconds
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        __TimeDuration(seconds: seconds)
    }
}

/*
extension TimeDuration {
    public enum TimeCodeFormatAlt {
        /// Hours with at least two digits, minutes and seconds (`01:23:45` or `04:33:10`).
        case full
        /// Hours witho one or more digits,  minutes and seconds (`1:23:45` or `4:33:10`).
        case fullUnpadded
        /// Minutes and seconds, and hours only if non-zero; with at least two digits for the first unit (`03:45` or `4:33:10`).
        case compact
        /// Minutes and seconds, and hours only if non-zero; with one or more digits for the first unit (`3:45` or `4:33:10`).
        case compactUnpadded
        /// Uses only the necessary units (`44`, `23:45` or `4:33:10`).
        case short
    }
    
    public func timecodeString(format: TimeCodeFormatAlt = .compact, omitLeadingZeroInFirstUnit: Bool = true, subsecondsPrecision: Int = 0, separator: String = ":", subsecondSeparator: String = ",") -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        let showHours = format == .full || format == .fullUnpadded || ((format == .short || format == .compact || format == .compactUnpadded) && hours > 0)
        let showMinutes = format != .short || (showHours || minutes > 0)
        
        return timecodeString(showHours: showHours, showMinutes: showMinutes, showSeconds: true, omitLeadingZeroInFirstUnit: format == .fullUnpadded || format == .compactUnpadded, subsecondsPrecision: subsecondsPrecision, separator: separator, subsecondSeparator: subsecondSeparator)
    }
}
*/
