//
//  AuxiliaryImageData.swift
//
//
//  Created by Florian Zand on 01.05.26.
//

import Foundation
import ImageIO

extension ImageProperties {
    public struct AuxiliaryData {
        /// The type of the auxiliary data.
        public let type: AuxiliaryDataType?
        /// The auxiliary data for the image.
        public let data: Data?
        /// A dictionary of keys that describe the auxiliary data.
        public let dataDescription: [CFString: Any]?
        /// The metadata for any auxiliary data.
        public let metadata: CGImageMetadata?
        /// The raw values.
        public let rawValue: [CFString: Any]
        
        init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            self.type = rawValue[typed: kCGImagePropertyAuxiliaryDataType]
            self.data = rawValue[typed: kCGImageAuxiliaryDataInfoData]
            self.dataDescription = rawValue[typed: kCGImageAuxiliaryDataInfoDataDescription]
            self.metadata = rawValue[typed: kCGImageAuxiliaryDataInfoMetadata]
        }
    }
}

extension ImageProperties.AuxiliaryData {
    /// A type representing an auxiliary image data type.
    public struct AuxiliaryDataType: RawRepresentable {
        /// The type for depth map information.
        public static let depth = Self(kCGImageAuxiliaryDataTypeDepth)

        /// The type for image disparity information.
        public static let disparity = Self(kCGImageAuxiliaryDataTypeDisparity)

        /// The type for High Dynamic Range (HDR) gain map information.
        public static let hdrGainMap = Self(kCGImageAuxiliaryDataTypeHDRGainMap)

        /// The type for portrait effects matte information.
        public static let portraitEffectsMatte = Self(kCGImageAuxiliaryDataTypePortraitEffectsMatte)

        /// The type for glasses matte information.
        public static let semanticSegmentationGlassesMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationGlassesMatte)

        /// The type for hair matte information.
        public static let semanticSegmentationHairMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationHairMatte)

        /// The type for skin matte information.
        public static let semanticSegmentationSkinMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationSkinMatte)

        /// The type for sky matte information.
        public static let semanticSegmentationSkyMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationSkyMatte)

        /// The type for teeth matte information.
        public static let semanticSegmentationTeethMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationTeethMatte)

        public let rawValue: CFString

        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: CFString) {
            self.rawValue = rawValue
        }
    }
}
