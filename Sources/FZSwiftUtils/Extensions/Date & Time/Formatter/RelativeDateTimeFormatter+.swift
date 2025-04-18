//
//  RelativeDateTimeFormatter+.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension RelativeDateTimeFormatter {
    /// Sets the calendar.
    @discardableResult
    func calendar(_ calendar: Calendar) -> Self {
        self.calendar = calendar
        return self
    }
    
    /// Sets the locale.
    @discardableResult
    func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// The style to use when describing a relative date, for example “yesterday” or “1 day ago”.
    @discardableResult
    func dateTimeStyle(_ style: DateTimeStyle) -> Self {
        dateTimeStyle = style
        return self
    }
    
    /// Sets style to use when formatting the quantity or the name of the unit, such as “1 day ago” or “one day ago”.
    @discardableResult
    func unitsStyle(_ style: UnitsStyle) -> Self {
        unitsStyle = style
        return self
    }
    
    /**
     Formats the specified time duration using the formatter’s calendar.
     
     - Parameters:
        - timeDuration:
        - inPast: A Boolean value indicating whether the duration should be interpreted as occurring in the past (e.g. "2 hours ago") or in the future (e.g "in 2 hours").
     */
    func localizedString(for timeDuration: TimeDuration, inPast: Bool) {
        localizedString(fromTimeInterval: inPast ? -timeDuration.seconds : timeDuration.seconds)
    }
}
