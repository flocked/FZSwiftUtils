//
//  ByteCountFormatter+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

import Foundation

public extension ByteCountFormatter {
    /**
     Initializes a `ByteCountFormatter` instance with the specified allowed units and count style.

     - Parameter allowedUnits: The allowed units for formatting byte counts.
     - Parameter countStyle: The count style for formatting byte counts. Default value is `.file`.
     */
    convenience init(allowedUnits: Units, countStyle: CountStyle = .file) {
        self.init()
        self.allowedUnits = allowedUnits
        self.countStyle = countStyle
    }

    /**
     Returns the localized string representation of the given `Measurement` object.

     - Parameter measurement: The `Measurement` object representing the byte count.
     - Parameter locale: The locale to use for localization.
     - Returns: The localized string representation of the byte count.
     */
    func localizedString(from measurement: Measurement<UnitInformationStorage>, locale: Locale) -> String {
        let string = string(from: measurement)
        return localizedString(string, locale: locale)
    }

    /**
     Returns the localized string representation of the given byte count.

     - Parameter byteCount: The byte count.
     - Parameter locale: The locale to use for localization.
     - Returns: The localized string representation of the byte count.
     */
    func localizedString(fromByteCount byteCount: Int64, locale: Locale) -> String {
        let string = string(fromByteCount: byteCount)
        return localizedString(string, locale: locale)
    }

    /**
     Returns the localized string representation of the given object.

     - Parameter obj: The object to format.
     - Parameter locale: The locale to use for localization.
     - Returns: The localized string representation of the object.
     */
    func localizedString(for obj: Any?, locale: Locale) -> String? {
        let string = string(for: obj)
        if let string = string {
            return localizedString(string, locale: locale)
        }
        return string
    }

    /**
     Returns the localized string by replacing unit descriptions in the given string.

     - Parameter string: The original string.
     - Parameter locale: The locale to use for localization.
     - Returns: The localized string with replaced unit descriptions.
     */
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

    /**
     Returns the localized unit descriptions for the specified locale.

     - Parameter locale: The locale to use for localization.
     - Returns: An array of localized unit descriptions.
     */
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
