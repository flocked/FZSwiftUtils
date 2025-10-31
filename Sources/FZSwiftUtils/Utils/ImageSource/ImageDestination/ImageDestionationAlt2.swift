//
//  ImageExporter.swift
//
//
//  Created by Florian Zand on 25.10.25.
//

import ImageIO
import Foundation
import UniformTypeIdentifiers

/// Exports images as file or data.
class ImageExporter {
    
    private var images: [ExportImage] = []
    
    enum ExportImage {
        case image(_ image: CGImage, metadata: CGImageMetadata?, properties: [CFString: Any]?)
        case sourceImage(_ imageSource: CGImageSource, index: Int, properties: [CFString: Any]? = nil)
    }
    
    /// The supported image type identifiers.
    public static var supportedTypeIdentifiers: Set<String> {
        Set(CGImageDestinationCopyTypeIdentifiers() as! [String])
    }
    
    /// The supported image content types.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public static var supportedContentTypes: Set<UTType> {
        Set(supportedTypeIdentifiers.compactMap({ UTType($0) }))
    }
    
    /// Creates a image exporter with the specified type identifier.
    public init?(type typeIdentifier: String = "public.image.png") {
        self.imageTypeIdentifier = typeIdentifier
    }
    
    /// Creates a image exporter with the specified content type.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public init?(type: UTType) {
        self.imageContentType = type
    }
    
    /**
     A Boolean value indicating whether the image has been created..
     
     Once the image is created you can't create it again.
     */
    public private(set) var didCreateImage = false
    
    /**
     Adds the specified image to the image, optionally including metadata and additional properties.

     - Parameters:
       - image: The image to add.
       - metadata: Optional metadata to embed in the image.
       - properties: Optional dictionary of image destination properties (e.g., compression quality, orientation).
     */
    public func addImage(_ image: CGImage, metadata: CGImageMetadata? = nil, properties: [CFString: Any]? = nil) {
        guard !didCreateImage else { return }
        images.append(.image(image, metadata: metadata, properties: properties))
    }
    
    /**
     Adds the specified images to the image, optionally including metadata and additional properties.

     - Parameters:
       - image: The image to add.
       - metadata: Optional metadata to embed in the image.
       - properties: Optional dictionary of image destination properties (e.g., compression quality, orientation).
     */
    public func addImages(_ images: [CGImage], metadata: CGImageMetadata? = nil, properties: [CFString: Any]? = nil) {
        images.forEach({ addImage($0, metadata: metadata, properties: properties) })
    }

    /**
     Adds all images from the specified image source to the image, optionally applying the same specified properties to each image.

     - Parameters:
       - imageSource: The `CGImageSource` containing the images to copy.
       - properties: Optional dictionary of image destination properties to apply to each image.
     */
    public func addImages(from imageSource: CGImageSource, properties: [CFString: Any]? = nil) {
        guard !didCreateImage else { return }
        let imageCount = CGImageSourceGetCount(imageSource)
        (0..<imageCount).forEach({ addImage(from: imageSource, at: $0, properties: properties) })
    }

    /**
     Adds an image from the specified image source at the given index to the image destination.

     - Parameters:
       - imageSource: The image source containing the image.
       - index: The index of the image in the source to add.
       - properties: Optional dictionary of image destination properties to apply to this image.
     */
    public func addImage(from imageSource: CGImageSource, at index: Int, properties: [CFString: Any]? = nil) {
        guard !didCreateImage else { return }
        images.append(.sourceImage(imageSource, index: index, properties: properties))
    }
    
    /**
     The image type identifier of the image destination.
     
     - Note: You can only change the property to a supported image type identifier, else it gets reseted to it's previous value. Check ``supportedTypeIdentifiers`` for all supported identifiers.
     */
    public var imageTypeIdentifier: String = "public.image.png" {
        didSet {
            if !Self.supportedTypeIdentifiers.contains(imageTypeIdentifier) {
                imageTypeIdentifier = oldValue
            }
        }
    }
    
    /**
     The image content type of the image destination.
     
     - Note: You can only change the property to a supported image content type, else it gets reseted to it's previous value. Check ``supportedContentTypes`` for all supported content types.
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var imageContentType: UTType {
        get { UTType(imageTypeIdentifier)! }
        set { imageTypeIdentifier = newValue.identifier }
    }
        
    ///  The image properties of all images in the image.
    public var imageProperties: [CFString: Any] = [:]
    
    /// The auxiliary data, such as mattes and depth information, that accompany the image.
    public var auxiliaryData: [CFString: Any] = [:]
    
    /// The compression quality for lossy formats, where 1.0 represents maximum quality.
    public var lossyCompressionQuality: CGFloat = 1.0 {
        didSet { lossyCompressionQuality.clamp(to: 0.0...1.0) }
    }

    /// The background color of the image.
    public var backgroundColor: CGColor?

    /// The date and time to embed in the image metadata.
    public var dateTime: Date?

    /// A Boolean value that indicates whether to embed a thumbnail image.
    public var embedThumbnail: Bool = false

    /// The maximum pixel dimension for resizing the output image.
    public var imageMaxPixelSize: Int? {
        didSet { imageMaxPixelSize?.clamp(min: 1) }
    }

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
     Creates image data with all added images and configured properties.
     
     If it successfully created the image data, all added images get removed.
     
     - Returns:The image data, or `nil` if creating the image failed.
     */
    public func createImageData() -> Data? {
        guard !didCreateImage else { return nil }
        let totalImages = images.count
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, imageTypeIdentifier as CFString, totalImages, nil) else { return nil }
        setupImageDestination(destination)
        guard finalizeImageDestination(destination) else { return nil }
        return Data(data)
    }
    
    /**
     Creates an image file with all applied images and configured properties.
     
     If it successfully created the image file, all added images get removed.
     
     - Parameter url: The destination URL of the image file.
     - Returns: `true` if the image file was created successfully, or `false` if an error occurred.
     */
    public func createImageFile(at url: URL) -> Bool {
        guard !didCreateImage else { return false }
        let totalImages = images.count
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, imageTypeIdentifier as CFString, totalImages, nil) else { return false }
        setupImageDestination(destination)
        return finalizeImageDestination(destination)
    }
    
    func setupImageDestination(_ imageDestination: CGImageDestination) {
        for pendingImage in images {
            switch pendingImage {
            case .image(let image, let metadata, let properties):
                if let metadata = metadata {
                    CGImageDestinationAddImageAndMetadata(imageDestination, image, metadata, properties as CFDictionary?)
                } else {
                    CGImageDestinationAddImage(imageDestination, image, properties as CFDictionary?)
                }
            case .sourceImage(let imageSource, let index, let properties):
                CGImageDestinationAddImageFromSource(imageDestination, imageSource, index, properties as CFDictionary?)
            }
        }
        let imageProperties = finalImageProperties
        if !imageProperties.isEmpty {
            CGImageDestinationSetProperties(imageDestination, imageProperties as CFDictionary)
        }
        /*
        if !auxiliaryData.isEmpty {
            CGImageDestinationAddAuxiliaryDataInfo(imageDestination, <#T##auxiliaryImageDataType: CFString##CFString#>, <#T##auxiliaryDataInfoDictionary: CFDictionary##CFDictionary#>)
        }
         */
    }
    
    func finalizeImageDestination(_ imageDestination: CGImageDestination) -> Bool {
        let success = CGImageDestinationFinalize(imageDestination)
        if success {
            didCreateImage = true
            images = []
        }
        return success
    }
    
    private var finalImageProperties: [CFString: Any] {
        var dict = imageProperties
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
