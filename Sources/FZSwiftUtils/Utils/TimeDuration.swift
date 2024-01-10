//
//  TimeDuration.swift
//
//
//  Created by Florian Zand on 10.03.23.
//

import AVKit
import Foundation

/// A structure representing a time duration.
public struct TimeDuration: Hashable, Sendable {
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
        let interval = date.timeIntervalSince(another)
        seconds = (interval >= 0.0) ? interval : 0
    }

    /**
      Initializes a new `TimeDuration` instance with the specified duration in various units of time.

      - Parameters:
        - nanoSeconds: The duration in nanoseconds. The default value is `0`.
        - milliseconds: The duration in milliseconds. The default value is `0`.
        - seconds: The duration in seconds. The default value is `0`.
        - minutes: The duration in minutes. The default value is `0`.
     - hours: The duration in hours. The default value is `0`.
        - days: The duration in days. The default value is `0`.
        - weeks: The duration in weeks. The default value is `0`.
        - months: The duration in months. The default value is `0`.
        - years: The duration in years. The default value is `0`.
      */
    public init(nanoseconds: Double = 0, milliseconds: Double = 0, seconds: Double = 0, minutes: Double = 0, hours: Double = 0, days: Double = 0, weeks: Double = 0, months: Double = 0, years: Double = 0) {
        self.seconds = seconds
        self.seconds += (milliseconds / 1000)
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

    /// The duration in nanoSeconds.
    public var nanoseconds: Double {
        get { milliseconds / 1_000_000 }
        set { milliseconds = newValue / 1_000_000 }
    }

    /// The duration in milliseconds.
    public var milliseconds: Double {
        get { seconds / 1000 }
        set { seconds = newValue / 1000 }
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

    /// The duration in months.
    public var months: Double {
        get { value(for: .month) }
        set { seconds = seconds(for: newValue, .month) }
    }

    /// The duration in years.
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

    func value(for unit: Unit) -> Double {
        seconds / unit.calendarComponent.timeInterval!
    }

    func seconds(for value: Double, _ unit: Unit) -> Double {
        unit.convert(value, to: .second)
    }
}

public extension TimeDuration {
    /**
     Returns a time duration with the specified nanoseconds.

     - Parameter value: The nanoseconds.
     - Returns: `TimeDuration`with the specified nanoseconds.
     */
    static func nanoseconds(_ value: Double) -> Self { Self(nanoseconds: value) }

    /**
     Returns a time duration with the specified milliseconds.

     - Parameter value: The milliseconds.
     - Returns: `TimeDuration`with the specified milliseconds.
     */
    static func milliseconds(_ value: Double) -> Self { Self(milliseconds: value) }

    /**
     Returns a time duration with the specified seconds.

     - Parameter value: The seconds.
     - Returns: `TimeDuration`with the specified seconds.
     */
    static func seconds(_ value: Double) -> Self { Self(seconds: value) }

    /**
     Returns a time duration with the specified minutes.

     - Parameter value: The minutes.
     - Returns: `TimeDuration`with the specified minutes.
     */
    static func minutes(_ value: Double) -> Self { Self(minutes: value) }

    /**
     Returns a time duration with the specified hours.

     - Parameter value: The hours.
     - Returns: `TimeDuration`with the specified hours.
     */
    static func hours(_ value: Double) -> Self { Self(hours: value) }

    /**
     Returns a time duration with the specified days.

     - Parameter value: The days.
     - Returns: `TimeDuration`with the specified days.
     */
    static func days(_ value: Double) -> Self { Self(days: value) }

    /**
     Returns a time duration with the specified weeks.

     - Parameter value: The weeks.
     - Returns: `TimeDuration`with the specified weeks.
     */
    static func weeks(_ value: Double) -> Self { Self(weeks: value) }

    /**
     Returns a time duration with the specified months.

     - Parameter value: The months.
     - Returns: `TimeDuration`with the specified months.
     */
    static func months(_ value: Double) -> Self { Self(months: value) }

    /**
     Returns a time duration with the specified years.

     - Parameter value: The years.
     - Returns: `TimeDuration`with the specified years.
     */
    static func years(_ value: Double) -> Self { Self(years: value) }
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
}

extension TimeDuration: Codable {
    public enum CodingKeys: CodingKey {
        case seconds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys.self)
        try container.encode(seconds, forKey: .seconds)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seconds = try container.decode(Double.self, forKey: .seconds)
    }
}

/*
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
 */

public extension TimeDuration {
    ///  Enumeration representing different duration time units.
    enum Unit: Int, CaseIterable {
        /// Nanosecond
        case nanoSecond = 0
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

        var calendarComponent: Calendar.Component {
            switch self {
            case .nanoSecond: return .second
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

        func convert(_ number: Double, to targetUnit: Unit) -> Double {
            let factor: Double = 60
            let conversionFactor = pow(factor, Double(rawValue - targetUnit.rawValue))
            return number * conversionFactor
        }
    }

    /// The time duration units.
    struct Units: OptionSet {
        public let rawValue: UInt
        /// Nanosecond
        public static let nanoSecond = Units(rawValue: 1 << 0)
        /// Millisecond
        public static let millisecond = Units(rawValue: 1 << 1)
        /// Second
        public static let second = Units(rawValue: 1 << 2)
        /// Minute
        public static let minute = Units(rawValue: 1 << 3)
        /// Hour
        public static let hour = Units(rawValue: 1 << 4)
        /// Day
        public static let day = Units(rawValue: 1 << 5)
        /// Week
        public static let week = Units(rawValue: 1 << 6)
        /// Month
        public static let month = Units(rawValue: 1 << 7)
        /// Year
        public static let year = Units(rawValue: 1 << 8)

        /// All used units.
        public static let all = Units(rawValue: 1 << 9)
        /// All used units compact.
        public static let allCompact = Units(rawValue: 1 << 10)
        /// All used units detailed.
        public static let allDetailed: Units = [.second, .minute, .hour, .hour, .day, .week, .month, .year]

        /// Creates a units structure with the specified raw value.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// Creates a units structure with the specified time duration unit.
        public init(unit: Unit) {
            rawValue = Self.allCases.first(where: { $0.unit == unit })?.rawValue ?? 1 << 2
        }

        static let allCases: [Units] = [.nanoSecond, .millisecond, .second, .minute, .hour, .day, .week, .month, .year]
        var unit: Unit? {
            switch self {
            case .nanoSecond: return .nanoSecond
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
            var units: [TimeDuration.Unit] = []
            for unitCase in Self.allCases {
                if let unit = unitCase.unit {
                    if contains(unitCase) {
                        units.append(unit)
                    }
                }
            }
            if self == .allDetailed {
                units.append(contentsOf: elements().compactMap(\.unit).collect())
            }
            if contains(.all) { units.append(contentsOf: duration.preferredUnits(compact: false)) }
            if contains(.allCompact) { units.append(contentsOf: duration.preferredUnits(compact: true)) }
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

    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }

    /// A string representation of the time duration.
    var string: String {
        string(allowedUnits: .all)
    }

    /// A compact string representation of the time duration.
    public var stringCompact: String {
        string(allowedUnits: .allCompact, style: .brief)
    }

    /**
     Returns a string representation of the time duration using the specified time unit and style.

     - Parameters:
       - unit: The unit to use for formatting the time duration.
       - style: The formatting style. The default value is `full`.

     - Returns: A string representation of the time duration.
     */
    public func string(for unit: Unit, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        string(allowedUnits: .init(unit: unit), style: style)
    }

    /**
     Returns a string representation of the time duration using the specified allowed time units and style.

     - Parameters:
       - allowedUnits: The allowed units for formatting the time duration. The default value is `all`.
       - style: The formatting style. The default value is `full`.

     - Returns: A string representation of the time duration.
     */
    public func string(allowedUnits: Units = .all, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        let allowedUnits = allowedUnits.units(for: self)
        let formatter = formatter
        formatter.allowedComponents = allowedUnits.compactMap(\.calendarComponent).uniqued()
        formatter.unitsStyle = style
        return formatter.string(from: TimeInterval(seconds))!
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

    /// Adds two time durations and stores the result in the left-hand-side variable.
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Subtracts the two time durations.
    public static func - (lhs: Self, rhs: Self) -> Self {
        var seconds = lhs.seconds - rhs.seconds
        if seconds < 0 { seconds = 0 }
        return Self(seconds)
    }

    /// Subtracts the second time duration from the first and stores the difference in the left-hand-side variable.
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    /// A Boolean value indicating whether the first time duration is smaller than the second time duration.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds < rhs.seconds
    }

    /// A Boolean value indicating whether the first time duration is smaller or equal to the second time duration.
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds <= rhs.seconds
    }

    /// A Boolean value indicating whether the first time duration is larger than the second time duration.
    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds > rhs.seconds
    }

    /// A Boolean value indicating whether the first time duration is larger or equal to the second time duration.
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds >= rhs.seconds
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

public extension Collection where Element == TimeDuration {
    /**
     The average duration of all durations in the collection.

     - Returns: A `TimeDuration` instance representing the average duration. If the collection is empty, it returns `zerp`.
     */
    func average() -> TimeDuration {
        guard !isEmpty else { return .zero }
        let average = compactMap(\.seconds).average().rounded(.down)
        return TimeDuration(average)
    }

    /**
     The total duration of all durations in the collection.

     - Returns: A `TimeDuration` instance representing the total duration. If the collection is empty, it returns `zero`.
     */
    func sum() -> TimeDuration {
        guard !isEmpty else { return .zero }
        let sum = compactMap(\.seconds).sum()
        return TimeDuration(sum)
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
         - userInfo: Custom user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
         - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.

      - Returns:A new Timer object, configured according to the specified parameters.
      */
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
    convenience init(timeInterval interval: TimeDuration, repeats: Bool, block: @escaping ((Timer) -> Void)) {
        self.init(timeInterval: interval.seconds, repeats: repeats, block: block)
    }

    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters:
        - interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
        - target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
        - selector: The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument).
        - userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
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
    static func scheduledTimer(withTimeInterval interval: TimeDuration, repeats: Bool, block: @escaping ((Timer) -> Void)) -> Timer {
        scheduledTimer(withTimeInterval: interval.seconds, repeats: repeats, block: block)
    }

    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters:
        - interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
        - target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
        - selector: The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument).
        - userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
    static func scheduledTimer(timeInterval interval: TimeDuration, target: Any, selector: Selector, userInfo: Any?, repeats: Bool) -> Timer {
        scheduledTimer(timeInterval: interval.seconds, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
    }
}
