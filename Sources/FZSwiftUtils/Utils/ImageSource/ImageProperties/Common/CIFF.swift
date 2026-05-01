//
//  CIFF.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation

import ImageIO

public extension ImageSource.ImageProperties {
    struct CIFF {
        /// The raw values.
        public let rawValues: [CFString: Any]

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

        init(ciffData: [CFString: Any]) {
            rawValues = ciffData
            cameraSerialNumber = ciffData[typed: kCGImagePropertyCIFFCameraSerialNumber]
            continuousDrive = ciffData[typed: kCGImagePropertyCIFFContinuousDrive]
            description = ciffData[typed: kCGImagePropertyCIFFDescription]
            firmware = ciffData[typed: kCGImagePropertyCIFFFirmware]
            flashExposureComp = ciffData[typed: kCGImagePropertyCIFFFlashExposureComp]
            focusMode = ciffData[typed: kCGImagePropertyCIFFFocusMode]
            imageFileName = ciffData[typed: kCGImagePropertyCIFFImageFileName]
            imageName = ciffData[typed: kCGImagePropertyCIFFImageName]
            imageSerialNumber = ciffData[typed: kCGImagePropertyCIFFImageSerialNumber]
            lensMaxMM = ciffData[typed: kCGImagePropertyCIFFLensMaxMM]
            lensMinMM = ciffData[typed: kCGImagePropertyCIFFLensMinMM]
            lensModel = ciffData[typed: kCGImagePropertyCIFFLensModel]
            measuredEV = ciffData[typed: kCGImagePropertyCIFFMeasuredEV]
            meteringMode = ciffData[typed: kCGImagePropertyCIFFMeteringMode]
            ownerName = ciffData[typed: kCGImagePropertyCIFFOwnerName]
            recordID = ciffData[typed: kCGImagePropertyCIFFRecordID]
            releaseMethod = ciffData[typed: kCGImagePropertyCIFFReleaseMethod]
            releaseTiming = ciffData[typed: kCGImagePropertyCIFFReleaseTiming]
            selfTimingTime = ciffData[typed: kCGImagePropertyCIFFSelfTimingTime]
            shootingMode = ciffData[typed: kCGImagePropertyCIFFShootingMode]
            whiteBalanceIndex = ciffData[typed: kCGImagePropertyCIFFWhiteBalanceIndex]
        }
    }
}

/*
 let kSYImagePropertyCIFFMaxAperture = "MaxAperture" as CFString
 let kSYImagePropertyCIFFMinAperture = "MinAperture" as CFString
 let kSYImagePropertyCIFFUniqueModelID = "UniqueModelID" as CFString
 */
