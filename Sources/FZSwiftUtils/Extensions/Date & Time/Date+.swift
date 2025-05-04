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
    func isInSame(_ component: Calendar.Component, as date: Date, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    /**
     Checks if the date is in the current specified component.

     - Parameters:
        - component: The component to check against the current date.
        - calendar: The calendar.

     - Returns: `true` if the date is in the current specified component; otherwise, `false`.
     */
    func isInCurrent(_ component: Calendar.Component, calendar: Calendar = .current) -> Bool {
        isInSame(component, as: Date(), in: calendar)
    }
    
    /// Compares the date to another date by the specified component.
    func compare(_ component: Calendar.Component, to date: Date, in calendar: Calendar = .current) -> ComparisonResult {
        calendar.compare(self, to: date, toGranularity: component)
    }
    
    /// A Boolean value indicating whether the specified date is within the same as the date.
    func isSameDay(as date: Date, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }
    
    /// A Boolean value indicating whether the date is within today.
    func isToday(calendar: Calendar = .current) -> Bool {
        calendar.isDateInToday(self)
    }
    
    /// A Boolean value indicating whether the date is within tomorrow.
    func isTomorrow(calendar: Calendar = .current) -> Bool {
        calendar.isDateInTomorrow(self)
    }
    
    /// A Boolean value indicating whether the date is within yesterday.
    func isYesterday(calendar: Calendar = .current) -> Bool {
        calendar.isDateInTomorrow(self)
    }
    
    /// A Boolean value indicating whether the date is within a weekend period (Saturday or Sunday).
    func isWeekend(calendar: Calendar = .current) -> Bool {
        calendar.isDateInWeekend(self)
    }
    
    /// A Boolean value indicating whether the date is a workday (Monday to Friday).
    func isWorkday(calendar: Calendar = .current) -> Bool {
        !calendar.isDateInWeekend(self)
    }
    
    

    /**
     Checks if the date is between two other dates.

     - Parameters:
        - date1: The first date to compare.
        - date2: The second date to compare.

     - Returns: `true` if the date is between `date1` and `date2`, inclusive; otherwise, `false`.
     */
    func isBetween(_ date1: Date, _ date2: Date) -> Bool {
        return self >= min(date1, date2) && self <= max(date1, date2)
    }

    /**
     Checks if the date is between the specified date interval.

     - Parameter interval: The date interval.

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
        set { setValue(newValue, for: .quarter) }
    }

    /// The month of this date.
    var month: Int {
        get { value(for: .month) }
        set { setValue(newValue, for: .month) }
    }

    /// The week of the month of this date.
    var weekOfMonth: Int {
        get { value(for: .weekOfMonth) }
        set { setValue(newValue, for: .weekOfMonth) }
    }

    /// The week of the year of this date.
    var weekOfYear: Int {
        get { value(for: .weekOfYear) }
        set { setValue(newValue, for: .weekOfYear) }
    }

    /// The day of this date.
    var day: Int {
        get { value(for: .day) }
        set { setValue(newValue, for: .day) }
    }

    /// The weekday of this date (between `1` = Sunday and `7` = Saturday).
    var weekday: Int {
        get { value(for: .weekday) }
        set { setValue(newValue, for: .weekday) }
    }
    
    /// The day of the year of this date.
    var dayOfYear: Int {
        get {
            if #available(macOS 15, iOS 18.0, tvOS 18.0, watchOS 11.0, *) {
                return value(for: .dayOfYear)
            }
            return Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 0
        }
        set {
            if #available(macOS 15, iOS 18.0, tvOS 18.0, watchOS 11.0, *) {
                setValue(newValue, for: .dayOfYear)
            } else {
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: self)
                guard let newDate = calendar.date(byAdding: .day, value: newValue - 1, to: beginning(of: .year)!),  let finalDate = calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: timeComponents.second ?? 0, of: newDate) else { return }
                self = finalDate
            }
        }
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
        set { setValue(newValue, for: .nanosecond) }
    }
    
    /**
     Returns a string representation of the date from the specified date format string.
     
     - Parameter format: The date format string.
     */
    func string(using format: String) -> String {
        DateFormatter(format).string(from: self)
    }
    
    /**
     Returns a string representation from the specified date formatter components.
     
     - Parameter format: The date format.
     */
    func string(using format: DateFormat) -> String {
        DateFormatter(format).string(from: self)
    }
    
    /**
     Returns a string representation of the date that the system formats using the formatter.
     
     - Parameter formatter: The date formatter.
     */
    func string(using formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }
    
    /// Returns the starting time and duration of the specificed calendar component.
    func dateInterval(for component: Calendar.Component, calendar: Calendar = .current) -> DateInterval? {
        calendar.dateInterval(of: component, for: self)
    }
    
    /// Returns a `DateInterval` of the weekend contained by the date, or `nil` if the date is not in a weekend.
    func dateIntervalOfWeekend(calendar: Calendar = .current) -> DateInterval? {
        calendar.dateIntervalOfWeekend(containing: self)
    }
    
    /// Returns a `DateInterval` of the next weekend, which starts strictly after the date.
    func nextWeekend(calendar: Calendar = .current) -> DateInterval? {
        calendar.nextWeekend(startingAfter: self)
    }
    
    /// Returns a `DateInterval` of the previous weekend, which starts strictly after the date.
    func previousWeekend(calendar: Calendar = .current) -> DateInterval? {
        calendar.nextWeekend(startingAfter: self, direction: .backward)
    }

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


    /// Defines different ways to compare a `Date`.
    enum Comparison {
        /// Checks if the date is now.
        case now
        /// Checks if the date is today.
        case today
        /// Checks if the date is yesterday.
        case yesterday
        /// Checks if the date is tomorrow.
        case tomorrow
        /// Checks if the date falls on a weekend (Saturday or Sunday).
        case weekend
        /// Checks if the date is a workday (Monday to Friday).
        case workday
        /// Checks if the date is in the past (before the current moment).
        case past
        /// Checks if the date is in the future (after the current moment).
        case future
        /// Checks if the date falls within the current specified calendar component (e.g., current month or year).
        case this(Calendar.Component)
        /// Checks if the date is on the same calendar day as the given date.
        case sameDay(Date)
        /// Checks if the specified calendar component matches that of another date.
        case same(Calendar.Component, as: Date)
        /// Checks if the date falls within the next or previous N values of the specified calendar component. If the value is positive, it checks the next N of the component; if negative, it checks the last N.
        case within(Int, Calendar.Component)
        /// Checks if the date falls within the previous calendar component period (e.g., last month, last year).
        case previous(Calendar.Component)
        /// Checks if the date falls within the next calendar component period (e.g., next month, next year).
        case next(Calendar.Component)
    }

    static func == (lhs: Date, rhs: Comparison) -> Bool {
        var from: Date
        let to: Date
        switch rhs {
        case .today:
            return lhs.isToday()
        case .yesterday:
            return lhs.isYesterday()
        case .tomorrow:
            return lhs.isTomorrow()
        case .weekend:
            return lhs.isWeekend()
        case .workday:
            return lhs.isWorkday()
        case .past:
            return lhs < Date()
        case .future:
            return lhs > Date()
        case let .this(unit):
            from = lhs.beginning(of: unit) ?? lhs
            to = from.end(of: unit) ?? from
        case let .next(unit):
            from = lhs.adding(1, to: unit)
            from = from.beginning(of: unit) ?? from
            to = from.end(of: unit) ?? from
        case let .within(value, unit):
            from = lhs.adding(value, to: unit)
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
            return lhs.isSameDay(as: date)
        case .same(let component, let date):
            return lhs.isInSame(component, as: date)
        }
        return lhs.isBetween(from, to)
    }
}

public func > (lhs: Date?, rhs: Date) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs > rhs
}

public func >= (lhs: Date?, rhs: Date) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs >= rhs
}

public func <= (lhs: Date?, rhs: Date) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs <= rhs
}

public func < (lhs: Date?, rhs: Date) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs < rhs
}

public func == (lhs: Date?, rhs: Date) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs == rhs
}
