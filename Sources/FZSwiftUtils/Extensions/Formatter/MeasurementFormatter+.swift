//
//  MeasurementFormatter+.swift
//
//
//  Created by Florian Zand on 18.04.25.
//

import Foundation

extension MeasurementFormatter {
    /// Creates a measurement formatter with the specified unit style, unit options and locale.
    @_disfavoredOverload
    public convenience init(unitStyle: Formatter.UnitStyle = .medium, unitOptions: UnitOptions = [], locale: Locale = .current, numberFormatter: NumberFormatter? = nil) {
        self.init()
        self.unitStyle = unitStyle
        self.unitOptions = unitOptions
        self.locale = locale
        self.numberFormatter = numberFormatter ?? self.numberFormatter
    }
    
    /// Sets the options for how the unit is formatted.
    @discardableResult
    public func unitOptions(_ options: UnitOptions) -> Self {
        unitOptions = options
        return self
    }
    
    /// Sets the unit style.
    @discardableResult
    public func unitStyle(_ style: Formatter.UnitStyle) -> Self {
        unitStyle = style
        return self
    }
    
    /// Sets the locale of the formatter.
    @discardableResult
    public func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// Sets the number formatter used to format the quantity of a measurement.
    @discardableResult
    public func numberFormatter(_ formatter: NumberFormatter) -> Self {
        numberFormatter = formatter
        return self
    }
}
