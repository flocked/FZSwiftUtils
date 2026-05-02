//
//  CGMutableImageMetadata+.swift
//
//
//  Created by Florian Zand on 01.05.26.
//

#if canImport(ImageIO)
import Foundation
import ImageIO

public extension CGMutableImageMetadata {
    /**
     Update the value of an existing metadata tag, or create a new tag using the specified information.

     This method assigns a value to a metadata node identified by a path string. If a parent tag is provided, the path is resolved relative to that tag.

     - Parameters:
       - value: The new value for the property. The new value’s type must match the expected XMP type of the property at the specified path.
       - path: The metadata path where the value should be set.
       - parent: An optional parent tag used as the base for resolving the path.
     - Returns: `true` if the value was successfully set; otherwise, `false`.
     */
    @discardableResult
    func setValue(_ value: CFTypeRef, at path: String, parent: CGImageMetadataTag? = nil) -> Bool {
        CGImageMetadataSetValueWithPath(self, parent, path as CFString, value)
    }
    
    /**
     Updates the value of the metadata tag assigned to the specified image property.
     Sets a metadata value that corresponds to a standard image property.

     This method assigns a value using a known image property name within a specific metadata directory.

     - Parameters:
       - value: The value to assign. This must be a Core Foundation type supported by image metadata.
       - propertyName: The name of the property. For example, specify `kCGImagePropertyTIFFOrientation`, `kCGImagePropertyExifDateTimeOriginal`, or `kCGImagePropertyIPTCKeywords`.
       - directory: The metadata subdictionary to which the image property belongs. For example, specify `exif` for image properties that are part of the image’s EXIF metadata.
     - Returns: `true` if the value was successfully set; otherwise, `false`.
     */
    @discardableResult
    func setValue(_ value: CFTypeRef, matchingImageProperty propertyName: CFString, of directory: CGImageMetadata.ImagePropertyDirectory) -> Bool {
        CGImageMetadataSetValueMatchingImageProperty(self, directory.rawValue, propertyName, value)
    }
    
    /**
     Sets the tag at the specified path in the metadata object.
     
     This method inserts or replaces a metadata tag at the given path. If a parent tag is provided, the path is resolved relative to that tag.

     - Parameters:
       - tag: The tag object to add to the metadata. This function retains the tag object.
       - path: The metadata path where the tag should be placed.
       - parent: An optional parent tag used as the base for resolving the path.
     - Returns: `true` if the tag was successfully set; otherwise, `false`.
     */
    @discardableResult
    func setTag(_ tag: CGImageMetadataTag, for path: String, parent: CGImageMetadataTag? = nil) -> Bool {
        CGImageMetadataSetTagWithPath(self, parent, path as CFString, tag)
    }
    
    /**
     Removes the tag at the specified path from the metadata object.
     
     - Parameters:
        - path: A string that represents the path to the tag.
        - parent: The parent tag, or `nil` to add or update a tag starting at the top-level of the metadata object. If this parameter is `nil`, you must include a valid prefix string in the path parameter.
     - Returns: `True` if the tag has been removed, or `false` if it encountered a problem.
     */
    @discardableResult
    func removeTag(at path: String, parent: CGImageMetadataTag? = nil) -> Bool {
        CGImageMetadataRemoveTagWithPath(self, parent, path as CFString)
    }
    
    /**
     Registers the specified namespace and prefix with the metadata object.
     
     All tags you add to this mutable tag must belong to known namespaces. When you encounter an unrecognized prefix in a metadata path, call this function to register the prefix before you add the corresponding tag.
     
     You don’t need to register the standard metadata spaces, or any metadata spaces that are already present in the image’s metadata. Register only the namespaces you need to support additional metadata tags.
     
     If the namespace already exists and the prefix parameter conflicts with the already registered prefix, this function throws an error.
     
     - Parameters:
        - namespace: The namespace to register. Specify a string with a custom namespace URI. A custom namespace must be a valid XML namespace. By convention, namespaces end with either the / or # character.
        - prefix: An abbreviation for the XML namespace. You must specify a valid string for custom namespace.
     */
    func registerNamespace(_ namespace: String, forPrefix prefix: String) throws {
        var unmanagedError: Unmanaged<CFError>?
        let success = CGImageMetadataRegisterNamespaceForPrefix(self, namespace as CFString, prefix as CFString, &unmanagedError)
        if !success, let error = unmanagedError?.takeRetainedValue() {
            throw error
        }
    }
}

#endif
