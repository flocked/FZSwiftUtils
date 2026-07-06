//
//  ImageProperties.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreGraphics
import Foundation
import ImageIO

/// Properties of an image.
public struct ImageProperties: RawRepresentable {
    /// The raw values.
    public let rawValue: [CFString: Any]

    /// The file size of the image.
    public let fileSize: DataSize?
    /// The pixel width of the image.
    public let pixelWidth: CGFloat?
    /// The pixel height of the image.
    public let pixelHeight: CGFloat?
                
    /// A Boolean value that indicates whether the image has an alpha channel.
    public let hasAlpha: Bool?
    /// The color model of the image.
    public let colorModel: ColorModel?
    /// The color profile of the image.
    public let colorProfile: String?
    /// The dpi width of the image.
    public let dpiWidth: CGFloat?
    /// The dpi height of the image.
    public let dpiHeight: CGFloat?
    /// The number of bits in the color sample of a pixel.
    public let depth: Int?
    /// A Boolean value that indicates whether the image contains floating-point pixel samples.
    public let isFloat: Bool
        
    private var _orientation: CGImagePropertyOrientation?

    /// Additional GIF properties of the image.
    public let gif: GIF?
    /// Additional PNG properties of the image.
    public let png: PNG?
    /// Additional JPEG properties of the image.
    public let jpeg: JPEG?
    /// Additional TIFF properties of the image.
    public let tiff: TIFF?
    /// Additional HEIC properties of the image.
    public let heic: HEIC?
    /// Additional WEBP properties of the image.
    public let webp: WEBP?
    /// Additional Adobe Photoshop image properties of the image.
    public let a8bim: A8BIM?
    /// Additional Truevision Graphics Adapter (TGA) format properties of the image.
    public let tga: TGA?
    /// Additional Digital Negative (DNG) archival format image properties of the image.
    public let dng: DNG?
        
    /// Additional IPTC properties of the image.
    public let iptc: IPTC?
    /// Additional EXIF properties of the image.
    public let exif: EXIF?
    /// Additional GPS properties of the image.
    public let gps: GPS?
    /// Additional camera image file format (CIFF) properties of the image.
    public let ciff: CIFF?
    /// Additional picture style properties of the image.
    public let pictureStyle: [CFString: Any]?
    /// Additional properties for an image that contains minimally processed, or raw, data.
    public let raw: [CFString: Any]?
    /// A dictionary of properties related to the image’s on-disk file.
    public let FileContents: [CFString: Any]?
    /// A dictionary of properties specific to the `OpenEXR` metadata standard.
    public let openEXRA: OpenEXRA?
    /// The auxiliary data for the image.
    public let auxiliaryData: [AuxiliaryData]?

    /// Additional Canon camera properties of the image.
    public let canon: Canon?
    /// Additional Nikon camera properties of the image.
    public let nikon: Nikon?
    /// Additional Minolta camera properties of the image.
    public let minolta: [CFString: Any]?
    /// Additional Fuji camera properties of the image.
    public let fuji: [CFString: Any]?
    /// Additional Olympus camera properties of the image.
    public let olympus: [CFString: Any]?
    /// Additional Pentax camera properties of the image.
    public let pentax: [CFString: Any]?
    /// Additional Apple camera properties of the image.
    public let apple: [CFString: Any]?

    /// The pixel size of the image.
    public var pixelSize: CGSize? {
        guard let width = pixelWidth, let height = pixelHeight else { return nil }
        return orientation.needsSwap ? CGSize(height, width) : CGSize(width, height)
    }

    /// The dpi size of the image.
    public var dpiSize: CGSize? {
        guard let width = dpiWidth, let height = dpiHeight else { return nil }
        return orientation.needsSwap ? CGSize(height, width) : CGSize(width, height)
    }

    /// The orientation of the image.
    public var orientation: CGImagePropertyOrientation {
        _orientation ?? tiff?.orientation ?? iptc?.orientation ?? jpeg?.orientation ?? .up
    }

    /// A Boolean value indicating whether the image is a screenshot.
    public var isScreenshot: Bool {
        exif?.isScreenshot ?? false
    }

    /**
     The number of times that an animated image should play through its frames before stopping.

     A value of `0` means the animated image repeats forever.
     */
    public var loopCount: Int? {
        heic?.loopCount ?? gif?.loopCount ?? png?.loopCount ?? webp?.loopCount
    }

    /**
     The number of seconds to wait before displaying the next image in an animated sequence.

     The value of this key is never less than `100` millseconds, and the system adjusts values less than that amount to `100` milliseconds, as needed. Use ``unclampedDelayTime`` for the unclamped delay time.
     */
    public var clampedDelayTime: Double? {
        gif?.clampedDelayTime ?? heic?.clampedDelayTime ?? png?.clampedDelayTime ?? webp?.clampedDelayTime
    }

    /**
     The number of seconds to wait before displaying the next image in an animated sequence.

     This value may be `0` milliseconds or higher. Unlike the ``clampedDelayTime`` property, this value is not clamped at the low end of the range.
     */
    public var unclampedDelayTime: Double? {
        gif?.unclampedDelayTime ?? heic?.unclampedDelayTime ?? png?.unclampedDelayTime ?? webp?.unclampedDelayTime
    }

    /// The number of seconds to wait before displaying the next image in an animated sequence.
    public var delayTime: Double? {
        guard let delayTime = clampedDelayTime ?? unclampedDelayTime else { return nil }
        return delayTime < Self.frameDurationCap ? 0.1 : delayTime
    }
        
    /// The clamped and unclamped delay times for each frame, representing the number of seconds to wait before displaying the next image in an animated sequence.
    public var framesInfo: [FrameInfo]? {
        gif?.framesInfo ?? heic?.framesInfo ?? png?.framesInfo ?? webp?.framesInfo
    }
        
    private static let frameDurationCap: Double = 0.02 - Double.ulpOfOne

    public init(rawValue: [CFString: Any]) {
        self.rawValue = rawValue
        
        fileSize = (rawValue[typed: kCGImagePropertyFileSize] as Int64?).map({.bytes($0)})
        isFloat = rawValue[typed: kCGImagePropertyIsFloat] ?? false
        pixelWidth = rawValue[typed: kCGImagePropertyPixelWidth]
        pixelHeight = rawValue[typed: kCGImagePropertyPixelHeight]
        _orientation = rawValue[typed: kCGImagePropertyOrientation]
        dpiWidth = rawValue[typed: kCGImagePropertyDPIWidth]
        dpiHeight = rawValue[typed: kCGImagePropertyDPIHeight]
        hasAlpha = rawValue[typed: kCGImagePropertyHasAlpha]
        colorProfile = rawValue[typed: kCGImagePropertyProfileName]
        colorModel = rawValue[typed: kCGImagePropertyColorModel]
        depth = rawValue[typed: kCGImagePropertyDepth]
        gif = rawValue[typed: kCGImagePropertyGIFDictionary]
        png = rawValue[typed: kCGImagePropertyPNGDictionary]
        jpeg = rawValue[typed: kCGImagePropertyJFIFDictionary]
        tiff = rawValue[typed: kCGImagePropertyTIFFDictionary]
        heic = rawValue[typed: kCGImagePropertyHEICSDictionary]
        tga = rawValue[typed: kCGImagePropertyTGADictionary]
        webp = rawValue[typed: kCGImagePropertyWebPDictionary]
        a8bim = rawValue[typed: kCGImageProperty8BIMDictionary]
        dng = rawValue[typed: kCGImagePropertyDNGDictionary]
            
        ciff = rawValue[typed: kCGImagePropertyCIFFDictionary]
        gps = rawValue[typed: kCGImagePropertyGPSDictionary]
        exif = rawValue[typed: kCGImagePropertyExifDictionary]
        iptc = rawValue[typed: kCGImagePropertyIPTCDictionary]
        pictureStyle = rawValue[typed: "{PictureStyle}" as CFString]
        raw = rawValue[typed: kCGImagePropertyRawDictionary]
        FileContents = rawValue[typed: kCGImagePropertyFileContentsDictionary]
        openEXRA = rawValue[typed: kCGImagePropertyOpenEXRDictionary]
        auxiliaryData = (rawValue[typed: kCGImagePropertyAuxiliaryData] as [[CFString: Any]]?)?.compactMap(AuxiliaryData.init)
        
        canon = rawValue[typed: kCGImagePropertyMakerCanonDictionary]
        nikon = rawValue[typed: kCGImagePropertyMakerNikonDictionary]
        minolta = rawValue[typed: kCGImagePropertyMakerMinoltaDictionary]
        fuji = rawValue[typed: kCGImagePropertyMakerFujiDictionary]
        olympus = rawValue[typed: kCGImagePropertyMakerOlympusDictionary]
        pentax = rawValue[typed: kCGImagePropertyMakerPentaxDictionary]
        apple = rawValue[typed: kCGImagePropertyMakerAppleDictionary]
    }
}

/// A type that exposes raw image property metadata.
public protocol ImagePropertiesRawValueProviding {
    /// The raw image property metadata.
    var rawValue: [CFString: Any] { get }
}

public extension ImagePropertiesRawValueProviding {
    /// The keys contained in the raw image property metadata.
    var keys: Dictionary<CFString, Any>.Keys {
        rawValue.keys
    }
    
    /// The values contained in the raw image property metadata.
    var values: Dictionary<CFString, Any>.Values {
        rawValue.values
    }
    
    /// Returns the raw metadata value for the specified key.
    subscript(key: CFString) -> Any? {
        rawValue[key]
    }
    
    /// Returns the metadata value for the specified key as the inferred type.
    subscript<T>(typed key: CFString) -> T? {
        guard let value = self[key] else { return nil }
        guard let value = value as? T else {
            Swift.print("Wrong type for key: \(key). Expected: \(T.self), got: \(type(of: value)).")
            return nil
        }
        return value
    }
    
    /// Returns the metadata value for the specified key as the inferred raw-representable type.
    subscript<T>(typed key: CFString) -> T? where T: RawRepresentable {
        guard let value = self[key] else { return nil }
        guard let rawValue = value as? T.RawValue, let value = T(rawValue: rawValue) else {
            Swift.print("Wrong type for key: \(key). Expected: \(T.self), got: \(type(of: value)).")
            return nil
        }
        return value
    }
}

extension ImageProperties: ImagePropertiesRawValueProviding {}
extension ImageProperties.A8BIM: ImagePropertiesRawValueProviding {}
extension ImageProperties.AuxiliaryData: ImagePropertiesRawValueProviding {}
extension ImageProperties.Canon: ImagePropertiesRawValueProviding {}
extension ImageProperties.CIFF: ImagePropertiesRawValueProviding {}
extension ImageProperties.DNG: ImagePropertiesRawValueProviding {}
extension ImageProperties.EXIF: ImagePropertiesRawValueProviding {}
extension ImageProperties.GIF: ImagePropertiesRawValueProviding {}
extension ImageProperties.GPS: ImagePropertiesRawValueProviding {}
extension ImageProperties.HEIC: ImagePropertiesRawValueProviding {}
extension ImageProperties.IPTC: ImagePropertiesRawValueProviding {}
extension ImageProperties.IPTC.Artwork: ImagePropertiesRawValueProviding {}
extension ImageProperties.IPTC.CreatorContactInfo: ImagePropertiesRawValueProviding {}
extension ImageProperties.JPEG: ImagePropertiesRawValueProviding {}
extension ImageProperties.FrameInfo: ImagePropertiesRawValueProviding {}
extension ImageProperties.Nikon: ImagePropertiesRawValueProviding {}
extension ImageProperties.OpenEXRA: ImagePropertiesRawValueProviding {}
extension ImageProperties.PNG: ImagePropertiesRawValueProviding {}
extension ImageProperties.TGA: ImagePropertiesRawValueProviding {}
extension ImageProperties.TIFF: ImagePropertiesRawValueProviding {}
extension ImageProperties.WEBP: ImagePropertiesRawValueProviding {}

extension ImageProperties {
    public static let dateFormatter = DateFormatter.multiple(["yyyy:MM:dd HH:mm:ss", "HH:mm:ss.SSS", "YYYY:MM:DD", "HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ssXXXXX", "yyyyMMdd", "yyyy:MM:dd HH:mm:ss"]).includeISO8601(true).adjusted(true)
}

extension ImageProperties {
    /// Infromation about a single image frame.
    public struct FrameInfo {
        /// The raw values.
        public let rawValue: [CFString: Any]
        
        /**
         The number of seconds to wait before displaying the next image in the sequence, clamped to a minimum of 0.1 seconds.
         
         The value of this key is never less than 100 millseconds, and the system adjusts values less than that amount to 100 milliseconds, as needed. See ``unclampedDelayTime`` for the unclamped delay time.
         */
        public let delayTime: Double?
        
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         This value may be 0 milliseconds or higher. Unlike the ``clampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public let unclampedDelayTime: Double?
        
        init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            delayTime = rawValue[typed: kCGImagePropertyGIFDelayTime]
            unclampedDelayTime = rawValue[typed: kCGImagePropertyGIFUnclampedDelayTime]
        }
    }

    /// The color model of an image, such as RGB, CMYK, grayscale, or Lab.
    public struct ColorModel: RawRepresentable, CustomStringConvertible {
        /// Red, Green, Blue (RGB) color model.
        public static let rgb = Self(rawValue: kCGImagePropertyColorModelRGB as String)
        /// Grayscale color model.
        public static let gray = Self(rawValue: kCGImagePropertyColorModelGray as String)
        /// Cyan, Magenta, Yellow, Black (CMYK) color model.
        public static let cmyk = Self(rawValue: kCGImagePropertyColorModelCMYK as String)
        /// CIE Lab color model.
        public static let lab = Self(rawValue: kCGImagePropertyColorModelLab as String)
        
        public var description: String {
            rawValue
        }
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension CGImagePropertyOrientation: Swift.Encodable, Swift.Decodable {
    public var description: String {
        switch self {
        case .up: return "up"
        case .upMirrored: return "upMirrored"
        case .down: return "down"
        case .downMirrored: return "downMirrored"
        case .leftMirrored: return "leftMirrored"
        case .right: return "right"
        case .rightMirrored: return "rightMirrored"
        case .left: return "left"
        }
    }
    
    var transform: CGAffineTransform {
        switch rawValue {
        case 2: return CGAffineTransform(scaleX: -1, y: 1)
        case 3: return CGAffineTransform(scaleX: -1, y: -1)
        case 4: return CGAffineTransform(scaleX: 1, y: -1)
        case 5: return CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2)
        case 6: return CGAffineTransform(rotationAngle: .pi / 2)
        case 7: return CGAffineTransform(scaleX: -1, y: 1).rotated(by: -.pi / 2)
        case 8: return CGAffineTransform(rotationAngle: -.pi / 2)
        default: return CGAffineTransform.identity
        }
    }
    
    var needsSwap: Bool {
        switch rawValue {
        case 5 ... 8: return true
        default: return false
        }
    }
}

/*
#if canImport(UIKit)
import UIKit

public extension CGImagePropertyOrientation {
    var uiOrientation: UIImage.Orientation {
        switch self {
            case .up: .up
            case .upMirrored: .upMirrored
            case .down: .down
            case .downMirrored: .downMirrored
            case .left: .left
            case .leftMirrored: .leftMirrored
            case .right: .right
            case .rightMirrored: .rightMirrored
        @unknown default: .up
        }
    }
    
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

public extension UIImage.Orientation {
    var cgOrientation: CGImagePropertyOrientation {
        switch self {
            case .up: .up
            case .upMirrored: .upMirrored
            case .down: .down
            case .downMirrored: .downMirrored
            case .left: .left
            case .leftMirrored: .leftMirrored
            case .right: .right
            case .rightMirrored: .rightMirrored
        @unknown default: .up
        }
    }
    
    init(_ cgOrientation: CGImagePropertyOrientation) {
        switch cgOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}
#endif
*/

struct Torrent {
    var lastAverageThroughput: Int?
    var lastAttempt: Date?
}
