//
//  ImageDestination.swift
//
//
//  Created by Florian Zand on 30.10.25.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

/// An object tthat can create image data by adding and combining images and specifing image properties and metadata.
public class ImageDestination {
    
    private enum Step {
        case image(_ image: CGImage, metadata: CGImageMetadata?, properties: [CFString: Any]?)
        case sourceImage(imageSource: CGImageSource, index: Int, properties: [CFString: Any]?)
        case auxiliary(info: [CGImage.AuxiliaryDataInfoKey: Any], type: CGImage.AuxiliaryDataType)
    }
    
    private var steps: [Step] = []
    
    /// The content type of the image destination.
    public let contentType: UTType
    
    /// The number of images currently added to the destination.
    public internal(set) var imageCount = 0

    private var _imageProperties: [CFString: Any] = [:]

    /// The image properties to add the image.
    public var imageProperties: [CFString: Any] {
        get { _imageProperties }
        set { _imageProperties = newValue }
    }
    
    /**
     Adds the specified image to the image destination.
     
     - Parameters:
        - image: The image to add.
        - options: Options how to add the image.
        - properties: An optional dictionary that specifies the properties of the added image.
     */
    public func addImage(_ image: CGImage, options: ImageOptions = .init(), properties: [CFString: Any]? = nil) {
        steps += .image(image, metadata: nil, properties: options.dictionary(with: properties))
        imageCount += 1
    }
    
    /**
     Adds the specified image and it's metadata to the image destination.
     
     - Parameters:
        - image: The image to add.
        - metadata: The metadata for the image to add.
        - options: Options how to add the image.
        - properties: An optional dictionary that specifies the properties of the added image.
     */
    public func addImage(_ image: CGImage, metadata: CGImageMetadata, options: ImageOptions = .init(), properties: [CFString: Any]? = nil) {
        steps += .image(image, metadata: metadata, properties: options.dictionary(with: properties))
        imageCount += 1
    }
    
    /**
     Adds an image from an image source to an image destination.
     
     - Parameters:
        - source: An image source that contains the image.
        - index: The index of the image in the image source.
        - options: Options how to add the image.
        - properties: An optional dictionary that specifies additional image property information. The added image automatically inherits the properties found in the image source. Use this dictionary to add properties to the image, or to modify one of the inherited properties. To remove an inherited property altogether, specify NULL for the property’s value.
     */
    public func addImage(from source: ImageSource, at index: Int = 0, options: ImageOptions = .init()) {
        steps += .sourceImage(imageSource: source.cgImageSource, index: index, properties: options.dictionary)
        imageCount += 1
    }
    
    public func addAuxiliaryDataInfo(_ auxiliaryDataInfo: [CGImage.AuxiliaryDataInfoKey: Any], type: CGImage.AuxiliaryDataType) {
        steps += .auxiliary(info: auxiliaryDataInfo, type: type)
    }
    
    /// Saves the image by writing and returning the finale image as `Data`.
    public func save() throws -> Data {
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, contentType.identifier as CFString, imageCount, nil) else { throw Errors.saveFailed }
        addImagesAndProperties(to: destination)
        guard CGImageDestinationFinalize(destination) else { throw Errors.saveFailed }
        return mutableData as Data
    }
    
    /// Saves the final image by writing the image to the specified url.
    public func save(to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, contentType.identifier as CFString, imageCount, nil) else { throw Errors.saveFailedToURL(url) }
        addImagesAndProperties(to: destination)
        guard CGImageDestinationFinalize(destination) else { throw Errors.saveFailedToURL(url) }
    }
    
    private func addImagesAndProperties(to destination: CGImageDestination) {
        if !imageProperties.isEmpty {
            CGImageDestinationSetProperties(destination, imageProperties as CFDictionary)
        }
        for step in steps {
            switch step {
            case .image(let image, let metadata, let properties):
                if let metadata = metadata {
                    CGImageDestinationAddImageAndMetadata(destination, image, metadata, properties as CFDictionary?)
                } else {
                    CGImageDestinationAddImage(destination, image, properties as CFDictionary?)
                }
            case .sourceImage(let source, let index, let properties):
                CGImageDestinationAddImageFromSource(destination, source, index, properties as CFDictionary?)
            case .auxiliary(let info, let type):
                CGImageDestinationAddAuxiliaryDataInfo(destination, type.rawValue, info as CFDictionary)
            }
        }
    }

    /**
     Creates an image destination for the specified content type.
     
     Supported content types can be retrieved via ``supportedContentTypes``.

     - Parameter contentType: The `UTType` representing the image type (e.g. `.png`).
     - Returns: An instance if the type is supported; otherwise, `nil`.     
     */
    public init?(contentType: UTType) {
        guard Self.supportedContentTypes.contains(contentType) else { return nil }
        self.contentType = contentType
    }
        
    /// The content types that are supported by image destination.
    static let supportedContentTypes: Set<UTType> = {
        Set((CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []).compactMap { UTType($0) })
      }()
}

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
        public var preserveGainMap: Bool {
            get { _preserveGainMap }
            set { _preserveGainMap = newValue }
        }
        var _preserveGainMap = false
        
        public init(maxSize: Int? = nil, compressionQuality: CGFloat? = nil, backgroundColor: CGColor? = nil, embedThumbnail: Bool = false, optimizeColorForSharing: Bool = false) {
            self.maxSize = maxSize
            self.compressionQuality = compressionQuality
            self.backgroundColor = backgroundColor
            self.embedThumbnail = embedThumbnail
            self.optimizeColorForSharing = optimizeColorForSharing
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

extension ImageDestination {
    private enum Errors: LocalizedError {
        case saveFailed
        case saveFailedToURL(URL)
        
        public var errorDescription: String? {
            switch self {
            case .saveFailed:
                return "The image destination could not be saved to Data."
            case .saveFailedToURL:
                return "The image destination could not be saved to the specified URL."
            }
        }
        
        public var failureReason: String? {
            switch self {
            case .saveFailed:
                return "The save failed, possibly due to invalid image data or unsupported destination type."
            case .saveFailedToURL(let url):
                return "The save failed to \"\(url.path)\", possibly due to invalid image data or unsupported destination type."
            }
        }
    }
}
