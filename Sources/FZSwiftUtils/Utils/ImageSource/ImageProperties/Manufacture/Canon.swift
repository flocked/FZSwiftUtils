//
//  Canon.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageProperties {
    /// Canon camera specific image properties.
    struct Canon: RawRepresentable {
        /// The raw values.
        public var rawValue: [CFString: Any]

        /// The owner name recorded by the Canon camera.
        public var ownerName: String?
        /// The serial number of the Canon camera.
        public var cameraSerialNumber: Int?
        /// The serial number assigned to the captured image.
        public var imageSerialNumber: Int?
        /// The flash exposure compensation applied by the Canon camera.
        public var flashExposureComp: Double?
        /// The continuous drive mode recorded by the Canon camera.
        public var continuousDrive: Double?
        /// The model name of the mounted Canon lens.
        public var lensModel: String?
        /// The firmware version of the Canon camera.
        public var firmware: String?
        /// The aspect ratio information recorded by the Canon camera.
        public var aspectRatioInfo: Int?

        /// The minimum aperture value of the mounted lens.
        public var minAperture: Double?
        /// The maximum aperture value of the mounted lens.
        public var maxAperture: Double?
        /// The unique model identifier of the Canon camera.
        public var uniqueModelID: Int?
        /// The white balance setting recorded by the Canon camera.
        public var whiteBalance: ImageProperties.EXIF.WhiteBalanceMode?

        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            ownerName = rawValue[typed: kCGImagePropertyMakerCanonOwnerName]
            cameraSerialNumber = rawValue[typed: kCGImagePropertyMakerCanonCameraSerialNumber]
            imageSerialNumber = rawValue[typed: kCGImagePropertyMakerCanonImageSerialNumber]
            flashExposureComp = rawValue[typed: kCGImagePropertyMakerCanonFlashExposureComp]
            continuousDrive = rawValue[typed: kCGImagePropertyMakerCanonContinuousDrive]
            lensModel = rawValue[typed: kCGImagePropertyMakerCanonLensModel]
            firmware = rawValue[typed: kCGImagePropertyMakerCanonFirmware]
            aspectRatioInfo = rawValue[typed: kCGImagePropertyMakerCanonAspectRatioInfo]
            minAperture = rawValue[typed: "MinAperture" as CFString]
            maxAperture = rawValue[typed: "MaxAperture" as CFString]
            uniqueModelID = rawValue[typed: "UniqueModelID" as CFString]
            whiteBalance = rawValue[typed: "WhiteBalanceIndex" as CFString]
        }
    }
}
