//
//  DateComponentsFormatter+.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension DateComponentsFormatter {
    /// The allowed calendar components for formatting.
    var allowedComponents: [Calendar.Component] {
        get { allowedUnits.components }
        set { allowedUnits = NSCalendar.Unit(newValue.compactMap(\.nsUnit)) }
    }
}
