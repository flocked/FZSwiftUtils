//
//  PNG+Extended.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties.PNG {
    struct Extended: Codable {
        public var author: String?
        public var chromaticities: Double?
        public var comment: String?
        public var copyright: String?
        public var creationTime: Date?
        public var description: String?
        public var disclaimer: String?
        public var gamma: Double?
        public var interlaceType: InterlaceType?
        public var modificationTime: Date?
        public var software: String?
        public var source: String?
        public var sRGBIntent: sRGBIntent?
        public var title: String?
        public var warning: String?
        public var profileName: String?
        public var xPixelsPerMeter: Double?
        public var yPixelsPerMeter: Double?
        public var pixelsAspectRatio: Double?
        public var frameInfo: [String]?
        public var compressionFilter: CompressionFilter?
        public var canvasPixelWidth: Double?
        public var canvasPixelHeight: Double?
        public var canvasPixelSize: CGSize? {
            guard let width = canvasPixelWidth, let height = canvasPixelHeight else { return nil }
            return CGSize(width: width, height: height)
        }

        public enum sRGBIntent: Int, Codable {
            case perceptual = 0
            case relativeColorimetric = 1
            case saturation = 2
            case absoluteColorimetric = 3
        }

        public struct CompressionFilter: OptionSet, Codable {
            public let rawValue: Int32
            public init(rawValue: Int32) { self.rawValue = rawValue }
            static let noFilters = CompressionFilter(rawValue: IMAGEIO_PNG_NO_FILTERS)
            static let none = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_NONE)
            static let sub = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_SUB)
            static let up = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_UP)
            static let avg = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_AVG)
            static let paeth = CompressionFilter(rawValue: IMAGEIO_PNG_FILTER_PAETH)
            static let all = [CompressionFilter.none, sub, .up, .avg, .paeth] // IMAGEIO_PNG_ALL_FILTERS
        }

        public enum InterlaceType: Int, Codable {
            case nonInterlaced = 0
            case adam7Interlace = 1
        }

        enum CodingKeys: String, CodingKey {
            case author = "Author"
            case chromaticities = "Chromaticities"
            case comment = "Comment"
            case copyright = "Copyright"
            case creationTime = "Creation Time"
            case description = "Description"
            case disclaimer = "Disclaimer"
            case gamma = "Gamma"
            case interlaceType = "InterlaceType"
            case modificationTime = "ModificationTime"
            case software = "Software"
            case source = "Source"
            case sRGBIntent
            case title = "Title"
            case warning = "Warning"
            case xPixelsPerMeter = "XPixelsPerMeter"
            case yPixelsPerMeter = "YPixelsPerMeter"
            case pixelsAspectRatio = "PixelAspectRatio"
            case frameInfo = "FrameInfo"
            case canvasPixelWidth = "CanvasPixelWidth"
            case canvasPixelHeight = "CanvasPixelHeight"
            case compressionFilter = "kCGImagePropertyPNGCompressionFilter"
            case profileName = "ProfileName"
        }
    }
}
