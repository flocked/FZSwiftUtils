//
//  EXIF+HumanReadable.swift
//  
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageProperties.EXIF {
    var humanReadable: HumanReadable {
        return HumanReadable(self)
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
            guard let f = exif.focalLength35mm, f > 0.0 else {
                return nil
            }

            let mm = Int(round(f))
            return "(\(mm)mm)"
        }

        public var iso: String? {
            guard let iso = exif.isoSpeed, iso > 0.0 else {
                return nil
            }

            let integerISO = Int(round(iso))
            return "ISO \(integerISO)"
        }

        public var shutterSpeed: String? {
            guard let s = exif.shutterSpeed, s > 0.0 else {
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

extension ImageProperties.EXIF.FlashMode {
    var humanReadable: String {
        switch self {
        case .unknown:
            return "unknown"
        case .noFlash:
            return "No flash"
        case .fired:
            return "Fired"
        case .firedNotReturned:
            return "Fired, return not detected"
        case .firedReturned:
            return "Fired, return detected"
        case .onNotFired:
            return "On, did not fire"
        case .onFired:
            return "On, fired"
        case .onNotReturned:
            return "On, return not detected"
        case .onReturned:
            return "On, return detected"
        case .offNotFired:
            return "Off, did not fire"
        case .offNotFiredNotReturned:
            return "Off, did not fire, return not detected"
        case .autoNotFired:
            return "Auto, did not fire"
        case .autoFired:
            return "Auto, fired"
        case .autoFiredNotReturned:
            return "Auto, fired, return not detected"
        case .autoFiredReturned:
            return "Auto, fired, return detected"
        case .noFlashFunction:
            return "No flash function"
        case .offNoFlashFunction:
            return "Off, no flash function"
        case .firedRedEye:
            return "Fired, red-eye reduction"
        case .firedRedEyeNotReturned:
            return "Fired, red-eye reduction, return not detected"
        case .firedRedEyeReturned:
            return "Fired, red-eye reduction, return detected"
        case .onRedEye:
            return "On, red-eye reduction"
        case .onRedEyeNotReturned:
            return "On, red-eye reduction, return not detected"
        case .onRedEyeReturned:
            return "On, red-eye reduction, return detected"
        case .offRedEye:
            return "Off, red-eye reduction"
        case .autoNotFiredRedEye:
            return "Auto, did not fire, red-eye reduction"
        case .autoFiredRedEye:
            return "Auto, fired, red-eye reduction"
        case .autoFiredRedEyeNotReturned:
            return "Auto, fired, red-eye reduction, return not detected"
        case .autoFiredRedEyeReturned:
            return "Auto, fired, red-eye reduction, return detected"
        }
    }
}
