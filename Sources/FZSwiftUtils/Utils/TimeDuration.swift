//
//  TimeDuration.swift
//  TimeDuration
//
//  Created by Florian Zand on 10.03.23.
//

import Foundation
import AVKit

public struct TimeDuration: Hashable, Sendable {
    public init(_ seconds: Double) {
        self.seconds = seconds
    }
    
    public init(_ time: CMTime) {
        self.seconds = time.seconds
    }
       
    public init(nanoSeconds: Double = 0, milliseconds: Double = 0, seconds: Double = 0, minutes: Double = 0, days: Double = 0, weeks: Double = 0, months: Double = 0, years: Double = 0) {
        self.seconds = seconds
        self.seconds += (milliseconds / 1000)
        self.seconds += (nanoSeconds / 1000000000)
        self.seconds += self.seconds(for: minutes, .minute)
        self.seconds += self.seconds(for: hours, .hour)
        self.seconds += self.seconds(for: days, .day)
        self.seconds += self.seconds(for: weeks, .week)
        self.seconds += self.seconds(for: months, .month)
        self.seconds += self.seconds(for: years, .year)
    }
    
    public init(dateInterval: DateInterval) {
        self.seconds =  dateInterval.start.timeIntervalSince(dateInterval.end)
    }
    
    public var seconds: Double
    
    public var nanoSeconds: Double {
        get { milliseconds / 1000000 }
        set { self.milliseconds = newValue / 1000000 }
    }
    
    public var milliseconds: Double {
        get { seconds / 1000 }
        set { self.seconds = newValue / 1000 }
    }
    
    public var minutes: Double {
        get { value(for: .minute) }
        set { self.seconds = seconds(for: newValue, .minute) }
    }
    
    public var hours: Double {
        get { value(for: .hour) }
        set { self.seconds = seconds(for: newValue, .hour) }
    }
    
    public var days: Double {
        get { value(for: .day) }
        set { self.seconds = seconds(for: newValue, .day) }
    }
    
    public var weeks: Double {
        get { value(for: .week) }
        set { self.seconds = seconds(for: newValue, .week) }
    }
    
    public var months: Double {
        get { value(for: .month) }
        set { self.seconds = seconds(for: newValue, .month) }
    }
    
    public var years: Double {
        get { value(for: .year) }
        set { self.seconds = seconds(for: newValue, .year) }
    }
    
    public func startDate(end: Date) -> Date {
        end.adding(-Int(seconds), to: .second)
    }
    
    public func endDate(start: Date) -> Date {
        DateInterval(start: start, duration: self.seconds).end
    }
    
    internal func value(for unit: Unit) -> Double {
        return self.seconds / unit.calendarUnit.timeInterval!
    }
    
    internal func seconds(for value: Double, _ unit: Unit) -> Double {
        return unit.convert(value, to: .second)
    }
    
    public static var zero: TimeDuration {
        return TimeDuration(0.0)
    }
}

public extension DateInterval {
    var timeDuration: TimeDuration {
        TimeDuration(self.duration)
    }
}

extension TimeDuration: Codable {
    enum CodingKeys: CodingKey {
        case seconds
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
        try container.encode(self.seconds, forKey: .seconds)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.seconds = try container.decode(Double.self, forKey: .seconds)
    }
}

extension TimeDuration: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.seconds = Double(value)
    }
}

extension TimeDuration: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.seconds = value
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
             let factor: Double =  60
             let conversionFactor = pow(factor, Double(self.rawValue - targetUnit.rawValue))
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
    
    public func string(for unit:  Unit, style: DateComponentsFormatter.UnitsStyle  = .full) -> String {
        return self.string(allowedUnits: [unit], style: style)
    }
    
    public func string(allowedUnits: [Unit] = [.hour, .minute, .second], style: DateComponentsFormatter.UnitsStyle  = .full) -> String {
       let formatter = self.formatter
        formatter.allowedComponents = allowedUnits.compactMap({$0.calendarUnit})
        formatter.unitsStyle = style
        return formatter.string(from: TimeInterval(seconds))!
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension TimeDuration: DurationProtocol { }

extension TimeDuration: Comparable {
    public static func +(lhs: Self, rhs: Self) -> Self {
       Self(lhs.seconds+rhs.seconds)
   }
    
    public static func +=(lhs: inout Self, rhs: Self) {
       lhs = lhs + rhs
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
       var seconds = lhs.seconds-rhs.seconds
       if (seconds < 0) { seconds = 0 }
      return Self(seconds)
   }
   
    public static func -=(lhs: inout Self, rhs: Self) {
       lhs = lhs - rhs
   }
       
   public static func <(lhs: Self, rhs: Self) -> Bool {
       return lhs.seconds < rhs.seconds
   }
   
   public static func <=(lhs: Self, rhs: Self) -> Bool {
       return lhs.seconds <= rhs.seconds
   }
   
    public static func >(lhs: Self, rhs: Self) -> Bool {
       return lhs.seconds > rhs.seconds
   }
   
    public static func >=(lhs: Self, rhs: Self) -> Bool {
       return lhs.seconds >= rhs.seconds
   }
    
    public static func / (lhs: TimeDuration, rhs: Int) -> TimeDuration {
        TimeDuration(lhs.seconds/Double(rhs))
    }
    
    public static func * (lhs: TimeDuration, rhs: Int) -> TimeDuration {
        TimeDuration(lhs.seconds*Double(rhs))
    }
    
    public static func / (lhs: TimeDuration, rhs: TimeDuration) -> Double {
        lhs.seconds/rhs.seconds
    }
}
