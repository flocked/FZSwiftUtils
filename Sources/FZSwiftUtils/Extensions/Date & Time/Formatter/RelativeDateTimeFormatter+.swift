//
//  RelativeDateTimeFormatter+.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension RelativeDateTimeFormatter {
    /// Sets the calendar.
    func calendar(_ calendar: Calendar) -> Self {
        self.calendar = calendar
        return self
    }
    
    /// Sets the locale.
    func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// The style to use when describing a relative date, for example “yesterday” or “1 day ago”.
    func dateTimeStyle(_ style: DateTimeStyle) -> Self {
        dateTimeStyle = style
        return self
    }
    
    /// Sets style to use when formatting the quantity or the name of the unit, such as “1 day ago” or “one day ago”.
    func unitsStyle(_ style: UnitsStyle) -> Self {
        unitsStyle = style
        return self
    }
}
