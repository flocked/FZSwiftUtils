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
    public var seconds: Double {
        didSet {
            if seconds < 0.0 {
                seconds = 0.0
            }
        }
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
        public let rawValue: Int
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
        public init(rawValue: Int) {
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

     - Returns: A string representation of the time duration.
     */
    public func string(for unit: Unit, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        string(allowedUnits: .init(unit: unit), style: style)
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

     - Returns: A string representation of the time duration.
     */
    public func string(allowedUnits: Units = .all, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        let allowedUnits = allowedUnits.units(for: self)
        let formatter = DateComponentsFormatter()
        formatter.allowedComponents = allowedUnits.compactMap(\.calendarComponent).uniqued()
        formatter.unitsStyle = style
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    /**
     A timecode string representation of the time duration.

     - Parameters:
        - includingSeconds: A Boolean value indicating whether the string should include seconds.
        - precision: The amount of digits after the seconds decimal separator.
     */
    public func timecodeString(includingSeconds: Bool = true, precision: Int = 0) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        
        let h_ = h > 0 ? "\(h):" : ""
        let m_ = m < 10 ? "0\(m)" : "\(m)"
        let s_: String

        guard includingSeconds else {
            return h_ + m_
        }
        
        if precision >= 1 {
          s_ = String(format: "%0\(precision + 3).\(precision)f", fmod(seconds, 60))
        } else {
            let s = (Int(seconds) % 3600) % 60
            s_ = s < 10 ? "0\(s)" : "\(s)"
        }
        return h_ + m_ + ":" + s_
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

extension DispatchTime {
    public static func + (lhs: Self, rhs: TimeDuration) -> Self {
        lhs + rhs.seconds
    }
    
    public static func += (lhs: inout Self, rhs: TimeDuration) {
        lhs = lhs + rhs
    }
}

public extension Sequence where Element == TimeDuration {
    /**
     The total duration of all durations in the sequence.

     - Returns: A `TimeDuration` instance representing the total duration. If the sequence is empty, it returns `zero`.
     */
    func sum() -> TimeDuration {
        let sum = compactMap(\.seconds).sum()
        return TimeDuration(sum)
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
         - userInfo: Custom user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be `nil.
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
        - userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be `nil.
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
        - interval: The interval between firings of the timer. If interval is equal to `0.0` seconds, this method chooses the nonnegative value of `0.0001` seconds instead.
        - target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
        - selector: The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument).
        - userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be `nil`.
        - repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.

     - Returns:A new Timer object, configured according to the specified parameters.
     */
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
