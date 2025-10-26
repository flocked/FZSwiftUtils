//
//  ImageSource.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

public class ImageSource {
    /// The `CGImageSource`.
    public let cgImageSource: CGImageSource

    /// The type identifier of the image source.
    public var typeIdentifier: String? {
        CGImageSourceGetType(cgImageSource) as String?
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /// The content type of the image source.
    public var contentType: UTType? {
        guard let typeIdentifier = typeIdentifier else { return nil }
        return UTType(typeIdentifier)
    }

    /// The number of images of the images included in the image source.
    public var count: Int {
        CGImageSourceGetCount(cgImageSource)
    }

    /// The current status of the image source.
    public var status: CGImageSourceStatus {
        CGImageSourceGetStatus(cgImageSource)
    }

    /// Returns the current status of an image at the specified index in the image source.
    public func status(at index: Int) -> CGImageSourceStatus {
        CGImageSourceGetStatusAtIndex(cgImageSource, index)
    }

    /// Returns the index of the primary image for an HEIF image, or `0` for any other image format.
    public var primaryImageIndex: Int {
        CGImageSourceGetPrimaryImageIndex(cgImageSource)
    }

    /**
     Returns the properties of the image source.

     These properties apply to the container in general but not necessarily to any individual image contained in the image source.
     */
    public func properties() -> ImageProperties? {
        let rawValue = CGImageSourceCopyProperties(cgImageSource, nil) as? [String: Any] ?? [:]        
        return rawValue.toModel(ImageProperties.self, decoder: ImageProperties.decoder)
    }

    /**
     Returns the properties of an image at the specified index in the image source.
     */
    public func properties(at index: Int) -> ImageProperties? {
        let rawValue = CGImageSourceCopyPropertiesAtIndex(cgImageSource, index, nil) as? [String: Any] ?? [:]
        return rawValue.toModel(ImageProperties.self, decoder: ImageProperties.decoder)
    }
    
    /// Returns the metadata of the image at the specified index.
    public func metadata(at index: Int? = nil) -> CGImageMetadata? {
        CGImageSourceCopyMetadataAtIndex(cgImageSource, index ?? primaryImageIndex, nil)
    }

    /**
     Returns the image at the specified index in the image source.

     - Parameters:
        - index: The zero-based index of the image you want. If the index is invalid, this method returns `nil.
        - options: Additional image creation options

     - Returns: The image at the specified index, or `nil` if an error occurs.
     */
    public func image(at index: Int? = nil, options: ImageOptions? = .init()) -> CGImage? {
        CGImageSourceCreateImageAtIndex(cgImageSource, index ?? primaryImageIndex, options?.dic)
    }

    /**
     Returns the image at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the image you want. If the index is invalid, this method returns `nil.
        - options: Additional image creation options

     - Returns: The image at the specified index, or `nil` if an error occurs.
     */
    public func image(at index: Int? = nil, options: ImageOptions? = .init()) async -> CGImage? {
        await withCheckedContinuation { continuation in
            image(at: index ?? primaryImageIndex, options: options) { image in
                continuation.resume(returning: image)
            }
        }
    }

    /**
     Returns the image at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the image you want. If the index is invalid, this method returns `nil.
        - options: Additional image creation options
        - completionHandler: A closure the method calls on completion which returns the image at the specified index, or `nil` if an error occurs.
     */
    public func image(at index: Int? = nil, options: ImageOptions? = .init(), completionHandler: @escaping (CGImage?) -> Void) {
        DispatchQueue.background.async {
            completionHandler(self.image(at: index ?? self.primaryImageIndex, options: options))
        }
    }

    /**
     Returns the thumbnail at the specified index in the image source.

     - Parameters:
        - index: The zero-based index of the thumbnail you want. If the index is invalid, this method returns `nil`.
        - options: Additional thumbnail creation options

     - Returns: The thumbnail at the specified index, or `nil` if an error occurs.
     */
    public func thumbnail(at index: Int? = nil, options: ThumbnailOptions? = .init()) -> CGImage? {
        CGImageSourceCreateThumbnailAtIndex(cgImageSource, index ?? primaryImageIndex, options?.toDictionary().cfDictionary)
    }

    /**
     Returns the thumbnail at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the thumbnail you want. If the index is invalid, this method returns `nil`.
        - options: Additional thumbnail creation options

     - Returns: The thumbnail at the specified index, or `nil` if an error occurs.
     */
    public func thumbnail(at index: Int? = nil, options: ThumbnailOptions? = .init()) async -> CGImage? {
        await withCheckedContinuation { continuation in
            thumbnail(at: index ?? primaryImageIndex, options: options) { image in
                continuation.resume(returning: image)
            }
        }
    }

    /**
     Returns the thumbnail at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the thumbnail you want. If the index is invalid, this method returns `nil.
        - options: Additional thumbnail creation options
        - completionHandler: A closure the method calls on completion which returns the thumbnail at the specified index, or `nil` if an error occurs.
     */
    public func thumbnail(at index: Int? = nil, options: ThumbnailOptions? = .init(), completionHandler: @escaping (CGImage?) -> Void) {
        DispatchQueue.background.async {
            completionHandler(self.thumbnail(at: index ?? self.primaryImageIndex, options: options))
        }
    }
    
    /// The images of the image source asynchronously.
    public func images(options: ImageOptions? = .init()) -> ImageSequence {
        ImageSequence(source: self, type: .image, imageOptions: options)
    }
    
    /// The images of the image source.
    @_disfavoredOverload
    public func images(options: ImageOptions? = .init()) -> [CGImage] {
        (try? images(options: options).collect()) ?? []
    }

    /// The thumbnails of the image source asynchronously.
    public func thumbnails(options: ThumbnailOptions? = .init()) -> ImageSequence {
        ImageSequence(source: self, type: .thumbnail, thumbnailOptions: options)
    }
    
    /// The thumbnails of the image source.
    @_disfavoredOverload
    public func thumbnails(options: ThumbnailOptions? = .init()) -> [CGImage] {
        (try? thumbnails(options: options).collect()) ?? []
    }

    /// The image frames of the image source asynchronously.
    public func imageFrames(options: ImageOptions? = .init()) -> ImageFrameSequence {
        ImageFrameSequence(source: self, type: .image, imageOptions: options)
    }
    
    /// The image frames of the image source.
    @_disfavoredOverload
    public func imageFrames(options: ImageOptions? = .init()) -> [CGImageFrame] {
        (try? imageFrames(options: options).collect()) ?? []
    }

    /// The thumbnail frames of the image source asynchronously.
    public func thumbnailFrames(options: ThumbnailOptions? = .init()) -> ImageFrameSequence {
        ImageFrameSequence(source: self, type: .thumbnail, thumbnailOptions: options)
    }
    
    /// The thumbnail frames of the image source.
    @_disfavoredOverload
    public func thumbnailFrames(options: ThumbnailOptions? = .init()) -> [CGImageFrame] {
        (try? thumbnailFrames(options: options).collect()) ?? []
    }
    
    /// Removes the cache for all images of the image data source.
    public func removeCache() {
        (0..<count).forEach({ removeCache(at: $0) })
    }
    
    /// Removes any cache for the image at the specified index.
    public func removeCache(at index: Int) {
        CGImageSourceRemoveCacheAtIndex(cgImageSource, index)
    }
    
    /**
     Updates the data in an incremental image source.
     
     This method updates the state of the image source and its contained images. Call this method one or more times to update the contents of an incremental data source. Each time you call the method, you must specify all of the accumulated image data, not just the new data you received.
     
     - Parameters:
        - data: The updated data for the image source. Each time you call this function, specify all of the accumulated image data so far.
        - isFinal: A Boolean value that indicates whether the data parameter represents the complete data set. Specify `true` if the data is complete or `false` if it isn’t.
     */
    public func updateDate(_ data: Data, isFinal: Bool) {
        CGImageSourceUpdateData(cgImageSource, data as CFData, isFinal)
    }

    /**
     Creates an image source that reads from a CGImageSource.

     - Parameters:
        - cgImageSource: The CGImageSource of the image.
     */
    public init(_ cgImageSource: CGImageSource) {
        self.cgImageSource = cgImageSource
    }

    /**
     Creates an image source that reads from a location specified by a URL.

     - Parameters:
        - url: The URL of the image.
     */
    public init?(url: URL) {
        guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        self.cgImageSource = cgImageSource
    }

    /**
     Creates an image source that reads from a location specified by a file path.

     - Parameters:
        - path: The file path of the image.
     */
    public convenience init?(path: String) {
        self.init(url: URL(fileURLWithPath: path))
    }

    /**
     Creates an image source that reads from data.

     - Parameters:
        - data: The data of the image.
     */
    public init?(data: Data) {
        guard let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        self.cgImageSource = cgImageSource
    }
    
    /**
     Creates an empty image source that you can use to accumulate incremental image data.
     
     This function creates an empty image source, which you use to accumulate data downloaded in chunks from the network. To add new chunks of data to the image source, call  ``updateDate(_:isFinal:)``.
     */
    public init() {
        self.cgImageSource = CGImageSourceCreateIncremental(nil)
    }
    
    /// The uniform type identifiers that are supported for image sources.
    public static func supportedTypeIdentifiers() -> Set<String> {
        (CGImageSourceCopyTypeIdentifiers() as? [String] ?? []).asSet
    }
    
    /// The content types that are supported for image sources.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public static func supportedContentTypes() -> Set<UTType> {
        supportedTypeIdentifiers().compactMap({ UTType($0) }).asSet
    }
    
    /// The content types that image source should be able to process.
    @available(macOS 14.2, iOS 17.2, tvOS 17.2, watchOS 10.2, *)
    public static var allowedTypeIdentifiers: Set<String>{
        get { getAssociatedValue("allowedTypeIdentifiers", object: self) ?? supportedTypeIdentifiers() }
        set {
            let supported = supportedTypeIdentifiers()
            let newValue = newValue.filter({ supported.contains($0) })
            guard newValue != allowedTypeIdentifiers else { return }
            setAssociatedValue(newValue, key: "allowedTypeIdentifiers", object: self)
            CGImageSourceSetAllowableTypes(Array(newValue) as CFArray)
        }
    }
    
    @available(macOS 14.2, iOS 17.2, tvOS 17.2, watchOS 10.2, *)
    public static var allowedContentTypes: Set<UTType> {
        get { allowedTypeIdentifiers.compactMap({ UTType($0) }).asSet }
        set { allowedTypeIdentifiers = newValue.map({ $0.identifier }).asSet }
    }
}

extension ImageSource: CustomStringConvertible {
    /// A string representation of the image source.
    public var description: String {
        "ImageSource[\(ObjectIdentifier(self))"
    }
}

extension ImageSource: Equatable {
    public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
        lhs.cgImageSource == rhs.cgImageSource
    }
}

public extension ImageSource {
    /// Returns if the image source is animated (e.g. GIF)
    var isAnimated: Bool {
        count > 1 && properties(at: 0)?.delayTime != nil
    }

    /// Returns if the image source is animatable (contains several images)
    var isAnimatable: Bool {
        count > 1
    }

    /// The pixel size of the image source.
    var pixelSize: CGSize? {
        properties(at: 0)?.pixelSize
    }

    private static let defaultFrameRate: Double = 15.0

    /// The default image frame duration for animating in seconds.
    static let defaultFrameDuration: Double = 1 / defaultFrameRate

    /**
     The total animation duration of an image source that is animated.,

     Returns `nil` if the image isn't animated.
     */
    var animationDuration: Double? {
        guard count > 1 else { return nil }
        let totalDuration = (0 ..< count).reduce(0) { $0 + (self.properties(at: $1)?.delayTime ?? 0.0) }
        return (totalDuration != 0.0) ? totalDuration : nil
    }
}

#if os(macOS)
    import AppKit
    public extension ImageSource {
        /**
         Creates an image source that reads from a `NSImage`.
         
         - Note: Loading an animated image takes time as each image frame is loaded initially. It's recommended to either use the url to the image if available, or parse the animation properties and frames via the image's `NSBitmapImageRep` representation.

         - Parameters:
            - image: The `NSImage` object.
         */
        convenience init?(image: NSImage) {
            let images = image.representations.compactMap({$0 as? NSBitmapImageRep}).flatMap({$0.getImages()})
            guard !images.isEmpty else { return nil }
            let types = Set(images.compactMap { $0.utType })
            let outputType = types.count == 1 ? (types.first ?? kUTTypeTIFF) : kUTTypeTIFF
            guard let mutableData = CFDataCreateMutable(nil, 0), let destination = CGImageDestinationCreateWithData(mutableData, outputType, images.count, nil) else { return nil }
            images.forEach { CGImageDestinationAddImage(destination, $0, nil) }
            guard CGImageDestinationFinalize(destination) else { return nil }
            guard let cgImageSource = CGImageSourceCreateWithData(mutableData, nil) else { return nil }
            self.init(cgImageSource)
        }
    }

#endif

#if canImport(UIKit)
    import UIKit
    public extension ImageSource {
        /**
         Creates an image source that reads from a `UIImage`.

         - Parameters:
            - image: The `UIImage` object.
         */
        convenience init?(image: UIImage) {
            guard let data = image.pngData() else { return nil }
            self.init(data: data)
        }
    }
#endif

public extension ImageSource {
    // The set of status values for images and image sources.
    enum Status: Int, CustomStringConvertible {
        /// The end of the file occurred unexpectedly.
        case unexpectedEOF = -5
        /// The data is not valid.
        case invalidData = -4
        /// The image is an unknown type.
        case unknownType = -3
        ///  The image source is reading the header.
        case readingHeader = -2
        /// The operation is not complete
        case incomplete = -1
        /// The operation is complete.
        case complete = 0
        
        init(_ status: CGImageSourceStatus) {
            self = .init(rawValue: Int(status.rawValue)) ?? .unknownType
        }

        public var description: String {
            switch self {
            case .unexpectedEOF: return "Unexpected EOF"
            case .invalidData: return "Invalid Data"
            case .unknownType: return "Unknown Type"
            case .readingHeader: return "Reading Header"
            case .incomplete: return "Incomplete"
            case .complete: return "Complete"
            }
        }
    }
}
