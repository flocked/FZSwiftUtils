//
//  ImageDestination.swift
//  FZSwiftUtils
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
    
    /// The type identifier of the image destionation.
    public let typeIdentifier: String
    
    /// The content type of the image destionation.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var contentType: UTType {
        UTType(typeIdentifier)!
    }
    
    /// The number of images currently added to the destination.
    public internal(set) var imageCount = 0
    
    /**
     A Boolean value indicating whether the destination has been finalized.

     After finalization, no further images, metadata, or auxiliary data may be added.
     */
    public internal(set) var isFinalized = false

    private var _imageProperties: [CFString: Any] = [:]

    /// The image properties to add the image.
    public var imageProperties: [CFString: Any] {
        get { _imageProperties }
        set {
            guard !isFinalized else { return }
            _imageProperties = newValue
        }
    }
    
    /**
     Adds the specified image to the image destionation.
     
     - Parameters:
        - image: The image to add.
        - options: Options how to add the image.
        - properties: An optional dictionary that specifies the properties of the added image.
     */
    public func addImage(_ image: CGImage, options: ImageOptions = .init(), properties: [CFString: Any]? = nil) {
        guard !isFinalized else { return }
        steps += .image(image, metadata: nil, properties: options.dictionary(with: properties))
        imageCount += 1
    }
    
    /**
     Adds the specified image and it's metadata to the image destionation.
     
     - Parameters:
        - image: The image to add.
        - metadata: The metadata for the image to add.
        - options: Options how to add the image.
        - properties: An optional dictionary that specifies the properties of the added image.
     */
    public func addImage(_ image: CGImage, metadata: CGImageMetadata, options: ImageOptions = .init(), properties: [CFString: Any]? = nil) {
        guard !isFinalized else { return }
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
    public func addImage(from source: CGImageSource, at index: Int, options: ImageOptions = .init()) {
        guard !isFinalized else { return }
        steps += .sourceImage(imageSource: source, index: index, properties: options.dictionary)
        imageCount += 1
    }
    
    public func addAuxiliaryDataInfo(_ auxiliaryDataInfo: [CGImage.AuxiliaryDataInfoKey: Any], type: CGImage.AuxiliaryDataType) {
        guard !isFinalized else { return }
        steps += .auxiliary(info: auxiliaryDataInfo, type: type)
    }
    
    /**
     Finalize creating the image by writing and returning the finale image as `Data`.
     
     Call this method as the final step in saving your images. If the finalization succeeds, you can’t add any more data to the image destination. Otherwise the methd throws.
     */
    public func finalize() throws -> Data {
        guard !isFinalized else { throw Errors.alreadyFinalized }
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, typeIdentifier as CFString, imageCount, nil) else { throw Errors.finalizationFailed }
        addImagesAndProperties(to: destination)
        guard CGImageDestinationFinalize(destination) else { throw Errors.finalizationFailed }
        steps = []
        isFinalized = true
        return mutableData as Data
    }
    
    /**
     Finalize creating the image by writing the image to the specified url.
     
     Call this method as the final step in saving your images. If the finalization succeeds, you can’t add any more data to the image destination. Otherwise the methd throws.
     */
    public func finalize(to url: URL) throws {
        guard !isFinalized else { throw Errors.alreadyFinalized }
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, typeIdentifier as CFString, imageCount, nil) else { throw Errors.finalizationFailed }
        addImagesAndProperties(to: destination)
        guard CGImageDestinationFinalize(destination) else { throw Errors.finalizationFailed }
        isFinalized = true
        steps = []
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
     Creates an image destination for a specified type identifier.
     
     Supported type identifiers can be retrieved via ``supportedTypeIdentifiers``.

     - Parameter typeIdentifier: The uniform type identifier of the image type (e.g., "public.png").
     - Returns: An instance if the type is supported; otherwise, `nil`.
     */
    public init?(typeIdentifier: String) {
        guard Self.supportedTypeIdentifers.contains(typeIdentifier) else { return nil }
        self.typeIdentifier = typeIdentifier
    }

    /**
     Creates an image destination for the specified content type.
     
     Supported content types can be retrieved via ``supportedContentTypes``.


     - Parameter contentType: The `UTType` representing the image type (e.g. `.png`).
     - Returns: An instance if the type is supported; otherwise, `nil`.     
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public init?(contentType: UTType) {
        guard Self.supportedContentTypes.contains(contentType) else { return nil }
        self.typeIdentifier = contentType.identifier
    }
    
    /// The image type identifiers that are supported by image destionation.
    public static let supportedTypeIdentifers = (CGImageDestinationCopyTypeIdentifiers() as NSArray).compactMap({ $0 as? String })
    
    /// The content types that are supported by image destionation.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public static var supportedContentTypes: [UTType] {
        supportedTypeIdentifers.compactMap({  UTType($0) })
    }
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
        @available(macOS 11.0, iOS 14.1, tvOS 14.1, watchOS 7.0, *)
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
        case finalizationFailed
        case alreadyFinalized
        
        public var errorDescription: String? {
            switch self {
            case .finalizationFailed:
                return "The image destination could not be finalized."
            case .alreadyFinalized:
                return "The image destination has already been finalized and cannot be modified further."
            }
        }
        
        public var failureReason: String? {
            switch self {
            case .finalizationFailed:
                return "The finalization process failed, possibly due to invalid image data or unsupported destination type."
            case .alreadyFinalized:
                return "Once finalized, an image destination cannot be reused or modified."
            }
        }
    }
}
