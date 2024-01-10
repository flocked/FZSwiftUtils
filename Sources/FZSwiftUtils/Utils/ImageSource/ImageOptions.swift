//
//  ImageOptions.swift
//
//
//  Created by Florian Zand on 03.06.22.
//

import Foundation

public extension ImageSource {
    /// Options for creating images.
    struct ImageOptions: Codable {
        /// A Boolean value that indicates whether to cache the decoded image.
        public var shouldCache: Bool? = true
        /// A Boolean value that indicates whether image decoding and caching happens at image creation time.
        public var shouldDecodeImmediately: Bool?
        /// The factor by which to scale down any returned images.
        public var subsampleFactor: SubsampleFactor?
        /// A Boolean that indicates whether to use floating-point values in returned images.
        public var shouldAllowFloat: Bool? = false

        /// The factor by which to scale down returned images.
        public enum SubsampleFactor: Int, Codable {
            /// Factor 2
            case factor2 = 2
            /// Factor 4
            case factor4 = 4
            /// Factor 8
            case factor8 = 8
        }

        var dic: CFDictionary {
            toDictionary() as CFDictionary
        }

        /// Returns new image options.
        public init() {}

        public enum CodingKeys: String, CodingKey {
            case shouldAllowFloat = "kCGImageSourceShouldAllowFloat"
            case shouldCache = "kCGImageSourceShouldCache"
            case shouldDecodeImmediately = "kCGImageSourceShouldCacheImmediately"
            case subsampleFactor = "kCGImageSourceSubsampleFactor"
        }
    }

    /// Options for creating thumbnails.
    struct ThumbnailOptions: Codable {
        /// A Boolean value that indicates whether to cache the decoded image.
        public var shouldCache: Bool? = true
        /// A Boolean value that indicates whether image decoding and caching happens at image creation time.
        public var shouldDecodeImmediately: Bool? = true
        /// The factor by which to scale down any returned images.
        public var subsampleFactor: SubsampleFactor?
        /// A Boolean that indicates whether to use floating-point values in returned images.
        public var shouldAllowFloat: Bool? = false
        /// The maximum size of a thumbnail image, specified in pixels.
        public var maxSize: Int?
        /// A Boolean value that indicates whether to rotate and scale the thumbnail image to match the image’s orientation and aspect ratio.
        public var shouldTransform: Bool?
        var createIfAbsent: Bool?
        var createAlways: Bool? = true

        /// Option when a thumbnail should be created.
        public var createOption: CreateOption {
            get { if createAlways == true { return .always } else if createIfAbsent == true { return .ifAbsent }
                return .never
            }
            set { createAlways = (newValue == .always) ? true : nil
                createIfAbsent = (newValue == .ifAbsent) ? true : nil
            }
        }

        /// The factor by which to scale down returned images.
        public enum SubsampleFactor: Int, Codable {
            /// Factor 2
            case factor2 = 2
            /// Factor 4
            case factor4 = 4
            /// Factor 8
            case factor8 = 8
        }

        /// Option when a thumbnail should be created.
        public enum CreateOption: Codable {
            /// Creates a thumbnail if the data source doesn’t contain one.
            case ifAbsent
            /// Creates always a thumbnail.
            case always
            /// Creates never a thumbnail
            case never
        }

        var dic: CFDictionary {
            toDictionary() as CFDictionary
        }

        /// Returns new thumbnail options.
        public init() {}

        /**
         Returns new thumbnail options with the specified maximum thumbnail size.
         - Parameter maxSize: The maximum size for the thumbnails.
         - Returns:New thumbnail options.
         */
        public static func maxSize(_ maxSize: CGSize) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.maxSize = Int(max(maxSize.width, maxSize.height))
            return options
        }

        /**
         Returns new thumbnail options with the specified maximum thumbnail size.
         - Parameter maxSize: The maximum size for the thumbnails.
         - Returns:New thumbnail options.
         */
        public static func maxSize(_ maxSize: Int) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.maxSize = maxSize
            return options
        }

        /**
         Returns new thumbnail options with the specified subsample factor.
         - Parameter subsampleFactor: The factor by which to scale down returned images.
         - Returns:New thumbnail options.
         */
        public static func subsampleFactor(_ subsampleFactor: SubsampleFactor) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.subsampleFactor = subsampleFactor
            return options
        }

        public enum CodingKeys: String, CodingKey {
            case shouldAllowFloat = "kCGImageSourceShouldAllowFloat"
            case shouldCache = "kCGImageSourceShouldCache"
            case shouldDecodeImmediately = "kCGImageSourceShouldCacheImmediately"
            case subsampleFactor = "kCGImageSourceSubsampleFactor"
            case maxSize = "kCGImageSourceThumbnailMaxPixelSize"
            case shouldTransform = "kCGImageSourceCreateThumbnailWithTransform"
            case createIfAbsent = "kCGImageSourceCreateThumbnailFromImageIfAbsent"
            case createAlways = "kCGImageSourceCreateThumbnailFromImageAlways"
        }
    }
}
