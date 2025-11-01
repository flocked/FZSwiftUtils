//
//  ImageAuxiliaryDataType.swift
//
//
//  Created by Florian Zand on 01.11.25.
//

import Foundation
import ImageIO

extension CGImage {
    /// Represents the type of auxiliary image data.
    public struct AuxiliaryDataType: RawRepresentable, Hashable {
        
        /// The type for depth map information.
        public static let depth = Self(kCGImageAuxiliaryDataTypeDepth)
        /// The type for image disparity information.
        public static let disparity = Self(kCGImageAuxiliaryDataTypeDisparity)
        /// The type for portrait effects matte information.
        public static let portraitEffectsMatte = Self(kCGImageAuxiliaryDataTypePortraitEffectsMatte)
        /// The type for skin matte informaton.
        public static let semanticSegmentationSkinMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationSkinMatte)
        /// The type for hair matte information.
        public static let semanticSegmentationHairMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationHairMatte)
        /// The type for teeth matte information.
        public static let semanticSegmentationTeethMatte = Self(kCGImageAuxiliaryDataTypeSemanticSegmentationTeethMatte)
        
        public let rawValue: CFString
        
        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public init(_ key: CFString) {
            rawValue = key
        }
    }

    /// Represents the info key of auxiliary image data.
    public struct AuxiliaryDataInfoKey: RawRepresentable, Hashable {
        
        /// The auxiliary data for the image.
        public static let data = Self(kCGImageAuxiliaryDataInfoData)
        /// A dictionary of keys that describe the auxiliary data.
        public static let dataDescription = Self(kCGImageAuxiliaryDataInfoDataDescription)
        /// The metadata for any auxiliary data.
        public static let metadata = Self(kCGImageAuxiliaryDataInfoMetadata)
        
        public let rawValue: CFString
        
        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public init(_ key: CFString) {
            rawValue = key
        }
    }
}

/*
 let kCGImageDestinationOptimizeColorForSharing: CFString

 let kCGImageDestinationBackgroundColor: CFString

 let kCGImageDestinationEmbedThumbnail: CFString
 A Boolean value that indicates whether to embed a thumbnail for JPEG and HEIF images.
 let kCGImageDestinationImageMaxPixelSize: CFString

kCGImageDestinationLossyCompressionQuality
 kCGImageDestinationPreserveGainMap
*/
