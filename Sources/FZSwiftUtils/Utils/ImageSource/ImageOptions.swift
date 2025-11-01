//
//  ImageOptions.swift
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
         Returns the options for generating images.

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
            return options as CFDictionary
        }
    }

    /// Options for creating thumbnails.
    struct ThumbnailOptions: Codable, Hashable {
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
         Specifies when a thumbnail should be created.
         
         Some images contain pre-rendered thumbnails that can be returned. Alternatively, a new thumbnail can be generated.
         */
        public var creationPolicy: CreationPolicy = .always

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
         Specifies when a thumbnail should be created.
         
         Some images contain pre-rendered thumbnails that can be returned. Alternatively, a new thumbnail can be generated.
         */
        public enum CreationPolicy: Codable {
            /// Always create a thumbnail from the image even if a thumbnail is present in the image data source.
            case always
            /// Create a thumbnail if the image data source doesn’t contain a thumbnail.
            case ifAbsent
            /// Only uses pre-rendered thumbnails from the original image data source.
            case never
        }

        /**
         Returns the options for generating thumbnails.

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

        var dic: CFDictionary {
            var options: [CFString: Any] = [:]
            options[kCGImageSourceShouldAllowFloat] = allowsFloat
            options[kCGImageSourceShouldCache] = caches
            options[kCGImageSourceShouldCacheImmediately] = decodesImmediately
            options[kCGImageSourceCreateThumbnailWithTransform] = transformsIfNeeded
            options[kCGImageSourceSubsampleFactor] = subsampleFactor?.rawValue
            options[kCGImageSourceThumbnailMaxPixelSize] = maxSize
            switch self.creationPolicy {
            case .ifAbsent: options[kCGImageSourceCreateThumbnailFromImageIfAbsent] = true
            case .always: options[kCGImageSourceCreateThumbnailFromImageAlways] = true
            case .never: break
            }
            return options as CFDictionary
        }
    }
}
