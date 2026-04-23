//
//  Canon.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension ImageSource.ImageProperties {
    /// Canon camera specific image properties.
    struct Canon: Codable {
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
        public var whiteBalance: ImageSource.ImageProperties.EXIF.WhiteBalanceMode?

        enum CodingKeys: String, CodingKey {
            case ownerName = "OwnerName"
            case cameraSerialNumber = "CameraSerialNumber"
            case imageSerialNumber = "ImageSerialNumber"
            case flashExposureComp = "FlashExposureComp"
            case continuousDrive = "ContinuousDrive"
            case lensModel = "LensModel"
            case firmware = "Firmware"
            case aspectRatioInfo = "AspectRatioInfo"
            case minAperture = "MinAperture"
            case maxAperture = "MaxAperture"
            case uniqueModelID = "UniqueModelID"
            case whiteBalance = "WhiteBalanceIndex"
        }
    }
}
