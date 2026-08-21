//
//  TimeDuration.swift
//
//
//  Created by Florian Zand on 10.03.23.
//

import CoreMedia
import Foundation

/**

 A structure representing a time duration.

 To generate a localized string representation of a `TimeDuration`, use one of the following methods:

 - ``string(for:style:locale:)``
 - ``string(allowedUnits:style:maximumUnitCount:zeroFormattingBehavior:locale:)``
 - ``relativeString(dateTimeStyle:unitsStyle:locale:)``

 Alternatively, you can use `TimeDuration` with ``Foundation/DateComponentsFormatter`` or ``Foundation/RelativeDateTimeFormatter`` and their [string(for:)](https://developer.apple.com/documentation/foundation/datecomponentsformatter/string(for:)).
 */
public struct TimeDuration: Hashable, Sendable, Codable {
    /**
     Initializes a new `TimeDuration` instance with the specified duration in seconds.

     - Parameter seconds: The duration in seconds.
     */
    public init(_ seconds: Double) {
        self.seconds = seconds
    }

    #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
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
        self.seconds += (milliseconds / 1000)
        self.seconds += (microseconds / 1000000)
        self.seconds += (nanoseconds / 1000000000)
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
    public var seconds: Double

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
    static func nanoseconds(_ value: Double) -> Self {
        Self(nanoseconds: value)
    }

    /// Returns a time duration with the specified microseconds.
    static func microseconds(_ value: Double) -> Self {
        Self(microseconds: value)
    }

    /// Returns a time duration with the specified milliseconds.
    static func milliseconds(_ value: Double) -> Self {
        Self(milliseconds: value)
    }

    /// Returns a time duration with the specified seconds.
    static func seconds(_ value: Double) -> Self {
        Self(seconds: value)
    }

    /// Returns a time duration with the specified minutes.
    static func minutes(_ value: Double) -> Self {
        Self(minutes: value)
    }

    /// Returns a time duration with the specified hours.
    static func hours(_ value: Double) -> Self {
        Self(hours: value)
    }

    /// Returns a time duration with the specified days.
    static func days(_ value: Double) -> Self {
        Self(days: value)
    }

    /// Returns a time duration with the specified weeks.
    static func weeks(_ value: Double) -> Self {
        Self(weeks: value)
    }

    /// Returns a time duration with the specified months, using the average length of a month (`~30.436875` days).
    static func months(_ value: Double) -> Self {
        Self(months: value)
    }

    /// Returns a time duration with the specified years, using the average length of a year (`~365.2425` days).
    static func years(_ value: Double) -> Self {
        Self(years: value)
    }
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
    public var rawValue: Double {
        seconds
    }
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

    /// The time interval between the date value and the current date and time.
    var timeDurationSincceNow: TimeDuration {
        .seconds(timeIntervalSinceNow)
    }

    /// The interval between the date value and 00:00:00 UTC on 1 January 2001.
    var timeDurationSinceReferenceDate: TimeDuration {
        .seconds(timeIntervalSinceReferenceDate)
    }

    /// The interval between the date value and 00:00:00 UTC on 1 January 1970.
    var timeDurationSincce1970: TimeDuration {
        .seconds(timeIntervalSince1970)
    }

    /// Creates a new date value by adding the specified time duration to this date.
    func addingTimeDuration(_ duration: TimeDuration) -> Date {
        addingTimeInterval(duration.seconds)
    }

    /// Adds the specified time interval to this date.
    mutating func addTimeDuration(_ duration: TimeDuration) {
        addTimeInterval(duration.seconds)
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

extension TimeDuration {
    ///  Enumeration representing different duration time units.
    enum Unit: Int, CaseIterable {
        /// Nanosecond
        case nanosecond = 1
        /// Microsecond
        case microsecond = 2
        /// Millisecond
        case millisecond = 4
        /// Second
        case second = 8
        /// Minute
        case minute = 16
        /// Hour
        case hour = 32
        /// Day
        case day = 64
        /// Week
        case week = 128
        /// Month
        case month = 256
        /// Year
        case year = 512

        private var secondsPerUnit: Double {
            switch self {
            case .nanosecond: 1e-9
            case .microsecond: 1e-6
            case .millisecond: 1e-3
            case .second: 1
            case .minute: 60
            case .hour: 3600
            case .day: 86400
            case .week: 604800
            case .month: 2629746
            case .year: 31557600
            }
        }

        func value(for seconds: Double) -> Double {
            seconds / secondsPerUnit
        }

        func seconds(for value: Double) -> Double {
            value * secondsPerUnit
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
        string()
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
        string(allowedUnits: .compact, style: .brief)
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
    public func string(for unit: ComponentsFormatStyle.Unit, style: ComponentsFormatStyle.UnitsStyle = .full, locale: Locale = .current) -> String {
        string(allowedUnits: .init(rawValue: unit.rawValue), style: style, locale: locale)
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
        - allowedUnits: The allowed units for formatting the time duration.
        - style: The formatting style.
        - maximumUnitCount: The maximum number of time units to include in the output string.
        - zeroFormattingBehavior: The formatting style for units whose value is `0`.
        - locale: The language of the string.

     - Returns: A string representation of the time duration.
     */
    public func string(allowedUnits: ComponentsFormatStyle.Units = .all, style: ComponentsFormatStyle.UnitsStyle = .full, maximumUnitCount: Int = 0, zeroFormattingBehavior: ComponentsFormatStyle.ZeroFormattingBehavior = .default, locale: Locale = .current) -> String {
        string(for: allowedUnits, maximumUnitCount: maximumUnitCount, unitsStyle: style, zeroFormattingBehavior: zeroFormattingBehavior, locale: locale)
    }

    /**
     Returns an  amount of time remaining string representation of the time duration using the specified allowed time units and style.

     Example usage:

     ```swift
     let duration = TimeDuration(seconds: 1, minutes: 2, hours: 3)

     // "3hrs 2min remaining"
     duration.timeRemainingString(allowedUnits: [.minute, .hour], style: .brief)

     // "3 hours, 2 minutes, 1 second remaining"
     duration.timeRemainingString(allowedUnits: .all, style: .full)
     ```

     - Parameters:
        - allowedUnits: The allowed units for formatting the time duration.
        - style: The formatting style.
        - maximumUnitCount: The maximum number of time units to include in the output string.
        - zeroFormattingBehavior: The formatting style for units whose value is `0`.
        - includesApproximationPhrase: A Boolean value indicating whether output strings reflect the amount of time remaining.
        - locale: The language of the string.

     - Returns: A string representation of the time duration.
     */
    public func timeRemainingString(allowedUnits: ComponentsFormatStyle.Units = .default, style: ComponentsFormatStyle.UnitsStyle = .full, maximumUnitCount: Int = 0, zeroFormattingBehavior: ComponentsFormatStyle.ZeroFormattingBehavior = .default, includesApproximationPhrase: Bool = false, locale: Locale = .current) -> String {
        string(for: allowedUnits, maximumUnitCount: maximumUnitCount, includesTimeRemainingPhrase: true, includesApproximationPhrase: includesApproximationPhrase, unitsStyle: style, zeroFormattingBehavior: zeroFormattingBehavior, locale: locale)
    }

    private func string(for allowedUnits: ComponentsFormatStyle.Units = [], maximumUnitCount: Int = 0, includesTimeRemainingPhrase: Bool = false, includesApproximationPhrase: Bool = false, unitsStyle: ComponentsFormatStyle.UnitsStyle = .positional, zeroFormattingBehavior: ComponentsFormatStyle.ZeroFormattingBehavior = .default, allowsFractionalUnits: Bool = false, collapsesLargestUnit: Bool = false, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: ComponentsFormatStyle.CapitalizationContext = .unknown) -> String {
        ComponentsFormatStyle(allowedUnits: allowedUnits, unitsStyle: unitsStyle, maximumUnitCount: maximumUnitCount, zeroFormattingBehavior: zeroFormattingBehavior, allowsFractionalUnits: allowsFractionalUnits, collapsesLargestUnit: collapsesLargestUnit, includesTimeRemainingPhrase: includesTimeRemainingPhrase, includesApproximationPhrase: includesApproximationPhrase, locale: locale, calendar: calendar, capitalizationContext: capitalizationContext).format(self)
    }

    /**
     Returns a string representation of the time duration using the specified allowed time units and style.

     Example usage:

     ```swift
     let duration = TimeDuration.days(-1)

     // "1 day ago"
     duration.relativeString()

     // "yesterday"
     duration.relativeString(presentation: .named)
     ```

     - Parameters:
        - presentation: The style to use when describing a relative date, such as “1 day ago” or “yesterday”.
        - unitsStyle: The style to use when formatting the quantity or the name of the unit, such as “1 day ago” or “one day ago”.
        - locale:  The locale to use when formatting the relative date.
        - calendar: The calendar to use when formatting the relative date.
        - capitalizationContext: The capitalization context to use when formatting the relative date.

     - Returns: A string representation of the time duration.
     */
    public func relativeString(presentation: RelativeFormatStyle.Presentation = .numeric, unitsStyle: RelativeFormatStyle.UnitsStyle = .full, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: RelativeFormatStyle.CapitalizationContext = .unknown) -> String {
        RelativeFormatStyle(presentation: presentation, unitsStyle: unitsStyle, locale: locale, calendar: calendar, capitalizationContext: capitalizationContext).format(self)
    }

    /**
     Returns a formatted timecode string representation of the duration.

     - Parameters:
        - format: The formatting style describing which units should be included in the resulting timecode.
       - signDisplay: The formatting style controlling whether a sign should be displayed.
       - subsecondsPrecision: The number of digits to display after the fractional separator. Specify `0` to omit fractional seconds.
       - separator: The string used to separate hours, minutes, and seconds.
       - subsecondSeparator: The string used to separate seconds and fractional seconds.
        - padsFirstUnit: A Boolean value indicating whether the first displayed time unit is padded to at least two digits.
     - Returns: A formatted timecode string representation of the duration.

     Example usage:

     ```
     var duration = TimeDuration.seconds(13832)
     duration.formattedTimecode()
     // "3:50:32"
     duration.formattedTimecode(format: .full)
     // "03:50:32"
     duration.formattedTimecode(format: .minutesSeconds)
     // "230:32"
     duration.formattedTimecode(subsecondsPrecision: 2)
     // "3:50:32.44"

     duration = TimeDuration.seconds(-90)
     duration.formattedTimecode()
     // "-1:30"

     duration = TimeDuration.seconds(90)
     duration.formattedTimecode(signDisplay: .always)
     // "+1:30"
     duration.formattedTimecode(signDisplay: .always)
     // "+1:30"

     duration = TimeDuration.seconds(59.125)
     duration.formattedTimecode(subsecondsPrecision: 3, separator: ":", subsecondSeparator: ",")
     // "59,125"
     ```
     */
    public func timecodeString(style: TimecodeFormatStyle.Style = .compact, signDisplay: TimecodeFormatStyle.SignDisplay = .automatic, subsecondsPrecision: Int = 0, separator: String = ":", subsecondSeparator: String = ".", padsFirstUnit: Bool = false) -> String {
        TimecodeFormatStyle(style: style, signDisplay: signDisplay, subsecondsPrecision: subsecondsPrecision, separator: separator, subsecondSeparator: subsecondSeparator, padsFirstUnit: padsFirstUnit).format(self)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension TimeDuration: DurationProtocol {}

extension TimeDuration: Comparable, AdditiveArithmetic {
    /// Returns the time duration with its additive inverse.
    public static prefix func - (lhs: Self) -> Self {
        var value = lhs
        value.seconds = -value.seconds
        return value
    }

    /// Replaces this value with its additive inverse.
    public mutating func negate() {
        self = -self
    }

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

    /// Returns the time duration multiplied by the specified value.
    public static func * <V: BinaryInteger>(lhs: Self, rhs: V) -> Self {
        Self(lhs.seconds * Double(rhs))
    }

    /// Returns the time duration multiplied by the specified value.
    public static func * <V: BinaryInteger>(lhs: V, rhs: Self) -> Self {
        Self(rhs.seconds * Double(lhs))
    }

    /// Multiplies the time duration by the specified value.
    public static func *= <V: BinaryInteger>(lhs: inout Self, rhs: V) {
        lhs.seconds *= Double(rhs)
    }

    /// Returns the time duration multiplied by the specified value.
    public static func * <V: BinaryFloatingPoint>(lhs: Self, rhs: V) -> Self {
        Self(lhs.seconds * Double(rhs))
    }

    /// Returns the time duration multiplied by the specified value.
    public static func * <V: BinaryFloatingPoint>(lhs: V, rhs: Self) -> Self {
        Self(rhs.seconds * Double(lhs))
    }

    /// Multiplies the time duration by the specified value.
    public static func *= <V: BinaryFloatingPoint>(lhs: inout Self, rhs: V) {
        lhs.seconds *= Double(rhs)
    }

    /// Returns the time duration divided by the specified value.
    public static func / <V: BinaryInteger>(lhs: Self, rhs: V) -> Self {
        Self(lhs.seconds / Double(rhs))
    }

    /// Divides the time duration by the specified value.
    public static func /= <V: BinaryInteger>(lhs: inout Self, rhs: V) {
        lhs.seconds /= Double(rhs)
    }

    /// Returns the time duration divided by the specified value.
    public static func / <V: BinaryFloatingPoint>(lhs: Self, rhs: V) -> Self {
        Self(lhs.seconds / Double(rhs))
    }

    /// Divides the time duration by the specified value.
    public static func /= <V: BinaryFloatingPoint>(lhs: inout Self, rhs: V) {
        lhs.seconds /= Double(rhs)
    }

    /// Returns the ratio of the two time durations.
    public static func / (lhs: Self, rhs: Self) -> Double {
        lhs.seconds / rhs.seconds
    }
}

public extension DispatchTime {
    @_disfavoredOverload
    static func + (lhs: Self, rhs: TimeDuration) -> Self {
        lhs + rhs.seconds
    }

    @_disfavoredOverload
    static func - (lhs: Self, rhs: TimeDuration) -> Self {
        lhs - rhs.seconds
    }
}

public extension Collection where Element == TimeDuration {
    /**
     The average duration of all durations in the collection.

     - Returns: A `TimeDuration` instance representing the average duration. If the collection is empty, it returns `zerp`.
     */
    func average() -> TimeDuration {
        TimeDuration(map { $0.seconds }.average())
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
        __TimeDuration(seconds: seconds)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __TimeDuration, result: inout Self?) {
        result = TimeDuration(source.seconds)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __TimeDuration, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __TimeDuration?) -> Self {
        if let source = source {
            var result: TimeDuration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return .zero
    }
}

/// The Objective-C type for `TimeDuration`.
public class __TimeDuration: NSObject, NSCopying, NSCoding {
    let seconds: Double

    init(seconds: Double) {
        self.seconds = seconds
    }

    public func encode(with coder: NSCoder) {
        coder.encode(seconds, forKey: "seconds")
    }

    public required init?(coder: NSCoder) {
        seconds = coder.decode("seconds") ?? .zero
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || seconds == other.seconds
    }

    override public var hash: Int {
        Hasher.hash(seconds)
    }
}

public extension TimeDuration {
    /// Formats the time duration using ``ComponentsFormatStyle``.
    func formatted() -> String {
        formatted(.components())
    }

    /// Formats the time duration value with the specified format.
    func formatted<F: FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == TimeDuration {
        style.format(self)
    }

    /// Formats the time duration value with the specified format.
    func formatted(_ style: TimeDuration.RelativeFormatStyle) -> String {
        style.format(self)
    }

    /// Formats the time duration value with the specified format.
    func formatted(_ style: TimeDuration.ComponentsFormatStyle) -> String {
        style.format(self)
    }

    /// Formats the time duration value with the specified format.
    func formatted(_ style: TimeDuration.TimecodeFormatStyle) -> String {
        style.format(self)
    }
}

public extension TimeDuration {
    /// A format style that forms locale-aware string representations of a relative time.
    struct RelativeFormatStyle: FormatStyle {
        /**
         The style to use when describing a relative date, for example `“yesterday”` or `“1 day ago”`.

         The default value is ``Presentation/numeric``.
         */
        public var presentation: Presentation
        /**
         The style to use when formatting the quantity or the name of the unit, such as `“1 day ago”` or `“one day ago”`.

         The default value is ``UnitsStyle/full``.
         */
        public var unitsStyle: UnitsStyle

        /**
         The locale to use when formatting the relative date.

         To change the format style’s locale, use ``locale(_:)``.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nslocale/autoupdatingcurrent).
         */
        public var locale: Locale

        /**
         The calendar to use when formatting relative dates.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nscalendar/autoupdatingcurrent).
         */
        public var calendar: Calendar

        /**
         The capitalization context to use when formatting the relative dates.

         Setting the capitalization context to ``CapitalizationContext/beginningOfSentence`` sets the first word of the relative date string to upper-case. A capitalization context set to ``CapitalizationContext/middleOfSentence`` keeps all words in the string lower-cased.

         The default value is ``CapitalizationContext/unknown``.
         */
        public var capitalizationContext: CapitalizationContext

        /// An attributed format style based on the relative time duration format style.
        public var attributed: Attributed {
            .init(style: self)
        }

        public func locale(_ locale: Locale) -> Self {
            var copy = self
            copy.locale = locale
            return copy
        }

        /// The capitalization formatting context used when formatting dates and times.
        public enum CapitalizationContext: Int, Hashable, Codable, CustomStringConvertible {
            /// An unknown formatting context.
            case unknown
            ///  A formatting context determined automatically at runtime.
            case dynamic
            /// The formatting context for stand-alone usage.
            case standalone
            /// The formatting context for a list or menu item.
            case listItem
            /// The formatting context for the beginning of a sentence.
            case beginningOfSentence
            ///  The formatting context for the middle of a sentence.
            case middleOfSentence

            public var description: String {
                switch self {
                case .unknown: "unknown"
                case .dynamic: "unknown"
                case .standalone: "standalone"
                case .listItem: "listItem"
                case .beginningOfSentence: "beginningOfSentence"
                case .middleOfSentence: "middleOfSentence"
                }
            }
        }

        /// A type that represents the style to use when formatting relative dates, such as “1 week ago” or “last week”.
        public enum Presentation: Int, Codable, Hashable, CustomStringConvertible {
            /// A style that uses named styles to describe relative dates, such as “yesterday”, “last week”, or “next week”.
            case named = 1
            /// A style that uses a numeric style to describe relative dates, such as “1 day ago” or “in 3 weeks”.
            case numeric = 0

            public var description: String {
                self == .named ? "named" : "numeric"
            }
        }

        /// A type that represents the style to use when formatting the units of relative dates.
        public enum UnitsStyle: Int, Codable, Hashable, CustomStringConvertible {
            /// A style that uses abbreviated units, such as “2 mo. ago”.
            case abbreviated = 3
            /// A style that uses full units, such as “2 months ago”.
            case full = 0
            /// A style that uses shortened units, such as “2 mo. ago”.
            case short = 2
            /// A style that spells out units such as “two months ago”.
            case spellOut = 1

            public var description: String {
                switch self {
                case .abbreviated: "abbreviated"
                case .full: "full"
                case .short: "short"
                case .spellOut: "spellOut"
                }
            }
        }

        /**
         Creates a relative date format style with the specified presentation, units, locale, calendar, and capitalization context.

         - Parameters:
            - presentation: The style to use when describing a relative date, such as “1 day ago” or “yesterday”.
            - unitsStyle: The style to use when formatting the quantity or the name of the unit, such as “1 day ago” or “one day ago”.
            - locale:  The locale to use when formatting the relative date.
            - calendar: The calendar to use when formatting the relative date.
            - capitalizationContext: The capitalization context to use when formatting the relative date.
         */
        public init(presentation: Presentation = .numeric, unitsStyle: UnitsStyle = .full, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: CapitalizationContext = .unknown) {
            self.presentation = presentation
            self.unitsStyle = unitsStyle
            self.locale = locale
            self.calendar = calendar
            self.capitalizationContext = capitalizationContext
        }

        /**
         Formats a time duration as a relative duration, using this style.

         Use this method when you want to create a single style instance, and then use it to format multiple values. To format a single time duration, use the ``TimeDuration/formatted(_:)`` instance method, passing in an instance of ``TimeDuration/RelativeFormatStyle``.

         - Parameter timeDuration: The time duration to format.
         - Returns: A formatted representation of `timeDuration`, formatted according to the style’s configuration.
         */
        public func format(_ timeDuration: TimeDuration) -> String {
            Self.formatterCache.withLock {
                $0[FormatterKey(presentation: presentation, unitsStyle: unitsStyle, locale: locale, calendar: calendar, capitalizationContext: capitalizationContext), default: {
                    let formatter = RelativeDateTimeFormatter()
                    formatter.dateTimeStyle = .init(rawValue: presentation.rawValue) ?? .numeric
                    formatter.unitsStyle = .init(rawValue: unitsStyle.rawValue) ?? .full
                    formatter.locale = locale
                    formatter.formattingContext = .init(rawValue: capitalizationContext.rawValue) ?? .unknown
                    formatter.calendar = calendar
                    return formatter
                }()].localizedString(fromTimeInterval: timeDuration.seconds)
            }
        }

        private struct FormatterKey: Hashable {
            let presentation: Presentation
            let unitsStyle: UnitsStyle
            let locale: Locale
            let calendar: Calendar
            let capitalizationContext: CapitalizationContext
        }

        private static let formatterCache = Mutex([FormatterKey: RelativeDateTimeFormatter]())
    }
}

public extension TimeDuration.RelativeFormatStyle {
    /// A format style that provides attributed string representations of ``TimeDuration`` values.
    struct Attributed: FormatStyle {
        /**
         The style to use when describing a relative date, for example `“yesterday”` or `“1 day ago”`.

         The default value is ``Presentation/numeric``.
         */
        public var presentation: Presentation {
            get { style.presentation }
            set { style.presentation = newValue }
        }

        /**
         The style to use when formatting the quantity or the name of the unit, such as `“1 day ago”` or `“one day ago”`.

         The default value is ``UnitsStyle/full``.
         */
        public var unitsStyle: UnitsStyle {
            get { style.unitsStyle }
            set { style.unitsStyle = newValue }
        }

        /**
         The locale to use when formatting the relative date.

         To change the format style’s locale, use ``locale(_:)``.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nslocale/autoupdatingcurrent).
         */
        public var locale: Locale {
            get { style.locale }
            set { style.locale = newValue }
        }

        /**
         The calendar to use when formatting relative dates.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nscalendar/autoupdatingcurrent).
         */
        public var calendar: Calendar {
            get { style.calendar }
            set { style.calendar = newValue }
        }

        /**
         The capitalization context to use when formatting the relative dates.

         Setting the capitalization context to ``CapitalizationContext/beginningOfSentence`` sets the first word of the relative date string to upper-case. A capitalization context set to ``CapitalizationContext/middleOfSentence`` keeps all words in the string lower-cased.

         The default value is ``CapitalizationContext/unknown``.
         */
        public var capitalizationContext: CapitalizationContext {
            get { style.capitalizationContext }
            set { style.capitalizationContext = newValue }
        }

        private var style: TimeDuration.RelativeFormatStyle

        init(style: TimeDuration.RelativeFormatStyle) {
            self.style = style
        }

        public func locale(_ locale: Locale) -> TimeDuration.RelativeFormatStyle.Attributed {
            .init(style: style.locale(locale))
        }

        /**
         Formats a time duration as an attributed relative duration, using this style.

         Use this method when you want to create a single style instance, and then use it to format multiple values. To format a single time duration, use the ``TimeDuration/formatted(_:)`` instance method, passing in an instance of ``TimeDuration/RelativeFormatStyle/Attributed``.

         - Parameter timeDuration: The time duration to format.
         - Returns: An attributed formatted representation of `timeDuration`, formatted according to the style’s configuration.
         */
        public func format(_ timeDuration: TimeDuration) -> AttributedString {
            AttributedString(style.format(timeDuration))
        }
    }
}

public extension FormatStyle where Self == TimeDuration.RelativeFormatStyle {
    /// Returns a format style for formatting a time duration as relative.
    static var relative: Self {
        relative()
    }

    /**
     Returns a format style for formatting a time duration as relative.

     - Parameters:
        - presentation: The style to use when describing a relative date, such as “1 day ago” or “yesterday”.
        - unitsStyle: The style to use when formatting the quantity or the name of the unit, such as “1 day ago” or “one day ago”.
        - calendar: The calendar to use when formatting the relative date.
        - capitalizationContext: The capitalization context to use when formatting the relative date.
     */
    static func relative(presentation: Self.Presentation = .numeric, unitsStyle: Self.UnitsStyle = .full, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: Self.CapitalizationContext = .unknown) -> TimeDuration.RelativeFormatStyle {
        TimeDuration.RelativeFormatStyle(presentation: presentation, unitsStyle: unitsStyle, calendar: calendar, capitalizationContext: capitalizationContext)
    }
}

public extension TimeDuration {
    struct ComponentsFormatStyle: FormatStyle {
        /**
         The calendrical components that the formatter is allowed to include in the output string.

         The default value is ``Units/default``.
         */
        public var allowedUnits: Units

        /**
         The maximum number of time units to include in the output string, or `nil` to include all units.

         Use this property to limit the number of units displayed in the resulting string. For example, with this property set to 2, instead of “1h 10m, 30s”, the resulting string would be “1h 10m”. Use this property when you are constrained for space or want to round up values to the nearest large unit.

         The default value of this property is `nil`.
         */
        public var maximumUnitCount: Int? {
            didSet {
                guard let clamped = maximumUnitCount?.clamped(min: 0) else { return }
                maximumUnitCount = clamped == 0 ? nil : clamped
            }
        }

        /**
         A Boolean value indicating whether output strings reflect the amount of time remaining.

         Setting this property to `true` results in output strings like `“30 minutes remaining”`.

         The default value of this property is `false`.
         */
        public var includesTimeRemainingPhrase: Bool
        /**
         A Boolean value indicating whether the resulting phrase reflects an inexact time value.

         Setting the value of this property to `true` adds phrasing to output strings to reflect that the given time value is approximate and not exact. Using this property yields more correct phrasing than simply prepending the string `“About”` to an output string.

         The default value of this property is `false`.
         */
        public var includesApproximationPhrase: Bool
        /**
         The formatting style for unit names.

         Configures the strings to use (if any) for unit names such as days, hours, minutes, and seconds. Use this property to specify whether you want abbreviated or shortened versions of unit names—for example, `hrs` instead of `hours`.

         The default value of this property is ``UnitsStyle/positional``
         */
        public var unitsStyle: UnitsStyle
        /**
         The formatting style for units whose value is `0`.

         When the value for a particular unit is `0`, the zero formatting behavior determines whether that value is retained or omitted from any resulting strings. For example, when the formatting behavior is ``ZeroFormattingBehavior/dropTrailing``, the value of one hour, ten minutes, and zero seconds would omit the mention of seconds.

         The default value of this property is ``ZeroFormattingBehavior/default``.
         */
        public var zeroFormattingBehavior: ZeroFormattingBehavior
        /**
         A Boolean indicating whether non-integer units may be used for values.

         Fractional units may be used when a value cannot be exactly represented using the available units. For example, if minutes are not allowed, the value `“1h 30m”` could be formatted as `“1.5h”`.

         The default value of this property is `false`.
         */
        public var allowsFractionalUnits: Bool
        /**
         The default calendar to use when formatting date components.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nscalendar/autoupdatingcurrent)
         */
        public var calendar: Calendar
        /**
         A Boolean value indicating whether to collapse the largest unit into smaller units when a certain threshold is met.

         An example of when this property might apply is when expressing 63 seconds worth of time. When this property is set to `true`, the formatted value would be `“63s”`. When the value of this property is `false`, the formatted value would be `“1m 3s”`.

         The default value of this property is `false`.
         */
        public var collapsesLargestUnit: Bool

        /**
         The capitalization context to use when formatting the dates.

         Setting the capitalization context to ``CapitalizationContext/beginningOfSentence`` sets the first word of the relative date string to upper-case. A capitalization context set to ``CapitalizationContext/middleOfSentence`` keeps all words in the string lower-cased.

         The default value is ``CapitalizationContext/unknown``.
         */
        public var capitalizationContext: CapitalizationContext

        /**
         The locale to use when formatting the date.

         To change the format style’s locale, use ``locale(_:)``.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nslocale/autoupdatingcurrent).
         */
        public var locale: Locale
        
        /**
         The date to use as the starting point when calculating components with variable lengths.

         Components such as months, days, and hours can have different lengths depending on the ``calendar`` and date. When this value is set, the format style calculates those components as though counting from this date in ``calendar``.

         The default value is `nil`, which uses the default behavior.
         */
        public var referenceDate: Date?

        /// An attributed format style based on the components time duration format style.
        public var attributed: Attributed {
            .init(style: self)
        }

        public func locale(_ locale: Locale) -> Self {
            var copy = self
            copy.locale = locale
            return copy
        }

        /**
         Formats a time duration as date components, using this style.

         Use this method when you want to create a single style instance, and then use it to format multiple values. To format a single time duration, use the ``TimeDuration/formatted(_:)`` instance method, passing in an instance of ``TimeDuration/ComponentsFormatStyle``.

         - Parameter timeDuration: The time duration to format.
         - Returns: A formatted representation of `timeDuration`, formatted according to the style’s configuration.
         */
        public func format(_ timeDuration: TimeDuration) -> String {
            let allowedUnits = allowedUnits.units(for: timeDuration)
            return Self.formatterCache.withLock {
                $0[.init(allowedUnits: allowedUnits, maximumUnitCount: maximumUnitCount ?? 0, includesTimeRemainingPhrase: includesTimeRemainingPhrase, includesApproximationPhrase: includesApproximationPhrase, allowsFractionalUnits: allowsFractionalUnits, zeroFormattingBehavior: zeroFormattingBehavior, collapsesLargestUnit: collapsesLargestUnit, unitsStyle: unitsStyle, locale: locale, calendar: calendar, capitalizationContext: capitalizationContext, referenceDate: referenceDate), default: {
                    let formatter = DateComponentsFormatter()
                    formatter.allowedComponents = .init(rawValue: allowedUnits.rawValue)
                    formatter.unitsStyle = .init(rawValue: unitsStyle.rawValue) ?? .positional
                    formatter.calendar = calendar
                    formatter.locale = locale
                    formatter.referenceDate = referenceDate
                    formatter.maximumUnitCount = maximumUnitCount ?? 0
                    formatter.collapsesLargestUnit = collapsesLargestUnit
                    formatter.allowsFractionalUnits = allowsFractionalUnits
                    formatter.formattingContext = .init(rawValue: capitalizationContext.rawValue) ?? .unknown
                    formatter.zeroFormattingBehavior = .init(rawValue: zeroFormattingBehavior.rawValue)
                    formatter.includesApproximationPhrase = includesApproximationPhrase
                    formatter.includesTimeRemainingPhrase = includesTimeRemainingPhrase
                    return formatter
                }()].string(from: timeDuration.seconds) ?? "\(timeDuration.seconds)"
            }
        }

        private struct FormatterKey: Hashable {
            let allowedUnits: Units
            let maximumUnitCount: Int
            let includesTimeRemainingPhrase: Bool
            let includesApproximationPhrase: Bool
            let allowsFractionalUnits: Bool
            let zeroFormattingBehavior: ZeroFormattingBehavior
            let collapsesLargestUnit: Bool
            let unitsStyle: UnitsStyle
            let locale: Locale
            let calendar: Calendar
            let capitalizationContext: CapitalizationContext
            let referenceDate: Date?
        }

        private static let formatterCache = Mutex([FormatterKey: DateComponentsFormatter]())

        /**
         Creates a components time duration format style with the specified values.

         - Parameters:
            - allowedUnits: The calendrical components that the formatter is allowed to include in the output string.
            - unitsStyle: The formatting style for unit names.
            - maximumUnitCount: The maximum number of time units to include in the output string, or `nil` to include all units.
            - zeroFormattingBehavior: The formatting style for units whose value is `0`.
            - allowsFractionalUnits: A Boolean indicating whether non-integer units may be used for values.
            - collapsesLargestUnit: A Boolean value indicating whether to collapse the largest unit into smaller units when a certain threshold is met.
            - includesTimeRemainingPhrase: A Boolean value indicating whether output strings reflect the amount of time remaining.
            - includesApproximationPhrase: A Boolean value indicating whether the resulting phrase reflects an inexact time value.
            - locale: The locale to use when formatting the date.
            - calendar: The default calendar to use when formatting date components.
            - capitalizationContext: The capitalization context to use when formatting the dates.
            - referenceDate: The date to use as the starting point when calculating components with variable lengths, or `nil`, to use the default behavior.
         */
        public init(allowedUnits: Units = .default, unitsStyle: UnitsStyle = .positional, maximumUnitCount: Int? = nil, zeroFormattingBehavior: ZeroFormattingBehavior = .default, allowsFractionalUnits: Bool = false, collapsesLargestUnit: Bool = false, includesTimeRemainingPhrase: Bool = false, includesApproximationPhrase: Bool = false, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: CapitalizationContext = .unknown, referenceDate: Date? = nil) {
            self.allowedUnits = allowedUnits
            self.unitsStyle = unitsStyle
            let maximumUnits = maximumUnitCount?.clamped(min: 0)
            self.maximumUnitCount = maximumUnits == 0 ? nil : maximumUnits
            self.zeroFormattingBehavior = zeroFormattingBehavior
            self.allowsFractionalUnits = allowsFractionalUnits
            self.collapsesLargestUnit = collapsesLargestUnit
            self.includesTimeRemainingPhrase = includesTimeRemainingPhrase
            self.includesApproximationPhrase = includesApproximationPhrase
            self.locale = locale
            self.calendar = calendar
            self.capitalizationContext = capitalizationContext
            self.referenceDate = referenceDate
        }

        /**
         Creates a components time duration format style for the specified calendrical unit.

         - Parameters:
            - fixedUnit: The calendrical unit to use when formatting the time duration.
            - unitsStyle: The formatting style for unit names.
            - allowsFractionalUnits: A Boolean indicating whether non-integer units may be used for values.
            - includesTimeRemainingPhrase: A Boolean value indicating whether output strings reflect the amount of time remaining.
            - includesApproximationPhrase: A Boolean value indicating whether the resulting phrase reflects an inexact time value.
            - locale: The locale to use when formatting the date.
            - calendar: The default calendar to use when formatting date components.
            - capitalizationContext: The capitalization context to use when formatting the dates.
            - referenceDate: The date to use as the starting point when calculating components with variable lengths, or `nil`, to use the default behavior.
         */
        public init(fixedUnit: Unit, unitsStyle: UnitsStyle = .positional, allowsFractionalUnits: Bool = false, includesTimeRemainingPhrase: Bool = false, includesApproximationPhrase: Bool = false, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: CapitalizationContext = .unknown, referenceDate: Date? = nil) {
            self.init(allowedUnits: .init(rawValue: fixedUnit.rawValue), unitsStyle: unitsStyle, allowsFractionalUnits: allowsFractionalUnits, includesTimeRemainingPhrase: includesTimeRemainingPhrase, includesApproximationPhrase: includesApproximationPhrase, locale: locale, calendar: calendar, capitalizationContext: capitalizationContext, referenceDate: referenceDate)
        }

        /// Formatting constants for when values contain zeroes.
        public struct ZeroFormattingBehavior: OptionSet, Codable, Hashable, CustomStringConvertible {
            /// The default formatting behavior. When using positional units, this behavior drops leading zeroes but pads middle and trailing values with zeros as needed. For example, with hours, minutes, and seconds displayed, the value for one hour and 10 seconds is “1:00:10”. For all other unit styles, this behavior drops all units whose values are 0. For example, when days, hours, minutes, and seconds are allowed, the abbreviated version of one hour and 10 seconds is displayed as “1h 10s”.
            public static let `default` = Self(rawValue: 1 << 0)
            /// The drop leading zeroes formatting behavior. Units whose values are 0 are dropped starting at the beginning of the sequence. Units continue to be dropped until a non-zero value is encountered. For example, when days, hours, minutes, and seconds are allowed, the abbreviated version of ten minutes is displayed as “10m 0s”.
            public static let dropLeading = Self(rawValue: 1 << 1)
            /// The drop middle zero units behavior. Units whose values are 0 are dropped from anywhere in the middle of a sequence. For example, when days, hours, minutes, and seconds are allowed, the abbreviated version of one hour, zero minutes, and five seconds is displayed as “0d 1h 5s”.
            public static let dropMiddle = Self(rawValue: 1 << 2)
            /// The drop trailing zero units behavior. Units whose value is 0 are dropped starting at the end of the sequence. For example, when days, hours, minutes, and seconds are allowed, the abbreviated version of one hour is displayed as “0d 1h”.
            public static let dropTrailing = Self(rawValue: 1 << 3)
            ///  The drop all zero units behavior. This behavior drops all units whose values are 0. For example, when days, hours, minutes, and seconds are allowed, the abbreviated version of one hour is displayed as “1h”.
            public static let dropAll = Self(rawValue: 14)
            /// The add padding zeroes behavior. This behavior pads values with zeroes as appropriate. For example, consider the value of one hour formatted using the positional and abbreviated unit styles. When days, hours, minutes, and seconds are allowed, the value is displayed as “0d 1:00:00” using the positional style, and as “0d 1h 0m 0s” using the abbreviated style.
            public static let pad = Self(rawValue: 65536)

            public var description: String {
                var strings: [String] = []
                if contains(.default) { strings += ".default" }
                if contains(.dropLeading) { strings += ".dropLeading" }
                if contains(.dropMiddle) { strings += ".dropMiddle" }
                if contains(.dropTrailing) { strings += ".dropTrailing" }
                if contains(.dropAll) { strings += ".dropAll" }
                if contains(.pad) { strings += ".pad" }
                if strings.count == 1 { return strings.first! }
                return "[\(strings.joined(separator: ", "))]"
            }

            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }

            public let rawValue: UInt
        }

        /// The calendrical unit to use when formatting a duration.
        public enum Unit: UInt, Hashable, Codable {
            /// The year component.
            case year = 4
            /// The month component.
            case month = 8
            /// The week component.
            case week = 4096
            /// The day component.
            case day = 16
            /// The hour component.
            case hour = 32
            /// The minute component.
            case minute = 64
            /// The second component.
            case second = 128
        }

        /// The calendrical units that can be used when formatting a duration.
        public struct Units: OptionSet, Codable, Hashable, CustomStringConvertible {
            /// A value that indicates the formatter should automatically select the appropriate components.
            public static let `default`: Self = []
            /// The year component.
            public static let year = Self(rawValue: 4)
            /// The month component.
            public static let month = Self(rawValue: 8)
            /// The week-of-month component.
            public static let week = Self(rawValue: 4096)
            /// The day component.
            public static let day = Self(rawValue: 16)
            /// The hour component.
            public static let hour = Self(rawValue: 32)
            /// The minute component.
            public static let minute = Self(rawValue: 64)
            /// The second component.
            public static let second = Self(rawValue: 128)

            /// A value that allows the use of all supported calendar components.
            public static let all: Self = [.year, .month, .day, .hour, .minute, .second, .week]
            /// A value that includes each unit whose value is nonzero, plus seconds.
            public static let nonZero = Self(rawValue: 1 << 24)
            /// A value that includes up to the three most significant nonzero units.
            public static let preferred = Self(rawValue: 1 << 25)
            /// A value that includes up to the two most significant nonzero units.
            public static let compact = Self(rawValue: 1 << 26)

            public var description: String {
                if self == .default { return ".default" }
                var strings: [String] = []
                if contains(.nonZero) { strings += ".nonZero" }
                if contains(.preferred) { strings += ".preferred" }
                if contains(.compact) { strings += ".compact" }
                if contains(.second) { strings += ".second" }
                if contains(.minute) { strings += ".minute" }
                if contains(.hour) { strings += ".hour" }
                if contains(.day) { strings += ".day" }
                if contains(.week) { strings += ".week" }
                if contains(.month) { strings += ".month" }
                if contains(.year) { strings += ".year" }
                if strings.count == 1 { return strings.first! }
                return "[\(strings.joined(separator: ", "))]"
            }

            public let rawValue: UInt

            /// Creates a units structure with the specified raw value.
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
         
            fileprivate func units(for duration: TimeDuration) -> Self {
                var units = self
                if contains(.nonZero) { units += .nonZero(for: duration) }
                if contains(.preferred) { units += .preferred(for: duration, compact: false) }
                if contains(.compact) { units += .preferred(for: duration, compact: true) }
                return units
            }
            
            private static func nonZero(for duration: TimeDuration) -> Self {
                var units: Self = .second
                if duration.years >= 1 { units.insert(.year) }
                if duration.months >= 1 { units.insert(.month) }
                if duration.weeks >= 1 { units.insert(.week) }
                if duration.days >= 1 { units.insert(.day) }
                if duration.hours >= 1 { units.insert(.hour) }
                if duration.minutes >= 1 { units.insert(.minute) }
                return units
            }
            
            private static func preferred(for duration: TimeDuration, compact: Bool) -> Self {
                let currentUnits = nonZero(for: duration)
                return Self([Self.year, .month, .week, .day, .hour, .minute, .second].filter { currentUnits.contains($0) }.prefix(compact ? 2 : 3))
            }
        }

        public enum UnitsStyle: Int, Hashable, Codable, CustomStringConvertible {
            /// A style that spells out the units and quantities of time.
            case spellOut = 4
            /// A style that spells out the units of time, but not the quantities.
            case full = 3
            /// A style that uses a shortened spelling for units.
            case short = 2
            /// style that uses a shortened spelling for units of time that is shorter than DateComponentsFormatter.UnitsStyle.short.
            case brief = 5
            /// A style that uses the most abbreviated spelling for units of time.
            case abbreviated = 1
            /// A style that uses the position of a unit of time to identify its value.
            case positional = 0

            public var description: String {
                switch self {
                case .spellOut: "spellOut"
                case .full: "full"
                case .short: "short"
                case .brief: "brief"
                case .abbreviated: "abbreviated"
                case .positional: "positional"
                }
            }
        }

        /// The capitalization formatting context used when formatting dates and times.
        public enum CapitalizationContext: Int, Hashable, Codable, CustomStringConvertible {
            /// An unknown formatting context.
            case unknown
            ///  A formatting context determined automatically at runtime.
            case dynamic
            /// The formatting context for stand-alone usage.
            case standalone
            /// The formatting context for a list or menu item.
            case listItem
            /// The formatting context for the beginning of a sentence.
            case beginningOfSentence
            ///  The formatting context for the middle of a sentence.
            case middleOfSentence

            public var description: String {
                switch self {
                case .unknown: "unknown"
                case .dynamic: "unknown"
                case .standalone: "standalone"
                case .listItem: "listItem"
                case .beginningOfSentence: "beginningOfSentence"
                case .middleOfSentence: "middleOfSentence"
                }
            }
        }
    }
}

public extension TimeDuration.ComponentsFormatStyle {
    /// A format style that provides attributed string representations of ``TimeDuration`` values.
    struct Attributed: FormatStyle {
        /**
         The calendrical components that the formatter is allowed to include in the output string.

         The default value is ``Units/default``.
         */
        public var allowedUnits: Units {
            get { style.allowedUnits }
            set { style.allowedUnits = newValue }
        }

        /**
         The maximum number of time units to include in the output string, or `nil` to include all units.

         Use this property to limit the number of units displayed in the resulting string. For example, with this property set to 2, instead of “1h 10m, 30s”, the resulting string would be “1h 10m”. Use this property when you are constrained for space or want to round up values to the nearest large unit.

         The default value of this property is `nil`.
         */
        public var maximumUnitCount: Int? {
            get { style.maximumUnitCount }
            set { style.maximumUnitCount = newValue }
        }

        /**
         A Boolean value indicating whether output strings reflect the amount of time remaining.

         Setting this property to `true` results in output strings like `“30 minutes remaining”`.

         The default value of this property is `false`.
         */
        public var includesTimeRemainingPhrase: Bool {
            get { style.includesTimeRemainingPhrase }
            set { style.includesTimeRemainingPhrase = newValue }
        }

        /**
         A Boolean value indicating whether the resulting phrase reflects an inexact time value.

         Setting the value of this property to `true` adds phrasing to output strings to reflect that the given time value is approximate and not exact. Using this property yields more correct phrasing than simply prepending the string `“About”` to an output string.

         The default value of this property is `false`.
         */
        public var includesApproximationPhrase: Bool {
            get { style.includesApproximationPhrase }
            set { style.includesApproximationPhrase = newValue }
        }

        /**
         The formatting style for unit names.

         Configures the strings to use (if any) for unit names such as days, hours, minutes, and seconds. Use this property to specify whether you want abbreviated or shortened versions of unit names—for example, `hrs` instead of `hours`.

         The default value of this property is ``UnitsStyle/positional``
         */
        public var unitsStyle: UnitsStyle {
            get { style.unitsStyle }
            set { style.unitsStyle = newValue }
        }

        /**
         The formatting style for units whose value is `0`.

         When the value for a particular unit is `0`, the zero formatting behavior determines whether that value is retained or omitted from any resulting strings. For example, when the formatting behavior is ``ZeroFormattingBehavior/dropTrailing``, the value of one hour, ten minutes, and zero seconds would omit the mention of seconds.

         The default value of this property is ``ZeroFormattingBehavior/default``.
         */
        public var zeroFormattingBehavior: ZeroFormattingBehavior {
            get { style.zeroFormattingBehavior }
            set { style.zeroFormattingBehavior = newValue }
        }

        /**
         A Boolean indicating whether non-integer units may be used for values.

         Fractional units may be used when a value cannot be exactly represented using the available units. For example, if minutes are not allowed, the value `“1h 30m”` could be formatted as `“1.5h”`.

         The default value of this property is `false`.
         */
        public var allowsFractionalUnits: Bool {
            get { style.allowsFractionalUnits }
            set { style.allowsFractionalUnits = newValue }
        }

        /**
         The default calendar to use when formatting date components.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nscalendar/autoupdatingcurrent)
         */
        public var calendar: Calendar {
            get { style.calendar }
            set { style.calendar = newValue }
        }

        /**
         A Boolean value indicating whether to collapse the largest unit into smaller units when a certain threshold is met.

         An example of when this property might apply is when expressing 63 seconds worth of time. When this property is set to `true`, the formatted value would be `“63s”`. When the value of this property is `false`, the formatted value would be `“1m 3s”`.

         The default value of this property is `false`.
         */
        public var collapsesLargestUnit: Bool {
            get { style.collapsesLargestUnit }
            set { style.collapsesLargestUnit = newValue }
        }

        /**
         The capitalization context to use when formatting the dates.

         Setting the capitalization context to ``CapitalizationContext/beginningOfSentence`` sets the first word of the relative date string to upper-case. A capitalization context set to ``CapitalizationContext/middleOfSentence`` keeps all words in the string lower-cased.

         The default value is ``CapitalizationContext/unknown``.
         */
        public var capitalizationContext: CapitalizationContext {
            get { style.capitalizationContext }
            set { style.capitalizationContext = newValue }
        }

        /**
         The locale to use when formatting the date.

         To change the format style’s locale, use ``locale(_:)``.

         The default value is [autoupdatingCurrent](https://developer.apple.com/documentation/foundation/nslocale/autoupdatingcurrent).
         */
        public var locale: Locale {
            get { style.locale }
            set { style.locale = newValue }
        }
        
        /**
         The date to use as the starting point when calculating components with variable lengths.

         Components such as months, days, and hours can have different lengths depending on the ``calendar`` and date. When this value is set, the format style calculates those components as though counting from this date in ``calendar``.

         The default value is `nil`, which uses the default behavior.
         */
        public var referenceDate: Date? {
            get { style.referenceDate }
            set { style.referenceDate = newValue }
        }

        public func locale(_ locale: Locale) -> Self {
            .init(style: style.locale(locale))
        }

        /**
         Formats a time duration as attributed date components, using this style.

         Use this method when you want to create a single style instance, and then use it to format multiple values. To format a single time duration, use the ``TimeDuration/formatted(_:)`` instance method, passing in an instance of ``TimeDuration/ComponentsFormatStyle/Attributed``.

         - Parameter timeDuration: The time duration to format.
         - Returns: An attributed formatted representation of `timeDuration`, formatted according to the style’s configuration.
         */
        public func format(_ timeDuration: TimeDuration) -> AttributedString {
            AttributedString(style.format(timeDuration))
        }

        private var style: TimeDuration.ComponentsFormatStyle

        init(style: TimeDuration.ComponentsFormatStyle) {
            self.style = style
        }
    }
}

public extension FormatStyle where Self == TimeDuration.ComponentsFormatStyle {
    /// Returns a format style for formatting a time duration as time remaining.
    static var components: Self {
        components()
    }

    /**
     Returns a format style for formatting a time duration.

     - Parameters:
        - allowedUnits: The calendrical components that the formatter is allowed to include in the output string.
        - unitsStyle: The formatting style for unit names.
        - maximumUnitCount: The maximum number of time units to include in the output string, or `nil` to include all units.
        - zeroFormattingBehavior: The formatting style for units whose value is `0`.
        - allowsFractionalUnits: A Boolean indicating whether non-integer units may be used for values.
        - collapsesLargestUnit: A Boolean value indicating whether to collapse the largest unit into smaller units when a certain threshold is met.
        - includesApproximationPhrase: A Boolean value indicating whether the resulting phrase reflects an inexact time value.
        - calendar: The default calendar to use when formatting date components.
        - capitalizationContext: The capitalization context to use when formatting the dates.
        - referenceDate: The date to use as the starting point when calculating components with variable lengths, or `nil`, to use the default behavior.
     */
    static func components(allowedUnits: Self.Units = .default, unitsStyle: Self.UnitsStyle = .positional, maximumUnitCount: Int? = nil, zeroFormattingBehavior: Self.ZeroFormattingBehavior = .default, allowsFractionalUnits: Bool = false, collapsesLargestUnit: Bool = false, includesApproximationPhrase: Bool = false, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: Self.CapitalizationContext = .unknown, referenceDate: Date? = nil) -> Self {
        TimeDuration.ComponentsFormatStyle(allowedUnits: allowedUnits, unitsStyle: unitsStyle, maximumUnitCount: maximumUnitCount, zeroFormattingBehavior: zeroFormattingBehavior, allowsFractionalUnits: allowsFractionalUnits, collapsesLargestUnit: collapsesLargestUnit, includesApproximationPhrase: includesApproximationPhrase, calendar: calendar, capitalizationContext: capitalizationContext, referenceDate: referenceDate)
    }

    /**
     Returns a format style for formatting a time duration.

     - Parameters:
        - fixedUnit: The calendrical unit to use when formatting the time duration.
        - unitsStyle: The formatting style for unit names.
        - allowsFractionalUnits: A Boolean indicating whether non-integer units may be used for values.
        - includesApproximationPhrase: A Boolean value indicating whether the resulting phrase reflects an inexact time value.
        - calendar: The default calendar to use when formatting date components.
        - capitalizationContext: The capitalization context to use when formatting the dates.
        - referenceDate: The date to use as the starting point when calculating components with variable lengths, or `nil`, to use the default behavior.
     */
    static func components(fixedUnit: Self.Unit, unitsStyle: Self.UnitsStyle = .positional, allowsFractionalUnits: Bool = false, includesApproximationPhrase: Bool = false, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: Self.CapitalizationContext = .unknown, referenceDate: Date? = nil) -> Self {
        TimeDuration.ComponentsFormatStyle(fixedUnit: fixedUnit, unitsStyle: unitsStyle, allowsFractionalUnits: allowsFractionalUnits, includesApproximationPhrase: includesApproximationPhrase, calendar: calendar, capitalizationContext: capitalizationContext, referenceDate: referenceDate)
    }

    /// Returns a format style for formatting a time duration as time remaining.
    static var timeRemaining: Self {
        timeRemaining()
    }

    /**
     Returns a format style for formatting a time duration as time remaining.

     - Parameters:
        - allowedUnits: The calendrical components that the formatter is allowed to include in the output string.
        - unitsStyle: The formatting style for unit names.
        - maximumUnitCount: The maximum number of time units to include in the output string, or `nil` to include all units.
        - zeroFormattingBehavior: The formatting style for units whose value is `0`.
        - allowsFractionalUnits: A Boolean indicating whether non-integer units may be used for values.
        - collapsesLargestUnit: A Boolean value indicating whether to collapse the largest unit into smaller units when a certain threshold is met.
        - includesApproximationPhrase: A Boolean value indicating whether the resulting phrase reflects an inexact time value.
        - calendar: The default calendar to use when formatting date components.
        - capitalizationContext: The capitalization context to use when formatting the dates.
        - referenceDate: The date to use as the starting point when calculating components with variable lengths, or `nil`, to use the default behavior.
     */
    static func timeRemaining(allowedUnits: Self.Units = .default, unitsStyle: Self.UnitsStyle = .positional, maximumUnitCount: Int? = nil, zeroFormattingBehavior: Self.ZeroFormattingBehavior = .default, allowsFractionalUnits: Bool = false, collapsesLargestUnit: Bool = false, includesApproximationPhrase: Bool = false, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: Self.CapitalizationContext = .unknown, referenceDate: Date? = nil) -> Self {
        TimeDuration.ComponentsFormatStyle(allowedUnits: allowedUnits, unitsStyle: unitsStyle, maximumUnitCount: maximumUnitCount, zeroFormattingBehavior: zeroFormattingBehavior, allowsFractionalUnits: allowsFractionalUnits, collapsesLargestUnit: collapsesLargestUnit, includesTimeRemainingPhrase: true, includesApproximationPhrase: includesApproximationPhrase, calendar: calendar, capitalizationContext: capitalizationContext, referenceDate: referenceDate)
    }

    /**
     Returns a format style for formatting a time duration as time remaining.

     - Parameters:
        - fixedUnit: The calendrical unit to use when formatting the time duration.
        - unitsStyle: The formatting style for unit names.
        - allowsFractionalUnits: A Boolean indicating whether non-integer units may be used for values.
        - includesApproximationPhrase: A Boolean value indicating whether the resulting phrase reflects an inexact time value.
        - calendar: The default calendar to use when formatting date components.
        - capitalizationContext: The capitalization context to use when formatting the dates.
        - referenceDate: The date to use as the starting point when calculating components with variable lengths, or `nil`, to use the default behavior.
     */
    static func timeRemaining(fixedUnit: Self.Unit, unitsStyle: Self.UnitsStyle = .positional, allowsFractionalUnits: Bool = false, includesApproximationPhrase: Bool = false, calendar: Calendar = .autoupdatingCurrent, capitalizationContext: Self.CapitalizationContext = .unknown, referenceDate: Date? = nil) -> Self {
        TimeDuration.ComponentsFormatStyle(fixedUnit: fixedUnit, unitsStyle: unitsStyle, allowsFractionalUnits: allowsFractionalUnits, includesTimeRemainingPhrase: true, includesApproximationPhrase: includesApproximationPhrase, calendar: calendar, capitalizationContext: capitalizationContext, referenceDate: referenceDate)
    }
}

public extension TimeDuration {
    /// A format style that represents a time duration as a timecode string.
    struct TimecodeFormatStyle: FormatStyle {
        /**
         The formatting style describing which units should be included in the resulting timecode.

         The default value is ``Style/compact``.
         */
        public var style: Style
        /**
         The formatting style controlling whether a sign should be displayed.

         The default value is ``SignDisplay/automatic``.
         */
        public var signDisplay: SignDisplay
        /**
         The number of digits to display after the fractional separator.

         The default value is `0`.
         */
        public var subsecondsPrecision: Int
        /**
         The string used to separate hours, minutes, and seconds.

         The default value is `":"`.
         */
        public var separator: String
        /**
         The string used to separate seconds and fractional seconds.

         The default value is `"."`.
         */
        public var subsecondSeparator: String
        /**
         A Boolean value indicating whether the first displayed time unit is padded to at least two digits.

         The default value is `false`.
         */
        public var padsFirstUnit: Bool
        /// An attributed format style based on the timecode time duration format style.
        public var attributed: Attributed {
            .init(style: self)
        }

        /// A formatting style describing which time components should be included in a timecode string.
        public enum Style: Int, Hashable, Codable {
            /// Displays hours, minutes, and seconds (e.g. `3:23:45`).
            case hoursMinutesSeconds
            /// Displays minutes and seconds, allowing minutes to exceed `59` (e.g. `23:45` or `235:45`).
            case minutesSeconds
            /// Displays only the total seconds (e.g. `31` or `23545`).
            case seconds
            /// Always displays hours, minutes, and seconds using at least two digits for the hours component (e.g. `01:23:45`).
            case full
            /// Always displays hours, minutes, and seconds while omitting leading zeros from the hours component (e.g. `1:23:45`).
            case fullCompact
            /// Displays minutes and seconds, automatically including hours when needed (e.g. `23:45` or `4:33:10`).
            case compact
            /// Displays only the necessary units (e.g. `44`, `23:45`, or `4:33:10`).
            case short
        }

        /// A formatting style describing how the sign of a timecode should be displayed.
        public enum SignDisplay: Hashable, Codable {
            /// Displays the sign only for negative durations.
            case automatic
            /// Always displays either a positive (`+`) or negative (`-`) sign.
            case always
            /// Never displays a sign.
            case never
        }

        /**
         Creates a timecode format style with the specified values.

         - Parameters:
            - style: The formatting style describing which units should be included in the resulting timecode.
            - signDisplay: The formatting style controlling whether a sign should be displayed.
            - subsecondsPrecision: The number of digits to display after the fractional separator. Specify `0` to omit fractional seconds.
            - separator: The string used to separate hours, minutes, and seconds.
            - subsecondSeparator: The string used to separate seconds and fractional seconds.
            - padsFirstUnit: A Boolean value indicating whether the first displayed time unit is padded to at least two digits.
         */
        public init(style: Style = .compact, signDisplay: SignDisplay = .automatic, subsecondsPrecision: Int = 0, separator: String = ":", subsecondSeparator: String = ".", padsFirstUnit: Bool = false) {
            self.style = style
            self.signDisplay = signDisplay
            self.subsecondsPrecision = subsecondsPrecision
            self.separator = separator
            self.subsecondSeparator = subsecondSeparator
            self.padsFirstUnit = padsFirstUnit
        }

        /**
         Formats a time duration as a timecode string, using this style.

         Use this method when you want to create a single style instance, and then use it to format multiple values. To format a single time duration, use the ``TimeDuration/formatted(_:)`` instance method, passing in an instance of ``TimeDuration/TimecodeFormatStyle``.

         - Parameter timeDuration: The time duration to format.
         - Returns: A formatted representation of `timeDuration`, formatted according to the style’s configuration.
         */
        public func format(_ timeDuration: TimeDuration) -> String {
            let precision = max(0, subsecondsPrecision)
            let scale = Int(pow(10.0, Double(precision)))

            let isNegative = timeDuration.seconds < 0
            let roundedUnits = Int((abs(timeDuration.seconds) * Double(scale)).rounded())

            let wholeSeconds = roundedUnits / scale
            let fractionalUnits = roundedUnits % scale

            let hours = wholeSeconds / 3600
            let minutes = (wholeSeconds / 60) % 60
            let secs = wholeSeconds % 60

            let sign: String = switch signDisplay {
            case .automatic: isNegative ? "-" : ""
            case .always: isNegative ? "-" : "+"
            case .never: ""
            }

            func padded(_ value: Int, width: Int = 2) -> String {
                String(format: "%0\(width)d", value)
            }

            func firstUnit(_ value: Int) -> String {
                padsFirstUnit ? padded(value) : "\(value)"
            }

            let body: String

            switch style {
            case .hoursMinutesSeconds:
                body = "\(firstUnit(hours))\(separator)\(padded(minutes))\(separator)\(padded(secs))"

            case .minutesSeconds:
                body = "\(firstUnit(wholeSeconds / 60))\(separator)\(padded(secs))"

            case .seconds:
                body = firstUnit(wholeSeconds)

            case .full:
                body = "\(padded(hours))\(separator)\(padded(minutes))\(separator)\(padded(secs))"

            case .fullCompact:
                body = "\(firstUnit(hours))\(separator)\(padded(minutes))\(separator)\(padded(secs))"

            case .compact:
                body = hours > 0
                    ? "\(hours)\(separator)\(padded(minutes))\(separator)\(padded(secs))"
                    : "\(firstUnit(wholeSeconds / 60))\(separator)\(padded(secs))"

            case .short:
                if hours > 0 {
                    body = "\(hours)\(separator)\(padded(minutes))\(separator)\(padded(secs))"
                } else if wholeSeconds >= 60 {
                    body = "\(firstUnit(wholeSeconds / 60))\(separator)\(padded(secs))"
                } else {
                    body = firstUnit(wholeSeconds)
                }
            }

            if precision > 0 {
                return sign + body + subsecondSeparator + padded(fractionalUnits, width: precision)
            }

            return sign + body
        }
    }
}

public extension TimeDuration.TimecodeFormatStyle {
    /// A format style that provides attributed string representations of ``TimeDuration`` values.
    struct Attributed: FormatStyle {
        /**
         The formatting style describing which units should be included in the resulting timecode.

         The default value is ``Style/compact``.
         */
        public var style: Style {
            get { formatStyle.style }
            set { formatStyle.style = newValue }
        }

        /**
         The formatting style controlling whether a sign should be displayed.

         The default value is ``SignDisplay/automatic``.
         */
        public var signDisplay: SignDisplay {
            get { formatStyle.signDisplay }
            set { formatStyle.signDisplay = newValue }
        }

        /**
         The number of digits to display after the fractional separator.

         The default value is `0`.
         */
        public var subsecondsPrecision: Int {
            get { formatStyle.subsecondsPrecision }
            set { formatStyle.subsecondsPrecision = newValue }
        }

        /**
         The string used to separate hours, minutes, and seconds.

         The default value is `":"`.
         */
        public var separator: String {
            get { formatStyle.separator }
            set { formatStyle.separator = newValue }
        }

        /**
         The string used to separate seconds and fractional seconds.

         The default value is `"."`.
         */
        public var subsecondSeparator: String {
            get { formatStyle.subsecondSeparator }
            set { formatStyle.subsecondSeparator = newValue }
        }

        /**
         A Boolean value indicating whether the first displayed time unit is padded to at least two digits.

         The default value is `false`.
         */
        public var padsFirstUnit: Bool {
            get { formatStyle.padsFirstUnit }
            set { formatStyle.padsFirstUnit = newValue }
        }

        private var formatStyle: TimeDuration.TimecodeFormatStyle

        init(style: TimeDuration.TimecodeFormatStyle) {
            self.formatStyle = style
        }

        /**
         Formats a time duration as an attributed timecode string, using this style.

         Use this method when you want to create a single style instance, and then use it to format multiple values. To format a single time duration, use the ``TimeDuration/formatted(_:)`` instance method, passing in an instance of ``TimeDuration/TimecodeFormatStyle/Attributed``.

         - Parameter timeDuration: The time duration to format.
         - Returns: An attributed formatted representation of `timeDuration`, formatted according to the style’s configuration.
         */
        public func format(_ timeDuration: TimeDuration) -> AttributedString {
            AttributedString(formatStyle.format(timeDuration))
        }
    }
}

public extension FormatStyle where Self == TimeDuration.TimecodeFormatStyle {
    /// Returns a format style for formatting a time duration as a timecode string.
    static var timecode: Self {
        timecode()
    }

    /**
     Returns a format style for formatting a time duration as a timecode string.

     - Parameters:
        - style: The formatting style describing which units should be included in the resulting timecode.
        - signDisplay: The formatting style controlling whether a sign should be displayed.
        - subsecondsPrecision: The number of digits to display after the fractional separator. Specify `0` to omit fractional seconds.
        - separator: The string used to separate hours, minutes, and seconds.
        - subsecondSeparator: The string used to separate seconds and fractional seconds.
        - padsFirstUnit: A Boolean value indicating whether the first displayed time unit is padded to at least two digits.
     */
    static func timecode(style: Self.Style = .compact, signDisplay: Self.SignDisplay = .automatic, subsecondsPrecision: Int = 0, separator: String = ":", subsecondSeparator: String = ".", padsFirstUnit: Bool = false) -> Self {
        Self(style: style, signDisplay: signDisplay, subsecondsPrecision: subsecondsPrecision, separator: separator, subsecondSeparator: subsecondSeparator, padsFirstUnit: padsFirstUnit)
    }
}
