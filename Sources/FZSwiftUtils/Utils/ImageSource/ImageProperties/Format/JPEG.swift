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
        public enum DensityUnit: Int, Codable {
            /// No units; the aspect ratio is given by the relative values of X and Y density.
            case none
            /// Dots per inch (DPI).
            case dotsPerInch
            /// Dots per centimeter.
            case dotsPerCentimeter
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
