//
//  CIFF.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation

import ImageIO

public extension ImageProperties {
    struct CIFF: RawRepresentable {
        /// The raw values.
        public var rawValue: [CFString: Any]

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

        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            cameraSerialNumber = rawValue[typed: kCGImagePropertyCIFFCameraSerialNumber]
            continuousDrive = rawValue[typed: kCGImagePropertyCIFFContinuousDrive]
            description = rawValue[typed: kCGImagePropertyCIFFDescription]
            firmware = rawValue[typed: kCGImagePropertyCIFFFirmware]
            flashExposureComp = rawValue[typed: kCGImagePropertyCIFFFlashExposureComp]
            focusMode = rawValue[typed: kCGImagePropertyCIFFFocusMode]
            imageFileName = rawValue[typed: kCGImagePropertyCIFFImageFileName]
            imageName = rawValue[typed: kCGImagePropertyCIFFImageName]
            imageSerialNumber = rawValue[typed: kCGImagePropertyCIFFImageSerialNumber]
            lensMaxMM = rawValue[typed: kCGImagePropertyCIFFLensMaxMM]
            lensMinMM = rawValue[typed: kCGImagePropertyCIFFLensMinMM]
            lensModel = rawValue[typed: kCGImagePropertyCIFFLensModel]
            measuredEV = rawValue[typed: kCGImagePropertyCIFFMeasuredEV]
            meteringMode = rawValue[typed: kCGImagePropertyCIFFMeteringMode]
            ownerName = rawValue[typed: kCGImagePropertyCIFFOwnerName]
            recordID = rawValue[typed: kCGImagePropertyCIFFRecordID]
            releaseMethod = rawValue[typed: kCGImagePropertyCIFFReleaseMethod]
            releaseTiming = rawValue[typed: kCGImagePropertyCIFFReleaseTiming]
            selfTimingTime = rawValue[typed: kCGImagePropertyCIFFSelfTimingTime]
            shootingMode = rawValue[typed: kCGImagePropertyCIFFShootingMode]
            whiteBalanceIndex = rawValue[typed: kCGImagePropertyCIFFWhiteBalanceIndex]
        }
    }
}

/*
 let kSYImagePropertyCIFFMaxAperture = "MaxAperture" as CFString
 let kSYImagePropertyCIFFMinAperture = "MinAperture" as CFString
 let kSYImagePropertyCIFFUniqueModelID = "UniqueModelID" as CFString
 */
