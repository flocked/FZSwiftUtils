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
    struct ImageOptions: Hashable {
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
        
        var dictionary: CFDictionary {
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

/*
public extension ImageSource {
    struct ImageOptionsAlt: OptionSet {
        /// The returned image caches.
        public static let caches = Self(rawValue: 0 << 0)
        /// The returned image decodes and caches at image creation time.
        public static let decodesImmediately = Self(rawValue: 0 << 1)
        /// The returned image uses floating-point values.
        public static let allowsFloat = Self(rawValue: 0 << 2)
        
        /// The factor by which to scale down returned images.
        public enum SubsampleFactor: Int, Codable, Hashable {
            /// Factor 2
            case factor2 = 2
            /// Factor 4
            case factor4 = 4
            /// Factor 8
            case factor8 = 8
        }
        
        /// The factor by which to scale down any returned images.
        public static func subsampleFactor(_ factor: SubsampleFactor) -> Self {
            switch factor {
            case .factor2: .subsampleFactor2
            case .factor4: .subsampleFactor4
            case .factor8: .subsampleFactor8
            }
        }
        
        private static let subsampleFactor2 = Self(rawValue: 0 << 3)
        private static let subsampleFactor4 = Self(rawValue: 0 << 4)
        private static let subsampleFactor8 = Self(rawValue: 0 << 5)
        
        /// The preferred dynamic range to use when decoding the image.
        @available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
        public static func preferredDynamicRange(_ dynamicRange: DynamicRange) -> Self {
            dynamicRange == .standard ? .preferStandardDynamicRange : .preferHighDynamicRange
        }
        
        /// The dynamic range to prefer when decoding an image.
        @available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
        public enum DynamicRange: Int, Codable {
            /// Standard dynamic range.
            case standard
            /// High dynamic range.
            case high
        }
        
        private static let preferHighDynamicRange = Self(rawValue: 0 << 6)
        private static let preferStandardDynamicRange = Self(rawValue: 0 << 7)
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
*/
