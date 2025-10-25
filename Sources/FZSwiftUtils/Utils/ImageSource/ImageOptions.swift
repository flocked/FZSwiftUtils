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
        public var shouldCache: Bool = true
        /// A Boolean value indicating whether image decoding and caching happens at image creation time.
        public var shouldDecodeImmediately: Bool = false
        /// The factor by which to scale down any returned images.
        public var subsampleFactor: SubsampleFactor?
        /// A Boolean indicating whether to use floating-point values in returned images.
        public var shouldAllowFloat: Bool = false

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
            - shouldCache: A Boolean value indicating whether to cache the decoded image.
            - shouldDecodeImmediately: A Boolean value indicating whether image decoding and caching happens at image creation time.
            - shouldAllowFloat: A Boolean indicating whether to use floating-point values in returned images.
            - subsampleFactor: The factor by which to scale down any returned images.
         */
        public init(shouldCache: Bool = true, shouldDecodeImmediately: Bool = false, shouldAllowFloat: Bool = false, subsampleFactor: SubsampleFactor? = nil) {
            self.shouldCache = shouldCache
            self.shouldDecodeImmediately = shouldDecodeImmediately
            self.shouldAllowFloat = shouldAllowFloat
            self.subsampleFactor = subsampleFactor
        }
        
        var dic: CFDictionary {
            var options: [CFString: Any] = [:]
            options[kCGImageSourceShouldAllowFloat] = shouldAllowFloat
            options[kCGImageSourceShouldCache] = shouldCache
            options[kCGImageSourceShouldCacheImmediately] = shouldDecodeImmediately
            options[kCGImageSourceSubsampleFactor] = subsampleFactor?.rawValue
            return options as CFDictionary
        }
    }

    /// Options for creating thumbnails.
    struct ThumbnailOptions: Codable, Hashable {
        /// A Boolean value indicating whether to cache the decoded image.
        public var shouldCache: Bool = true
        /// A Boolean value indicating whether image decoding and caching happens at image creation time.
        public var shouldDecodeImmediately: Bool = true
        /// The factor by which to scale down any returned images.
        public var subsampleFactor: SubsampleFactor?
        /// A Boolean indicating whether to use floating-point values in returned images.
        public var shouldAllowFloat: Bool = false
        /// The maximum width and height of a thumbnail image, or `nil` to use the original image size.
        public var maxSize: Int?
        /// A Boolean value indicating whether to rotate and scale the thumbnail image to match the image’s orientation and aspect ratio.
        public var shouldTransform: Bool = false
        
        /**
         Specifies when a thumbnail should be created.
         
         Some images contain pre-rendered thumbnails that can be returned. Alternatively, a new thumbnail can be generated.
         */
        public var createOption: CreateOption = .always

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
        public enum CreateOption: Codable {
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
            - shouldCache: A Boolean value indicating whether to cache the decoded image.
            - shouldDecodeImmediately: A Boolean value indicating whether image decoding and caching happens at image creation time.
            - shouldAllowFloat: A Boolean indicating whether to use floating-point values in returned images.
            - shouldTransform:A Boolean value indicating whether to rotate and scale the thumbnail image to match the image’s orientation and aspect ratio.
            - subsampleFactor: The factor by which to scale down any returned images.
         */
        public init(create: CreateOption = .always, maxSize: Int? = nil, shouldCache: Bool = true, shouldDecodeImmediately: Bool = true, shouldAllowFloat: Bool = false, shouldTransform: Bool = false, subsampleFactor: SubsampleFactor? = nil) {
            self.maxSize = maxSize
            self.shouldCache = shouldCache
            self.shouldDecodeImmediately = shouldDecodeImmediately
            self.shouldAllowFloat = shouldAllowFloat
            self.shouldTransform = shouldTransform
            self.subsampleFactor = subsampleFactor
            self.createOption = create
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
            options[kCGImageSourceShouldAllowFloat] = shouldAllowFloat
            options[kCGImageSourceShouldCache] = shouldCache
            options[kCGImageSourceShouldCacheImmediately] = shouldDecodeImmediately
            options[kCGImageSourceCreateThumbnailWithTransform] = shouldTransform
            options[kCGImageSourceSubsampleFactor] = subsampleFactor?.rawValue
            options[kCGImageSourceThumbnailMaxPixelSize] = maxSize
            switch self.createOption {
            case .ifAbsent: options[kCGImageSourceCreateThumbnailFromImageIfAbsent] = true
            case .always: options[kCGImageSourceCreateThumbnailFromImageAlways] = true
            case .never: break
            }
            return options as CFDictionary
        }
    }
}
