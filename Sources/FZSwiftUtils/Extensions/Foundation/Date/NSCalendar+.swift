//
//  NSCalendar+.swift
//  
//
//  Created by Florian Zand on 10.03.23.
//

import Foundation

extension NSCalendar.Unit {
    public static var allCases: NSCalendar.Unit {
        return  NSCalendar.Unit([.nanosecond, .second, .minute, .hour, .day, .weekOfMonth, .month, .year])
    }
    public var components: [Calendar.Component] {
        var components: [Calendar.Component] = []
        if (self.contains(.era)) { components.append(.era)}
        if (self.contains(.year)) { components.append(.year)}
        if (self.contains(.month)) { components.append(.month)}
        if (self.contains(.day)) { components.append(.day)}
        if (self.contains(.hour)) { components.append(.hour)}
        if (self.contains(.minute)) { components.append(.minute)}
        if (self.contains(.second)) { components.append(.second)}
        if (self.contains(.weekday)) { components.append(.weekday)}
        if (self.contains(.weekdayOrdinal)) { components.append(.weekdayOrdinal)}
        if (self.contains(.quarter)) { components.append(.quarter)}
        if (self.contains(.weekOfMonth)) { components.append(.weekOfMonth)}
        if (self.contains(.weekOfYear)) { components.append(.weekOfYear)}
        if (self.contains(.yearForWeekOfYear)) { components.append(.yearForWeekOfYear)}
        if (self.contains(.nanosecond)) { components.append(.nanosecond)}
        if (self.contains(.calendar)) { components.append(.calendar)}
        if (self.contains(.timeZone)) { components.append(.timeZone)}
        return components
    }
}
