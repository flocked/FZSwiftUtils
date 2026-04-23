//
//  CIFF.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

public extension ImageSource.ImageProperties {
    struct CIFF: Codable {
        /// The camera serial number.
        public var cameraSerialNumber: String?
        /// The continuous drive mode.
        public var continuousDrive: Double?
        /// The camera description.
        public var description: String?
        /// The firmware version of the camera.
        public var firmware: String?
        /// The flash exposure compensation.
        public var flashExposureComp: Double?
        /// The focus mode.
        public var focusMode: String?
        /// The image file name.
        public var imageFileName: String?
        /// The image name.
        public var imageName: String?
        /// The image serial number.
        public var imageSerialNumber: Int?
        /// The maximum lens length in millimeters.
        public var lensMaxMM: Double?
        /// The minimum lens length in millimeters.
        public var lensMinMM: Double?
        /// The lens model.
        public var lensModel: String?
        /// The measured exposure value.
        public var measuredEV: Double?
        /// The metering mode.
        public var meteringMode: Double?
        /// The name of the camera’s owner.
        public var ownerName: String?
        /// The number of images taken since the camera shipped.
        public var recordID: Int?
        /// The method of shutter release—single-shot or continuous.
        public var releaseMethod: Double?
        /// The release timing stored in the CIFF metadata.
        public var releaseTiming: Double?
        /// The time in milliseconds until shutter release when using the self-timer.
        public var selfTimingTime: Double?
        /// The shooting mode.
        public var shootingMode: Double?
        /// The white balance index.
        public var whiteBalanceIndex: Double?

        enum CodingKeys: String, CodingKey {
            case cameraSerialNumber = "CameraSerialNumber"
            case continuousDrive = "ContinuousDrive"
            case description = "Description"
            case firmware = "Firmware"
            case flashExposureComp = "FlashExposureComp"
            case focusMode = "FocusMode"
            case imageFileName = "ImageFileName"
            case imageName = "ImageName"
            case imageSerialNumber = "ImageSerialNumber"
            case lensMaxMM = "LensMaxMM"
            case lensMinMM = "LensMinMM"
            case lensModel = "LensModel"
            case measuredEV = "MeasuredEV"
            case meteringMode = "MeteringMode"
            case ownerName = "OwnerName"
            case recordID = "RecordID"
            case releaseMethod = "ReleaseMethod"
            case releaseTiming = "ReleaseTiming"
            case selfTimingTime = "SelfTimingTime"
            case shootingMode = "ShootingMode"
            case whiteBalanceIndex = "WhiteBalanceIndex"
        }
    }
}

/*
 let kSYImagePropertyCIFFMaxAperture = "MaxAperture" as CFString
 let kSYImagePropertyCIFFMinAperture = "MinAperture" as CFString
 let kSYImagePropertyCIFFUniqueModelID = "UniqueModelID" as CFString
 */
