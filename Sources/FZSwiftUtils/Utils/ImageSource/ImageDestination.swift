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
    public static let supportedContentTypes = Set((CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []).compactMap { UTType($0) })
    
    private enum ImageEntry {
        case image(_ image: CGImage, metadata: CGImageMetadata?, properties: [CFString: Any]?, auxiliaryData: [ImageProperties.AuxiliaryData])
        case sourceImage(imageSource: CGImageSource, index: Int, properties: [CFString: Any]?, auxiliaryData: [ImageProperties.AuxiliaryData])
    }
    
    private var imageEntries: [ImageEntry] = []
    
    /// The content type of the image destination.
    public let contentType: UTType
    
    /// The number of images currently added to the destination.
    public var imageCount: Int {
        imageEntries.count
    }

    /// The image properties to add the image.
    public var imageProperties: [CFString: Any] = [:]
    
    /**
     Adds the specified image to the image destination.

     - Parameters:
        - image: The image to add.
        - options: The options to use when adding the image.
        - properties: An optional dictionary containing image properties for the added image.
        - metadata: The metadata to associate with the image.
        - auxiliaryData: The auxiliary data, such as depth and matte information, to associate with the image.
     */
    public func addImage(_ image: CGImage, options: ImageOptions = .init(), properties: [CFString: Any]? = nil, metadata: CGImageMetadata? = nil, auxiliaryData: [ImageProperties.AuxiliaryData] = []) {
        imageEntries += .image(image, metadata: metadata, properties: (properties ?? [:]).merging(options.dictionary), auxiliaryData: auxiliaryData)
    }
    
    /**
     Adds an image from the specified image source to the image destination.
     
     - Parameters:
        - source: An image source that contains the image.
        - index: The index of the image in the image source.
        - options: Options how to add the image.
        - properties: An optional dictionary that specifies additional image property information. The added image automatically inherits the properties found in the image source. Use this dictionary to add properties to the image, or to modify one of the inherited properties. To remove an inherited property altogether, specify `nil` for the property’s value.
     */
    public func addImage(from source: ImageSource, at index: Int = 0, options: ImageOptions = .init(), properties: [CFString: Any]? = nil, auxiliaryData: [ImageProperties.AuxiliaryData] = []) {
        imageEntries += .sourceImage(imageSource: source.cgImageSource, index: index, properties: (properties ?? [:]).merging(options.dictionary), auxiliaryData: auxiliaryData)
    }
    
    /**
     Adds all images from the specified image source to the image destination.
     
     - Parameters:
        - source: The image source that provides the images.
        - options: Options how to add the images.
        - properties: An optional dictionary that specifies additional image property information. The added images automatically inherits the properties found in the image source. Use this dictionary to add properties to the images, or to modify one of the inherited properties. To remove an inherited property altogether, specify `nil` for the property’s value.
     */
    public func addImages(from source: ImageSource, options: ImageOptions = .init(), properties: [CFString: Any]? = nil) {
        (0..<source.count).forEach({ addImage(from: source, at: $0, options: options, properties: properties) })
    }
    
    /// Creates the finale image.
    public func createImage() throws -> NSUIImage {
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
        for entry in imageEntries {
            switch entry {
            case .image(let image, let metadata, let properties, let auxiliaryData):
                if let metadata = metadata {
                    CGImageDestinationAddImageAndMetadata(destination, image, metadata, properties as CFDictionary?)
                } else {
                    CGImageDestinationAddImage(destination, image, properties as CFDictionary?)
                }
                for data in auxiliaryData {
                    CGImageDestinationAddAuxiliaryDataInfo(destination, data.type.rawValue, data.rawValue as CFDictionary)
                }
            case .sourceImage(let source, let index, let properties, let auxiliaryData):
                CGImageDestinationAddImageFromSource(destination, source, index, properties as CFDictionary?)
                for data in auxiliaryData {
                    CGImageDestinationAddAuxiliaryDataInfo(destination, data.type.rawValue, data.rawValue as CFDictionary)
                }
            }
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
