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
    struct Canon {
        /// The raw values.
        public let rawValues: [CFString: Any]

        /// The owner name recorded by the Canon camera.
        public let ownerName: String?
        /// The serial number of the Canon camera.
        public let cameraSerialNumber: Int?
        /// The serial number assigned to the captured image.
        public let imageSerialNumber: Int?
        /// The flash exposure compensation applied by the Canon camera.
        public let flashExposureComp: Double?
        /// The continuous drive mode recorded by the Canon camera.
        public let continuousDrive: Double?
        /// The model name of the mounted Canon lens.
        public let lensModel: String?
        /// The firmware version of the Canon camera.
        public let firmware: String?
        /// The aspect ratio information recorded by the Canon camera.
        public let aspectRatioInfo: Int?

        /// The minimum aperture value of the mounted lens.
        public let minAperture: Double?
        /// The maximum aperture value of the mounted lens.
        public let maxAperture: Double?
        /// The unique model identifier of the Canon camera.
        public let uniqueModelID: Int?
        /// The white balance setting recorded by the Canon camera.
        public let whiteBalance: ImageProperties.EXIF.WhiteBalanceMode?

        init(canonData: [CFString: Any]) {
            rawValues = canonData
            ownerName = canonData[typed: kCGImagePropertyMakerCanonOwnerName]
            cameraSerialNumber = canonData[typed: kCGImagePropertyMakerCanonCameraSerialNumber]
            imageSerialNumber = canonData[typed: kCGImagePropertyMakerCanonImageSerialNumber]
            flashExposureComp = canonData[typed: kCGImagePropertyMakerCanonFlashExposureComp]
            continuousDrive = canonData[typed: kCGImagePropertyMakerCanonContinuousDrive]
            lensModel = canonData[typed: kCGImagePropertyMakerCanonLensModel]
            firmware = canonData[typed: kCGImagePropertyMakerCanonFirmware]
            aspectRatioInfo = canonData[typed: kCGImagePropertyMakerCanonAspectRatioInfo]
            minAperture = canonData[typed: "MinAperture" as CFString]
            maxAperture = canonData[typed: "MaxAperture" as CFString]
            uniqueModelID = canonData[typed: "UniqueModelID" as CFString]
            whiteBalance = canonData[typed: "WhiteBalanceIndex" as CFString]
        }
    }
}
