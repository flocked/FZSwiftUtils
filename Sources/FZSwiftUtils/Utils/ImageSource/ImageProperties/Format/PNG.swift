//
//  PNG.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    struct PNG: Codable {
        /// The author of the image.
        public var author: String?
        /// The chromaticities.
        public var chromaticities: Double?
        /// The comment about the image.
        public var comment: String?
        /// The PNG filter to apply prior to compression.
        public var compressionFilter: CompressionFilter?
        /// The copyright of the image.
        public var copyright: String?
        /// The creation date of the image.
        public var creationTime: Date?
        /**
         The number of times that an animated image should play through its frames before stopping.

         A value of `0` means the animated image repeats forever.
         */
        public var loopCount: Int?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         The value of this key is never less than `100` millseconds, and the system adjusts values less than that amount to `100` milliseconds, as needed. Use ``unclampedDelayTime`` for the unclamped delay time.
         */
        public var clampedDelayTime: Double?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         This value may be `0` milliseconds or higher. Unlike the ``unclampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public var unclampedDelayTime: Double?
        
        /// A description of the image.
        public var description: String?
        /// The disclaimer for the image.
        public var disclaimer: String?
        /// The gamma value.
        public var gamma: Double?
        /// The interlace type.
        public var interlaceType: InterlaceType?
        /// The modification date of the image.
        public var modificationTime: Date?
        /// The pixel aspect ratio of the PNG image.
        public var pixelAspectRatio: Double?
        /// The software used to create the image.
        public var software: String?
        /// The source description for the PNG image.
        public var source: String?
        /// The title of the image.
        public var title: String?
        /// The warning for the image.
        public var warning: String?
        /// The number of pixels per meter along the x-axis.
        public var xPixelsPerMeter: Double?
        /// The number of pixels per meter along the y-axis.
        public var yPixelsPerMeter: Double?
        /// The sRGB intent.
        public var sRGBIntent: SRGBIntent?

        /// The number of seconds to wait before displaying the next image in an animated sequence.
        public var delayTime: Double? {
            unclampedDelayTime ?? clampedDelayTime
        }
        
        /// The pixel width of the main image.
        public var canvasPixelWidth: Double?
        
        /// The pixel height of the main image.
        public var canvasPixelHeight: Double?
        
        /// The pixel size of the main image.
        public var canvasPixelSize: CGSize? {
            guard let width = canvasPixelWidth, let height = canvasPixelHeight else { return nil }
            return CGSize(width: width, height: height)
        }
        
        /// The clamped and unclamped delay times for each frame, representing the number of seconds to wait before displaying the next image in an animated sequence.
        public var framesInfo: [FrameInfo]?
        
        /// The rendering intent of a PNG image.
        public enum SRGBIntent: Int, Codable {
            /// Perceptual rendering intent.
            case perceptual = 0
            /// Relative colorimetric rendering intent.
            case relativeColorimetric = 1
            /// Saturation rendering intent.
            case saturation = 2
            /// Absolute colorimetric rendering intent.
            case absoluteColorimetric = 3
        }
        
        /// The interlace mode of a PNG image.
        public enum InterlaceType: Int, Codable {
            /// The image is not interlaced.
            case nonInterlaced = 0
            /// The image uses Adam7 interlacing.
            case adam7Interlace = 1
        }
        
        /// The PNG filter to apply prior to compression.
        public struct CompressionFilter: OptionSet, Codable {
            /// No PNG filters.
            public static let noFilters = CompressionFilter(rawValue: IMAGEIO_PNG_NO_FILTERS)
            /// A filter in which each byte is unchanged.
            public static let none = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_NONE)
            /// A filter in which each byte is replaced with the difference between it and the corresponding byte to its left.
            public static let sub = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_SUB)
            /// A filter in which each byte is replaced with the difference between it and the byte above it.
            public static let up = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_UP)
            /// A filter in which each byte is replaced with the difference between it and the average of the bytes above it and to its left.
            public static let avg = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_AVG)
            /// A filter in which each byte is replaced with the difference between it and the Paeth predictor of the bytes to its left, above, and upper left.
            public static let paeth = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_PAETH)
            
            public let rawValue: Int32
            public init(rawValue: Int32) { self.rawValue = rawValue }
        }

        enum CodingKeys: String, CodingKey {
            case author = "Author"
            case chromaticities = "Chromaticities"
            case comment = "Comment"
            case compressionFilter = "kCGImagePropertyPNGCompressionFilter"
            case copyright = "Copyright"
            case creationTime = "Creation Time"
            case loopCount = "LoopCount"
            case clampedDelayTime = "DelayTime"
            case unclampedDelayTime = "UnclampedDelayTime"
            case description = "Description"
            case disclaimer = "Disclaimer"
            case gamma = "Gamma"
            case interlaceType = "InterlaceType"
            case modificationTime = "ModificationTime"
            case pixelAspectRatio = "PixelAspectRatio"
            case software = "Software"
            case source = "Source"
            case title = "Title"
            case warning = "Warning"
            case xPixelsPerMeter = "XPixelsPerMeter"
            case yPixelsPerMeter = "YPixelsPerMeter"
            case sRGBIntent
            case framesInfo = "FrameInfoArray"
            case canvasPixelWidth = "CanvasPixelWidth"
            case canvasPixelHeight = "CanvasPixelHeight"
        }
    }
}
