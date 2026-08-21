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
    var components: Set<Calendar.Component> {
        var components: Set<Calendar.Component> = []
        if contains(.era) { components.insert(.era) }
        if contains(.year) { components.insert(.year) }
        if contains(.month) { components.insert(.month) }
        if contains(.day) { components.insert(.day) }
        if contains(.hour) { components.insert(.hour) }
        if contains(.minute) { components.insert(.minute) }
        if contains(.second) { components.insert(.second) }
        if contains(.weekday) { components.insert(.weekday) }
        if contains(.weekdayOrdinal) { components.insert(.weekdayOrdinal) }
        if contains(.quarter) { components.insert(.quarter) }
        if contains(.weekOfMonth) { components.insert(.weekOfMonth) }
        if contains(.weekOfYear) { components.insert(.weekOfYear) }
        if contains(.yearForWeekOfYear) { components.insert(.yearForWeekOfYear) }
        if contains(.nanosecond) { components.insert(.nanosecond) }
        if contains(.calendar) { components.insert(.calendar) }
        if contains(.timeZone) { components.insert(.timeZone) }
        return components
    }
}
