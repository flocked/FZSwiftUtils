//
//  CGImageDestination+.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 27.07.26.
//

import Foundation
import ImageIO

public extension CGImageDestination {
     func setProperties(_ properties: [CFString: Any]) {
        CGImageDestinationSetProperties(self, properties as CFDictionary)
    }
    
    func addImage(_ image: CGImage, metadata: CGImageMetadata? = nil, properties: [CFString: Any]? = nil) {
        if let metadata = metadata {
            CGImageDestinationAddImageAndMetadata(self, image, metadata, properties as CFDictionary?)
        } else {
            CGImageDestinationAddImage(self, image, properties as CFDictionary?)
        }
    }
    
    func addImageFromSource(_ source: CGImageSource, at index: Int, properties: [CFString: Any]? = nil) {
        CGImageDestinationAddImageFromSource(self, source, index, properties as CFDictionary?)
    }
    
    func addAuxiliaryDataInfo(_ auxiliaryDataInfo: [CFString: Any], type: CFString) {
        CGImageDestinationAddAuxiliaryDataInfo(self, type as CFString, auxiliaryDataInfo as CFDictionary)
    }
    

}

extension CFType where Self == CGImageDestination {
    /**
     Creates an image destination that writes to the specified URL.
     
     - Parameters:
        - url: The URL at which to write the image data. This object overwrites any data at the specified URL.
        - type: The uniform type identifier of the resulting image file.
        - imageCount: The number of images (not including thumbnail images) you want to include in the image file.
     - Returns: An image destination, or `nil` if an error occurs.
     */
    public init?(url: URL, type typeIdentifier: String, imageCount: Int) {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, typeIdentifier as CFString, imageCount, nil) else { return nil }
        self = destination
    }
    
    /**
     Creates an image destination that writes to mutable data object.
     
     - Parameters:
        - data: The data object in which to store the image data.
        - type: The uniform type identifier of the resulting image file.
        - imageCount: The number of images (not including thumbnail images) you want to include in the image file.
     - Returns: An image destination, or `nil` if an error occurs.
     */
    public init?(data: CFMutableData, type typeIdentifier: String, imageCount: Int) {
        guard let destination = CGImageDestinationCreateWithData(data, typeIdentifier as CFString, imageCount, nil) else { return nil }
        self = destination
    }
}
/*
 guard let destination = CGImageDestinationCreateWithURL(url as CFURL, contentType.identifier as CFString, imageCount, nil) else { throw Errors.saveFailedToURL(url) }
 addImagesAndProperties(to: destination)
 guard CGImageDestinationFinalize(destination) else { throw Errors.saveFailedToURL(url) }
 */
