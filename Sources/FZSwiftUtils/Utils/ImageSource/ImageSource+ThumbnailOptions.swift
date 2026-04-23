//
//  ImageSource+ThumbnailOptions.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageSource {
    /// Options for creating thumbnails.
    struct ThumbnailOptions: Hashable {
        /// A Boolean value indicating whether to cache the decoded image.
        public var caches: Bool = true
        /// A Boolean value indicating whether image decoding and caching happens at image creation time.
        public var decodesImmediately: Bool = true
        /// The factor by which to scale down any returned images.
        public var subsampleFactor: SubsampleFactor?
        /// A Boolean indicating whether to use floating-point values in returned images.
        public var allowsFloat: Bool = false
        /// The maximum width and height of a thumbnail image, or `nil` to use the original image size.
        public var maxSize: Int?
        /// A Boolean value indicating whether to rotate and scale the thumbnail image to match the image’s orientation and aspect ratio.
        public var transformsIfNeeded: Bool = false
        
        /**
         Specifies how thumbnail images are obtained.
         
         Some images contain embedded thumbnails that can be used.
         */
        public var creationPolicy: CreationPolicy = .always
        
        /// The preferred dynamic range to use when decoding the thumbnail.
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
        
        /**
         Describes how thumbnail images should be obtained.
         
         Some images contain embedded thumbnails that can be used.
         */
        public enum CreationPolicy: Codable {
            /// Always generate a thumbnail from the full image,  even if a thumbnail is present in the image data source.
            case always
            /// Use an embedded thumbnail if available; otherwise generate one from the full image.
            case ifAbsent
            /// Only uses embedded thumbnails from the image data source.
            case embeddedOnly
        }
        
        /// The dynamic range to prefer when decoding a thumbnail.
        @available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
        enum DynamicRange: Int, Codable {
            /// Standard dynamic range (SDR)
            case standard
            /// High dynamic range (HDR)
            case high
        }

        /**
         Creates the options for generating thumbnails.

         - Parameters:
            - create: Option when a thumbnail should be created.
            - maxSize: The maximum size of a thumbnail image, specified in pixels, or `nil` to use the original image size.
            - caches: A Boolean value indicating whether to cache the decoded image.
            - decodesImmediately: A Boolean value indicating whether image decoding and caching happens at image creation time.
            - allowsFloat: A Boolean indicating whether to use floating-point values in returned images.
            - transformsIfNeeded:A Boolean value indicating whether to rotate and scale the thumbnail image to match the image’s orientation and aspect ratio.
            - subsampleFactor: The factor by which to scale down any returned images.
         */
        public init(create: CreationPolicy = .always, maxSize: Int? = nil, caches: Bool = true, decodesImmediately: Bool = true, allowsFloat: Bool = false, transformsIfNeeded: Bool = false, subsampleFactor: SubsampleFactor? = nil) {
            self.maxSize = maxSize
            self.caches = caches
            self.decodesImmediately = decodesImmediately
            self.allowsFloat = allowsFloat
            self.transformsIfNeeded = transformsIfNeeded
            self.subsampleFactor = subsampleFactor
            self.creationPolicy = create
        }

        /**
         Returns options for generating thumbnails with the specified maximum thumbnail size.

         - Parameter maxSize: The maximum size for the thumbnails.
         */
        public static func maxSize(_ maxSize: Int) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.maxSize = maxSize
            return options
        }

        /**
         Returns options for generating thumbnails with the specified subsample factor.

         - Parameter subsampleFactor: The factor by which to scale down returned images.
         */
        public static func subsampleFactor(_ subsampleFactor: SubsampleFactor) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.subsampleFactor = subsampleFactor
            return options
        }

        var dictionary: CFDictionary {
            var options: [CFString: Any] = [:]
            options[kCGImageSourceShouldAllowFloat] = allowsFloat
            options[kCGImageSourceShouldCache] = caches
            options[kCGImageSourceShouldCacheImmediately] = decodesImmediately
            options[kCGImageSourceCreateThumbnailWithTransform] = transformsIfNeeded
            options[kCGImageSourceSubsampleFactor] = subsampleFactor?.rawValue
            options[kCGImageSourceThumbnailMaxPixelSize] = maxSize
            if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *), preferredDynamicRange != nil {
                options[kCGImageSourceDecodeRequest] = preferredDynamicRange == .standard ? kCGImageSourceDecodeToSDR : kCGImageSourceDecodeToHDR
            }
            switch creationPolicy {
            case .ifAbsent: options[kCGImageSourceCreateThumbnailFromImageIfAbsent] = true
            case .always: options[kCGImageSourceCreateThumbnailFromImageAlways] = true
            case .embeddedOnly: break
            }
            return options as CFDictionary
        }
    }
}

/*
public extension ImageSource {
    struct ThumbnailOptionsAlt: OptionSet {
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
        
        /// A Boolean value indicating whether to rotate and scale the thumbnail image to match the image’s orientation and aspect ratio.
        public static let transformIfNeeded = Self(rawValue: 0 << 6)
        
        private static let createAlways = Self(rawValue: 0 << 7)
        private static let createIfAbsent = Self(rawValue: 0 << 8)
        private static let createEmbeddedOnly = Self(rawValue: 0 << 9)
        
        /**
         Specifies how thumbnail images are obtained.
         
         Some images contain embedded thumbnails that can be used.
         */
        public static func creationPolicy(_ policy: CreationPolicy) -> Self {
            switch policy {
            case .always: .createAlways
            case .ifAbsent: .createIfAbsent
            case .embeddedOnly: .createEmbeddedOnly
            }
        }
        
        /**
         Describes how thumbnail images should be obtained.
         
         Some images contain embedded thumbnails that can be used.
         */
        public enum CreationPolicy: Codable {
            /// Always generate a thumbnail from the full image,  even if a thumbnail is present in the image data source.
            case always
            /// Use an embedded thumbnail if available; otherwise generate one from the full image.
            case ifAbsent
            /// Only uses embedded thumbnails from the image data source.
            case embeddedOnly
        }
        
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
        
        private static let preferHighDynamicRange = Self(rawValue: 0 << 10)
        private static let preferStandardDynamicRange = Self(rawValue: 0 << 11)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        var dic: CFDictionary {
            var options: [CFString: Any] = [:]
            options[kCGImageSourceShouldAllowFloat] = contains(.allowsFloat)
            options[kCGImageSourceShouldCache] = contains(.caches)
            options[kCGImageSourceShouldCacheImmediately] = contains(.decodesImmediately)
            options[kCGImageSourceCreateThumbnailWithTransform] = contains(.transformIfNeeded)
            if contains(.subsampleFactor8) {
                options[kCGImageSourceSubsampleFactor] = 8
            } else if contains(.subsampleFactor4) {
                options[kCGImageSourceSubsampleFactor] = 4
            } else if contains(.subsampleFactor2) {
                options[kCGImageSourceSubsampleFactor] = 2
            }
            // options[kCGImageSourceThumbnailMaxPixelSize] = maxSize
            if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
                if contains(.preferHighDynamicRange) {
                    options[kCGImageSourceDecodeRequest] = kCGImageSourceDecodeToHDR
                } else if contains(.preferStandardDynamicRange) {
                    options[kCGImageSourceDecodeRequest] = kCGImageSourceDecodeToSDR
                }
            }
            if contains(.createAlways) {
                options[kCGImageSourceCreateThumbnailFromImageAlways] = true
            } else if contains(.createIfAbsent) {
                options[kCGImageSourceCreateThumbnailFromImageIfAbsent] = true
            }
            return options as CFDictionary
        }
    }
}
*/
