//
//  UnitInformationStorage+.swift
//  
//
//  Created by Florian Zand on 24.04.25.
//

import Foundation

public extension UnitInformationStorage {
    func localized(to locale: Locale, unitStyle: Formatter.UnitStyle = .medium) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = unitStyle
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
