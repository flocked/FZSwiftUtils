//
//  TIFF.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct TIFF: RawRepresentable {
        /// The raw values.
        public var rawValue: [CFString: Any]
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
        @available(macOS 14.4, iOS 17.4, tvOS 17.4, watchOS 10.4, visionOS 1.0, *)
        public var xPosition: Double? {
            get { _xPosition }
        }
        
        private var _xPosition: Double?

        /// The number of pixels per resolution unit in the image height direction.
        @available(macOS 14.4, iOS 17.4, tvOS 17.4, watchOS 10.4, visionOS 1.0, *)
        public var yPosition: Double? {
            get { _yPosition }
        }
        private var _yPosition: Double?

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

        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            artist = rawValue[typed: kCGImagePropertyTIFFArtist]
            compression = rawValue[typed: kCGImagePropertyTIFFCompression]
            copyright = rawValue[typed: kCGImagePropertyTIFFCopyright]
            documentName = rawValue[typed: kCGImagePropertyTIFFDocumentName]
            hostComputer = rawValue[typed: kCGImagePropertyTIFFHostComputer]
            imageDescription = rawValue[typed: kCGImagePropertyTIFFImageDescription]
            cameraMaker = rawValue[typed: kCGImagePropertyTIFFMake]
            cameraModel = rawValue[typed: kCGImagePropertyTIFFModel]
            photometricInterpretation = rawValue[typed: kCGImagePropertyTIFFPhotometricInterpretation]
            primaryChromaticities = rawValue[typed: kCGImagePropertyTIFFPrimaryChromaticities]
            resolutionUnit = rawValue[typed: kCGImagePropertyTIFFResolutionUnit]
            software = rawValue[typed: kCGImagePropertyTIFFSoftware]
            tileLength = rawValue[typed: kCGImagePropertyTIFFTileLength]
            tileWidth = rawValue[typed: kCGImagePropertyTIFFTileWidth]
            transferFunction = rawValue[typed: kCGImagePropertyTIFFTransferFunction]
            whitePoint = rawValue[typed: kCGImagePropertyTIFFWhitePoint]
            if #available(macOS 14.4, iOS 17.4, tvOS 17.4, watchOS 10.4, visionOS 1.1, *) {
                _xPosition = rawValue[typed: kCGImagePropertyTIFFXPosition]
                _yPosition = rawValue[typed: kCGImagePropertyTIFFYPosition]
            } else {
                _xPosition = nil
                _yPosition = nil
            }
            xResolution = rawValue[typed: kCGImagePropertyTIFFXResolution]
            yResolution = rawValue[typed: kCGImagePropertyTIFFYResolution]
            orientation = rawValue[typed: kCGImagePropertyTIFFOrientation]
            timestamp = rawValue[typed: kCGImagePropertyTIFFDateTime, using: ImageProperties.dateFormatter]
        }
    }
}
