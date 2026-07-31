//
//  NSCalendar+.swift
//
//
//  Created by Florian Zand on 10.03.23.
//

import Foundation

public extension NSCalendar.Unit {
    /// Creates a calendar unit from the specified calendar components.
    init<S: Sequence<Calendar.Component>>(_ elements: S) {
        self.init(elements.compactMap(\.nsUnit))
    }

    /// The calendar components represented by the unit.
    var components: [Calendar.Component] {
        var components: [Calendar.Component] = []
        if contains(.era) { components += .era }
        if contains(.year) { components += .year }
        if contains(.month) { components += .month }
        if contains(.day) { components += .day }
        if contains(.hour) { components += .hour }
        if contains(.minute) { components += .minute }
        if contains(.second) { components += .second }
        if contains(.weekday) { components += .weekday }
        if contains(.weekdayOrdinal) { components += .weekdayOrdinal }
        if contains(.quarter) { components += .quarter }
        if contains(.weekOfMonth) { components += .weekOfMonth }
        if contains(.weekOfYear) { components += .weekOfYear }
        if contains(.yearForWeekOfYear) { components += .yearForWeekOfYear }
        if contains(.nanosecond) { components += .nanosecond }
        if contains(.calendar) { components += .calendar }
        if contains(.timeZone) { components += .timeZone }
        return components
    }
}
