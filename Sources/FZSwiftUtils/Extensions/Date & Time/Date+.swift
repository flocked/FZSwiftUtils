//
//  Date+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

import Foundation

public extension Date {
    /**
     Adds a value to a specific component of the date.

     - Parameters:
        - value: The value to be added.
        - component: The component of the date to which the value should be added.
        - calendar: The calendar to use.

     - Returns: A new `Date` object obtained by adding the specified value to the given component of the date.
     */
    func adding(_ value: Int, to component: Calendar.Component, calendar: Calendar = Calendar.current) -> Date {
        calendar.date(byAdding: component, value: value, to: self) ?? self
    }

    /**
     Returns the value of a specific component of the date.

     - Parameters:
        - component: The component of the date for which to retrieve the value.
     - calendar: The calendar to use.

     - Returns: The value of the specified component of the date. If the value is not available, 0 is returned.
     */
    func value(for component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        let components = calendar.dateComponents([component], from: self)
        return components.value(for: component) ?? 0
    }

    /**
     Sets the value of a specific component of the date.

     - Parameters:
        - value: The new value to set.
        - component: The component of the date to be set.
        - calendar: The calendar to use.

     This method mutates the current date by setting the specified component to the given value.
     */
    mutating func setValue(_ value: Int, for component: Calendar.Component, calendar: Calendar = Calendar.current) {
        self = calendar.date(bySetting: component, value: value, of: self) ?? self
    }

    /**
     Checks if a specific component of the date is the same as the corresponding component in another date.

     - Parameters:
        - component: The component of the date to compare.
        - date: The date to compare against.
        - calendar: The calendar to use for the comparison. Defaults to the current calendar.

     - Returns: `true` if the specified component of the date is the same as the corresponding component in the other date; otherwise, `false`.
     */
    func isSame(_ component: Calendar.Component, to date: Date, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    /**
     Checks if the date is between two other dates.

     - Parameters:
        - date1: The first date to compare.
        - date2: The second date to compare.

     - Returns: `true` if the date is between `date1` and `date2`, inclusive; otherwise, `false`.
     */
    func isBetween(_ date1: Date, _ date2: Date) -> Bool {
        if date1 == date2 {
            return self == date1
        }
        return DateInterval(start: (date1 < date2) ? date1 : date2, end: (date1 < date2) ? date2 : date1).contains(self)
    }

    /**
     Checks if the date is between the specified date interval.

     - Parameters:
        - interval: The date interval.

     - Returns: `true` if the date is between the date interval, otherwise, `false`.
     */
    func isBetween(_ interval: DateInterval) -> Bool {
        interval.contains(self)
    }

    /// The year of this date.
    var year: Int {
        get { value(for: .year) }
        set { setValue(newValue, for: .year) }
    }

    /// The quarter of this date.
    var quarter: Int {
        get { value(for: .quarter) }
        set { setValue(newValue, for: .second) }
    }

    /// The month of this date.
    var month: Int {
        get { value(for: .month) }
        set { setValue(newValue, for: .month) }
    }

    /// The week of this date.
    var weekOfMonth: Int {
        get { value(for: .weekOfMonth) }
        set { setValue(newValue, for: .weekOfMonth) }
    }

    /// The week of this date.
    var weekOfYear: Int {
        get { value(for: .weekOfYear) }
        set { setValue(newValue, for: .weekOfYear) }
    }

    /// The day of this date.
    var day: Int {
        get { value(for: .day) }
        set { setValue(newValue, for: .day) }
    }

    /// The weekday of this date.
    var weekday: Int {
        get { value(for: .weekday) }
        set { setValue(newValue, for: .weekday) }
    }

    /// The hour of this date.
    var hour: Int {
        get { value(for: .hour) }
        set { setValue(newValue, for: .hour) }
    }

    /// The minute of this date.
    var minute: Int {
        get { value(for: .minute) }
        set { setValue(newValue, for: .minute) }
    }

    /// The second of this date.
    var second: Int {
        get { value(for: .second) }
        set { setValue(newValue, for: .second) }
    }

    /// The nanosecond of this date.
    var nanosecond: Int {
        get { value(for: .nanosecond) }
        set { setValue(newValue, for: .second) }
    }
    
    /**
     Returns a string representation of the date from the specified date format string.
     
     - Parameter formatter: The date format string.
     */
    func string(using format: String) -> String {
        DateFormatter(format).string(from: self)
    }
    
    /**
     Returns a string representation from the specified date formatter components.
     
     - Parameter components: The date formatter components.
     */
    func string(components: DateFormatter.Component...) -> String {
        DateFormatter(components: components).string(from: self)
    }
    
    /**
     Returns a string representation of the date that the system formats using the formatter.
     
     - Parameter formatter: The date formatter.
     */
    func string(using formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }
}

public extension Date {
    /**
     Returns the beginning date of a specific component.

     - Parameters:
        - component: The component of the date for which to retrieve the start date.
        - calendar: The calendar.

     - Returns: The beginning date of the specified component, or `nil` if the component is not supported or the calculation fails.
     */
    func beginning(of component: Calendar.Component, calendar: Calendar = Calendar.current) -> Date? {
        var startDate = self
        var timeInterval: TimeInterval = 0
        guard calendar.dateInterval(of: component, start: &startDate, interval: &timeInterval, for: self) else { return nil }
        return startDate
    }

    
    /**
     Returns the end date of a specific component.

     - Parameters:
        - component: The component of the date for which to retrieve the end date.
        - calendar: The calendar.
        - returnNextIfAtBoundary: A Boolean value indicating whether to return the next date if at boundary.

     - Returns: The end date of the specified component, or `nil` if the component is not supported or the calculation fails.
     */
    func end(of component: Calendar.Component, calendar: Calendar = Calendar.current, returnNextIfAtBoundary: Bool = true) -> Date? {
        guard let startDate = beginning(of: component, calendar: Calendar.current) else { return nil }
        if startDate == self && !returnNextIfAtBoundary { return self }
        return startDate.adding(1, to: component, calendar: calendar)
    }

    /**
     Checks if the date is in the current specified component.

     - Parameter component: The component to check against the current date.

     - Returns: `true` if the date is in the current specified component; otherwise, `false`.
     */
    func isInCurrent(_ component: Calendar.Component) -> Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: component)
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
        var value: (Calendar.Component, Int) {
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
        lhs.adding(rhs.value.1, to: rhs.value.0)
    }

    static func += (lhs: inout Self, rhs: Component) {
        lhs = lhs.adding(rhs.value.1, to: rhs.value.0)
    }

    static func - (lhs: Self, rhs: Component) -> Self {
        lhs.adding(-rhs.value.1, to: rhs.value.0)
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
        var from: Date
        let to: Date
        switch rhs {
        case .today:
            from = lhs.beginning(of: .day) ?? lhs
            to = from.end(of: .day) ?? from
        case .yesterday:
            from = lhs.adding(-1, to: .day)
            from = from.beginning(of: .day) ?? from
            to = from.end(of: .day) ?? from
        case .tomorrow:
            from = lhs.adding(1, to: .day)
            from = from.beginning(of: .day) ?? from
            to = from.end(of: .day) ?? from
        case let .this(unit):
            from = lhs.beginning(of: unit) ?? lhs
            to = from.end(of: unit) ?? from
        case let .next(unit):
            from = lhs.adding(1, to: unit)
            from = from.beginning(of: unit) ?? from
            to = from.end(of: unit) ?? from
        case let .last(value, unit):
            from = lhs.adding(-value, to: unit)
            from = from.beginning(of: unit) ?? from
            to = from.end(of: unit) ?? from
        case .now:
            from = Date()
            to = Date().adding(30, to: .second)
        case let .previous(unit):
            from = lhs.adding(-1, to: unit)
            from = from.beginning(of: unit) ?? from
            to = from.end(of: unit) ?? from
        case let .sameDay(date):
            from = date.beginning(of: .day) ?? date
            to = date.end(of: .day) ?? date
        }
        return lhs.isBetween(from, to)
    }
}
