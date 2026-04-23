//
//  ImageProperties.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreGraphics
import Foundation
import ImageIO

public extension ImageSource {
    struct ImageProperties: Codable {
        /// The file size of the image.
        public var fileSize: DataSize?
        /// The pixel width of the image.
        public var pixelWidth: CGFloat?
        /// The pixel height of the image.
        public var pixelHeight: CGFloat?
                
        /// A Boolean value that indicates whether the image has an alpha channel.
        public var hasAlpha: Bool?
        /// The color model of the image.
        public var colorModel: ColorModel?
        /// The color profile of the image.
        public var colorProfile: String?
        /// The dpi width of the image.
        public var dpiWidth: CGFloat?
        /// The dpi height of the image.
        public var dpiHeight: CGFloat?
        /// The number of bits in the color sample of a pixel.
        public var depth: Int?
        
        private var _orientation: CGImagePropertyOrientation?

        /// Additional GIF properties of the image.
        public var gif: GIF?
        /// Additional PNG properties of the image.
        public var png: PNG?
        /// Additional JPEG properties of the image.
        public var jpeg: JPEG?
        /// Additional TIFF properties of the image.
        public var tiff: TIFF?
        /// Additional IPTC properties of the image.
        public var iptc: IPTC?
        /// Additional HEIC properties of the image.
        public var heic: HEIC?
        
        /// Additional WEBP properties of the image.
        public var webp: WEBP?
        /// Additional Adobe Photoshop image properties of the image.
        public var a8bim: A8BIM?
        /// Additional Truevision Graphics Adapter (TGA) format properties of the image.
        public var tga: TGA?
        /// Additional Digital Negative (DNG) archival format image properties of the image.
        public var dng: DNG?

        /// Additional EXIF properties of the image.
        public var exif: EXIF?
        /// Additional GPS properties of the image.
        public var gps: GPS?
        /// Additional camera image file format (CIFF) properties of the image.
        public var ciff: CIFF?
        
        /// Additional Canon camera properties of the image.
        public var canon: Canon?
        /// Additional Nikon camera properties of the image.
        public var nikon: Nikon?
        
        /*
        /// Additional Minolta camera properties of the image.
        public var minolta: [String: String]?
        /// Additional Fuji camera properties of the image.
        public var fuji: [String: String]?
        /// Additional Olympus camera properties of the image.
        public var olympus: [String: String]?
        /// Additional Pentax camera properties of the image.
        public var pentax: [String: String]?
         */

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

         This value may be `0` milliseconds or higher. Unlike the ``unclampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public var unclampedDelayTime: Double? {
            gif?.unclampedDelayTime ?? heic?.unclampedDelayTime ?? png?.unclampedDelayTime ?? webp?.unclampedDelayTime
        }

        /// The number of seconds to wait before displaying the next image in an animated sequence.
        public var delayTime: Double? {
            guard let delayTime = clampedDelayTime ?? unclampedDelayTime else { return nil }
            return delayTime < ImageProperties.frameDurationCap ? 0.1 : delayTime
        }
        
        /// The clamped and unclamped delay times for each frame, representing the number of seconds to wait before displaying the next image in an animated sequence.
        public var framesInfo: [FrameInfo]? {
            gif?.framesInfo ?? heic?.framesInfo ?? png?.framesInfo ?? webp?.framesInfo
        }
        
        private static let frameDurationCap: Double = 0.02 - Double.ulpOfOne

        enum CodingKeys: String, CodingKey, CaseIterable {
            case fileSize = "FileSize"
            case pixelWidth = "PixelWidth"
            case pixelHeight = "PixelHeight"
            case _orientation = "Orientation"
            
            case dpiWidth = "DPIWidth"
            case dpiHeight = "DPIHeight"
            case hasAlpha = "HasAlpha"
            case colorProfile = "ProfileName"
            case colorModel = "ColorModel"
            case depth = "Depth"
            
            case gif = "{GIF}"
            case png = "{PNG}"
            case jpeg = "{JFIF}"
            case tiff = "{TIFF}"
            case iptc = "{IPTC}"
            case heic = "{HEICS}"
            case tga = "{TGA}"
            case webp = "{WebP}"
            case a8bim = "{8BIM}"
            case dng = "{DNG}"
            
            case exif = "{Exif}"
            case gps = "{GPS}"
            case ciff = "{CIFF}"
            
            case canon = "{MakerCanon}"
            case nikon = "{MakerNikon}"
            /*
            case minolta = "{MakerMinolta}"
            case fuji = "{MakerFuji}"
            case olympus = "{MakerOlympus}"
            case pentax = "{MakerPentax}"
             */
        }
    }
}

extension ImageSource.ImageProperties {
    init?(_ dictionary: CFDictionary?) {
        do {
            self = try Self.decoder.decode(from: dictionary as? [String: Any] ?? [:])
        } catch {
            Swift.print(error)
            return nil
        }
    }
    
    private static let decoder = DictionaryDecoder(dateDecodingStrategy: .formatted(.multiple(["yyyy:MM:dd HH:mm:ss", "HH:mm:ss.SSS", "YYYY:MM:DD", "HH:mm:ss"])))
}

extension ImageSource.ImageProperties {
    /// Infromation about a single image frame.
    public struct FrameInfo: Codable {
        /**
         The number of seconds to wait before displaying the next image in the sequence, clamped to a minimum of 0.1 seconds.
         
         The value of this key is never less than 100 millseconds, and the system adjusts values less than that amount to 100 milliseconds, as needed. See ``unclampedDelayTime`` for the unclamped delay time.
         */
        public var delayTime: Double?
        
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         This value may be 0 milliseconds or higher. Unlike the ``clampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public var unclampedDelayTime: Double?
        
        enum CodingKeys: String, CodingKey {
            case delayTime = "DelayTime"
            case unclampedDelayTime = "UnclampedDelayTime"
        }
    }
}

extension ImageSource.ImageProperties {
    /// The color model of an image, such as RGB, CMYK, grayscale, or Lab.
    public struct ColorModel: RawRepresentable, Codable, CustomStringConvertible {
        /// RGB.
        public static let rgb = Self(rawValue: "RGB")
        /// Gray.
        public static let gray = Self(rawValue: "Gray")
        /// CMYK.
        public static let cmyk = Self(rawValue: "CMYK")
        /// Lab.
        public static let lab = Self(rawValue: "Lab")
        
        public var description: String { rawValue }
        
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

/// let kSYImagePropertyPictureStyle = "{PictureStyle}" as CFString
