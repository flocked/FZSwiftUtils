//
//  Canon.swift
//  
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension ImageSource.ImageProperties {
    struct Canon: Codable {
        public var ownerName: String?
        public var cameraSerialNumber: Int?
        public var imageSerialNumber: Int?
        public var flashExposureComp: Double?
        public var continuousDrive: Double?
        public var lensModel: String?
        public var firmware: String?
        public var aspectRatioInfo: Int?

        public var minAperture: Double?
        public var maxAperture: Double?
        public var uniqueModelID: Int?
        public var whiteBalance: ImageSource.ImageProperties.EXIF.WhiteBalance?

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
