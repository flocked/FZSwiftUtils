//
//  JPEG.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreGraphics
import Foundation
import ImageIO

public extension ImageProperties {
    struct JPEG: RawRepresentable {
        /// The raw values.
        public var rawValue: [CFString: Any]
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
        public enum DensityUnit: Int, Codable {
            /// No units; the aspect ratio is given by the relative values of X and Y density.
            case none
            /// Dots per inch (DPI).
            case dotsPerInch
            /// Dots per centimeter.
            case dotsPerCentimeter
        }

        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            xDensity = rawValue[typed: kCGImagePropertyJFIFXDensity]
            yDensity = rawValue[typed: kCGImagePropertyJFIFYDensity]
            orientation = rawValue[typed: kCGImagePropertyOrientation]
            version = rawValue[typed: kCGImagePropertyJFIFVersion]
            densityUnit = rawValue[typed: kCGImagePropertyJFIFDensityUnit]
            isProgressive = rawValue[typed: kCGImagePropertyJFIFIsProgressive]
        }
    }
}
