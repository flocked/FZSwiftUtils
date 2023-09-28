//
//  EXIF+Extended.swift
//  
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension ImageSource.ImageProperties.EXIF {
    struct Extended {
        public var exposureTime: Double?
        public var exposureProgram: ExposureProgram?
        public var spectralSensitivity: Double?
        public var oECF: Double?
        public var sensitivityType: SensitivityType?
        public var standardOutputSensitivity: Double?
        public var recommendedExposureIndex: Double?
        public var iSOSpeedLatitudeyyy: Double?
        public var iSOSpeedLatitudezzz: Double?
        public var version: Double?
        public var dateTimeOriginal: Date?
        public var dateTimeDigitized: Double?
        public var offsetTime: Double?
        public var offsetTimeOriginal: Double?
        public var offsetTimeDigitized: Double?
        public var componentsConfiguration: Double?
        public var compressedBitsPerPixel: Double?
        public var brightnessValue: Double?
        public var maxApertureValue: Double?
        public var subjectDistance: Double?
        public var subjectDistanceRange: SubjectDistanceRange?
        public var meteringMode: Double?
        public var lightSource: LightSource?
        public var flash: Double?
        public var subjectArea: Double?
        public var makerNote: Double?
        public var subsecTime: Double?
        public var subsecTimeOriginal: Double?
        public var subsecTimeDigitized: Double?
        public var flashPixVersion: Double?
        public var relatedSoundFile: Double?
        public var flashEnergy: Double?
        public var spatialFrequencyResponse: Double?
        public var focalPlaneXResolution: Double?
        public var focalPlaneYResolution: Double?
        public var focalPlaneResolutionUnit: FocalPlaneResolutionUnit?
        public var subjectLocation: Double?
        public var exposureIndex: Double?
        public var sensingMethod: SensingMethod?
        public var fileSource: Double?
        public var sceneType: Double?
        public var cFAPattern: Double?
        public var customRendered: CustomRendered?
        public var exposureMode: Double?
        public var whiteBalance: Double?
        public var digitalZoomRatio: Double?
        public var focalLenIn35mmFilm: Double?
        public var sceneCaptureType: SceneCaptureType?
        public var gainControl: GainControl?
        public var contrast: Contrast?
        public var saturation: Saturation?
        public var sharpness: Sharpness?
        public var deviceSettingDescription: Double?
        public var subjectDistRange: Double?
        public var imageUniqueID: Double?
        public var cameraOwnerName: Double?
        public var bodySerialNumber: Double?
        public var lensSpecification: Double?
        public var lensSerialNumber: Double?
        public var gamma: Double?
        public var compositeImage: Double?
        public var sourceImageNumberOfCompositeImage: Double?
        public var sourceExposureTimesOfCompositeImage: Double?

        enum CodingKeys: String, CodingKey {
            case exposureTime = "ExposureTime"
            case exposureProgram = "ExposureProgram"
            case spectralSensitivity = "SpectralSensitivity"
            case oECF = "OECF"
            case sensitivityType = "SensitivityType"
            case standardOutputSensitivity = "StandardOutputSensitivity"
            case recommendedExposureIndex = "RecommendedExposureIndex"
            case iSOSpeedLatitudeyyy = "ISOSpeedLatitudeyyy"
            case iSOSpeedLatitudezzz = "ISOSpeedLatitudezzz"
            case version = "ExifVersion"
            case dateTimeOriginal = "DateTimeOriginal"
            case dateTimeDigitized = "DateTimeDigitized"
            case offsetTime = "OffsetTime"
            case offsetTimeOriginal = "OffsetTimeOriginal"
            case offsetTimeDigitized = "OffsetTimeDigitized"
            case componentsConfiguration = "ComponentsConfiguration"
            case compressedBitsPerPixel = "CompressedBitsPerPixel"
            case brightnessValue = "BrightnessValue"
            case maxApertureValue = "MaxApertureValue"
            case subjectDistance = "SubjectDistance"
            case meteringMode = "MeteringMode"
            case lightSource = "LightSource"
            case flash = "Flash"
            case subjectArea = "SubjectArea"
            case makerNote = "MakerNote"
            case subsecTime = "SubsecTime"
            case subsecTimeOriginal = "SubsecTimeOriginal"
            case subsecTimeDigitized = "SubsecTimeDigitized"
            case flashPixVersion = "FlashPixVersion"
            case relatedSoundFile = "RelatedSoundFile"
            case flashEnergy = "FlashEnergy"
            case spatialFrequencyResponse = "SpatialFrequencyResponse"
            case focalPlaneXResolution = "FocalPlaneXResolution"
            case focalPlaneYResolution = "FocalPlaneYResolution"
            case focalPlaneResolutionUnit = "FocalPlaneResolutionUnit"
            case subjectLocation = "SubjectLocation"
            case exposureIndex = "ExposureIndex"
            case sensingMethod = "SensingMethod"
            case fileSource = "FileSource"
            case sceneType = "SceneType"
            case cFAPattern = "CFAPattern"
            case customRendered = "CustomRendered"
            case exposureMode = "ExposureMode"
            case whiteBalance = "WhiteBalance"
            case digitalZoomRatio = "DigitalZoomRatio"
            case focalLenIn35mmFilm = "FocalLenIn35mmFilm"
            case sceneCaptureType = "SceneCaptureType"
            case gainControl = "GainControl"
            case contrast = "Contrast"
            case saturation = "Saturation"
            case sharpness = "Sharpness"
            case deviceSettingDescription = "DeviceSettingDescription"
            case subjectDistRange = "SubjectDistRange"
            case imageUniqueID = "ImageUniqueID"
            case cameraOwnerName = "CameraOwnerName"
            case bodySerialNumber = "BodySerialNumber"
            case lensSpecification = "LensSpecification"
            case lensMake = "LensMake"
            case lensModel = "LensModel"
            case lensSerialNumber = "LensSerialNumber"
            case gamma = "Gamma"
            case compositeImage = "CompositeImage"
            case sourceImageNumberOfCompositeImage = "SourceImageNumberOfCompositeImage"
            case sourceExposureTimesOfCompositeImage = "SourceExposureTimesOfCompositeImage"
            case subjectDistanceRange = "SubjectDistanceRange"
        }
    }
}
