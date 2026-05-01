//
//  TIFF.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct TIFF {
        /// The raw values.
        public let rawValues: [CFString: Any]
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

        init(tiffData: [CFString: Any]) {
            rawValues = tiffData
            artist = tiffData[typed: kCGImagePropertyTIFFArtist]
            compression = tiffData[typed: kCGImagePropertyTIFFCompression]
            copyright = tiffData[typed: kCGImagePropertyTIFFCopyright]
            documentName = tiffData[typed: kCGImagePropertyTIFFDocumentName]
            hostComputer = tiffData[typed: kCGImagePropertyTIFFHostComputer]
            imageDescription = tiffData[typed: kCGImagePropertyTIFFImageDescription]
            cameraMaker = tiffData[typed: kCGImagePropertyTIFFMake]
            cameraModel = tiffData[typed: kCGImagePropertyTIFFModel]
            photometricInterpretation = tiffData[typed: kCGImagePropertyTIFFPhotometricInterpretation]
            primaryChromaticities = tiffData[typed: kCGImagePropertyTIFFPrimaryChromaticities]
            resolutionUnit = tiffData[typed: kCGImagePropertyTIFFResolutionUnit]
            software = tiffData[typed: kCGImagePropertyTIFFSoftware]
            tileLength = tiffData[typed: kCGImagePropertyTIFFTileLength]
            tileWidth = tiffData[typed: kCGImagePropertyTIFFTileWidth]
            transferFunction = tiffData[typed: kCGImagePropertyTIFFTransferFunction]
            whitePoint = tiffData[typed: kCGImagePropertyTIFFWhitePoint]
            if #available(macOS 14.4, iOS 17.4, tvOS 17.4, watchOS 10.4, *) {
                _xPosition = tiffData[typed: kCGImagePropertyTIFFXPosition]
                _yPosition = tiffData[typed: kCGImagePropertyTIFFYPosition]
            } else {
                _xPosition = nil
                _yPosition = nil
            }
            xResolution = tiffData[typed: kCGImagePropertyTIFFXResolution]
            yResolution = tiffData[typed: kCGImagePropertyTIFFYResolution]
            orientation = tiffData[typed: kCGImagePropertyTIFFOrientation]
            timestamp = tiffData[typed: kCGImagePropertyTIFFDateTime, using: ImageProperties.dateFormatter]
        }
    }
}
