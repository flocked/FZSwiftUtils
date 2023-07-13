//
//  DateFormatter+.swift
//  
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension DateFormatter {
    /**
     Creates a `DateFormatter` with the specified date format.

     - Parameter format: The date format string to use for the `DateFormatter`.

     - Returns: A `DateFormatter` object with the specified date format.
     */
    convenience init(_ format: String) {
        self.init()
        dateFormat = format
    }
    
    /// /// The date formatter used for parsing ISO8601 dates, i.e. "2021-02-25T05:34:47+00:00".
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
}

public extension DateComponentsFormatter {
    /**
     An array of allowed calendar components for formatting.
     */
    var allowedComponents: [Calendar.Component] {
        get { allowedUnits.components }
        set {
            var unit: NSCalendar.Unit = []
            newValue.compactMap { $0.nsUnit }.forEach { unit.insert($0) }
            allowedUnits = unit
        }
    }
}
