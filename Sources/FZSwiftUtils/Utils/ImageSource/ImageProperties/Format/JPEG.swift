//
//  JPEG.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreGraphics
import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    struct JPEG: Codable {
        /// The x pixel density.
        public var xDensity: CGFloat?
        /// The y pixel density.
        public var yDensity: CGFloat?
        /// The orientation of the image.
        public var orientation: CGImagePropertyOrientation?
        /// The version of the image.
        public var version: [Int]?
        /// The unit of the x and y density.
        public var densityUnit: DensityUnit?
        /// A Boolean value indicating whether there are versions of the image of increasing quality.
        public var isProgressive: Bool?
        
        /// The unit of the x and y density.
        public struct DensityUnit: RawRepresentable, Codable {
            /// No units; the aspect ratio is given by the relative values of X and Y density.
            public static let none = Self.init(rawValue: 0)
            /// Dots per inch (DPI).
            public static let dotsPerInch = Self.init(rawValue: 0)
            /// Dots per centimeter.
            public static let dotsPerCentimeter = Self.init(rawValue: 0)
            
            public let rawValue: Int
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }

        enum CodingKeys: String, CodingKey {
            case xDensity = "XDensity"
            case yDensity = "YDensity"
            case orientation = "Orientation"
            case version = "JFIFVersion"
            case densityUnit = "DensityUnit"
            case isProgressive = "IsProgressive"
        }
    }
}
