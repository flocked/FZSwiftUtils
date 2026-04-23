//
//  TIFF.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    struct TIFF: Codable {
        /// The artist who created the image.
        public var artist: String?
        /// The compression scheme used on the image data.
        public var compression: Double?
        /// Copyright information.
        public var copyright: String?
        /// The document name.
        public var documentName: String?
        /// The computer or operating system used when the image was created.
        public var hostComputer: String?
        /// The image description.
        public var imageDescription: String?
        /// The name of the manufacturer of the camera or input device.
        public var cameraMaker: String?
        /// The camera or input device model.
        public var cameraModel: String?
        /// The color space of the image data.
        public var photometricInterpretation: Double?
        /// The chromaticities of the primaries of the image.
        public var primaryChromaticities: [Double]?
        /// The name and version of the software used for image creation.
        public var software: String?
        /// The tile length.
        public var tileLength: Int?
        /// The tile width.
        public var tileWidth: Int?
        /// The transfer function, in tabular format, used to map pixel components from a nonlinear form into a linear form.
        public var transferFunction: Double?
        /// The white point of the image.
        public var whitePoint: [Double]?
        /// The horizontal position of the TIFF image.
        public var xPosition: Double?
        /// The number of pixels per resolution unit in the image height direction.
        public var yPosition: Double?
        /// The units of resolution.
        public var resolutionUnit: Double?
        /// The number of pixels per resolution unit in the image width direction.
        public var xResolution: Double?
        /// The number of pixels per resolution unit in the image height direction.
        public var yResolution: Double?
        /// The image orientation.
        public var orientation: CGImagePropertyOrientation?
        /// The date and time that the image was created.
        public var timestamp: Date?

        enum CodingKeys: String, CodingKey {
            case artist = "Artist"
            case compression = "Compression"
            case copyright = "Copyright"
            case documentName = "DocumentName"
            case hostComputer = "HostComputer"
            case imageDescription = "ImageDescription"
            case cameraMaker = "Make"
            case cameraModel = "Model"
            case photometricInterpretation = "PhotometricInterpretation"
            case primaryChromaticities = "PrimaryChromaticities"
            case resolutionUnit = "ResolutionUnit"
            case software = "Software"
            case tileLength = "TileLength"
            case tileWidth = "TileWidth"
            case transferFunction = "TransferFunction"
            case whitePoint = "WhitePoint"
            case xPosition = "XPosition"
            case xResolution = "XResolution"
            case yPosition = "YPosition"
            case yResolution = "YResolution"
            case orientation = "Orientation"
            case timestamp = "DateTime"
        }
    }
}
