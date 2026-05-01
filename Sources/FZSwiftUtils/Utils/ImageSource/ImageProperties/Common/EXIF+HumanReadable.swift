//
//  EXIF+HumanReadable.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageProperties.EXIF {
    var humanReadable: HumanReadable {
        HumanReadable(self)
    }

    struct HumanReadable {
        public var fNumber: String? {
            guard let f = exif.fNumber, f > 0.0 else {
                return nil
            }
            // Default to showing one decimal place...
            let oneTenthPrecisionfNumber = round(f * 10.0) / 10.0
            let integerAperture = Int(oneTenthPrecisionfNumber)

            // ..but avoid displaying .0
            if oneTenthPrecisionfNumber == Double(integerAperture) {
                return "f/\(integerAperture)"
            }

            return "f/\(oneTenthPrecisionfNumber)"
        }

        public var focalLength: String? {
            guard let f = exif.focalLength, f > 0.0 else {
                return nil
            }

            let mm = Int(round(f))
            return "\(mm)mm"
        }

        public var focalLength35mm: String? {
            guard let f = exif.focalLengthIn35mmFilm, f > 0.0 else {
                return nil
            }

            let mm = Int(round(f))
            return "(\(mm)mm)"
        }

        public var iso: String? {
            guard let iso = exif.isoSpeed as? Double, iso > 0.0 else {
                return exif.isoSpeed as? String
            }

            let integerISO = Int(round(iso))
            return "ISO \(integerISO)"
        }

        public var shutterSpeed: String? {
            guard let s = exif.shutterSpeedValue, s > 0.0 else {
                return nil
            }

            if s < 1.0 {
                let dividend = Int(round(1.0 / s))
                return "1/\(dividend)"
            }

            let oneTenthPrecisionSeconds = round(s * 10.0) / 10.0
            return "\(oneTenthPrecisionSeconds)s"
        }

        let exif: ImageProperties.EXIF
        init(_ exif: ImageProperties.EXIF) {
            self.exif = exif
        }
    }
}
