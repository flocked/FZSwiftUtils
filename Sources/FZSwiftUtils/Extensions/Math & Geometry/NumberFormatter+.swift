//
//  NumberFormatter+.swift
//  FZCollection
//
//  Created by Florian Zand on 06.06.22.
//

import CoreGraphics
import Foundation

public extension NumberFormatter {
    static func decimal(min: Int = 0, max: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter(minFractionDigits: min, maxFractionDigits: max)
        formatter.numberStyle = .decimal
        return formatter
    }

    static func percent(min: Int = 0, max: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter(minFractionDigits: min, maxFractionDigits: max)
        formatter.numberStyle = .percent
        return formatter
    }

    convenience init(minFractionDigits: Int) {
        self.init()
        minimumFractionDigits = minFractionDigits
    }

    convenience init(maxFractionDigits: Int) {
        self.init()
        maximumFractionDigits = maxFractionDigits
    }

    convenience init(minFractionDigits: Int, maxFractionDigits: Int) {
        self.init()
        minimumFractionDigits = minFractionDigits
        maximumFractionDigits = maxFractionDigits
    }

    func string(from value: Double) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: Float) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: CChar) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: Bool) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: Int) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: Int16) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: Int32) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: Int64) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: UInt) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: UInt16) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: UInt32) -> String? { string(from: NSNumber(value: value)) }
    func string(from value: UInt64) -> String? { string(from: NSNumber(value: value)) }

    static func forInteger(with format: String = "#,###", numberOfDigits: Int = 0, locale: Locale? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale ?? Locale.current
        formatter.positiveFormat = format
        formatter.negativeFormat = "-\(format)"
        formatter.minimumIntegerDigits = numberOfDigits
        formatter.usesGroupingSeparator = false
        return formatter
    }

    static func forFloatingPoint(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale ?? Locale.current
        formatter.maximumFractionDigits = numberOfDigits
        formatter.positiveFormat = format
        formatter.negativeFormat = "-\(format)"

        return formatter
    }
}

public extension Int {
    func localized(with format: String = "#,###", numberOfDigits: Int = 0, locale: Locale? = nil) -> String {
        let formatter = NumberFormatter.forInteger(with: format, numberOfDigits: numberOfDigits, locale: locale)
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

public extension Double {
    func localized(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> String {
        let formatter = NumberFormatter.forFloatingPoint(with: format, numberOfDigits: numberOfDigits, locale: locale)
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

public extension Float {
    func localized(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> String {
        let formatter = NumberFormatter.forFloatingPoint(with: format, numberOfDigits: numberOfDigits, locale: locale)
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

public extension CGFloat {
    func localized(with format: String = "#.#", numberOfDigits: Int = 1, locale: Locale? = nil) -> String {
        return Double(self).localized(with: format, numberOfDigits: numberOfDigits, locale: locale)
    }
}
