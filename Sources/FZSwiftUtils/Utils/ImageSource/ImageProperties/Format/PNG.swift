//
//  PNG.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct PNG {
        /// The raw values.
        public let rawValues: [CFString: Any]
        /// The author of the image.
        public let author: String?
        /// The chromaticities.
        public let chromaticities: [Double]?
        /// The comment about the image.
        public let comment: String?
        /// The PNG filter to apply prior to compression.
        public let compressionFilter: CompressionFilter?
        /// The copyright of the image.
        public let copyright: String?
        /// The creation date of the image.
        public let creationTime: Date?
        /**
         The number of times that an animated image should play through its frames before stopping.

         A value of `0` means the animated image repeats forever.
         */
        public let loopCount: Int?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         The value of this key is never less than `100` millseconds, and the system adjusts values less than that amount to `100` milliseconds, as needed. Use ``unclampedDelayTime`` for the unclamped delay time.
         */
        public let clampedDelayTime: Double?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         This value may be `0` milliseconds or higher. Unlike the ``unclampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public let unclampedDelayTime: Double?
        
        /// A description of the image.
        public let description: String?
        /// The disclaimer for the image.
        public let disclaimer: String?
        /// The gamma value.
        public let gamma: Double?
        /// The interlace type.
        public let interlaceType: InterlaceType?
        /// The modification date of the image.
        public let modificationTime: Date?
        /// The pixel aspect ratio of the PNG image.
        public let pixelAspectRatio: Double?
        /// The software used to create the image.
        public let software: String?
        /// The source description for the PNG image.
        public let source: String?
        /// The title of the image.
        public let title: String?
        /// The warning for the image.
        public let warning: String?
        /// The number of pixels per meter along the x-axis.
        public let xPixelsPerMeter: Double?
        /// The number of pixels per meter along the y-axis.
        public let yPixelsPerMeter: Double?
        /// The sRGB intent.
        public let sRGBIntent: SRGBIntent?

        /// The number of seconds to wait before displaying the next image in an animated sequence.
        public var delayTime: Double? {
            unclampedDelayTime ?? clampedDelayTime
        }
        
        /// The pixel width of the main image.
        public let canvasPixelWidth: Double?
        
        /// The pixel height of the main image.
        public let canvasPixelHeight: Double?
        
        /// The pixel size of the main image.
        public var canvasPixelSize: CGSize? {
            guard let width = canvasPixelWidth, let height = canvasPixelHeight else { return nil }
            return CGSize(width: width, height: height)
        }
        
        /// The clamped and unclamped delay times for each frame, representing the number of seconds to wait before displaying the next image in an animated sequence.
        public let framesInfo: [FrameInfo]?
        
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

        init(pngData: [CFString: Any]) {
            rawValues = pngData
            author = pngData[typed: kCGImagePropertyPNGAuthor]
            chromaticities = pngData[typed: kCGImagePropertyPNGChromaticities]
            comment = pngData[typed: kCGImagePropertyPNGComment]
            compressionFilter = pngData[typed: kCGImagePropertyPNGCompressionFilter]
            copyright = pngData[typed: kCGImagePropertyPNGCopyright]
            creationTime = pngData[typed: kCGImagePropertyPNGCreationTime, using: ImageProperties.dateFormatter]
            loopCount = pngData[typed: kCGImagePropertyAPNGLoopCount]
            clampedDelayTime = pngData[typed: kCGImagePropertyAPNGDelayTime]
            unclampedDelayTime = pngData[typed: kCGImagePropertyAPNGUnclampedDelayTime]
            description = pngData[typed: kCGImagePropertyPNGDescription]
            disclaimer = pngData[typed: kCGImagePropertyPNGDisclaimer]
            gamma = pngData[typed: kCGImagePropertyPNGGamma]
            interlaceType = pngData[typed: kCGImagePropertyPNGInterlaceType]
            modificationTime = pngData[typed: kCGImagePropertyPNGModificationTime, using: ImageProperties.dateFormatter]
            pixelAspectRatio = pngData[typed: kCGImagePropertyPNGPixelsAspectRatio]
            software = pngData[typed: kCGImagePropertyPNGSoftware]
            source = pngData[typed: kCGImagePropertyPNGSource]
            title = pngData[typed: kCGImagePropertyPNGTitle]
            warning = pngData[typed: kCGImagePropertyPNGWarning]
            xPixelsPerMeter = pngData[typed: kCGImagePropertyPNGXPixelsPerMeter]
            yPixelsPerMeter = pngData[typed: kCGImagePropertyPNGYPixelsPerMeter]
            sRGBIntent = pngData[typed: kCGImagePropertyPNGsRGBIntent]
            framesInfo = (pngData[typed: kCGImagePropertyAPNGFrameInfoArray] as [[CFString: Any]]?)?.map(FrameInfo.init(frameInfoData:))
            canvasPixelWidth = pngData[typed: kCGImagePropertyAPNGCanvasPixelWidth]
            canvasPixelHeight = pngData[typed: kCGImagePropertyAPNGCanvasPixelHeight]
        }
    }
}
