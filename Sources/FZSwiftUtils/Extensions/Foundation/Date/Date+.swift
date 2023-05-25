//
//  Date.swift
//  FZExtensions
//
//  Created by Florian Zand on 07.06.22.
//

import Foundation

public extension Date {
    func adding(_ value: Int, to component: Calendar.Component) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }

    func value(for component: Calendar.Component) -> Int {
        let components = Calendar.current.dateComponents([component], from: self)
        return components.value(for: component) ?? 0
    }

    mutating func setValue(_ value: Int, for component: Calendar.Component) {
        self = Calendar.current.date(bySetting: component, value: value, of: self) ?? self
    }

    func isSame(_ component: Calendar.Component, to date: Date, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isBetween(_ date1: Date, _ date2: Date) -> Bool {
        return DateInterval(start: date1, end: date2).contains(self)
    }

    var year: Int {
        get { value(for: .year) }
        set { setValue(newValue, for: .year) }
    }

    var month: Int {
        get { value(for: .month) }
        set { setValue(newValue, for: .month) }
    }

    var weekOfMonth: Int {
        get { value(for: .weekOfMonth) }
        set { setValue(newValue, for: .weekOfMonth) }
    }

    var weekOfYear: Int {
        get { value(for: .weekOfYear) }
        set { setValue(newValue, for: .weekOfYear) }
    }

    var day: Int {
        get { value(for: .day) }
        set { setValue(newValue, for: .day) }
    }

    var weekday: Int {
        get { value(for: .weekday) }
        set { setValue(newValue, for: .weekday) }
    }

    var hour: Int {
        get { value(for: .hour) }
        set { setValue(newValue, for: .hour) }
    }

    var minute: Int {
        get { value(for: .minute) }
        set { setValue(newValue, for: .minute) }
    }

    var second: Int {
        get { value(for: .second) }
        set { setValue(newValue, for: .second) }
    }
}

public extension Date {
    func start(of component: Calendar.Component) -> Date {
        if component == .day {
            return Calendar.current.startOfDay(for: self)
        }

        var components: Set<Calendar.Component> {
            switch component {
            case .second:
                return [.year, .month, .day, .hour, .minute, .second]

            case .minute:
                return [.year, .month, .day, .hour, .minute]

            case .hour:
                return [.year, .month, .day, .hour]

            case .weekOfYear, .weekOfMonth:
                return [.yearForWeekOfYear, .weekOfYear]

            case .month:
                return [.year, .month]

            case .year:
                return [.year]

            default:
                return []
            }
        }

        guard !components.isEmpty else { return self }
        return Calendar.current.date(from: Calendar.current.dateComponents(components, from: self)) ?? self
    }

    func end(of component: Calendar.Component) -> Date {
        let calendar = Calendar.current
        switch component {
        case .second:
            var date = adding(1, to: .second)
            date = calendar.date(from:
                calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date))!
            date = date.adding(-1, to: .second)
            return date

        case .minute:
            var date = adding(1, to: .minute)
            let after = calendar.date(from:
                calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date))!
            date = after.adding(-1, to: .second)
            return date

        case .hour:
            var date = adding(1, to: .hour)
            let after = calendar.date(from:
                calendar.dateComponents([.year, .month, .day, .hour], from: date))!
            date = after.adding(-1, to: .second)
            return date

        case .day:
            var date = adding(1, to: .day)
            date = calendar.startOfDay(for: date)
            date = date.adding(-1, to: .second)
            return date

        case .weekOfYear, .weekOfMonth:
            var date = self
            let beginningOfWeek = calendar.date(from:
                calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            date = beginningOfWeek.adding(7, to: .day).adding(-1, to: .second)
            return date

        case .month:
            var date = adding(1, to: .month)
            let after = calendar.date(from:
                calendar.dateComponents([.year, .month], from: date))!
            date = after.adding(-1, to: .second)
            return date

        case .year:
            var date = adding(1, to: .year)
            let after = calendar.date(from:
                calendar.dateComponents([.year], from: date))!
            date = after.adding(-1, to: .second)
            return date
        default:
            return self
        }
    }

    func isInCurrent(_ component: Calendar.Component) -> Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: component)
    }

    enum Component {
        case year(Int = 1)
        case quarter(Int = 1)
        case month(Int = 1)
        case week(Int = 1)
        case day(Int = 1)
        case hour(Int = 1)
        case minute(Int = 1)
        case second(Int = 1)
        case nanosecond(Int = 1)
        internal var value: (Calendar.Component, Int) {
            switch self {
            case let .year(value): return (.year, value)
            case let .quarter(value): return (.quarter, value)
            case let .month(value): return (.month, value)
            case let .week(value): return (.weekOfYear, value)
            case let .day(value): return (.day, value)
            case let .hour(value): return (.hour, value)
            case let .minute(value): return (.minute, value)
            case let .second(value): return (.second, value)
            case let .nanosecond(value): return (.nanosecond, value)
            }
        }
    }

    static func + (lhs: Self, rhs: Component) -> Self {
        return lhs.adding(rhs.value.1, to: rhs.value.0)
    }

    static func += (lhs: inout Self, rhs: Component) {
        lhs = lhs.adding(rhs.value.1, to: rhs.value.0)
    }

    static func - (lhs: Self, rhs: Component) -> Self {
        return lhs.adding(-rhs.value.1, to: rhs.value.0)
    }

    static func -= (lhs: inout Self, rhs: Component) {
        lhs = lhs.adding(-rhs.value.1, to: rhs.value.0)
    }

    enum ComparisonType {
        case now
        case today
        case yesterday
        case tomorrow
        case this(Calendar.Component)
        case previous(Calendar.Component)
        case next(Calendar.Component)
        case last(Int, Calendar.Component)
        case sameDay(Date)
    }

    static func == (lhs: Date, rhs: ComparisonType) -> Bool {
        let from: Date
        let to: Date
        switch rhs {
        case .today:
            from = lhs.start(of: .day)
            to = from.end(of: .day)
        case .yesterday:
            from = lhs.adding(-1, to: .day).start(of: .day)
            to = from.end(of: .day)
        case .tomorrow:
            from = lhs.adding(1, to: .day).start(of: .day)
            to = from.end(of: .day)
        case let .this(unit):
            from = lhs.start(of: unit)
            to = from.end(of: unit)
        case let .next(unit):
            from = lhs.adding(1, to: unit).start(of: unit)
            to = from.end(of: unit)
        case let .last(value, unit):
            from = lhs.adding(-value, to: unit).start(of: unit)
            to = from.end(of: unit)
        case .now:
            from = Date()
            to = Date().adding(30, to: .second)
        case let .previous(unit):
            from = lhs.adding(-1, to: unit).start(of: unit)
            to = from.end(of: unit)
        case let .sameDay(date):
            from = date.start(of: .day)
            to = date.end(of: .day)
        }
        return lhs.isBetween(from, to)
    }
}
