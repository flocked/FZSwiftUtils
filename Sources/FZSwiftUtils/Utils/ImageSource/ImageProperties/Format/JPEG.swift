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
    struct JPEG {
        /// The raw values.
        public let rawValues: [CFString: Any]
        /// The x pixel density.
        public let xDensity: CGFloat?
        /// The y pixel density.
        public let yDensity: CGFloat?
        /// The orientation of the image.
        public let orientation: CGImagePropertyOrientation?
        /// The version of the image.
        public let version: [Int]?
        /// The unit of the x and y density.
        public let densityUnit: DensityUnit?
        /// A Boolean value indicating whether there are versions of the image of increasing quality.
        public let isProgressive: Bool?
        
        /// The unit of the x and y density.
        public enum DensityUnit: Int, Codable {
            /// No units; the aspect ratio is given by the relative values of X and Y density.
            case none
            /// Dots per inch (DPI).
            case dotsPerInch
            /// Dots per centimeter.
            case dotsPerCentimeter
        }

        init(jpegData: [CFString: Any]) {
            rawValues = jpegData
            xDensity = jpegData[typed: kCGImagePropertyJFIFXDensity]
            yDensity = jpegData[typed: kCGImagePropertyJFIFYDensity]
            orientation = jpegData[typed: kCGImagePropertyOrientation]
            version = jpegData[typed: kCGImagePropertyJFIFVersion]
            densityUnit = jpegData[typed: kCGImagePropertyJFIFDensityUnit]
            isProgressive = jpegData[typed: kCGImagePropertyJFIFIsProgressive]
        }
    }
}
