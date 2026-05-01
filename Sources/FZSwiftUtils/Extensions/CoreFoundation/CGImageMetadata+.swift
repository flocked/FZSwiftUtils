//
//  CGImageMetadata+.swift
//
//
//  Created by Florian Zand on 01.05.26.
//

#if canImport(ImageIO)
import Foundation
import ImageIO

extension CGImageMetadata {
    /**
     Enumerates the metadata tags starting at the specified root path.

     Return `true` to continue enumeration, or `false` to stop.

     - Parameters:
       - rootPath: The metadata path to begin enumeration from, or `nil` to start from the metadata root.
       - recursive: A Boolean value indicating whether enumeration should include descendant tags.
       - block: A closure invoked for each tag. The closure receives the current tag and its full path.
     */
    public func enumerateTags(at rootPath: String? = nil, recursive: Bool = false, using block: @escaping (_ tag: CGImageMetadataTag, _ path: String)->(Bool)) {
        CGImageMetadataEnumerateTagsUsingBlock(self, rootPath as CFString?, recursive ? [kCGImageMetadataEnumerateRecursively: true] as CFDictionary : nil) { path, tag in
            block(tag, path as String)
        }
    }
    
    /**
     Returns a data object that contains the metadata object’s contents serialized into the XMP format.
     
     Use this function to create sidecar files with metadata for image formats that don’t support embedded XMP, or that you cannot edit due to other format restrictions. For example, use this function to create the data for proprietary RAW camera formats.
     */
    public func createXMPData() -> Data? {
        CGImageMetadataCreateXMPData(self, nil) as? Data
    }

    /**
     Returns the tag at the specified metadata path.
     
     - Parameters:
       - parent: The parent tag to search from, or `nil` to search from the metadata root.
       - path: The metadata path of the tag.
     - Returns: The matching metadata tag, or `nil` if no tag exists at the path.
     */
    public func tag(withPath path: String, parent: CGImageMetadataTag? = nil) -> CGImageMetadataTag? {
        CGImageMetadataCopyTagWithPath(self, parent, path as CFString)
    }

    /// Returns all root-level metadata tags.
    public var tags: [CGImageMetadataTag]? {
        CGImageMetadataCopyTags(self) as? [CGImageMetadataTag]
    }

    /**
     Returns the tag matching the specified image property.
     
     Use this function to quickly search the different metadata dictionaries for a specific tag. The returned tag object contains appropriate values for all fields, including the namespace, prefix, and XMP type.
     
     When you request an `EXIF` or `IPTC` property, this function fills in the namespace, prefix, and XMP type information by copying information from an appropriate XMP type. For example, when you request the `kCGImagePropertyExifDateTimeOriginal` property, the function fills in the information using the `photoshop:DateTime` XMP tag. When this bridging occurs, property fields retain their XMP format, rather than the EXIF or IPTC format.
     
     - Parameters:
        - propertyName: The name of the image property to search.
        - dictionary:The metadata subdictionary to which the image property belongs. For example, specify `exif` for image properties that are part of the image’s EXIF metadata.
     - Returns: The matching metadata tag, or `nil` if no matching tag exists.
     */
    public func tag(forImageProperty propertyName: CFString, in dictionary: ImagePropertyDirectory) -> CGImageMetadataTag? {
        CGImageMetadataCopyTagMatchingImageProperty(self, dictionary.rawValue, propertyName)
    }

    /**
     Returns the string value at the specified metadata path.
     
     The XMP type of the property at the specified path must be [string](https://developer.apple.com/documentation/imageio/cgimagemetadatatype/string) or [alternateText](https://developer.apple.com/documentation/imageio/cgimagemetadatatype/alternateText). If the property contains alternate text, this function returns the element with the x-default language qualifier.
     
     - Parameters:
        - path: A string that represents the path to the tag. A path consists of the tag’s name, plus optional prefix and parent information. Separate prefix information from other path information using a colon (:) character. Separate parent and child tags using the period (.) character. For example, the string `“exif:Flash.RedEyeMode”` represents the path to the RedEyeMode field of the Flash parent structure in the EXIF metadata.
        - parent: The parent tag to search from, or `nil` to search from the metadata root.
     - Returns: The string value at the path, or `nil` if  the tag wasn’t found or doesn’t contain a string value.
     */
    public func stringValue(withPath path: String, parent: CGImageMetadataTag? = nil) -> CFString? {
        CGImageMetadataCopyStringValueWithPath(self, parent, path as CFString)
    }
    /// A type representing an image property dictionary.
    public struct ImagePropertyDirectory: ExpressibleByStringInterpolation {
        
        /// The IPTC metadata dictionary.
        public static let iptc = Self(kCGImagePropertyIPTCDictionary)
        /// The Exif metadata dictionary.
        public static let exif = Self(kCGImagePropertyExifDictionary)
        /// The GPS metadata dictionary.
        public static let gps = Self(kCGImagePropertyGPSDictionary)
        /// The CIFF metadata dictionary.
        public static let ciff = Self(kCGImagePropertyCIFFDictionary)
        /// The Canon maker metadata dictionary.
        public static let canon = Self(kCGImagePropertyMakerCanonDictionary)
        /// The Nikon maker metadata dictionary.
        public static let nikon = Self(kCGImagePropertyMakerNikonDictionary)
        /// The Apple maker metadata dictionary.
        public static let apple = Self(kCGImagePropertyMakerAppleDictionary)
        /// The Minolta maker metadata dictionary.
        public static let minolta = Self(kCGImagePropertyMakerMinoltaDictionary)
        /// The Fuji maker metadata dictionary.
        public static let fuji = Self(kCGImagePropertyMakerFujiDictionary)
        /// The Olympus maker metadata dictionary.
        public static let olympus = Self(kCGImagePropertyMakerOlympusDictionary)
        /// The Pentax maker metadata dictionary.
        public static let pentax = Self(kCGImagePropertyMakerPentaxDictionary)
        /// The DNG metadata dictionary.
        public static let dng = Self(kCGImagePropertyDNGDictionary)
        /// The 8BIM metadata dictionary.
        public static let BIM8 = Self(kCGImageProperty8BIMDictionary)
        /// The TIFF metadata dictionary.
        public static let tiff = Self(kCGImagePropertyTIFFDictionary)
        /// The GIF metadata dictionary.
        public static let gif = Self(kCGImagePropertyGIFDictionary)
        /// The PNG metadata dictionary.
        public static let png = Self(kCGImagePropertyPNGDictionary)
        /// The WebP metadata dictionary.
        public static let webp = Self(kCGImagePropertyWebPDictionary)
        /// The HEICS metadata dictionary.
        public static let heic = Self(kCGImagePropertyHEICSDictionary)
        /// The JFIF (JPEG) metadata dictionary.
        public static let jpeg = Self(kCGImagePropertyJFIFDictionary)
        /// The TGA metadata dictionary.
        public static let tga = Self(kCGImagePropertyTGADictionary)
        
        public let rawValue: CFString
        
        public init(_ rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue as CFString
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value as CFString
        }
    }
}

extension CFType where Self == CGImageMetadata {
    /**
     Creates a collection of metadata tags from the specified XMP data.
     
     - Parameter xmpData: An object containin XMP data. The contents of this object must represent a complete XMP tree. The XMP data may include packet headers.
     */
    public init?(xmpData: Data) {
        guard let tag = CGImageMetadataCreateFromXMPData(xmpData as CFData) else { return nil }
        self = tag
    }
}

#endif
