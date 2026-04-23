//
//  Nikon.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension ImageSource.ImageProperties {
    struct Nikon: Codable {
        /// The ISO setting values recorded by the Nikon camera.
        public var iSOSetting: [Int]?
        /// The color mode selected on the Nikon camera.
        public var colorMode: String?
        /// The image quality mode selected on the Nikon camera.
        public var quality: String?
        /// The white balance mode selected on the Nikon camera.
        public var whiteBalanceMode: String?
        /// The sharpening mode selected on the Nikon camera.
        public var sharpenMode: String?
        /// The focus mode selected on the Nikon camera.
        public var focusMode: String?
        /// The flash setting selected on the Nikon camera.
        public var flashSetting: String?
        /// The ISO selection mode selected on the Nikon camera.
        public var iSOSelection: String?
        /// The flash exposure compensation applied by the Nikon camera.
        public var flashExposureComp: Double?
        /// The image adjustment mode selected on the Nikon camera.
        public var imageAdjustment: String?
        /// The lens adapter value recorded by the Nikon camera.
        public var lensAdapter: String?
        /// The type flags of the mounted Nikon lens.
        public var lensType: LensType?
        /// The lens information string recorded by the Nikon camera.
        public var lensInfo: String?
        /// The focus distance recorded by the Nikon camera.
        public var focusDistance: Double?
        /// The digital zoom factor used by the Nikon camera.
        public var digitalZoom: Double?
        /// The shooting mode flags recorded by the Nikon camera.
        public var shootingMode: ShootingMode?
        /// The serial number of the Nikon camera.
        public var cameraSerialNumber: String?
        /// The shutter count of the Nikon camera.
        public var shutterCount: Int?

        /// The Nikon shooting mode flags.
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

        /// The Nikon lens type flags.
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
