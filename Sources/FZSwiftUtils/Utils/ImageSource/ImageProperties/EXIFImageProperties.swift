//
//  EXIF.swift
//  ATest
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import CoreGraphics

extension ImageProperties {
    public struct EXIF: Codable {
        public var xDimension: Double?
        public var yDimension: Double?
        public var userComment: String?
        public var fNumber: Double?
        public var isoSpeedRatings: [Double]?
        public var shutterSpeed: Double?
        public var isoSpeed: Double?
        public var aperture: Double?
        public var colorSpaceName: String?
        
        public var dateTimeOriginal: Date?

        public var colorSpace: CGColorSpace? {
            get {
                guard let name = colorSpaceName else { return nil }
                return CGColorSpace(name: name as CFString)
            }
            set {
                self.colorSpaceName = newValue?.name as String?
            }
        }
        
        public var focalLength: Double?
        public var focalLength35mm: Double?
        public var exposureCompensation: String?
        public var lensMaker: String?
        public var lensModel: String?
        
        public var isScreenshot: Bool {
            guard let userComment = userComment else { return false }
                return userComment == "Screenshot"
        }
        
        enum CodingKeys: String, CodingKey {
            case xDimension = "PixelXDimension"
            case yDimension = "PixelYDimension"
            case userComment = "UserComment"
            case fNumber = "FNumber"
            case colorSpaceName = "ColorSpace"
            case focalLength = "FocalLength"
            case focalLength35mm = "FocalLenIn35mmFilm"
            case exposureCompensation = "ExposureBiasValue"
            case lensMaker = "LensMake"
            case lensModel = "LensModel"
            case isoSpeed = "ISOSpeed"
            case aperture = "ApertureValue"
            case isoSpeedRatings = "ISOSpeedRatings"
            case shutterSpeed = "ShutterSpeedValue"
            case dateTimeOriginal = "DateTimeOriginal"

          }
        }
    }

extension ImageProperties.EXIF {
    public enum FocalPlaneResolutionUnit: Int, Codable {
         case noAbsoluteUnitOfMeasurement = 1
         case inch = 2
         case centimeter = 3
     }

     public enum SensingMethod: Int, Codable {
         case notDefined = 1
         case oneChipColorAreaSensor = 2
         case twoChipColorAreaSensor = 3
         case threeChipColorAreaSensor = 4
         case colorSequentialAreaSensor = 5
         case trilinearSensor = 7
         case colorSequentialLinearSensor = 8
     }

     public enum CustomRendered: Int, Codable {
         case normalProcess = 0
         case customProcess = 1
     }
    
    public enum SceneCaptureType: Int, Codable {
        case standard = 0
        case landscape = 1
        case portrait = 2
        case nightScene = 3
    }

    public enum GainControl: Int, Codable {
        case none = 0
        case lowGainUp = 1
        case highGainUp = 2
        case lowGainDown = 3
        case highGainDown = 4
    }

   public enum Contrast: Int, Codable {
        case normal = 0
        case soft = 1
        case hard = 2
    }
    
    public enum Saturation: Int, Codable {
        case normal = 0
        case lowSaturation = 1
        case highSaturation = 2
    }

    public enum Sharpness: Int, Codable {
        case normal = 0
        case soft = 1
        case hard = 2
    }

   public enum SubjectDistanceRange: Int, Codable {
        case unknown = 0
        case macro = 1
        case closeView = 2
        case distantView = 3
    }
    
    public enum SensitivityType: Int, Codable {
        case unknown                                                          = 0
        case standardOutputSensitivity                                        = 1
        case recommendedExposureIndex                                         = 2
        case isoSpeed                                                         = 3
        case standardOutputSensitivityAndRecommendedExposureIndex             = 4
        case standardOutputSensitivityAndISOSpeed                             = 5
        case recommendedExposureIndexAndISOSpeed                              = 6
        case standardOutputSensitivityAndRecommendedExposureIndexAndISOSpeed  = 7
    }
    
    public enum LightSource: Int, Codable {
        case unknown = 0
        case daylight = 1
        case fluorescent = 2
        case tungstenIncandescentLight = 3
        case flash = 4
        case fineWeather = 9
        case cloudyWeather = 10
        case shade = 11
        case daylightFluorescent = 12 // (D 5700 - 7100K)
        case dayWhiteFluorescent = 13 // (N 4600 - 5400K)
        case coolWhiteFluorescent = 14 // (W 3900 - 4500K)
        case whiteFluorescent = 15 // (WW 3200 - 3700K)
        case standardLightA = 17
        case standardLightB = 18
        case standardLightC = 19
        case d55 = 20
        case d65 = 21
        case d75 = 22
        case d50 = 23
        case isoStudioTungsten = 24
        case otherLightSource = 255
    }
    public enum ExposureProgram: Int, Codable {
            case notDefined = 0
            case manual = 1
            case normalProgram = 2
            case aperturePriority = 3
            case shutterPriority = 4
            case creativeProgram = 5 // (biased toward depth of field)
            case actionProgram = 6 // (biased toward fast shutter speed)
            case portraitMode = 7 // (for closeup photos with the background out of focus)
            case landscapeMode = 8 // (for landscape photos with the background in focus)
        }
    
    public enum MeteringMode: String, Codable {
        case average = "average"
        case centerWeightedAverage = "center-weighted-average"
        case multiSpot = "multi-spot"
        case other = "other"
        case partial = "partial"
        case pattern = "pattern"
        case spot = "spot"
        case unknown = "unknown"
        
        init(meteringMode: Int?) {
            switch(meteringMode) {
                case 1:
                    self = .average
                case 2:
                    self = .centerWeightedAverage
                case 3:
                    self = .spot
                case 4:
                    self = .multiSpot
                case 5:
                    self = .pattern
                case 6:
                    self = .partial
                case 255:
                    self = .other
                case 0:
                    self = .unknown
                default:
                    self = .unknown
            }
        }
    }

    public enum WhiteBalance: String, Codable {
        case auto = "auto"
        case manual = "manual"
        case unknown = "unknown"
        init(whiteBalance: Int?) {
            switch(whiteBalance) {
                case 0:
                    self = .auto
                case 1:
                    self = .manual
                default:
                    self = .unknown
            }
        }
    }
    
    public enum FlashMode: String, Codable {
        case unknown = "unknown"
        case noFlash = "no-flash"
        case fired = "fired"
        case firedNotReturned = "fired-not-returned"
        case firedReturned = "fired-returned"
        case onNotFired = "on-not-fired"
        case onFired = "on-fired"
        case onNotReturned = "on-not-returned"
        case onReturned = "on-returned"
        case offNotFired = "off-not-fired"
        case offNotFiredNotReturned = "off-not-fired-not-returned"
        case autoNotFired = "auto-not-fired"
        case autoFired = "auto-fired"
        case autoFiredNotReturned = "auto-fired-not-returned"
        case autoFiredReturned = "auto-fired-returned"
        case noFlashFunction = "no-flash-function"
        case offNoFlashFunction = "off-no-flash-function"
        case firedRedEye = "fired-red-eye"
        case firedRedEyeNotReturned = "fired-red-eye-not-returned"
        case firedRedEyeReturned = "fired-red-eye-returned"
        case onRedEye = "on-red-eye"
        case onRedEyeNotReturned = "on-red-eye-not-returned"
        case onRedEyeReturned = "on-red-eye-returned"
        case offRedEye = "off-red-eye"
        case autoNotFiredRedEye = "auto-not-fired-red-eye"
        case autoFiredRedEye = "auto-fired-red-eye"
        case autoFiredRedEyeNotReturned = "auto-fired-red-eye-not-returned"
        case autoFiredRedEyeReturned = "auto-fired-red-eye-returned"
        
        init(flashState: Int?) {
            switch(flashState) {
                case 0:
                    self = .noFlash
                case 1:
                    self = .fired
                case 5:
                    self = .firedNotReturned
                case 7:
                    self = .firedReturned
                case 8:
                    self = .onNotFired
                case 9:
                    self = .onFired
                case 13:
                    self = .onNotReturned
                case 15:
                    self = .onReturned
                case 16:
                    self = .offNotFired
                case 20:
                    self = .offNotFiredNotReturned
                case 24:
                    self = .autoNotFired
                case 25:
                    self = .autoFired
                case 29:
                    self = .autoFiredNotReturned
                case 31:
                    self = .autoFiredReturned
                case 32:
                    self = .noFlash
                case 48:
                    self = .offNoFlashFunction
                case 65:
                    self = .firedRedEye
                case 69:
                    self = .firedRedEyeNotReturned
                case 71:
                    self = .firedRedEyeReturned
                case 73:
                    self = .onRedEye
                case 77:
                    self = .onRedEyeNotReturned
                case 79:
                    self = .onRedEyeReturned
                case 80:
                    self = .offRedEye
                case 88:
                    self = .autoNotFiredRedEye
                case 89:
                    self = .autoFiredRedEye
                case 93:
                    self = .autoFiredRedEyeNotReturned
                case 95:
                    self = .autoFiredRedEyeReturned
                default:
                    self = .unknown
            }
        }
    }
}
