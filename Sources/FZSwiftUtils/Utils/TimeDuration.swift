//
//  TimeDuration.swift
//  TimeDuration
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
       - days: The duration in days. The default value is `0`.
       - weeks: The duration in weeks. The default value is `0`.
       - months: The duration in months. The default value is `0`.
       - years: The duration in years. The default value is `0`.
     */
    public init(nanoSeconds: Double = 0, milliseconds: Double = 0, seconds: Double = 0, minutes: Double = 0, days: Double = 0, weeks: Double = 0, months: Double = 0, years: Double = 0) {
        self.seconds = seconds
        self.seconds += (milliseconds / 1000)
        self.seconds += (nanoSeconds / 1_000_000_000)
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

    /// The duration in seconds.
    public var seconds: Double

    /// The duration in nanoSeconds.
    public var nanoSeconds: Double {
        get { milliseconds / 1_000_000 }
        set { milliseconds = newValue / 1_000_000 }
    }

    /// The duration in milliseconds.
    public var milliseconds: Double {
        get { seconds / 1000 }
        set { seconds = newValue / 1000 }
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

    internal func value(for unit: Unit) -> Double {
        return seconds / unit.calendarUnit.timeInterval!
    }

    internal func seconds(for value: Double, _ unit: Unit) -> Double {
        return unit.convert(value, to: .second)
    }

    
    /// Returns a `TimeDuration`  with zero seconds.
    public static var zero: TimeDuration {
        return TimeDuration(0.0)
    }
}

public extension DateInterval {
    var timeDuration: TimeDuration {
        TimeDuration(duration)
    }
}

extension TimeDuration: Codable {
    enum CodingKeys: CodingKey {
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
    enum Unit: Int, CaseIterable {
        case nanoSecond
        case millisecond
        case second
        case minute
        case hour
        case day
        case week
        case month
        case year
        internal var calendarUnit: Calendar.Component {
            switch self {
            case .nanoSecond: return .nanosecond
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
}

extension TimeDuration: CustomStringConvertible {
    public var description: String {
        return string()
    }

    internal var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }

    public var string: String {
        return string()
    }

    public var stringCompact: String {
        return string(style: .brief)
    }

    public func string(for unit: Unit, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        return string(allowedUnits: [unit], style: style)
    }

    public func string(allowedUnits: [Unit] = [.hour, .minute, .second], style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        let formatter = self.formatter
        formatter.allowedComponents = allowedUnits.compactMap { $0.calendarUnit }
        formatter.unitsStyle = style
        return formatter.string(from: TimeInterval(seconds))!
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
