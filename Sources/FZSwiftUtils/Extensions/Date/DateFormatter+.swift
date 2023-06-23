//
//  DateFormatter+.swift
//  FZCollection
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
}

public extension DateComponentsFormatter {
    var allowedComponents: [Calendar.Component] {
        get { allowedUnits.components }
        set {
            var unit: NSCalendar.Unit = []
            newValue.compactMap { $0.nsUnit }.forEach { unit.insert($0) }
            allowedUnits = unit
        }
    }
}
