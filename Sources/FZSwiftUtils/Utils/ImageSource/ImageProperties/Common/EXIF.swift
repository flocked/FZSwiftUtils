//
//  EXIF.swift
//
//
//  Created by TakashiUshikoshi on 2023/06/30
//
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    /// Exchangeable Image File Format (EXIF) data.
    struct EXIF: Codable, Equatable, Hashable {
        //  MARK: - Camera Settings
        
        /// For a particular camera mode, indicates the conditions for taking the picture.
        public let deviceSettingDescription: AnyCodable?
        
        /// The F-number.
        public var fNumber: Double?
        
        /// The shutter speed value.
        public var shutterSpeedValue: Double?
        
        /// The aperture value.
        public var apertureValue: Double?
        
        /// The maximum aperture value.
        public var maxApertureValue: Double?
        
        /// The focal length.
        public var focalLength: Double?
        
        /// The spectral sensitivity of each channel.
        public var spectralSensitivity: Double?
        
        /// The ISO speed ratings.
        public var isoSpeedRatings: [AnyCodable]?
        
        /// The distance to the subject, in meters.
        public var subjectDistance: Double?
        
        /// The metering mode.
        public var meteringMode: MeteringMode?
        
        /// The subject area.
        public var subjectArea: AnyCodable?
        
        /// The location of the image’s primary subject.
        public var subjectLocation: AnyCodable?
        
        /// The sensor type of the camera or input device.
        public var sensingMethod: SensingMethod?
        
        /// The scene type.
        public var sceneType: Int?
        
        /// The digital zoom ratio.
        public var digitalZoomRatio: Double?
        
        /// The equivalent focal length in 35 mm film.
        public var focalLengthIn35mmFilm: Double?
        
        /// The scene capture type; for example, standard, landscape, portrait, or night.
        public var sceneCaptureType: SceneCaptureType?
        
        /// The distance to the subject.
        public var subjectDistanceRange: SubjectDistanceRangeType?
        
        //  MARK: - Exposure
        
        /// The exposure time.
        public var exposureTime: TimeInterval?
        
        /// The exposure program.
        public var exposureProgram: ExposureProgram?
        
        /// The selected exposure index.
        public var exposureIndex: Int?
        
        /// The exposure mode setting.
        public var exposureMode: ExposureMode?
        
        /// The ISO speed setting used to capture the image.
        public var isoSpeed: AnyCodable?
        
        /// The ISO speed latitude yyy value.
        public var isoSpeedLatitudeYYY: AnyCodable?
        
        /// The ISO speed latitude zzz value.
        public var isoSpeedLatitudeZZZ: AnyCodable?
        
        /// The recommended exposure index.
        public var recommendedExposureIndex: Int?
        
        /// The exposure bias value.
        public var exposureBiasValue: Double?
        
        /// The type of sensitivity data stored for the image.
        public var sensitivityType: SensitivityType?
        
        /// The sensitivity data for the image.
        public var standardOutputSensitivity: UInt?
        
        /// The exposure times for composite images.
        public var sourceExposureTimesOfCompositeImage: AnyCodable?
        
        //  MARK: - Image Quality
        
        /// The color filter array (CFA) pattern, which is the geometric pattern of the image sensor for a 1-chip color sensor area.
        public var cfaPattern: AnyCodable?
        
        /// The brightness value.
        public var brightnessValue: Double?
        
        /// The light source.
        public var lightSource: LightSourceType?
        
        /// The flash status when the image was shot.
        public var flash: FlashMode?
        
        /// The spatial frequency table and spatial frequency response values in the width, height, and diagonal directions.
        public var spatialFrequencyResponse: String?
        
        /// The contrast setting.
        public var contrast: ContrastDirection?
        
        /// The saturation setting.
        public var saturation: SaturationDirection?
        
        /// The sharpness setting.
        public var sharpness: SharpnessDirection?
        
        /// The gamma setting.
        public var gamma: Double?
        
        /// The white balance mode.
        public var whiteBalance: WhiteBalanceMode?
        
        //  MARK: - Image Settings
        
        /// The gain adjustment setting.
        public var gainControl: GainControl?
        
        /// The unique ID of the image.
        public var imageUniqueId: String?
        
        /// The bits per pixel of the compression mode.
        public var compressedBitsPerPixel: Double?
        
        /// The color space.
        public var colorSpace: ColorSpace?
        
        /// The x dimension of a pixel.
        public var pixelXDimension: UInt?
        
        /// The y dimension of a pixel.
        public var pixelYDimension: UInt?
        
        /// A sound file related to the image.
        public var relatedSoundFile: String?
        
        /// The number of image-width pixels (x-axis) per focal plane resolution unit.
        public var focalPlaneXResolution: Double?
        
        /// The number of image-height pixels (y-axis) per focal plane resolution unit.
        public var focalPlaneYResolution: Double?
        
        /// The unit of measurement for the focal plane x and y resolutions.
        public var focalPlaneResolutionUnit: ResolutionUnit?
        
        /// Special rendering performed on the image data.
        public var customRendered: CustomRenderedType?
        
        public var compositeImage: CompositeImageType?
        
        /// The opto-electric conversion function (OECF) that defines the relationship between the optical input of the camera and the resulting image.
        public var oecf: AnyCodable?
        
        /// The components configuration for compressed data.
        public var componentsConfiguration: [Int]?
        
        /// The number of images that make up a composite image.
        public var sourceImageNumberOfCompositeImage: [Int]?
        
        /// The image source.
        public var fileSource: FileSourceType?
        
        //  MARK: - Timestamp
        
        /// The original date and time.
        public var dateTimeOriginal: Date?
        
        /// The digitized date and time.
        public var dateTimeDigitized: Date?
        
        /// The fraction of seconds for the date and time tag.
        public var subsecTime: String?
        
        /// The fraction of seconds for the original date and time tag.
        public var subsecTimeOriginal: String?
        
        /// The fraction of seconds for the digitized date and time tag.
        public var subsecTimeDigitized: String?
        
        
        public var offsetTime: String?
        
        
        public var offsetTimeOriginal: String?
        
        
        public var offsetTimeDigitized: String?
        
        //  MARK: - Lens Information
        
        /// The specification information for the camera lens.
        public var lensSpecification: [Double]?
        
        /// A string with the name of the lens manufacturer.
        public var lensMake: String?
        
        /// A string with the lens model information.
        public var lensModel: String?
        
        /// A string with the lens’s serial number.
        public var lensSerialNumber: String?
        
        //  MARK: - Camera Information
        
        /// Information specified by the camera manufacturer.
        public var makerNote: AnyCodable?
        
        /// A user comment.
        public var userComment: String?
        
        /// A string with the name of the camera’s owner.
        public var cameraOwnerName: String?
        
        /// A string with the serial number of the camera.
        public var bodySerialNumber: String?
        
        //  MARK: - Flash Information
        
        /// The FlashPix version supported by an FPXR file.
        public var flashpixVersion: [Int]?
        
        /// The strobe energy when the image was captured, in beam candle power seconds.
        public var flashEnergy: Int?
        
        //  MARK: - EXIF Format
        
        /// The EXIF version.
        public var exifVersion: [Int]?
        
        /// A Boolean value indicating whether the image is a screenshot.
        public var isScreenshot: Bool {
            userComment == "Screenshot"
        }
    }
}

public extension ImageSource.ImageProperties.EXIF {
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

    /// The flash mode recorded for the image.
    enum FlashMode: Int, Codable, Hashable, Sendable, CaseIterable {
        /// No flash was used.
        case noFlash = 0x0
        /// The flash fired.
        case fired = 0x1
        /// The flash fired but no return light was detected.
        case firedReturnNotDetected = 0x5
        /// The flash fired and return light was detected.
        case firedReturnDetected = 0x7
        /// Flash was on but did not fire.
        case onDidNotFire = 0x8
        /// Flash was on and fired.
        case onFired = 0x9
        /// Flash was on, fired, and no return light was detected.
        case onReturnNotDetected = 0xd
        /// Flash was on, fired, and return light was detected.
        case onReturnDetected = 0xf
        /// Flash was off and did not fire.
        case offDidNotFire = 0x10
        /// Flash was off, did not fire, and no return light was detected.
        case offDidNotFireReturnNotDetected = 0x14
        /// Flash was in auto mode and did not fire.
        case autoDidNotFire = 0x18
        /// Flash was in auto mode and fired.
        case autoFired = 0x19
        /// Flash was in auto mode, fired, and no return light was detected.
        case autoFiredReturnNotDetected = 0x1d
        /// Flash was in auto mode, fired, and return light was detected.
        case autoFiredReturnDetected = 0x1f
        /// The device has no flash function.
        case noFlashFunction = 0x20
        /// Flash was off on a device with no flash function.
        case offNoFlashFunction = 0x30
        /// The flash fired with red-eye reduction.
        case firedRedEyeReduction = 0x41
        /// The flash fired with red-eye reduction and no return light was detected.
        case firedRedEyeReductionReturnNotDetected = 0x45
        /// The flash fired with red-eye reduction and return light was detected.
        case firedRedEyeReductionReturnDetected = 0x47
        /// Flash was on with red-eye reduction.
        case onRedEyeReduction = 0x49
        /// Flash was on with red-eye reduction and no return light was detected.
        case onRedEyeReductionReturnNotDetected = 0x4d
        /// Flash was on with red-eye reduction and return light was detected.
        case onRedEyeReductionReturnDetected = 0x4f
        /// Flash was off with red-eye reduction.
        case offRedEyeReduction = 0x50
        /// Flash was in auto mode with red-eye reduction and did not fire.
        case autoDidNotFireRedEyeReduction = 0x58
        /// Flash was in auto mode with red-eye reduction and fired.
        case autoFiredRedEyeReduction = 0x59
        /// Flash was in auto mode with red-eye reduction, fired, and no return light was detected.
        case autoFiredRedEyeReductionReturnNotDetected = 0x5d
        /// Flash was in auto mode with red-eye reduction, fired, and return light was detected.
        case autoFiredRedEyeReductionReturnDetected = 0x5f
        case unknown = 2
        
        public init?(rawValue: Int) {
            self = Self.allCases.first(where: {$0.rawValue == rawValue}) ?? .unknown
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

extension ImageSource.ImageProperties.EXIF {
    enum CodingKeys: String, CodingKey {
        case deviceSettingDescription = "DeviceSettingDescription"
        case fNumber = "FNumber"
        case shutterSpeedValue = "ShutterSpeedValue"
        case apertureValue = "ApertureValue"
        case maxApertureValue = "MaxApertureValue"
        case focalLength = "FocalLength"
        case spectralSensitivity = "SpectralSensitivity"
        case isoSpeedRatings = "ISOSpeedRatings"
        case subjectDistance = "SubjectDistance"
        case meteringMode = "MeteringMode"
        case subjectArea = "SubjectArea"
        case subjectLocation = "SubjectLocation"
        case sensingMethod = "SensingMethod"
        case sceneType = "SceneType"
        case digitalZoomRatio = "DigitalZoomRatio"
        case focalLengthIn35mmFilm = "FocalLenIn35mmFilm"
        case sceneCaptureType = "SceneCaptureType"
        case subjectDistanceRange = "SubjectDistRange"
        case exposureTime = "ExposureTime"
        case exposureProgram = "ExposureProgram"
        case exposureIndex = "ExposureIndex"
        case exposureMode = "ExposureMode"
        case isoSpeed = "ISOSpeed"
        case isoSpeedLatitudeYYY = "ISOSpeedLatitudeyyy"
        case isoSpeedLatitudeZZZ = "ISOSpeedLatitudezzz"
        case recommendedExposureIndex = "RecommendedExposureIndex"
        case exposureBiasValue = "ExposureBiasValue"
        case sensitivityType = "SensitivityType"
        case standardOutputSensitivity = "StandardOutputSensitivity"
        case sourceExposureTimesOfCompositeImage = "SourceExposureTimesOfCompositeImage"
        case cfaPattern = "CFAPattern"
        case brightnessValue = "BrightnessValue"
        case lightSource = "LightSource"
        case flash = "Flash"
        case spatialFrequencyResponse = "SpatialFrequencyResponse"
        case contrast = "Contrast"
        case saturation = "Saturation"
        case sharpness = "Sharpness"
        case gamma = "Gamma"
        case whiteBalance = "WhiteBalance"
        case gainControl = "GainControl"
        case imageUniqueId = "ImageUniqueID"
        case compressedBitsPerPixel = "CompressedBitsPerPixel"
        case colorSpace = "ColorSpace"
        case pixelXDimension = "PixelXDimension"
        case pixelYDimension = "PixelYDimension"
        case relatedSoundFile = "RelatedSoundFile"
        case focalPlaneXResolution = "FocalPlaneXResolution"
        case focalPlaneYResolution = "FocalPlaneYResolution"
        case focalPlaneResolutionUnit = "FocalPlaneResolutionUnit"
        case customRendered = "CustomRendered"
        case compositeImage = "CompositeImage"
        case oecf = "OECF"
        case componentsConfiguration = "ComponentsConfiguration"
        case sourceImageNumberOfCompositeImage = "SourceImageNumberOfCompositeImage"
        case fileSource = "FileSource"
        case dateTimeOriginal = "DateTimeOriginal"
        case dateTimeDigitized = "DateTimeDigitized"
        case subsecTime = "SubsecTime"
        case subsecTimeOriginal = "SubsecTimeOriginal"
        case subsecTimeDigitized = "SubsecTimeDigitized"
        case offsetTime = "OffsetTime"
        case offsetTimeOriginal = "OffsetTimeOriginal"
        case offsetTimeDigitized = "OffsetTimeDigitized"
        case lensSpecification = "LensSpecification"
        case lensMake = "LensMake"
        case lensModel = "LensModel"
        case lensSerialNumber = "LensSerialNumber"
        case makerNote = "MakerNote"
        case userComment = "UserComment"
        case cameraOwnerName = "CameraOwnerName"
        case bodySerialNumber = "BodySerialNumber"
        case flashpixVersion = "FlashPixVersion"
        case flashEnergy = "FlashEnergy"
        case exifVersion = "ExifVersion"
    }
}

/*
 let kSYImagePropertyExifAuxAutoFocusInfo = "AFInfo" as CFString
 let kSYImagePropertyExifAuxImageStabilization = "ImageStabilization" as CFString
 */
