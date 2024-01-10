//
//  ImageProperties+Nikon.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension ImageSource.ImageProperties {
    struct Nikon: Codable {
        public var iSOSetting: [Int]?
        public var colorMode: String?
        public var quality: String?
        public var whiteBalanceMode: String?
        public var sharpenMode: String?
        public var focusMode: String?
        public var flashSetting: String?
        public var iSOSelection: String?
        public var flashExposureComp: Double?
        public var imageAdjustment: String?
        public var lensAdapter: Double?
        public var lensType: LensType?
        public var lensInfo: String?
        public var focusDistance: Double?
        public var digitalZoom: Double?
        public var shootingMode: ShootingMode?
        public var cameraSerialNumber: String?
        public var shutterCount: Int?

        public struct ShootingMode: OptionSet, Codable {
            public let rawValue: Int32
            public init(rawValue: Int32) { self.rawValue = rawValue }
            public static let continuous = ShootingMode(rawValue: 1 << 0)
            public static let delay = ShootingMode(rawValue: 1 << 1)
            public static let pcControl = ShootingMode(rawValue: 1 << 2)
            public static let selfTimer = ShootingMode(rawValue: 1 << 3)
            public static let exposureBracketing = ShootingMode(rawValue: 1 << 4)
            public static let autoISO = ShootingMode(rawValue: 1 << 5)
            public static let whiteBalanceBracketing = ShootingMode(rawValue: 1 << 6)
            public static let irControl = ShootingMode(rawValue: 1 << 7)
            public static let dLightingBracketing = ShootingMode(rawValue: 1 << 8)
        }

        public struct LensType: OptionSet, Codable {
            public let rawValue: Int32
            public init(rawValue: Int32) { self.rawValue = rawValue }
            public static let MF = LensType(rawValue: 1 << 0)
            public static let D = LensType(rawValue: 1 << 1)
            public static let G = LensType(rawValue: 1 << 2)
            public static let VR = LensType(rawValue: 1 << 3)
        }

        enum CodingKeys: String, CodingKey {
            case iSOSetting = "ISOSetting"
            case colorMode = "ColorMode"
            case quality = "Quality"
            case whiteBalanceMode = "WhiteBalanceMode"
            case sharpenMode = "SharpenMode"
            case focusMode = "FocusMode"
            case flashSetting = "FlashSetting"
            case iSOSelection = "ISOSelection"
            case flashExposureComp = "FlashExposureComp"
            case imageAdjustment = "ImageAdjustment"
            case lensAdapter = "LensAdapter"
            case lensType = "LensType"
            case lensInfo = "LensInfo"
            case focusDistance = "FocusDistance"
            case digitalZoom = "DigitalZoom"
            case shootingMode = "ShootingMode"
            case cameraSerialNumber = "CameraSerialNumber"
            case shutterCount = "ShutterCount"
        }
    }
}
