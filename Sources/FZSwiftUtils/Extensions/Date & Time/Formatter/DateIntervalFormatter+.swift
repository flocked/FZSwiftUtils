//
//  DateIntervalFormatter+.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension DateIntervalFormatter {
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
    
    /// Sets the time zone.
    func timeZone(_ timeZone: TimeZone) -> Self {
        self.timeZone = timeZone
        return self
    }
    
    /// Sets the style to use when formatting hour, minute, and second information.
    func timeStyle(_ style: Style) -> Self {
        timeStyle = style
        return self
    }
    
    /// Sets the style to use when formatting day, month, and year information.
    func dateStyle(_ style: Style) -> Self {
        dateStyle = style
        return self
    }
    
    /// Sets the template for formatting one date and time value.
    func dateTemplate(_ template: String) -> Self {
        dateTemplate = template
        return self
    }
    
    /// The date components to use.
    var dateComponents: [DateFormat.DateComponent] {
        get { DateFormat(stringLiteral: dateTemplate).components() }
        set { dateTemplate = newValue.map({ $0.format }).joined() }
    }
    
    /// Sets the date components to use.
    func dateComponents(_ components: [DateFormat.DateComponent]) -> Self {
        dateComponents = components
        return self
    }
}
