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
        - properties: An optional dictionary that specifies the properties of the added image.
     */
    public func addImage(_ image: CGImage, properties: [CFString: Any]? = nil) {
        guard !isFinalized else { return }
        steps += .image(image, metadata: nil, properties: properties)
        imageCount += 1
    }
    
    /**
     Adds the specified image and it's metadata to the image destionation.
     
     - Parameters:
        - image: The image to add.
        - metadata: The metadata for the image to add.
        - properties: An optional dictionary that specifies the properties of the added image.
     */
    public func addImage(_ image: CGImage, metadata: CGImageMetadata, properties: [CFString: Any]? = nil) {
        guard !isFinalized else { return }
        steps += .image(image, metadata: metadata, properties: properties)
        imageCount += 1
    }
    
    /**
     Adds an image from an image source to an image destination.
     
     - Parameters:
        - source: An image source that contains the image.
        - index: The index of the image in the image source.
        - properties: An optional dictionary that specifies additional image property information. The added image automatically inherits the properties found in the image source. Use this dictionary to add properties to the image, or to modify one of the inherited properties. To remove an inherited property altogether, specify NULL for the property’s value.
     */
    public func addImage(from source: CGImageSource, at index: Int) {
        guard !isFinalized else { return }
        steps += .sourceImage(imageSource: source, index: index, properties: nil)
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
    public func finalizeData() throws -> Data {
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
