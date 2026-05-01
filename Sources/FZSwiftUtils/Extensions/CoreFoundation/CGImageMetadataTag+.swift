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
    public struct Namespace: CFStringKey, CustomStringConvertible {
        
        /// The Exif metadata namespace.
        public static let exif = kCGImageMetadataNamespaceExif as CGImageMetadataTag.Namespace
        /// The Exif Auxiliary metadata namespace.
        public static let exifAux = kCGImageMetadataNamespaceExifAux as CGImageMetadataTag.Namespace
        /// The ExifEX metadata namespace.
        public static let exifEX = kCGImageMetadataNamespaceExifEX as CGImageMetadataTag.Namespace
        /// The Dublin Core metadata namespace.
        public static let dublinCore = kCGImageMetadataNamespaceDublinCore as CGImageMetadataTag.Namespace
        /// The IPTC Core metadata namespace.
        public static let iptcCore = kCGImageMetadataNamespaceIPTCCore as CGImageMetadataTag.Namespace
        /// The IPTC Extension metadata namespace.
        public static let iptcExtension = kCGImageMetadataNamespaceIPTCExtension as CGImageMetadataTag.Namespace
        /// The Photoshop metadata namespace.
        public static let photoshop = kCGImageMetadataNamespacePhotoshop as CGImageMetadataTag.Namespace
        /// The TIFF metadata namespace.
        public static let tiff = kCGImageMetadataNamespaceTIFF as CGImageMetadataTag.Namespace
        /// The XMP Basic metadata namespace.
        public static let xmpBasic = kCGImageMetadataNamespaceXMPBasic as CGImageMetadataTag.Namespace
        /// The XMP Rights metadata namespace.
        public static let xmpRights = kCGImageMetadataNamespaceXMPRights as CGImageMetadataTag.Namespace
        
        public let rawValue: CFString
        
        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: CFString) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            rawValue as String
        }
    }

    /// A type representing a metadata prefix used to qualify image metadata tags.
    public struct Prefix: CFStringKey, CustomStringConvertible {
        
        /// The Exif metadata prefix.
        public static let exif = kCGImageMetadataPrefixExif as CGImageMetadataTag.Prefix
        /// The Exif Auxiliary metadata prefix.
        public static let exifAux = kCGImageMetadataPrefixExifAux as CGImageMetadataTag.Prefix
        /// The ExifEX metadata prefix.
        public static let exifEX = kCGImageMetadataPrefixExifEX as CGImageMetadataTag.Prefix
        /// The Dublin Core metadata prefix.
        public static let dublinCore = kCGImageMetadataPrefixDublinCore as CGImageMetadataTag.Prefix
        /// The IPTC Core metadata prefix.
        public static let iptcCore = kCGImageMetadataPrefixIPTCCore as CGImageMetadataTag.Prefix
        /// The IPTC Extension metadata prefix.
        public static let iptcExtension = kCGImageMetadataPrefixIPTCExtension as CGImageMetadataTag.Prefix
        /// The Photoshop metadata prefix.
        public static let photoshop = kCGImageMetadataPrefixPhotoshop as CGImageMetadataTag.Prefix
        /// The TIFF metadata prefix.
        public static let tiff = kCGImageMetadataPrefixTIFF as CGImageMetadataTag.Prefix
        /// The XMP Basic metadata prefix.
        public static let xmpBasic = kCGImageMetadataPrefixXMPBasic as CGImageMetadataTag.Prefix
        /// The XMP Rights metadata prefix.
        public static let xmpRights = kCGImageMetadataPrefixXMPRights as CGImageMetadataTag.Prefix
        
        public let rawValue: CFString
        
        public init(rawValue: CFString) {
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
