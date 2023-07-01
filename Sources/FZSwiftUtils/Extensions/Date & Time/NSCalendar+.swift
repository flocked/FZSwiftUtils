//
//  NSCalendar+.swift
//
//
//  Created by Florian Zand on 10.03.23.
//

import Foundation

public extension NSCalendar.Unit {
    /// Returns an array containing all unit's.
    static var allCases: NSCalendar.Unit {
        return NSCalendar.Unit([.nanosecond, .second, .minute, .hour, .day, .weekOfMonth, .month, .year])
    }

    var components: [Calendar.Component] {
        var components: [Calendar.Component] = []
        if contains(.era) { components.append(.era) }
        if contains(.year) { components.append(.year) }
        if contains(.month) { components.append(.month) }
        if contains(.day) { components.append(.day) }
        if contains(.hour) { components.append(.hour) }
        if contains(.minute) { components.append(.minute) }
        if contains(.second) { components.append(.second) }
        if contains(.weekday) { components.append(.weekday) }
        if contains(.weekdayOrdinal) { components.append(.weekdayOrdinal) }
        if contains(.quarter) { components.append(.quarter) }
        if contains(.weekOfMonth) { components.append(.weekOfMonth) }
        if contains(.weekOfYear) { components.append(.weekOfYear) }
        if contains(.yearForWeekOfYear) { components.append(.yearForWeekOfYear) }
        if contains(.nanosecond) { components.append(.nanosecond) }
        if contains(.calendar) { components.append(.calendar) }
        if contains(.timeZone) { components.append(.timeZone) }
        return components
    }
}
