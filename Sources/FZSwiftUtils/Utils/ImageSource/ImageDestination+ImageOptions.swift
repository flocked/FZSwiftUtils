//
//  ImageDestination+ImageOptions.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

extension ImageDestination {
    /// The options for adding an an image to the destination.
    public struct ImageOptions {
        
        /**
         The maximum width and height of the image.
         
         If present, the destination rescales the image as needed to fit within the maximum width and height. If this key isn’t present, the destination retains the native image size.
         */
        public var maxSize: Int?
        
        /**
         The desired compression quality to use when writing the image data.
         
         The compression factor must be in the range of `0.0` to `1.0`. A value of `1.0` specifies to use lossless compression if destination format supports it. A value of `0.0` implies to use maximum compression.
         */
        public var compressionQuality: CGFloat? {
            didSet { compressionQuality?.clamp(to: 0...1) }
        }
        
        /**
         ckground color to use when the image has an alpha component, but the destination format doesn’t support alpha.
         
         The color you provide must be a CGColor without an alpha component of its own. If the property is `nil` and a background color is needed, a white color is used.
         */
        public var backgroundColor: CGColor?
        
        /// A Boolean value that indicates whether to embed a thumbnail for JPEG and HEIF images.
        public var embedThumbnail = false
        
        /**
         A Boolean value that indicates whether to create the image using a colorspace.
         
         If you set this property to `true`, the image is color converted using its colorspace, which provides better compatibility with older devices.
         */
        public var optimizeColorForSharing = false
        
        /**
         A Boolean value that indicates whether to include a HEIF-embedded gain map in the image data.
         
         If you scale the destination image using the ``maxSize`` property, the destination also scales the gain map.
         */
        public var preserveGainMap = false
        
        /**
         Creates the options for adding images to the destination.

         - Parameters:
            - maxSize: The maximum width and height of the image.
            - compressionQuality: The desired compression quality to use when writing the image data.
            - backgroundColor: The background color to use when the destination format doesn’t support alpha.
            - embedThumbnail: A Boolean value that indicates whether to embed a thumbnail for JPEG and HEIF images.
            - optimizeColorForSharing: A Boolean value that indicates whether to color convert the image for better compatibility.
            - preserveGainMap: A Boolean value that indicates whether to include a HEIF-embedded gain map in the image data.
         */
        public init(maxSize: Int? = nil, compressionQuality: CGFloat? = nil, backgroundColor: CGColor? = nil, embedThumbnail: Bool = false, optimizeColorForSharing: Bool = false, preserveGainMap: Bool = false) {
            self.maxSize = maxSize
            self.compressionQuality = compressionQuality
            self.backgroundColor = backgroundColor
            self.embedThumbnail = embedThumbnail
            self.optimizeColorForSharing = optimizeColorForSharing
            self.preserveGainMap = preserveGainMap
        }
        
        func dictionary(with properties: [CFString:Any]?) -> [CFString:Any]? {
            guard var properties = properties else { return dictionary }
            dictionary.forEach({ properties[$0.key] = $0.value })
            return properties.isEmpty ? nil : properties
        }
        
        var dictionary: [CFString: Any] {
            var dict: [CFString: Any] = [:]
            dict[kCGImageDestinationImageMaxPixelSize] = maxSize
            dict[kCGImageDestinationBackgroundColor] = backgroundColor
            dict[kCGImageDestinationLossyCompressionQuality] = compressionQuality
            if embedThumbnail { dict[kCGImageDestinationEmbedThumbnail] = true }
            if optimizeColorForSharing { dict[kCGImageDestinationOptimizeColorForSharing] = true }
            if #available(macOS 11.0, iOS 14.1, tvOS 14.1, watchOS 7.0, *) {
                if preserveGainMap { dict[kCGImageDestinationPreserveGainMap] = true }
            }
            return dict
        }
    }
}
