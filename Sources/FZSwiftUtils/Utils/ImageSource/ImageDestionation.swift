//
//  ImageDestination.swift
//
//
//  Created by Florian Zand on 25.10.25.
//

import ImageIO
import Foundation
import UniformTypeIdentifiers

/**
 An object that you use to write image data to a URL or data object.
 */
public class ImageDestination {
    private let imageDestination: CGImageDestination
    private var imageData: NSMutableData?
    private var isFinalized = false
    
    /**
     Creates an image destination either in memory or at a specified file URL, and optionally copies images from a `CGImageSource`.

     - Parameters:
       - type: The UTI string of the desired image format (e.g., "public.image.png").
       - url: An optional file URL to write the image data to. If `nil`, the destination will be in-memory.
       - imageSource: An optional `CGImageSource` to copy images from.
     */
    public init?(type: String, url: URL? = nil, imageSource: CGImageSource) {
        guard let (dest, data) = Self.createDestination(url: url, type: type as CFString, count: CGImageSourceGetCount(imageSource)) else { return nil }
        self.imageDestination = dest
        self.imageData = data
        addImages(from: imageSource)
    }
    
    /**
     Creates an image destination either in memory or at a specified file URL, and optionally copies images from a `CGImageSource`.

     - Parameters:
       - type: The UTType of the desired image format (e.g., `.png` or `.jpeg`).
       - url: An optional file URL to write the image data to. If `nil`, the destination will be in-memory.
       - imageSource: An optional `CGImageSource` to copy images from.
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public init?(type: UTType, url: URL? = nil, imageSource: CGImageSource) {
        guard let (dest, data) = Self.createDestination(url: url, type: type.identifier as CFString, count: CGImageSourceGetCount(imageSource)) else { return nil }
        self.imageDestination = dest
        self.imageData = data
        addImages(from: imageSource)
    }
    
    /**
     Creates an empty image destination with a specified number of image slots, either in memory or at a file URL.

     - Parameters:
       - type: The UTI string of the desired image format (e.g., "public.image.png").
       - url: An optional file URL to write the image data to. If `nil`, the destination will be in-memory.
       - count: The number of images the destination should hold.
     */
    public init?(type: String, url: URL? = nil, count: Int = 1) {
        guard let (dest, data) = Self.createDestination(url: url, type: type as CFString, count: count) else { return nil }
        self.imageDestination = dest
        self.imageData = data
    }
    
    /**
     Creates an empty image destination with a specified number of image slots, either in memory or at a file URL.

     - Parameters:
       - type: The UTType of the desired image format (e.g., `.png` or `.jpeg`).
       - url: An optional file URL to write the image data to. If `nil`, the destination will be in-memory.
       - count: The number of images the destination should hold.
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public init?(type: UTType, url: URL? = nil, count: Int = 1) {
        guard let (dest, data) = Self.createDestination(url: url, type: type.identifier as CFString, count: count) else { return nil }
        self.imageDestination = dest
        self.imageData = data
    }
    
    private static func createDestination(url: URL?, type: CFString, count: Int) -> (CGImageDestination, NSMutableData?)? {
        if let url = url {
            guard let dest = CGImageDestinationCreateWithURL(url as CFURL, type, count, nil) else { return nil }
            return (dest, nil)
        } else {
            let data = NSMutableData()
            guard let dest = CGImageDestinationCreateWithData(data as CFMutableData, type, count, nil) else { return nil }
            return (dest, data)
        }
    }
    
    /**
     Adds the specified image to the image destination, optionally including metadata and additional properties.

     - Parameters:
       - image: The image to add.
       - metadata: Optional metadata to embed in the image.
       - properties: Optional dictionary of image destination properties (e.g., compression quality, orientation).
     */
    public func addImage(_ image: CGImage, metadata: CGImageMetadata? = nil, properties: [CFString: Any]? = nil) {
        if let metadata = metadata {
            CGImageDestinationAddImageAndMetadata(imageDestination, image, metadata, properties as CFDictionary?)
        } else {
            CGImageDestinationAddImage(imageDestination, image, properties as CFDictionary?)
        }
    }

    /**
     Adds all images from the specified image source to the image destination, optionally applying the same specified properties to each image.

     - Parameters:
       - imageSource: The `CGImageSource` containing the images to copy.
       - properties: Optional dictionary of image destination properties to apply to each image.
     */
    public func addImages(from imageSource: CGImageSource, properties: [CFString: Any]? = nil) {
        let imageCount = CGImageSourceGetCount(imageSource)
        (0..<imageCount).forEach({ addImage(from: imageSource, at: $0, properties: properties) })
    }

    /**
     Adds a image from the specified image source at the given index to the image destination.

     - Parameters:
       - imageSource: The image source containing the image.
       - index: The index of the image in the source to add.
       - properties: Optional dictionary of image destination properties to apply to this image.
     */
    public func addImage(from imageSource: CGImageSource, at index: Int, properties: [CFString: Any]? = nil) {
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, index, properties as CFDictionary?)
    }

    /**
     Sets the specified properties on the entire image destination.

     - Parameter properties: Dictionary of image destination properties (e.g., compression, metadata, orientation) to apply.
     */
    public func setProperties(_ properties: [CFString: Any]) {
        CGImageDestinationSetProperties(imageDestination, properties as CFDictionary)
    }
    
    /// The compression quality for lossy formats, where 1.0 represents maximum quality.
    public var lossyCompressionQuality: CGFloat = 1.0

    /// The background color to use when writing the image destination.
    public var backgroundColor: CGColor?

    /// The date and time to embed in the image metadata.
    public var dateTime: Date?

    /// A Boolean value that indicates whether to embed a thumbnail image.
    public var embedThumbnail: Bool = false

    /// The maximum pixel dimension for resizing the output image.
    public var imageMaxPixelSize: Int?

    /// The metadata to associate with the image destination.
    public var metadata: CGImageMetadata?

    /// A Boolean value that indicates whether to merge existing metadata with new values.
    public var mergeMetadata: Bool = false

    /// A Boolean value that indicates whether to optimize image color data for sharing.
    public var optimizeColorForSharing: Bool = false

    /// The EXIF orientation value to assign to the image.
    public var orientation: CGImagePropertyOrientation?

    /// A Boolean value that indicates whether to preserve gain map data in the output.
    @available(macOS 11.0, iOS 14.1, tvOS 14.1, watchOS 7.0, *)
    public var preserveGainMap: Bool {
        get { _preserveGainMap }
        set { _preserveGainMap = newValue }
    }
    var _preserveGainMap: Bool = false

    /// A Boolean value that indicates whether to exclude GPS data from the metadata.
    public var shouldExcludeGPS: Bool = false

    /// A Boolean value that indicates whether to exclude XMP data from the metadata.
    public var shouldExcludeXMP: Bool = false
    
    /**
     Applies all configured properties to the image destination and finalizes the write operation.
     
     - Returns: `true` if the image destination successfully finalized the images, or `false` if an error occurred.
     */
    @discardableResult
    public func finalize() -> Bool {
        let properties = propertyDictionary
        if !properties.isEmpty {
            CGImageDestinationSetProperties(imageDestination, properties as CFDictionary)
        }
        let success = CGImageDestinationFinalize(imageDestination)
        if success {
            isFinalized = true
        }
        return success
    }
    
    /// The image data generated by this destination after ``finalize()`` is called, or `nil` if a file URL was used.
    public var finalizedImageData: Data? {
        guard isFinalized, let imageData = imageData else { return nil }
        return Data(imageData)
    }
    
    private var propertyDictionary: [CFString: Any] {
        var dict: [CFString: Any] = [:]
        if lossyCompressionQuality != 1.0 {
            dict[kCGImageDestinationLossyCompressionQuality] = lossyCompressionQuality
        }
        if let backgroundColor = backgroundColor {
            dict[kCGImageDestinationBackgroundColor] = backgroundColor
        }
        if let date = dateTime {
            dict[kCGImageDestinationDateTime] = Self.exifDateFormatter.string(from: date) as CFString
        }
        if embedThumbnail {
            dict[kCGImageDestinationEmbedThumbnail] = true
        }
        if let imageMaxPixelSize = imageMaxPixelSize {
            dict[kCGImageDestinationImageMaxPixelSize] = imageMaxPixelSize
        }
        if let metadata = metadata {
            dict[kCGImageDestinationMetadata] = metadata
        }
        if mergeMetadata {
            dict[kCGImageDestinationMergeMetadata] = true
        }
        if optimizeColorForSharing {
            dict[kCGImageDestinationOptimizeColorForSharing] = true
        }
        if let orientation = orientation {
            dict[kCGImageDestinationOrientation] = orientation.rawValue
        }
        if #available(macOS 11.0, iOS 14.1, tvOS 14.1, watchOS 7.0, *), preserveGainMap {
            dict[kCGImageDestinationPreserveGainMap] = true
        }
        if shouldExcludeGPS {
            dict[kCGImageMetadataShouldExcludeGPS] = true
        }
        if shouldExcludeXMP {
            dict[kCGImageMetadataShouldExcludeXMP] = true
        }
        return dict
    }
    
    private static let exifDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss" // EXIF DateTime format
        return formatter
    }()
}

extension ImageSource {
    /**
     Creates a PNG image destination with an optional file URL and a specified number of images.

     - Parameters:
       - url: An optional file URL to write the PNG data to. If `nil`, the destination will be in-memory.
       - count: The number of images the destination should hold.
     - Returns: A new `ImageDestination` configured for PNG output, or `nil` if creation fails.
     */
    public static func png(url: URL? = nil, count: Int = 1) -> ImageDestination? {
        .init(type: "public.image.png", url: url, count: count)
    }

    /**
     Creates a PNG image destination with an optional file URL, copying images from a `CGImageSource`.

     - Parameters:
       - url: An optional file URL to write the PNG data to. If `nil`, the destination will be in-memory.
       - imageSource: The `CGImageSource` to copy images from.
     - Returns: A new `ImageDestination` configured for PNG output, or `nil` if creation fails.
     */
    public static func png(url: URL? = nil, imageSource: CGImageSource) -> ImageDestination? {
        .init(type: "public.image.png", url: url, imageSource: imageSource)
    }

    /**
     Creates a JPEG image destination with an optional file URL and a specified number of images.

     - Parameters:
       - url: An optional file URL to write the JPEG data to. If `nil`, the destination will be in-memory.
       - count: The number of images the destination should hold.
     - Returns: A new `ImageDestination` configured for JPEG output, or `nil` if creation fails.
     */
    public static func jpeg(url: URL? = nil, count: Int = 1) -> ImageDestination? {
        .init(type: "public.image.jpeg", url: url, count: count)
    }

    /**
     Creates a JPEG image destination with an optional file URL, copying images from a `CGImageSource`.

     - Parameters:
       - url: An optional file URL to write the JPEG data to. If `nil`, the destination will be in-memory.
       - imageSource: The `CGImageSource` to copy images from.
     - Returns: A new `ImageDestination` configured for JPEG output, or `nil` if creation fails.
     */
    public static func jpeg(url: URL? = nil, imageSource: CGImageSource) -> ImageDestination? {
        .init(type: "public.image.jpeg", url: url, imageSource: imageSource)
    }

    /**
     Creates a TIFF image destination with an optional file URL and a specified number of images.

     - Parameters:
       - url: An optional file URL to write the TIFF data to. If `nil`, the destination will be in-memory.
       - count: The number of images the destination should hold.
     - Returns: A new `ImageDestination` configured for TIFF output, or `nil` if creation fails.
     */
    public static func tiff(url: URL? = nil, count: Int = 1) -> ImageDestination? {
        .init(type: "public.image.tiff", url: url, count: count)
    }

    /**
     Creates a TIFF image destination with an optional file URL, copying images from a `CGImageSource`.

     - Parameters:
       - url: An optional file URL to write the TIFF data to. If `nil`, the destination will be in-memory.
       - imageSource: The `CGImageSource` to copy images from.
     - Returns: A new `ImageDestination` configured for TIFF output, or `nil` if creation fails.
     */
    public static func tiff(url: URL? = nil, imageSource: CGImageSource) -> ImageDestination? {
        .init(type: "public.image.tiff", url: url, imageSource: imageSource)
    }
    
    /**
     Creates a GIF image destination with an optional file URL and a specified number of images.

     - Parameters:
       - url: An optional file URL to write the GIF data to. If `nil`, the destination will be in-memory.
       - count: The number of images the destination should hold.
     - Returns: A new `ImageDestination` configured for GIF output, or `nil` if creation fails.
     */
    public static func gif(url: URL? = nil, count: Int) -> ImageDestination? {
        .init(type: "public.image.gif", url: url, count: count)
    }

    /**
     Creates a GIF image destination with an optional file URL, copying images from a `CGImageSource`.

     - Parameters:
       - url: An optional file URL to write the GIF data to. If `nil`, the destination will be in-memory.
       - imageSource: The `CGImageSource` to copy images from.
     - Returns: A new `ImageDestination` configured for GIF output, or `nil` if creation fails.
     */
    public static func gif(url: URL? = nil, imageSource: CGImageSource) -> ImageDestination? {
        .init(type: "public.image.gif", url: url, imageSource: imageSource)
    }
}
