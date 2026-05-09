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
        public let rawValue: [CFString: Any]

        /// The camera serial number.
        public let cameraSerialNumber: String?
        /// The continuous drive mode.
        public let continuousDrive: Double?
        /// The camera description.
        public let description: String?
        /// The firmware version of the camera.
        public let firmware: String?
        /// The flash exposure compensation.
        public let flashExposureComp: Double?
        /// The focus mode.
        public let focusMode: String?
        /// The image file name.
        public let imageFileName: String?
        /// The image name.
        public let imageName: String?
        /// The image serial number.
        public let imageSerialNumber: Int?
        /// The maximum lens length in millimeters.
        public let lensMaxMM: Double?
        /// The minimum lens length in millimeters.
        public let lensMinMM: Double?
        /// The lens model.
        public let lensModel: String?
        /// The measured exposure value.
        public let measuredEV: Double?
        /// The metering mode.
        public let meteringMode: Double?
        /// The name of the camera’s owner.
        public let ownerName: String?
        /// The number of images taken since the camera shipped.
        public let recordID: Int?
        /// The method of shutter release—single-shot or continuous.
        public let releaseMethod: Double?
        /// The release timing stored in the CIFF metadata.
        public let releaseTiming: Double?
        /// The time in milliseconds until shutter release when using the self-timer.
        public let selfTimingTime: Double?
        /// The shooting mode.
        public let shootingMode: Double?
        /// The white balance index.
        public let whiteBalanceIndex: Double?

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
