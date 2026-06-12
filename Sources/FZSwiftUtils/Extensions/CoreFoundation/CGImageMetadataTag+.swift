//
//  CGImageMetadataTag+.swift
//  
//
//  Created by Florian Zand on 01.05.26.
//

#if canImport(ImageIO)
import Foundation
import ImageIO

extension CGImageMetadataTag {
    /// The name of the tag.
    public var name: String? {
        CGImageMetadataTagCopyName(self) as? String
    }
    
    /// The prefix of the tag.
    public var prefix: Prefix? {
        guard let rawValue = CGImageMetadataTagCopyPrefix(self) else { return nil }
        return Prefix(rawValue)
    }
    
    /// The namespace of the tag.
    public var namespace: Namespace? {
        guard let rawValue = CGImageMetadataTagCopyNamespace(self) else { return nil }
        return Namespace(rawValue)
    }
    
    /// A shallow copy of the tag’s value.
    public var value: CFTypeRef? {
        CGImageMetadataTagCopyValue(self)
    }
    
    /// Returns the type of the metadata tag’s value.
    public var type: CGImageMetadataType {
        CGImageMetadataTagGetType(self)
    }
    
    /**
     Returns the metadata tags that act as qualifiers for the current tag.
     
     XMP allows a metadata tag to contain supplemental tags that act as qualifiers on the content. For example, the xml:lang qualifier provides alternate text entries for the current tag.
     */
    public var qualifiers: [CGImageMetadataTag] {
        CGImageMetadataTagCopyQualifiers(self) as? [CGImageMetadataTag]  ?? []
    }

    
    /// A type representing a metadata namespace used to qualify image metadata tags.
    public struct Namespace: CFStringKey, CustomStringConvertible, ExpressibleByStringLiteral {
        
        /// The Exif metadata namespace.
        public static let exif = Self(kCGImageMetadataNamespaceExif)
        /// The Exif Auxiliary metadata namespace.
        public static let exifAux = Self(kCGImageMetadataNamespaceExifAux)
        /// The ExifEX metadata namespace.
        public static let exifEX = Self(kCGImageMetadataNamespaceExifEX)
        /// The Dublin Core metadata namespace.
        public static let dublinCore = Self(kCGImageMetadataNamespaceDublinCore)
        /// The IPTC Core metadata namespace.
        public static let iptcCore = Self(kCGImageMetadataNamespaceIPTCCore)
        /// The IPTC Extension metadata namespace.
        public static let iptcExtension = Self(kCGImageMetadataNamespaceIPTCExtension)
        /// The Photoshop metadata namespace.
        public static let photoshop = Self(kCGImageMetadataNamespacePhotoshop)
        /// The TIFF metadata namespace.
        public static let tiff = Self(kCGImageMetadataNamespaceTIFF)
        /// The XMP Basic metadata namespace.
        public static let xmpBasic = Self(kCGImageMetadataNamespaceXMPBasic)
        /// The XMP Rights metadata namespace.
        public static let xmpRights = Self(kCGImageMetadataNamespaceXMPRights)
        
        public let rawValue: CFString
        
        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value as CFString
        }
        
        public init(_ rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            rawValue as String
        }
    }

    /// A type representing a metadata prefix used to qualify image metadata tags.
    public struct Prefix: CFStringKey, CustomStringConvertible, ExpressibleByStringLiteral {
        
        /// The Exif metadata prefix.
        public static let exif = Self(kCGImageMetadataPrefixExif)
        /// The Exif Auxiliary metadata prefix.
        public static let exifAux = Self(kCGImageMetadataPrefixExifAux)
        /// The ExifEX metadata prefix.
        public static let exifEX = Self(kCGImageMetadataPrefixExifEX)
        /// The Dublin Core metadata prefix.
        public static let dublinCore = Self(kCGImageMetadataPrefixDublinCore)
        /// The IPTC Core metadata prefix.
        public static let iptcCore = Self(kCGImageMetadataPrefixIPTCCore)
        /// The IPTC Extension metadata prefix.
        public static let iptcExtension = Self(kCGImageMetadataPrefixIPTCExtension)
        /// The Photoshop metadata prefix.
        public static let photoshop = Self(kCGImageMetadataPrefixPhotoshop)
        /// The TIFF metadata prefix.
        public static let tiff = Self(kCGImageMetadataPrefixTIFF)
        /// The XMP Basic metadata prefix.
        public static let xmpBasic = Self(kCGImageMetadataPrefixXMPBasic)
        /// The XMP Rights metadata prefix.
        public static let xmpRights = Self(kCGImageMetadataPrefixXMPRights)
        
        public let rawValue: CFString
        
        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value as CFString
        }
        
        public init(_ rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            rawValue as String
        }
    }
}

extension CFType where Self == CGImageMetadataTag {
    /**
     Creates a new image metadata tag, and fills it with the specified information.
     
     The newly created tag stores only a shallow copy of the original value. As a result, modifying the original value doesn’t affect the value in the new metadata tag.
     
     - Parameters:
        - namespace: The namespace for the tag. Specify a common XMP namespace, such as `exif`, or a string with a custom namespace URI. A custom namespace must be a valid XML namespace. By convention, namespaces end with either the `/` or `#` character.
        - prefix: An abbreviation for the XML namespace.
        - name: The name of the metadata tag. This string must correspond to a valid XMP name.
        - type: The type of data in the value parameter.
        - value: The value of the tag. The value’s type must match the information in the type parameter. Supported types for this parameter are `CFString`, `CFNumber`, `CFBoolean`, `CFArray`, and `CFDictionary`. The keys of a dictionary must be `CFString` types with XMP names. The values of a dictionary must be either `CFString` or `CGImageMetadataTag` types.
     */
    public init?(namespace: CGImageMetadataTag.Namespace, _ prefix: CGImageMetadataTag.Prefix? = nil, name: CFString, type: CGImageMetadataType, value: CFTypeRef) {
        guard let tag = CGImageMetadataTagCreate(namespace.rawValue, prefix?.rawValue, name, type, value) else { return nil }
        self = tag
    }
}

#endif
