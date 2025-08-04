//
//  DateFormatter+.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension DateFormatter {
    /**
     Creates a date formatter with the specified date format.

     - Parameter format: The date format string to use for the `DateFormatter`.
     */
    @_disfavoredOverload
    convenience init(_ format: String) {
        self.init()
        dateFormat = format
    }

    /// The date formatter used for parsing ISO8601 dates, i.e. "2021-02-25T05:34:47+00:00".
    static var iso8601: DateFormatter {
        let formatter = DateFormatter("yyyy-MM-dd'T'HH:mm:ssZ")
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }

    /// The date formatter used for parsing Zulu dates, i.e. "2021-02-03T20:19:55.317Z".
    static var zulu: DateFormatter {
        let formatter = DateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }
    
    /// Sets the time style.
    func style(_ style: Style) -> Self {
        dateStyle = style
        return self
    }
    
    /// Sets the date style.
    func timeStyle(_ style: Style) -> Self {
        timeStyle = style
        return self
    }
    
    /// Sets the date format string.
    @_disfavoredOverload
    func format(_ format: String) -> Self {
        dateFormat = format
        return self
    }
    
    /// Sets the calendar.
    func calendar(_ calendar: Calendar) -> Self {
        self.calendar = calendar
        return self
    }
    
    /// Sets the default date.
    func defaultDate(_ date: Date?) -> Self {
        defaultDate = date
        return self
    }
    
    /// Sets the locale.
    func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// Sets the time zone.
    func timeZone(_ timeZone: TimeZone?) -> Self {
        self.timeZone = timeZone
        return self
    }
    
    /// Sets the earliest date that can be denoted by a two-digit year specifier.
    func twoDigitStartDate(_ date: Date?) -> Self {
        twoDigitStartDate = date
        return self
    }
    
    /// Sets the start date of the Gregorian calendar.
    func gregorianStartDate(_ date: Date?) -> Self {
        gregorianStartDate = date
        return self
    }
    
    /// Sets the formatter behavior.
    func formatterBehavior(_ behavior: Behavior) -> Self {
        formatterBehavior = behavior
        return self
    }
    
    /// Sets the Boolean value indicating whether the formatter uses heuristics when parsing a string.
    func isLenient(_ isLenient: Bool) -> Self {
        self.isLenient = isLenient
        return self
    }
    
    /// Sets the Boolean value indicating whether the formatter uses phrases such as “today” and “tomorrow” for the date component.
    func doesRelativeDateFormatting(_ doesRelativeDateFormatting: Bool) -> Self {
        self.doesRelativeDateFormatting = doesRelativeDateFormatting
        return self
    }
    
    static func time(includingSeconds: Bool = true) -> DateFormatter {
        DateFormatter(includingSeconds ? "HH:mm:ss" : "HH:mm")
    }
    
    
    
    /// RFC 3339 format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    static let rfc3339 = DateFormatter("yyyy-MM-dd'T'HH:mm:ssZZZZZ").timeZone(.utc).locale(.posix).calendar(Calendar(identifier: .iso8601)).calendar(Calendar(identifier: .iso8601))
    
    /// RFC 1123 format: "EEE',' dd MMM yyyy HH':'mm':'ss zzz"
    static let rfc1123 = DateFormatter("EEE',' dd MMM yyyy HH':'mm':'ss zzz").timeZone(TimeZone(secondsFromGMT: 0)).locale(.posix)
    
    /**
     HTTP-date format (RFC 7231): "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
     
     This format is used in HTTP headers as defined in RFC 7231.
     It represents a date in GMT (e.g., "Fri, 25 Apr 2025 14:30:00 GMT").
     Commonly used in HTTP responses to specify the `Date` header.
     */
    static let httpHeader = DateFormatter("EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'").timeZone(TimeZone(abbreviation: "GMT")).locale(.posix)
}
