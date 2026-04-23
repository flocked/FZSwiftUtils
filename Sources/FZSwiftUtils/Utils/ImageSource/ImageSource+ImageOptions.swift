//
//  ImageSource+ImageOptions.swift
//
//
//  Created by Florian Zand on 03.06.22.
//

import Foundation
import ImageIO

public extension ImageSource {
    /// Options for creating images.
    struct ImageOptions: Codable, Hashable {
        /// A Boolean value indicating whether to cache the decoded image.
        public var caches: Bool = true
        /// A Boolean value indicating whether image decoding and caching happens at image creation time.
        public var decodesImmediately: Bool = false
        /// The factor by which to scale down any returned images.
        public var subsampleFactor: SubsampleFactor?
        /// A Boolean indicating whether to use floating-point values in returned images.
        public var allowsFloat: Bool = false
        
        /// The preferred dynamic range to use when decoding the image.
        @available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
        var preferredDynamicRange: DynamicRange? {
            get { DynamicRange(rawValue: _preferredDynamicRange ?? -1) }
            set { _preferredDynamicRange = newValue?.rawValue }
        }
        private var _preferredDynamicRange: Int?

        /// The factor by which to scale down returned images.
        public enum SubsampleFactor: Int, Codable, Hashable {
            /// Factor 2
            case factor2 = 2
            /// Factor 4
            case factor4 = 4
            /// Factor 8
            case factor8 = 8
        }
        
        /// The dynamic range to prefer when decoding an image.
        @available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
        public enum DynamicRange: Int, Codable {
            /// Standard dynamic range.
            case standard
            /// High dynamic range.
            case high
        }

        /**
         Creates the options for generating images.

         - Parameters:
            - caches: A Boolean value indicating whether to cache the decoded image.
            - decodesImmediately: A Boolean value indicating whether image decoding and caching happens at image creation time.
            - allowsFloat: A Boolean indicating whether to use floating-point values in returned images.
            - subsampleFactor: The factor by which to scale down any returned images.
         */
        public init(caches: Bool = true, decodesImmediately: Bool = false, allowsFloat: Bool = false, subsampleFactor: SubsampleFactor? = nil) {
            self.caches = caches
            self.decodesImmediately = decodesImmediately
            self.allowsFloat = allowsFloat
            self.subsampleFactor = subsampleFactor
        }
        
        var dic: CFDictionary {
            var options: [CFString: Any] = [:]
            options[kCGImageSourceShouldAllowFloat] = allowsFloat
            options[kCGImageSourceShouldCache] = caches
            options[kCGImageSourceShouldCacheImmediately] = decodesImmediately
            options[kCGImageSourceSubsampleFactor] = subsampleFactor?.rawValue
            if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *), preferredDynamicRange != nil {
                options[kCGImageSourceDecodeRequest] = preferredDynamicRange == .standard ? kCGImageSourceDecodeToSDR : kCGImageSourceDecodeToHDR
            }
            return options as CFDictionary
        }
    }
}
