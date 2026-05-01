//
//  Nikon.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageProperties {
    /// Nikon camera specific image properties.
    struct Nikon {
        /// The raw values.
        public let rawValues: [CFString: Any]

        /// The ISO setting values recorded by the Nikon camera.
        public let iSOSetting: [Int]?
        /// The color mode selected on the Nikon camera.
        public let colorMode: String?
        /// The image quality mode selected on the Nikon camera.
        public let quality: String?
        /// The white balance mode selected on the Nikon camera.
        public let whiteBalanceMode: String?
        /// The sharpening mode selected on the Nikon camera.
        public let sharpenMode: String?
        /// The focus mode selected on the Nikon camera.
        public let focusMode: String?
        /// The flash setting selected on the Nikon camera.
        public let flashSetting: String?
        /// The ISO selection mode selected on the Nikon camera.
        public let iSOSelection: String?
        /// The flash exposure compensation applied by the Nikon camera.
        public let flashExposureComp: Double?
        /// The image adjustment mode selected on the Nikon camera.
        public let imageAdjustment: String?
        /// The lens adapter value recorded by the Nikon camera.
        public let lensAdapter: String?
        /// The type flags of the mounted Nikon lens.
        public let lensType: LensType?
        /// The lens information string recorded by the Nikon camera.
        public let lensInfo: String?
        /// The focus distance recorded by the Nikon camera.
        public let focusDistance: Double?
        /// The digital zoom factor used by the Nikon camera.
        public let digitalZoom: Double?
        /// The shooting mode flags recorded by the Nikon camera.
        public let shootingMode: ShootingMode?
        /// The serial number of the Nikon camera.
        public let cameraSerialNumber: String?
        /// The shutter count of the Nikon camera.
        public let shutterCount: Int?

        /// The Nikon shooting mode flags.
        public struct ShootingMode: OptionSet, Codable {
            /// Continuous shooting, capturing multiple frames while the shutter is held.
            public static let continuous = ShootingMode(rawValue: 1 << 0)
            /// Delayed shooting after a predefined interval.
            public static let delay = ShootingMode(rawValue: 1 << 1)
            /// Remote shooting controlled from a connected computer.
            public static let pcControl = ShootingMode(rawValue: 1 << 2)
            /// Self-timer shooting with a countdown.
            public static let selfTimer = ShootingMode(rawValue: 1 << 3)
            /// Captures multiple images with varying exposure.
            public static let exposureBracketing = ShootingMode(rawValue: 1 << 4)
            /// Automatically adjusts ISO sensitivity.
            public static let autoISO = ShootingMode(rawValue: 1 << 5)
            /// Captures images with varying white balance.
            public static let whiteBalanceBracketing = ShootingMode(rawValue: 1 << 6)
            /// Enables infrared remote shutter control.
            public static let irControl = ShootingMode(rawValue: 1 << 7)
            /// Captures images with varying D-Lighting levels.
            public static let dLightingBracketing = ShootingMode(rawValue: 1 << 8)

            public let rawValue: Int32
            public init(rawValue: Int32) { self.rawValue = rawValue }
        }

        /// The Nikon lens type flags.
        public struct LensType: OptionSet, Codable {
            /// Manual focus lens.
            public static let MF = LensType(rawValue: 1 << 0)
            /// Lens with distance information support.
            public static let D = LensType(rawValue: 1 << 1)
            /// Lens without an aperture ring.
            public static let G = LensType(rawValue: 1 << 2)
            /// Lens with vibration reduction (image stabilization).
            public static let VR = LensType(rawValue: 1 << 3)
            
            public let rawValue: Int32
            public init(rawValue: Int32) { self.rawValue = rawValue }
        }

        init(nikonData: [CFString: Any]) {
            rawValues = nikonData
            iSOSetting = nikonData[typed: kCGImagePropertyMakerNikonISOSetting]
            colorMode = nikonData[typed: kCGImagePropertyMakerNikonColorMode]
            quality = nikonData[typed: kCGImagePropertyMakerNikonQuality]
            whiteBalanceMode = nikonData[typed: kCGImagePropertyMakerNikonWhiteBalanceMode]
            sharpenMode = nikonData[typed: kCGImagePropertyMakerNikonSharpenMode]
            focusMode = nikonData[typed: kCGImagePropertyMakerNikonFocusMode]
            flashSetting = nikonData[typed: kCGImagePropertyMakerNikonFlashSetting]
            iSOSelection = nikonData[typed: kCGImagePropertyMakerNikonISOSelection]
            flashExposureComp = nikonData[typed: kCGImagePropertyMakerNikonFlashExposureComp]
            imageAdjustment = nikonData[typed: kCGImagePropertyMakerNikonImageAdjustment]
            lensAdapter = nikonData[typed: kCGImagePropertyMakerNikonLensAdapter]
            lensType = nikonData[typed: kCGImagePropertyMakerNikonLensType]
            lensInfo = nikonData[typed: kCGImagePropertyMakerNikonLensInfo]
            focusDistance = nikonData[typed: kCGImagePropertyMakerNikonFocusDistance]
            digitalZoom = nikonData[typed: kCGImagePropertyMakerNikonDigitalZoom]
            shootingMode = nikonData[typed: kCGImagePropertyMakerNikonShootingMode]
            cameraSerialNumber = nikonData[typed: kCGImagePropertyMakerNikonCameraSerialNumber]
            shutterCount = nikonData[typed: kCGImagePropertyMakerNikonShutterCount]
        }
    }
}
