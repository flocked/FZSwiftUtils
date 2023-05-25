//
//  DateFormatter+.swift
//  FZCollection
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension DateFormatter {
    convenience init(_ format: String) {
        self.init()
        self.dateFormat = format
    }
}

public extension DateComponentsFormatter {
    var allowedComponents: [Calendar.Component] {
        get { allowedUnits.components }
        set {
            var unit: NSCalendar.Unit = []
            newValue.compactMap({$0.nsUnit}).forEach({unit.insert($0)})
            self.allowedUnits = unit
        }
    }
}
