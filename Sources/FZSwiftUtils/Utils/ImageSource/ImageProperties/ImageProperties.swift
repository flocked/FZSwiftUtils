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
        public var colorModel: String?
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
        /// Additional EXIF properties of the image.
        public var exif: EXIF?

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
            _orientation ?? tiff?.orientation ?? iptc?.orientation ?? .up
        }

        /// A Boolean value indicating whether the image is a screenshot.
        public var isScreenshot: Bool {
            exif?.isScreenshot ?? false
        }

        /**
         The number of times that an animated image should play through its frames before stopping.

         A value of 0 means the animated image repeats forever.
         */
        public var loopCount: Int? {
            heic?.loopCount ?? gif?.loopCount ?? png?.loopCount
        }

        /**
         The number of seconds to wait before displaying the next image in the sequence, clamped to a minimum of 0.1 seconds.
         
         The value of this key is never less than 100 millseconds, and the system adjusts values less than that amount to 100 milliseconds, as needed. See ``unclampedDelayTime`` for the unclamped delay time.
         */
        public var clampedDelayTime: Double? {
            gif?.clampedDelayTime ?? heic?.clampedDelayTime ?? png?.clampedDelayTime
        }

        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         This value may be 0 milliseconds or higher. Unlike the ``clampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public var unclampedDelayTime: Double? {
            gif?.unclampedDelayTime ?? heic?.unclampedDelayTime ?? png?.unclampedDelayTime
        }
        
        public var framesInfo: [FrameInfo]? {
            gif?.framesInfo ?? heic?.framesInfo ?? png?.framesInfo
        }

        /// The number of seconds to wait before displaying the next image in an animated sequence.
        public var delayTime: Double? {
            let value = clampedDelayTime ?? unclampedDelayTime
            if let value = value, value < ImageProperties.capDurationThreshold {
                return 0.1
            }
            return value
        }
        
        private static let capDurationThreshold: Double = 0.02 - Double.ulpOfOne

        enum CodingKeys: String, CodingKey, CaseIterable {
            case fileSize = "FileSize"
            case pixelWidth = "PixelWidth"
            case pixelHeight = "PixelHeight"
            case _orientation = "Orientation"
            case gif = "{GIF}"
            case png = "{PNG}"
            case jpeg = "{JFIF}"
            case tiff = "{TIFF}"
            case iptc = "{IPTC}"
            case heic = "{HEICS}"
            case exif = "{Exif}"
            case dpiWidth = "DPIWidth"
            case dpiHeight = "DPIHeight"
            case hasAlpha = "HasAlpha"
            case colorProfile = "ProfileName"
            case colorModel = "ColorModel"
            case depth = "Depth"
        }
    }
}

extension ImageSource.ImageProperties {
    static var decoder: JSONDecoder {
        .init(dateDecodingStrategy: .formatted("yyyy:MM:dd HH:mm:ss"))
    }

    static var encoder: JSONEncoder {
        .init(dateEncodingStrategy: .formatted("yyyy:MM:dd HH:mm:ss"))
    }
}

extension CGImagePropertyOrientation {
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
extension CGImagePropertyOrientation: Codable { }

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

/*
 {
DelayTime = "0.04";
UnclampedDelayTime = "0.04";
 */
