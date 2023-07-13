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

    /**
     Initializes a new `TimeDuration` instance with the specified `CMTime`.
     
     - Parameter time: The `CMTime` to use for the duration.
     */
    public init(_ time: CMTime) {
        seconds = time.seconds
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
        return TimeDuration(0.0)
    }

    internal func value(for unit: Unit) -> Double {
        return seconds / unit.calendarComponent.timeInterval!
    }

    internal func seconds(for value: Double, _ unit: Unit) -> Double {
        return unit.convert(value, to: .second)
    }
}

public extension TimeDuration {
    /**
     Returns a time duration with the specified nanoseconds.
     
     - Parameters value: The nanoseconds.
     - Returns: `TimeDuration`with the specified nanoseconds.
     */
    static func nanoseconds(_ value: Double) -> Self { return Self(nanoseconds: value) }
    
    /**
     Returns a time duration with the specified milliseconds.
     
     - Parameters value: The milliseconds.
     - Returns: `TimeDuration`with the specified milliseconds.
     */
    static func milliseconds(_ value: Double) -> Self { Self(milliseconds: value) }
    
    /**
     Returns a time duration with the specified seconds.
     
     - Parameters value: The seconds.
     - Returns: `TimeDuration`with the specified seconds.
     */
    static func seconds(_ value: Double) -> Self { Self(seconds: value) }
    
    /**
     Returns a time duration with the specified minutes.
     
     - Parameters value: The minutes.
     - Returns: `TimeDuration`with the specified minutes.
     */
    static func minutes(_ value: Double) -> Self { Self(minutes: value) }
    
    /**
     Returns a time duration with the specified hours.
     
     - Parameters value: The hours.
     - Returns: `TimeDuration`with the specified hours.
     */
    static func hours(_ value: Double) -> Self { Self(hours: value) }
    
    /**
     Returns a time duration with the specified days.
     
     - Parameters value: The days.
     - Returns: `TimeDuration`with the specified days.
     */
    static func days(_ value: Double) -> Self { Self(days: value) }
    
    /**
     Returns a time duration with the specified weeks.
     
     - Parameters value: The weeks.
     - Returns: `TimeDuration`with the specified weeks.
     */
    static func weeks(_ value: Double) -> Self { Self(weeks: value) }
    
    /**
     Returns a time duration with the specified months.
     
     - Parameters value: The months.
     - Returns: `TimeDuration`with the specified months.
     */
    static func months(_ value: Double) -> Self { Self(months: value) }
        
    /**
     Returns a time duration with the specified years.
     
     - Parameters value: The years.
     - Returns: `TimeDuration`with the specified years.
     */
    static func years(_ value: Double) -> Self { Self(years: value) }
}

public extension DateInterval {
    /// The time duration.
    var timeDuration: TimeDuration {
        TimeDuration(duration)
    }
}

extension TimeDuration: Codable {
    public enum CodingKeys: CodingKey {
        case seconds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
        try container.encode(seconds, forKey: .seconds)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seconds = try container.decode(Double.self, forKey: .seconds)
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
        internal var calendarComponent: Calendar.Component {
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

        internal func convert(_ number: Double, to targetUnit: Unit) -> Double {
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
            self.rawValue = Self.allCases.first(where: {$0.unit == unit})?.rawValue ??  1 << 2
        }
        
        internal static let allCases: [Units] = [.nanoSecond, .millisecond, .second, .minute, .hour, .day, .week, .month, .year]
        internal var unit: Unit? {
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
        
        internal func units(for duration: TimeDuration) -> [TimeDuration.Unit] {
            var units: [TimeDuration.Unit] = []
            for unitCase in Self.allCases {
                if let unit = unitCase.unit {
                    if self.contains(unitCase) {
                        units.append(unit) }
                }
            }
            if self == .allDetailed {
                units.append(contentsOf: self.elements().compactMap({$0.unit}).collect())
            }
            if self.contains(.all) { units.append(contentsOf: duration.preferredUnits(compact: false)) }
            if self.contains(.allCompact) { units.append(contentsOf: duration.preferredUnits(compact: true)) }
            units = units.uniqued()
            return units
        }
    }
}

extension TimeDuration: CustomStringConvertible {
    /// A string representation of the time duration.
    public var description: String {
        return string()
    }

    internal var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }

    /// A string representation of the time duration.
    public var string: String {
        return string(allowedUnits: .all)
    }

    /// A compact string representation of the time duration.
    public var stringCompact: String {
        return string(allowedUnits: .allCompact, style: .brief)
    }

    /**
     Returns a string representation of the time duration using the specified time unit and style.
     
     - Parameters:
       - unit: The unit to use for formatting the time duration.
       - style: The formatting style.
     
     - Returns: A string representation of the time duration.
     */
    public func string(for unit: Unit, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        return string(allowedUnits: .init(unit: unit), style: style)
    }

    /**
     Returns a string representation of the time duration using the specified allowed time units and style.
     
     - Parameters:
       - allowedUnits: The allowed units for formatting the time duration.
       - style: The formatting style.
     
     - Returns: A string representation of the time duration.
     */
    public func string(allowedUnits: Units = .all, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        let allowedUnits = allowedUnits.units(for: self)
        let formatter = self.formatter
        formatter.allowedComponents = allowedUnits.compactMap { $0.calendarComponent }.uniqued()
        formatter.unitsStyle = style
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    internal func allCurrentUnits() -> [Unit] {
        var units: [Unit] = []
        if self.years >= 1 {  units.append(.year)  }
        if self.months >= 1 { units.append(.month) }
        if self.weeks >= 1 {  units.append(.week) }
        if self.days >= 1 {  units.append(.day) }
        if self.hours >= 1 { units.append(.hour) }
        if self.minutes >= 1 { units.append(.minute) }
        units.append(.second)
        return units
    }
    
    internal func preferredUnits(compact: Bool = true) -> [Unit] {
        let currentUnits = allCurrentUnits()
        if compact == false, currentUnits.count >= 3 {
            return Array(currentUnits[0..<3])
        } else if currentUnits.count >= 2 {
            return Array(currentUnits[0..<2])
        } else {
            return [.second]
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension TimeDuration: DurationProtocol {}

extension TimeDuration: Comparable {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.seconds + rhs.seconds)
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    public static func += (lhs: inout Self, rhs: Double) {
        lhs = lhs + Self(rhs)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var seconds = lhs.seconds - rhs.seconds
        if seconds < 0 { seconds = 0 }
        return Self(seconds)
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.seconds < rhs.seconds
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.seconds <= rhs.seconds
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.seconds > rhs.seconds
    }

    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.seconds >= rhs.seconds
    }

    public static func / (lhs: TimeDuration, rhs: Int) -> TimeDuration {
        TimeDuration(lhs.seconds / Double(rhs))
    }

    public static func * (lhs: TimeDuration, rhs: Int) -> TimeDuration {
        TimeDuration(lhs.seconds * Double(rhs))
    }

    public static func / (lhs: TimeDuration, rhs: TimeDuration) -> Double {
        lhs.seconds / rhs.seconds
    }
}
