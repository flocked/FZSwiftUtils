//
//  EXIF.swift
//
//
//  Created by TakashiUshikoshi on 2023/06/30
//
//

import Foundation
import ImageIO

public extension ImageProperties {
    /// Exchangeable Image File Format (EXIF) data.
    struct EXIF {
        /// The raw values.
        public let rawValues: [CFString: Any]

        //  MARK: - Camera Settings
        
        /// For a particular camera mode, indicates the conditions for taking the picture.
        public let deviceSettingDescription: Any?
        
        /// The F-number.
        public let fNumber: Double?
        
        /// The shutter speed value.
        public let shutterSpeedValue: Double?
        
        /// The aperture value.
        public let apertureValue: Double?
        
        /// The maximum aperture value.
        public let maxApertureValue: Double?
        
        /// The focal length.
        public let focalLength: Double?
        
        /// The spectral sensitivity of each channel.
        public let spectralSensitivity: Double?
        
        /// The ISO speed ratings.
        public let isoSpeedRatings: [Double]?
        
        /// The distance to the subject, in meters.
        public let subjectDistance: Double?
        
        /// The metering mode.
        public let meteringMode: MeteringMode?
        
        /// The subject area.
        public let subjectArea: SubjectArea?
        
        /// The location of the image’s primary subject.
        public let subjectLocation: CGPoint?
        
        /// The sensor type of the camera or input device.
        public let sensingMethod: SensingMethod?
        
        /// The scene type.
        public let sceneType: Int?
        
        /// The digital zoom ratio.
        public let digitalZoomRatio: Double?
        
        /// The equivalent focal length in 35 mm film.
        public let focalLengthIn35mmFilm: Double?
        
        /// The scene capture type; for example, standard, landscape, portrait, or night.
        public let sceneCaptureType: SceneCaptureType?
        
        /// The distance to the subject.
        public let subjectDistanceRange: SubjectDistanceRangeType?
        
        //  MARK: - Exposure
        
        /// The exposure time.
        public let exposureTime: TimeInterval?
        
        /// The exposure program.
        public let exposureProgram: ExposureProgram?
        
        /// The selected exposure index.
        public let exposureIndex: Int?
        
        /// The exposure mode setting.
        public let exposureMode: ExposureMode?
        
        /// The ISO speed setting used to capture the image.
        public let isoSpeed: Double?
        
        /// The ISO speed latitude yyy value.
        public let isoSpeedLatitudeYYY: Double?
        
        /// The ISO speed latitude zzz value.
        public let isoSpeedLatitudeZZZ: Double?
        
        /// The recommended exposure index.
        public let recommendedExposureIndex: Int?
        
        /// The exposure bias value.
        public let exposureBiasValue: Double?
        
        /// The type of sensitivity data stored for the image.
        public let sensitivityType: SensitivityType?
        
        /// The sensitivity data for the image.
        public let standardOutputSensitivity: UInt?
        
        /// The exposure times for composite images.
        public let sourceExposureTimesOfCompositeImage: Any?
        
        //  MARK: - Image Quality
        
        /// The color filter array (CFA) pattern, which is the geometric pattern of the image sensor for a 1-chip color sensor area.
        public let cfaPattern: Any?
        
        /// The brightness value.
        public let brightnessValue: Double?
        
        /// The light source.
        public let lightSource: LightSourceType?
        
        /// The flash status when the image was shot.
        public let flash: Flash?
        
        /// The spatial frequency table and spatial frequency response values in the width, height, and diagonal directions.
        public let spatialFrequencyResponse: String?
        
        /// The contrast setting.
        public let contrast: ContrastDirection?
        
        /// The saturation setting.
        public let saturation: SaturationDirection?
        
        /// The sharpness setting.
        public let sharpness: SharpnessDirection?
        
        /// The gamma setting.
        public let gamma: Double?
        
        /// The white balance mode.
        public let whiteBalance: WhiteBalanceMode?
        
        //  MARK: - Image Settings
        
        /// The gain adjustment setting.
        public let gainControl: GainControl?
        
        /// The unique ID of the image.
        public let imageUniqueId: String?
        
        /// The bits per pixel of the compression mode.
        public let compressedBitsPerPixel: Double?
        
        /// The color space.
        public let colorSpace: ColorSpace?
        
        /// The x dimension of a pixel.
        public let pixelXDimension: UInt?
        
        /// The y dimension of a pixel.
        public let pixelYDimension: UInt?
        
        /// A sound file related to the image.
        public let relatedSoundFile: String?
        
        /// The number of image-width pixels (x-axis) per focal plane resolution unit.
        public let focalPlaneXResolution: Double?
        
        /// The number of image-height pixels (y-axis) per focal plane resolution unit.
        public let focalPlaneYResolution: Double?
        
        /// The unit of measurement for the focal plane x and y resolutions.
        public let focalPlaneResolutionUnit: ResolutionUnit?
        
        /// Special rendering performed on the image data.
        public let customRendered: CustomRenderedType?
        
        public let compositeImage: CompositeImageType?
        
        /// The opto-electric conversion function (OECF) that defines the relationship between the optical input of the camera and the resulting image.
        public let oecf: Double?
        
        /// The components configuration for compressed data.
        public let componentsConfiguration: [Int]?
        
        /// The number of images that make up a composite image.
        public let sourceImageNumberOfCompositeImage: [Int]?
        
        /// The image source.
        public let fileSource: FileSourceType?
        
        //  MARK: - Timestamp
        
        /// The original date and time.
        public let dateTimeOriginal: Date?
        
        /// The digitized date and time.
        public let dateTimeDigitized: Date?
        
        /// The fraction of seconds for the date and time tag.
        public let subsecTime: String?
        
        /// The fraction of seconds for the original date and time tag.
        public let subsecTimeOriginal: String?
        
        /// The fraction of seconds for the digitized date and time tag.
        public let subsecTimeDigitized: String?
        
        
        public let offsetTime: String?
        
        
        public let offsetTimeOriginal: String?
        
        
        public let offsetTimeDigitized: String?
        
        //  MARK: - Lens Information
        
        /// The specification information for the camera lens.
        public let lensSpecification: [Double]?
        
        /// A string with the name of the lens manufacturer.
        public let lensMake: String?
        
        /// A string with the lens model information.
        public let lensModel: String?
        
        /// A string with the lens’s serial number.
        public let lensSerialNumber: String?
        
        //  MARK: - Camera Information
        
        /// Information specified by the camera manufacturer.
        public let makerNote: String?
        
        /// A user comment.
        public let userComment: String?
        
        /// A string with the name of the camera’s owner.
        public let cameraOwnerName: String?
        
        /// A string with the serial number of the camera.
        public let bodySerialNumber: String?
        
        //  MARK: - Flash Information
        
        /// The FlashPix version supported by an FPXR file.
        public let flashpixVersion: [Int]?
        
        /// The strobe energy when the image was captured, in beam candle power seconds.
        public let flashEnergy: Int?
        
        //  MARK: - EXIF Format
        
        /// The EXIF version.
        public let exifVersion: [Int]?
        
        /// A Boolean value indicating whether the image is a screenshot.
        public var isScreenshot: Bool {
            userComment == "Screenshot"
        }
        
        /// Represents the EXIF subject area describing the location and optionally the size of the main subject within the image.
        public enum SubjectArea {
            /// A single point indicating the subject location in pixel coordinates.
            case point(x: Int, y: Int)
            /// A circular region centered at the given coordinates with the specified diameter in pixels.
            case circle(x: Int, y: Int, diameter: Int)
            /// A rectangular region defined by its top-left corner and size in pixels.
            case rectangle(x: Int, y: Int, width: Int, height: Int)
            
            init?(_ values: [Int]?) {
                guard let values else { return nil }
                    switch values.count {
                    case 2:
                        self = .point(x: values[0], y: values[1])
                    case 3:
                        self = .circle(x: values[0], y: values[1], diameter: values[2])
                    case 4:
                        self = .rectangle(x: values[0], y: values[1], width: values[2], height: values[3])
                    default:
                        return nil
                    }
                }
        }

        init(exifData: [CFString: Any]) {
            rawValues = exifData

            deviceSettingDescription = exifData[typed: kCGImagePropertyExifDeviceSettingDescription]
            fNumber = exifData[typed: kCGImagePropertyExifFNumber]
            shutterSpeedValue = exifData[typed: kCGImagePropertyExifShutterSpeedValue]
            apertureValue = exifData[typed: kCGImagePropertyExifApertureValue]
            maxApertureValue = exifData[typed: kCGImagePropertyExifMaxApertureValue]
            focalLength = exifData[typed: kCGImagePropertyExifFocalLength]
            spectralSensitivity = exifData[typed: kCGImagePropertyExifSpectralSensitivity]
            isoSpeedRatings = exifData[typed: kCGImagePropertyExifISOSpeedRatings]
            subjectDistance = exifData[typed: kCGImagePropertyExifSubjectDistance]
            meteringMode = exifData[typed: kCGImagePropertyExifMeteringMode]
            subjectArea = SubjectArea(exifData[typed: kCGImagePropertyExifSubjectArea])
            if let location: [CGFloat] = exifData[typed: kCGImagePropertyExifSubjectLocation], let x = location[safe: 0], let y = location[safe: 1] {
                subjectLocation = CGPoint(x: x, y: y)
            } else {
                subjectLocation = nil
            }
            sensingMethod = exifData[typed: kCGImagePropertyExifSensingMethod]
            sceneType = exifData[typed: kCGImagePropertyExifSceneType]
            digitalZoomRatio = exifData[typed: kCGImagePropertyExifDigitalZoomRatio]
            focalLengthIn35mmFilm = exifData[typed: kCGImagePropertyExifFocalLenIn35mmFilm]
            sceneCaptureType = exifData[typed: kCGImagePropertyExifSceneCaptureType]
            subjectDistanceRange = exifData[typed: kCGImagePropertyExifSubjectDistRange]
            
            exposureTime = exifData[typed: kCGImagePropertyExifExposureTime]
            exposureProgram = exifData[typed: kCGImagePropertyExifExposureProgram]
            exposureIndex = exifData[typed: kCGImagePropertyExifExposureIndex]
            exposureMode = exifData[typed: kCGImagePropertyExifExposureMode]
            isoSpeed = exifData[typed: kCGImagePropertyExifISOSpeed]
            isoSpeedLatitudeYYY = exifData[typed: kCGImagePropertyExifISOSpeedLatitudeyyy]
            isoSpeedLatitudeZZZ = exifData[typed: kCGImagePropertyExifISOSpeedLatitudezzz]
            recommendedExposureIndex = exifData[typed: kCGImagePropertyExifRecommendedExposureIndex]
            exposureBiasValue = exifData[typed: kCGImagePropertyExifExposureBiasValue]
            sensitivityType = exifData[typed: kCGImagePropertyExifSensitivityType]
            standardOutputSensitivity = exifData[typed: kCGImagePropertyExifStandardOutputSensitivity]
            sourceExposureTimesOfCompositeImage = exifData[kCGImagePropertyExifSourceExposureTimesOfCompositeImage]
            
            cfaPattern = exifData[kCGImagePropertyExifCFAPattern]
            brightnessValue = exifData[typed: kCGImagePropertyExifBrightnessValue]
            lightSource = exifData[typed: kCGImagePropertyExifLightSource]
            flash = exifData[typed: kCGImagePropertyExifFlash]
            spatialFrequencyResponse = exifData[typed: kCGImagePropertyExifSpatialFrequencyResponse]
            contrast = exifData[typed: kCGImagePropertyExifContrast]
            saturation = exifData[typed: kCGImagePropertyExifSaturation]
            sharpness = exifData[typed: kCGImagePropertyExifSharpness]
            gamma = exifData[typed: kCGImagePropertyExifGamma]
            whiteBalance = exifData[typed: kCGImagePropertyExifWhiteBalance]
            
            gainControl = exifData[typed: kCGImagePropertyExifGainControl]
            imageUniqueId = exifData[typed: kCGImagePropertyExifImageUniqueID]
            compressedBitsPerPixel = exifData[typed: kCGImagePropertyExifCompressedBitsPerPixel]
            colorSpace = exifData[typed: kCGImagePropertyExifColorSpace]
            pixelXDimension = exifData[typed: kCGImagePropertyExifPixelXDimension]
            pixelYDimension = exifData[typed: kCGImagePropertyExifPixelYDimension]
            relatedSoundFile = exifData[typed: kCGImagePropertyExifRelatedSoundFile]
            focalPlaneXResolution = exifData[typed: kCGImagePropertyExifFocalPlaneXResolution]
            focalPlaneYResolution = exifData[typed: kCGImagePropertyExifFocalPlaneYResolution]
            focalPlaneResolutionUnit = exifData[typed: kCGImagePropertyExifFocalPlaneResolutionUnit]
            customRendered = exifData[typed: kCGImagePropertyExifCustomRendered]
            compositeImage = exifData[typed: kCGImagePropertyExifCompositeImage]
            oecf = exifData[typed: kCGImagePropertyExifOECF]
            componentsConfiguration = exifData[typed: kCGImagePropertyExifComponentsConfiguration]
            sourceImageNumberOfCompositeImage = exifData[typed: kCGImagePropertyExifSourceImageNumberOfCompositeImage]
            fileSource = exifData[typed: kCGImagePropertyExifFileSource]
            
            dateTimeOriginal = exifData[typed: kCGImagePropertyExifDateTimeOriginal, using: ImageProperties.dateFormatter]
            dateTimeDigitized = exifData[typed: kCGImagePropertyExifDateTimeDigitized, using: ImageProperties.dateFormatter]
            subsecTime = exifData[typed: kCGImagePropertyExifSubsecTime]
            subsecTimeOriginal = exifData[typed: kCGImagePropertyExifSubsecTimeOriginal]
            subsecTimeDigitized = exifData[typed: kCGImagePropertyExifSubsecTimeDigitized]
            offsetTime = exifData[typed: kCGImagePropertyExifOffsetTime]
            offsetTimeOriginal = exifData[typed: kCGImagePropertyExifOffsetTimeOriginal]
            offsetTimeDigitized = exifData[typed: kCGImagePropertyExifOffsetTimeDigitized]
            
            lensSpecification = exifData[typed: kCGImagePropertyExifLensSpecification]
            lensMake = exifData[typed: kCGImagePropertyExifLensMake]
            lensModel = exifData[typed: kCGImagePropertyExifLensModel]
            lensSerialNumber = exifData[typed: kCGImagePropertyExifLensSerialNumber]
            
            makerNote = exifData[typed: kCGImagePropertyExifMakerNote]
            userComment = exifData[typed: kCGImagePropertyExifUserComment]
            cameraOwnerName = exifData[typed: kCGImagePropertyExifCameraOwnerName]
            bodySerialNumber = exifData[typed: kCGImagePropertyExifBodySerialNumber]
            
            flashpixVersion = exifData[typed: kCGImagePropertyExifFlashPixVersion]
            flashEnergy = exifData[typed: kCGImagePropertyExifFlashEnergy]
            exifVersion = exifData[typed: kCGImagePropertyExifVersion]
        }
    }
}

public extension ImageProperties.EXIF {
    /// The color space used to encode the image.
    enum ColorSpace: Int, Codable, Hashable, Sendable {
        /// The image uses the sRGB color space.
        case sRGB = 0x1
        /// The image uses the Adobe RGB color space.
        case adobeRGB = 0x2
        /// The image uses a wide-gamut RGB color space.
        case wideGamutRGB = 0xfffd
        /// The image uses an embedded ICC profile.
        case iccProfile = 0xfffe
        /// The image uses an uncalibrated color space.
        case uncalibrated = 0xffff
    }

    /// The composite image state of the image.
    enum CompositeImageType: Int, Codable, Hashable, Sendable {
        /// The composite image state is unknown.
        case unknown = 0
        /// The image is not a composite image.
        case notCompositeImage = 1
        /// The image is a general composite image.
        case generalCompositeImage = 2
        /// The image is a composite image captured while shooting.
        case compositeImageCapturedWhileShooting = 3
    }

    /// The contrast setting applied to the image.
    enum ContrastDirection: Int, Codable, Hashable, Sendable {
        /// The image uses normal contrast.
        case normal = 0
        /// The image uses soft contrast.
        case soft = 1
        /// The image uses hard contrast.
        case hard = 2
    }

    /// The custom rendering mode applied to the image.
    enum CustomRenderedType: Int, Codable, Hashable, Sendable {
        //  MARK: - standard Exif
        /// The image uses normal rendering.
        case normal = 0
        /// The image uses custom rendering.
        case custom = 1
        
        // MARK: - used by Apple iOS devices
        /// The image is an HDR image without the original being saved.
        case hdrNoOriginalSaved = 2
        /// The image is an HDR image with the original also saved.
        case hdrOriginalSaved = 3
        /// The image is the original image used for HDR generation.
        case originalForHDR = 4
        /// The image is a panorama.
        case panorama = 6
        /// The image is a portrait HDR capture.
        case portraitHDR = 7
        /// The image is a portrait capture.
        case portrait = 8
    }

    /// The exposure mode used to capture the image.
    enum ExposureMode: Int, Codable, Hashable, Sendable {
        /// The image uses automatic exposure.
        case auto = 0
        /// The image uses manual exposure.
        case manual = 1
        /// The image uses auto bracketing.
        case autoBracket = 2
    }

    /// The exposure program used to capture the image.
    enum ExposureProgram: Int, Codable, Hashable, Sendable {
        /// The exposure program is not defined.
        case notDefined = 0
        /// The image was captured using manual exposure.
        case manual = 1
        /// The image was captured using the normal program.
        case normalProgram = 2
        /// The image was captured using aperture priority.
        case aperturePriority = 3
        /// The image was captured using shutter priority.
        case shutterPriority = 4
        /// The image was captured using a creative program.
        case creativeProgram = 5
        /// The image was captured using an action program.
        case actionProgram = 6
        /// The image was captured using portrait mode.
        case portraitMode = 7
        /// The image was captured using landscape mode.
        case landscapeMode = 8
    }

    /// The file source from which the image data originated.
    enum FileSourceType: Int, Codable, Hashable, Sendable {
        /// The image data originated from a film scanner.
        case filmScanner = 1
        /// The image data originated from a reflection print scanner.
        case reflectionPrintScanner = 2
        /// The image data originated from a digital camera.
        case digitalCamera = 3
        /// The image data originated from an unknown source.
        case unknown = 0
    }
    
    /// Represents EXIF flash metadata.
    public struct Flash: RawRepresentable, CustomStringConvertible {
        public let rawValue: Int
        
        /// The flash flags stored in the EXIF value.
        public let options: Options
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
            self.options = Options(rawValue: rawValue)
        }

        /// A Boolean value indicating whether the flash fired.
        public var didFire: Bool {
            options.contains(.fired)
        }
        
        /// A Boolean value indicating whether the camera reported no flash function.
        public var hasNoFlashFunction: Bool {
            options.contains(.noFlashFunction)
        }

        /// A Boolean value indicating whether red-eye reduction mode was used.
        public var usedRedEyeReduction: Bool {
            options.contains(.redEyeReduction)
        }

        /// The strobe return detection status.
        public var returnStatus: ReturnStatus {
            switch (rawValue >> 1) & 0b11 {
            case 0: return .notAvailable
            case 2: return .notDetected
            case 3: return .detected
            default: return .reserved
            }
        }

        /// The flash firing mode.
        public var mode: FlashMode {
            switch (rawValue >> 3) & 0b11 {
            case 0: return .unknown
            case 1: return .compulsoryFiring
            case 2: return .compulsorySuppression
            case 3: return .auto
            default: return .unknown
            }
        }
        
        /// Represents EXIF flash bit flags.
        public struct Options: OptionSet {

            public let rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            /// The flash fired.
            public static let fired = Self(rawValue: 1 << 0)
            /// The camera has no flash function.
            public static let noFlashFunction = Self(rawValue: 1 << 5)
            /// Red-eye reduction mode was used.
            public static let redEyeReduction = Self(rawValue: 1 << 6)
        }
        
        /// Represents the EXIF strobe return detection status.
        public enum ReturnStatus {
            /// No strobe return detection function was available.
            case notAvailable
            /// Strobe return light was not detected.
            case notDetected
            /// Strobe return light was detected.
            case detected
            /// The return detection bits contain a reserved value.
            case reserved
        }
        
        /// Represents the EXIF flash firing mode.
        public enum FlashMode {
            /// The flash mode is unknown.
            case unknown
            /// Flash firing was compulsory.
            case compulsoryFiring
            /// Flash suppression was compulsory.
            case compulsorySuppression
            /// Flash was in automatic mode.
            case auto
        }
        
        public var description: String {
            var parts = [didFire ? "fired" : "not fired"]
            switch mode {
            case .compulsoryFiring: parts += "forced on"
            case .compulsorySuppression: parts += "forced off"
            case .auto: parts += "auto"
            case .unknown: break

            }
            switch returnStatus {
            case .detected: parts += "return detected"
            case .notDetected: parts += "return not detected"
            case .notAvailable, .reserved: break
            }
            if usedRedEyeReduction {
                parts += "red-eye reduction"
            }
            if hasNoFlashFunction {
                parts += "no flash function"
            }
            return parts.joined(separator: ", ")
        }
    }


    /// The gain adjustment applied during image capture.
    enum GainControl: Int, Codable, Hashable, Sendable {
        /// No gain adjustment was applied.
        case none = 0
        /// A low gain increase was applied.
        case lowGainUp = 1
        /// A high gain increase was applied.
        case highGainUp = 2
        /// A low gain reduction was applied.
        case lowGainDown = 3
        /// A high gain reduction was applied.
        case highGainDown = 4
    }

    /// The light source used when the image was captured.
    enum LightSourceType: Int, Codable, Hashable, Sendable {
        /// The light source is unknown.
        case unknown = 0
        /// The image was captured in daylight.
        case daylight = 1
        /// The image was captured under fluorescent lighting.
        case fluorescent = 2
        /// The image was captured under tungsten lighting.
        case tungsten = 3
        /// The image was captured with flash illumination.
        case flash = 4
        /// The image was captured in fine weather.
        case fineWeather = 9
        /// The image was captured in cloudy weather.
        case cloudyWeather = 10
        /// The image was captured in shade.
        case shade = 11
        /// The image was captured under daylight fluorescent lighting.
        case daylightFluorescent = 12
        /// The image was captured under day white fluorescent lighting.
        case dayWhiteFluorescent = 13
        /// The image was captured under cool white fluorescent lighting.
        case coolWhiteFluorescent = 14
        /// The image was captured under white fluorescent lighting.
        case whiteFluorescent = 15
        /// The image was captured under standard light A.
        case standardLightA = 17
        /// The image was captured under standard light B.
        case standardLightB = 18
        /// The image was captured under standard light C.
        case standardLightC = 19
        /// The image was captured under D55 lighting.
        case D55 = 20
        /// The image was captured under D65 lighting.
        case D65 = 21
        /// The image was captured under D75 lighting.
        case D75 = 22
        /// The image was captured under D50 lighting.
        case D50 = 23
        /// The image was captured under ISO studio tungsten lighting.
        case isoStudioTungsten = 24
        /// The image was captured under another light source.
        case other = 255
    }

    /// The metering mode used to determine the exposure.
    enum MeteringMode: Int, Codable, Hashable, Sendable {
        /// The metering mode is unknown.
        case unknown = 0
        /// The image uses average metering.
        case average = 1
        /// The image uses center-weighted average metering.
        case centerWeightedAverage = 2
        /// The image uses spot metering.
        case spot = 3
        /// The image uses multi-spot metering.
        case multiSpot = 4
        /// The image uses pattern metering.
        case pattern = 5
        /// The image uses partial metering.
        case partial = 6
        /// The image uses another metering mode.
        case other = 255
    }

    /// The pixel format used to encode the image data.
    enum PixelFormatType: Int, Codable, Sendable {
        /// The image uses a black and white pixel format.
        case blackWhite = 0x5
        /// The image uses an 8-bit grayscale pixel format.
        case _8BitGray = 0x8
        /// The image uses a 16-bit BGR555 pixel format.
        case _16BitBGR555 = 0x9
        /// The image uses a 16-bit BGR565 pixel format.
        case _16BitBGR565 = 0xa
        /// The image uses a 16-bit grayscale pixel format.
        case _16BitGray = 0xb
        /// The image uses a 24-bit BGR pixel format.
        case _24BitBGR = 0xc
        /// The image uses a 24-bit RGB pixel format.
        case _24BitRGB = 0xd
        /// The image uses a 32-bit BGR pixel format.
        case _32BitBGR = 0xe
        /// The image uses a 32-bit BGRA pixel format.
        case _32BitBGRA = 0xf
        /// The image uses a 32-bit premultiplied BGRA pixel format.
        case _32BitPBGRA = 0x10
        /// The image uses a 32-bit grayscale floating-point pixel format.
        case _32BitGrayFloat = 0x11
        /// The image uses a 48-bit RGB fixed-point pixel format.
        case _48BitRGBFixedPoint = 0x12
        /// The image uses a 32-bit BGR101010 pixel format.
        case _32BitBGR101010 = 0x13
        /// The image uses a 48-bit RGB pixel format.
        case _48BitRGB = 0x15
        /// The image uses a 64-bit RGBA pixel format.
        case _64BitRGBA = 0x16
        /// The image uses a 64-bit premultiplied RGBA pixel format.
        case _64BitPRGBA = 0x17
        /// The image uses a 96-bit RGB fixed-point pixel format.
        case _96BitRGBFixedPoint = 0x18
        /// The image uses a 128-bit RGBA floating-point pixel format.
        case _128BitRGBAFloat = 0x19
        /// The image uses a 128-bit premultiplied RGBA floating-point pixel format.
        case _128BitPRGBAFloat = 0x1a
        /// The image uses a 128-bit RGB floating-point pixel format.
        case _128BitRGBFloat = 0x1b
        /// The image uses a 32-bit CMYK pixel format.
        case _32BitCMYK = 0x1c
        /// The image uses a 64-bit RGBA fixed-point pixel format.
        case _64BitRGBAFixedPoint = 0x1d
        /// The image uses a 128-bit RGBA fixed-point pixel format.
        case _128BitRGBAFixedPoint = 0x1e
        /// The image uses a 64-bit CMYK pixel format.
        case _64BitCMYK = 0x1f
        /// The image uses a 24-bit three-channel pixel format.
        case _24Bit3Channels = 0x20
        /// The image uses a 32-bit four-channel pixel format.
        case _32Bit4Channels = 0x21
        /// The image uses a 40-bit five-channel pixel format.
        case _40Bit5Channels = 0x22
        /// The image uses a 48-bit six-channel pixel format.
        case _48Bit6Channels = 0x23
        /// The image uses a 56-bit seven-channel pixel format.
        case _56Bit7Channels = 0x24
        /// The image uses a 64-bit eight-channel pixel format.
        case _64Bit8Channels = 0x25
        /// The image uses a 48-bit three-channel pixel format.
        case _48Bit3Channels = 0x26
        /// The image uses a 64-bit four-channel pixel format.
        case _64Bit4Channels = 0x27
        /// The image uses an 80-bit five-channel pixel format.
        case _80Bit5Channels = 0x28
        /// The image uses a 96-bit six-channel pixel format.
        case _96Bit6Channels = 0x29
        /// The image uses a 112-bit seven-channel pixel format.
        case _112Bit7Channels = 0x2a
        /// The image uses a 128-bit eight-channel pixel format.
        case _128Bit8Channels = 0x2b
        /// The image uses a 40-bit CMYK plus alpha pixel format.
        case _40BitCMYKAlpha = 0x2c
        /// The image uses an 80-bit CMYK plus alpha pixel format.
        case _80BitCMYKAlpha = 0x2d
        /// The image uses a 32-bit three-channel plus alpha pixel format.
        case _32Bit3ChannelsAlpha = 0x2e
        /// The image uses a 40-bit four-channel plus alpha pixel format.
        case _40Bit4ChannelsAlpha = 0x2f
        /// The image uses a 48-bit five-channel plus alpha pixel format.
        case _48Bit5ChannelsAlpha = 0x30
        /// The image uses a 56-bit six-channel plus alpha pixel format.
        case _56Bit6ChannelsAlpha = 0x31
        /// The image uses a 64-bit seven-channel plus alpha pixel format.
        case _64Bit7ChannelsAlpha = 0x32
        /// The image uses a 72-bit eight-channel plus alpha pixel format.
        case _72Bit8ChannelsAlpha = 0x33
        /// The image uses a 64-bit three-channel plus alpha pixel format.
        case _64Bit3ChannelsAlpha = 0x34
        /// The image uses an 80-bit four-channel plus alpha pixel format.
        case _80Bit4ChannelsAlpha = 0x35
        /// The image uses a 96-bit five-channel plus alpha pixel format.
        case _96Bit5ChannelsAlpha = 0x36
        /// The image uses a 112-bit six-channel plus alpha pixel format.
        case _112Bit6ChannelsAlpha = 0x37
        /// The image uses a 128-bit seven-channel plus alpha pixel format.
        case _128Bit7ChannelsAlpha = 0x38
        /// The image uses a 144-bit eight-channel plus alpha pixel format.
        case _144Bit8ChannelsAlpha = 0x39
        /// The image uses a 64-bit half-float RGBA pixel format.
        case _64BitRGBAHalf = 0x3a
        /// The image uses a 48-bit half-float RGB pixel format.
        case _48BitRGBHalf = 0x3b
        /// The image uses a 32-bit RGBE pixel format.
        case _32BitRGBE = 0x3d
        /// The image uses a 16-bit half-float grayscale pixel format.
        case _16BitGrayHalf = 0x3e
        /// The image uses a 32-bit grayscale fixed-point pixel format.
        case _32BitGrayFixedPoint = 0x3f
    }

    /// The unit used for focal plane resolution values.
    enum ResolutionUnit: Int, Codable, Hashable, Sendable {
        /// The resolution uses no absolute unit.
        case none = 1
        /// The resolution is expressed in inches.
        case inches = 2
        /// The resolution is expressed in centimeters.
        case centimeter = 3
    }

    /// The saturation setting applied to the image.
    enum SaturationDirection: Int, Codable, Hashable, Sendable {
        /// The image uses normal saturation.
        case normal = 0
        /// The image uses low saturation.
        case low = 1
        /// The image uses high saturation.
        case high = 2
    }

    /// The intended scene capture type of the image.
    enum SceneCaptureType: Int, Codable, Hashable, Sendable {
        /// The image uses a standard scene capture type.
        case standard = 0
        /// The image uses a landscape scene capture type.
        case landscape = 1
        /// The image uses a portrait scene capture type.
        case portrait = 2
        /// The image uses a night scene capture type.
        case nightScene = 3
    }

    /// The sensor arrangement used to capture the image.
    enum SensingMethod: Int, Codable, Hashable, Sendable {
        /// The sensing method is not defined.
        case notDefined = 1
        /// The image was captured with a one-chip color area sensor.
        case oneChipColorAreaSensor = 2
        /// The image was captured with a two-chip color area sensor.
        case twoChipColorAreaSensor = 3
        /// The image was captured with a three-chip color area sensor.
        case threeChipColorAreaSensor = 4
        /// The image was captured with a color sequential area sensor.
        case colorSequentialAreaSensor = 5
        /// The image was captured with a trilinear sensor.
        case trilinearSensor = 7
        /// The image was captured with a color sequential linear sensor.
        case colorSequentialLinearSensor = 8
    }

    /// The sharpness setting applied to the image.
    enum SharpnessDirection: Int, Codable, Hashable, Sendable {
        /// The image uses normal sharpness.
        case normal = 0
        /// The image uses soft sharpness.
        case soft = 1
        /// The image uses hard sharpness.
        case hard = 2
    }

    /// The sensitivity definition used by the image metadata.
    enum SensitivityType: Int, Codable, Hashable, Sendable {
        /// The sensitivity type is unknown.
        case unknown = 0
        /// The sensitivity is expressed as standard output sensitivity.
        case standardOutputSensitivity = 1
        /// The sensitivity is expressed as a recommended exposure index.
        case recommendedExposureIndex = 2
        /// The sensitivity is expressed as ISO speed.
        case isoSpeed = 3
        /// The sensitivity uses standard output sensitivity and recommended exposure index.
        case standardOutputSensitivityAndRecommendedExposureIndex = 4
        /// The sensitivity uses standard output sensitivity and ISO speed.
        case standardOutputSensitivityAndISOSpeed = 5
        /// The sensitivity uses recommended exposure index and ISO speed.
        case recommendedExposureIndexAndISOSpeed = 6
        /// The sensitivity uses standard output sensitivity, recommended exposure index, and ISO speed.
        case standardOutputSensitivityRecommendedExposureIndexAndISOSpeed = 7
    }

    /// The subject distance range represented by the image metadata.
    enum SubjectDistanceRangeType: Int, Codable, Hashable, Sendable {
        /// The subject distance range is unknown.
        case unknown = 0
        /// The image was captured in a macro distance range.
        case macro = 1
        /// The image was captured in a close-view distance range.
        case closeView = 2
        /// The image was captured in a distant-view distance range.
        case distantView = 3
    }

    /// The white balance mode used to capture the image.
    enum WhiteBalanceMode: Int, Codable, Hashable, Sendable {
        /// The image uses automatic white balance.
        case auto = 0
        /// The image uses manual white balance.
        case manual = 1
    }
}

/*
 let kSYImagePropertyExifAuxAutoFocusInfo = "AFInfo" as CFString
 let kSYImagePropertyExifAuxImageStabilization = "ImageStabilization" as CFString
 */
