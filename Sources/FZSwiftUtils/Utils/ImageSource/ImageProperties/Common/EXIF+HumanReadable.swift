//
//  EXIF+HumanReadable.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageSource.ImageProperties.EXIF {
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
            guard let iso = exif.isoSpeed?.value as? Double, iso > 0.0 else {
                return exif.isoSpeed?.value as? String
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

        let exif: ImageSource.ImageProperties.EXIF
        init(_ exif: ImageSource.ImageProperties.EXIF) {
            self.exif = exif
        }
    }
}

extension ImageSource.ImageProperties.EXIF.FlashMode {
    var humanReadable: String {
        switch self {
        case .noFlash:
            return "No flash"
        case .fired:
            return "Fired"
        case .firedReturnNotDetected:
            return "Fired, return not detected"
        case .firedReturnDetected:
            return "Fired, return detected"
        case .onDidNotFire:
            return "On, did not fire"
        case .onFired:
            return "On, fired"
        case .onReturnNotDetected:
            return "On, return not detected"
        case .onReturnDetected:
            return "On, return detected"
        case .offDidNotFire:
            return "Off, did not fire"
        case .offDidNotFireReturnNotDetected:
            return "Off, did not fire, return not detected"
        case .autoDidNotFire:
            return "Auto, did not fire"
        case .autoFired:
            return "Auto, fired"
        case .autoFiredReturnNotDetected:
            return "Auto, fired, return not detected"
        case .autoFiredReturnDetected:
            return "Auto, fired, return detected"
        case .noFlashFunction:
            return "No flash function"
        case .offNoFlashFunction:
            return "Off, no flash function"
        case .firedRedEyeReduction:
            return "Fired, red-eye reduction"
        case .firedRedEyeReductionReturnNotDetected:
            return "Fired, red-eye reduction, return not detected"
        case .firedRedEyeReductionReturnDetected:
            return "Fired, red-eye reduction, return detected"
        case .onRedEyeReduction:
            return "On, red-eye reduction"
        case .onRedEyeReductionReturnNotDetected:
            return "On, red-eye reduction, return not detected"
        case .onRedEyeReductionReturnDetected:
            return "On, red-eye reduction, return detected"
        case .offRedEyeReduction:
            return "Off, red-eye reduction"
        case .autoDidNotFireRedEyeReduction:
            return "Auto, did not fire, red-eye reduction"
        case .autoFiredRedEyeReduction:
            return "Auto, fired, red-eye reduction"
        case .autoFiredRedEyeReductionReturnNotDetected:
            return "Auto, fired, red-eye reduction, return not detected"
        case .autoFiredRedEyeReductionReturnDetected:
            return "Auto, fired, red-eye reduction, return detected"
        }
    }
}
