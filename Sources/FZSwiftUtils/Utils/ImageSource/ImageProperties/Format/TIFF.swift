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
        public let rawValue: [CFString: Any]
        /// The artist who created the image.
        public let artist: String?
        /// The compression scheme used on the image data.
        public let compression: Double?
        /// Copyright information.
        public let copyright: String?
        /// The document name.
        public let documentName: String?
        /// The computer or operating system used when the image was created.
        public let hostComputer: String?
        /// The image description.
        public let imageDescription: String?
        /// The name of the manufacturer of the camera or input device.
        public let cameraMaker: String?
        /// The camera or input device model.
        public let cameraModel: String?
        /// The color space of the image data.
        public let photometricInterpretation: Double?
        /// The chromaticities of the primaries of the image.
        public let primaryChromaticities: [Double]?
        /// The name and version of the software used for image creation.
        public let software: String?
        /// The tile length.
        public let tileLength: Int?
        /// The tile width.
        public let tileWidth: Int?
        /// The transfer function, in tabular format, used to map pixel components from a nonlinear form into a linear form.
        public let transferFunction: Double?
        /// The white point of the image.
        public let whitePoint: [Double]?
        /// The horizontal position of the TIFF image.
        @available(macOS 14.4, iOS 17.4, tvOS 17.4, watchOS 10.4, *)
        public var xPosition: Double? {
            get { _xPosition }
        }
        
        private var _xPosition: Double?

        /// The number of pixels per resolution unit in the image height direction.
        @available(macOS 14.4, iOS 17.4, tvOS 17.4, watchOS 10.4, *)
        public var yPosition: Double? {
            get { _yPosition }
        }
        private var _yPosition: Double?

        /// The units of resolution.
        public let resolutionUnit: Double?
        /// The number of pixels per resolution unit in the image width direction.
        public let xResolution: Double?
        /// The number of pixels per resolution unit in the image height direction.
        public let yResolution: Double?
        /// The image orientation.
        public let orientation: CGImagePropertyOrientation?
        /// The date and time that the image was created.
        public let timestamp: Date?

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
            if #available(macOS 14.4, iOS 17.4, tvOS 17.4, watchOS 10.4, *) {
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
