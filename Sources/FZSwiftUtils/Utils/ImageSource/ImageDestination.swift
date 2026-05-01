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
        case auxiliary(auxiliaryData: ImageProperties.AuxiliaryData)
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
    
    /**
     Sets the auxiliary data, such as mattes and depth information, that accompany the image.
     
     Call this method after you add an image to the image destination. This method adds the specified depth or matte information to the most recently added image.

     - Parameters:
        - auxiliaryData: The auxiliary information to add.
        -  type: The type of the auxiliary information.
     */
    public func addAuxiliaryData(_ auxiliaryData: ImageProperties.AuxiliaryData) {
        steps += .auxiliary(auxiliaryData: auxiliaryData)
    }
    
    /// Creates the finale image.
    public func create() throws -> NSUIImage {
        guard let image = NSUIImage(data: try createData()) else { throw Errors.saveFailed }
        return image
    }
    
    /// Saves the image by writing and returning the finale image as `Data`.
    public func createData() throws -> Data {
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, contentType.identifier as CFString, imageCount, nil) else { throw Errors.saveFailed }
        addImagesAndProperties(to: destination)
        guard CGImageDestinationFinalize(destination) else { throw Errors.saveFailed }
        return mutableData as Data
    }
    
    /// Saves the final image by writing the image to the specified url.
    public func createFile(at url: URL) throws {
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
            case .auxiliary(auxiliaryData: let auxiliaryData):
                CGImageDestinationAddAuxiliaryDataInfo(destination, auxiliaryData.type.rawValue, auxiliaryData.rawValue as CFDictionary)
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
