//
//  Calendar+.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

import Foundation

extension Calendar.Component: CaseIterable {
    /// Returns an array containing all calendar components.
    public static var allCases: [Calendar.Component] {
        [.month, .weekday, .weekdayOrdinal, .weekOfYear, .weekOfMonth, .year, .yearForWeekOfYear, .weekOfYear, .quarter, .nanosecond, .second, .hour, .month, .minute, .day, .era]
    }
}

public extension Calendar.Component {
    /**
     Returns an array of string representations for the calendar component.

     E.g.:
     .month: ["months", "month", "mon"]
     .day: ["days", "day", "d"]

     - Returns: An array of string representations, or `nil` if no string representations are available for the component.
     */
    var stringRepresentations: [String]? {
        switch self {
        case .month: return ["months", "month", "mon"]
        case .weekOfMonth: return ["weeks", "week", "w"]
        case .minute: return ["minutes", "minute", "mins", "min", "m"]
        case .day: return ["days", "day", "d"]
        case .hour: return ["hours", "hour", "hrs", "hr", "h", "hs"]
        case .second: return ["seconds", "second", "secs", "sec", "s"]
        case .nanosecond: return ["nanoseconds", "nanosecond", "ns"]
        case .quarter: return ["quarters", "quarter"]
        default: return nil
        }
    }

    /// Returns the corresponding `NSCalendar.Unit` for the calendar component.
    var nsUnit: NSCalendar.Unit? {
        switch self {
        case .era: return .era
        case .year: return .year
        case .month: return .month
        case .day: return .day
        case .hour: return .hour
        case .minute: return .minute
        case .second: return .second
        case .weekday: return .weekday
        case .weekdayOrdinal: return .weekdayOrdinal
        case .quarter: return .quarter
        case .weekOfMonth: return .weekOfMonth
        case .weekOfYear: return .weekOfYear
        case .yearForWeekOfYear: return .yearForWeekOfYear
        case .nanosecond: return .nanosecond
        case .calendar: return .calendar
        case .timeZone: return .timeZone
        default: return nil
        }
    }

    /**
     Returns the time interval for the calendar component, if applicable.

     - Returns: The time interval for the component, or `nil` if the component does not have a corresponding time interval.
     */
    var timeInterval: Double? {
        switch self {
        case .era: return nil
        case .year: return (Calendar.Component.day.timeInterval! * 365.0)
        case .month: return (Calendar.Component.minute.timeInterval! * 43800)
        case .day: return 86400
        case .hour: return 3600
        case .minute: return 60
        case .second: return 1
        case .quarter: return (Calendar.Component.day.timeInterval! * 91.25)
        case .weekOfMonth, .weekOfYear: return (Calendar.Component.day.timeInterval! * 7)
        case .nanosecond: return 1e-9
        default: return nil
        }
    }
}

public extension Calendar {
    /// The calendar as `NSCalendar`.
    var nsCalendar: NSCalendar {
        self as NSCalendar
    }
}
