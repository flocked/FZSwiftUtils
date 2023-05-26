//
//  ByteCountFormatter+.swift
//  FZExtensions
//
//  Created by Florian Zand on 07.06.22.
//

import Foundation

public extension ByteCountFormatter {
    convenience init(allowedUnits: Units, countStyle: CountStyle = .file) {
        self.init()
        self.allowedUnits = allowedUnits
        self.countStyle = countStyle
    }

    func localizedString(from measurement: Measurement<UnitInformationStorage>, locale: Locale) -> String {
        let string = self.string(from: measurement)
        return localizedString(string, locale: locale)
    }

    func localizedString(fromByteCount byteCount: Int64, locale: Locale) -> String {
        let string = self.string(fromByteCount: byteCount)
        return localizedString(string, locale: locale)
    }

    func localizedString(for obj: Any?, locale: Locale) -> String? {
        let string = string(for: obj)
        if let string = string {
            return localizedString(string, locale: locale)
        }
        return string
    }

    internal func localizedString(_ string: String, locale: Locale) -> String {
        var string = string
        if includesUnit {
            let englishDescriptions = localizedDescriptions(for: locale)
            let localizedDescriptions = localizedDescriptions(for: locale)
            for (index, description) in localizedDescriptions.enumerated() {
                string = string.replacingOccurrences(of: englishDescriptions[index], with: description)
            }
        }
        return string
    }

    internal func localizedDescriptions(for locale: Locale) -> [String] {
        let units: [UnitInformationStorage] = [.bytes, .kilobytes, .megabytes, .gigabytes, .terabytes, .petabytes, .zettabytes, .yottabytes]
        return units.map { unit -> String in
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .short
            formatter.locale = locale
            return formatter.string(from: unit)
        }
    }
}
