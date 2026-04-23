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
    let cgImageSource: CGImageSource

    /// The content type of the image.
    public var contentType: UTType? {
        guard let typeIdentifier = CGImageSourceGetType(cgImageSource) as String? else { return nil }
        return UTType(typeIdentifier)
    }

    /// The number of images (not including thumbnails) in the image source.
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
        return try? rawValue.decode(as: ImageProperties.self, decoder: ImageProperties.decoder)
    }

    /**
     Returns the properties of an image at the specified index in the image source.
     */
    public func properties(at index: Int) -> ImageProperties? {
        let rawValue = CGImageSourceCopyPropertiesAtIndex(cgImageSource, index, nil) as? [String: Any] ?? [:]
        do {
            return try ImageProperties.dictionaryDecoder.decode(from: rawValue)
        } catch {
            Swift.print(error)
            return nil
        }
        return try? rawValue.decode(as: ImageProperties.self, decoder: ImageProperties.decoder)
    }
    
    /// Returns the metadata of the image at the specified index.
    public func metadata(at index: Int? = nil) -> CGImageMetadata? {
        CGImageSourceCopyMetadataAtIndex(cgImageSource, index ?? primaryImageIndex, nil)
    }

    /**
     Returns the image at the specified index in the image source.

     - Parameters:
        - index: The zero-based index of the image you want. If the index is invalid, this method returns `nil`.
        - options: Additional image creation options.

     - Returns: The image at the specified index, or `nil` if an error occurs.
     */
    public func image(at index: Int? = nil, options: ImageOptions = ImageOptions(caches: true, decodesImmediately: false, allowsFloat: false, subsampleFactor: nil)) -> CGImage? {
        try? ObjCRuntime.catchException { CGImageSourceCreateImageAtIndex(cgImageSource, index ?? primaryImageIndex, options.dictionary) }
    }

    /**
     Returns the image at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the image you want. If the index is invalid, this method returns `nil`.
        - options: Additional image creation options.

     - Returns: The image at the specified index, or `nil` if an error occurs.
     */
    public func image(at index: Int? = nil, options: ImageOptions = ImageOptions(caches: true, decodesImmediately: false, allowsFloat: false, subsampleFactor: nil)) async -> CGImage? {
        await withCheckedContinuation { continuation in
            image(at: index ?? primaryImageIndex, options: options) { image in
                continuation.resume(returning: image)
            }
        }
    }

    /**
     Returns the image at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the image you want. If the index is invalid, this method returns `nil`.
        - options: Additional image creation options.
        - completionHandler: A closure the method calls on completion which returns the image at the specified index, or `nil` if an error occurs.
     */
    public func image(at index: Int? = nil, options: ImageOptions = ImageOptions(caches: true, decodesImmediately: false, allowsFloat: false, subsampleFactor: nil), completionHandler: @escaping (CGImage?) -> Void) {
        DispatchQueue.background.async {
            completionHandler(self.image(at: index ?? self.primaryImageIndex, options: options))
        }
    }

    /**
     Returns the thumbnail at the specified index in the image source.

     - Parameters:
        - index: The zero-based index of the thumbnail you want. If the index is invalid, this method returns `nil`.
        - options: Additional thumbnail creation options.

     - Returns: The thumbnail at the specified index, or `nil` if an error occurs.
     */
    public func thumbnail(at index: Int? = nil, options: ThumbnailOptions = ThumbnailOptions(create: .always, maxSize: nil, caches: true, decodesImmediately: true, allowsFloat: false, transformsIfNeeded: false, subsampleFactor: nil)) -> CGImage? {
        try? ObjCRuntime.catchException { CGImageSourceCreateThumbnailAtIndex(cgImageSource, index ?? primaryImageIndex, options.dictionary) }
    }

    /**
     Returns the thumbnail at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the thumbnail you want. If the index is invalid, this method returns `nil`.
        - options: Additional thumbnail creation options.

     - Returns: The thumbnail at the specified index, or `nil` if an error occurs.
     */
    public func thumbnail(at index: Int? = nil, options: ThumbnailOptions = ThumbnailOptions(create: .always, maxSize: nil, caches: true, decodesImmediately: true, allowsFloat: false, transformsIfNeeded: false, subsampleFactor: nil)) async -> CGImage? {
        await withCheckedContinuation { continuation in
            thumbnail(at: index ?? primaryImageIndex, options: options) { image in
                continuation.resume(returning: image)
            }
        }
    }

    /**
     Returns the thumbnail at the specified index in the image source asynchronously.

     - Parameters:
        - index: The zero-based index of the thumbnail you want. If the index is invalid, this method returns `nil`.
        - options: Additional thumbnail creation options.
        - completionHandler: A closure the method calls on completion which returns the thumbnail at the specified index, or `nil` if an error occurs.
     */
    public func thumbnail(at index: Int? = nil, options: ThumbnailOptions = ThumbnailOptions(create: .always, maxSize: nil, caches: true, decodesImmediately: true, allowsFloat: false, transformsIfNeeded: false, subsampleFactor: nil), completionHandler: @escaping (CGImage?) -> Void) {
        DispatchQueue.background.async {
            completionHandler(self.thumbnail(at: index ?? self.primaryImageIndex, options: options))
        }
    }
    
    /// The images of the image source asynchronously.
    public func images(options: ImageOptions = ImageOptions(caches: true, decodesImmediately: false, allowsFloat: false, subsampleFactor: nil)) -> ImageSequence {
        ImageSequence(source: self, type: .image, imageOptions: options)
    }
    
    /// The images of the image source.
    @_disfavoredOverload
    public func images(options: ImageOptions = ImageOptions(caches: true, decodesImmediately: false, allowsFloat: false, subsampleFactor: nil)) -> [CGImage] {
        (try? images(options: options).collect()) ?? []
    }

    /// The thumbnails of the image source asynchronously.
    public func thumbnails(options: ThumbnailOptions = ThumbnailOptions(create: .always, maxSize: nil, caches: true, decodesImmediately: true, allowsFloat: false, transformsIfNeeded: false, subsampleFactor: nil)) -> ImageSequence {
        ImageSequence(source: self, type: .thumbnail, thumbnailOptions: options)
    }
    
    /// The thumbnails of the image source.
    @_disfavoredOverload
    public func thumbnails(options: ThumbnailOptions = ThumbnailOptions(create: .always, maxSize: nil, caches: true, decodesImmediately: true, allowsFloat: false, transformsIfNeeded: false, subsampleFactor: nil)) -> [CGImage] {
        (try? thumbnails(options: options).collect()) ?? []
    }

    /// The image frames of the image source asynchronously.
    public func imageFrames(options: ImageOptions = ImageOptions(caches: true, decodesImmediately: false, allowsFloat: false, subsampleFactor: nil)) -> ImageFrameSequence {
        ImageFrameSequence(source: self, type: .image, imageOptions: options)
    }
    
    /// The image frames of the image source.
    @_disfavoredOverload
    public func imageFrames(options: ImageOptions = ImageOptions(caches: true, decodesImmediately: false, allowsFloat: false, subsampleFactor: nil)) -> [CGImageFrame] {
        (try? imageFrames(options: options).collect()) ?? []
    }

    /// The thumbnail frames of the image source asynchronously.
    public func thumbnailFrames(options: ThumbnailOptions = ThumbnailOptions(create: .always, maxSize: nil, caches: true, decodesImmediately: true, allowsFloat: false, transformsIfNeeded: false, subsampleFactor: nil)) -> ImageFrameSequence {
        ImageFrameSequence(source: self, type: .thumbnail, thumbnailOptions: options)
    }
    
    /// The thumbnail frames of the image source.
    @_disfavoredOverload
    public func thumbnailFrames(options: ThumbnailOptions = ThumbnailOptions(create: .always, maxSize: nil, caches: true, decodesImmediately: true, allowsFloat: false, transformsIfNeeded: false, subsampleFactor: nil)) -> [CGImageFrame] {
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
    public func updateData(_ data: Data, isFinal: Bool) {
        CGImageSourceUpdateData(cgImageSource, data as CFData, isFinal)
    }
    
    /**
     Creates an empty image source that you can use to accumulate incremental image data.
     
     This function creates an empty image source, which you use to accumulate data downloaded in chunks from the network. To add new chunks of data to the image source, call  ``updateData(_:isFinal:)``.
     */
    public init() {
        self.cgImageSource = CGImageSourceCreateIncremental(nil)
    }

    /**
     Creates an image source that reads from a `CGImageSource`.

     - Parameters cgImageSource: The `CGImageSource` of the image.
     */
    public init(_ cgImageSource: CGImageSource) {
        self.cgImageSource = cgImageSource
    }

    /**
     Creates an image source that reads from a location specified by a URL.

     - Parameters:
        - url: The URL of the image.
        - typeIdentifierHint: The uniform type identifier representing the most likely image type.
     */
    public init?(url: URL, typeIdentifierHint: String? = nil) {
        guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, typeIdentifierHint.map({ [kCGImageSourceTypeIdentifierHint: $0 as CFString] }) as CFDictionary?) else { return nil }
        self.cgImageSource = cgImageSource
    }
    
    /**
     Creates an image source that reads from a location specified by a URL.

     - Parameters:
        - url: The URL of the image.
        - contentTypeHint: The content type representing the most likely image type.
     */
    public convenience init?(url: URL, contentTypeHint: UTType) {
        self.init(url: url, typeIdentifierHint: contentTypeHint.identifier)
    }

    /**
     Creates an image source that reads from data.

     - Parameters:
        - data: The data of the image.
        - typeIdentifierHint: The uniform type identifier representing the most likely image type.
     */
    public init?(data: Data, typeIdentifierHint: String? = nil) {
        guard let cgImageSource = CGImageSourceCreateWithData(data as CFData, typeIdentifierHint.map({ [kCGImageSourceTypeIdentifierHint: $0 as CFString] }) as CFDictionary?) else { return nil }
        self.cgImageSource = cgImageSource
    }
    
    /**
     Creates an image source that reads from data.

     - Parameters:
        - data: The data of the image.
        - contentTypeHint: The content type representing the most likely image type.
     */
    public convenience init?(data: Data, contentTypeHint: UTType) {
        self.init(data: data, typeIdentifierHint: contentTypeHint.identifier)
    }
    
    /// The content types that are supported for image sources.
    public static var supportedContentTypes: Set<UTType> {
        (CGImageSourceCopyTypeIdentifiers() as? [String] ?? []).compactMap({ UTType($0) }).asSet
    }

    /**
     The content types that image source should be able to process.
     
     The default value is ``supportedContentTypes``.
     */
    @available(macOS 14.2, iOS 17.2, tvOS 17.2, watchOS 10.2, *)
    public static var allowedContentTypes: Set<UTType> {
        get { getAssociatedValue("allowedTypeIdentifiers", object: self) ?? supportedContentTypes }
        set {
            let supported = supportedContentTypes
            let newValue = newValue.filter({ supported.contains($0) })
            guard newValue != allowedContentTypes else { return }
            setAssociatedValue(newValue, key: "allowedTypeIdentifiers", object: self)
            CGImageSourceSetAllowableTypes(newValue.map({$0.identifier}) as CFArray)
        }
    }
}

extension ImageSource: CustomStringConvertible, Equatable {
    /// A string representation of the image source.
    public var description: String {
        return "ImageSource[\(cgImageSource.hashValue)]"
    }
    
    public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
        CFEqual(lhs.cgImageSource, rhs.cgImageSource)
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
        let totalDuration = properties()?.framesInfo?.compactMap({ $0.delayTime ?? $0.unclampedDelayTime }).sum()
        return (totalDuration != 0.0) ? totalDuration : nil
    }
}

extension ImageSource {
    /// Returns a losslessly copied image as Data, applying the given options.
    func copyData(applying options: CopyOptions = CopyOptions()) throws -> Data {
        guard let typeIdentifier = contentType?.identifier else {
            throw NSError(domain: "CGImageSource", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get image type"])
        }
        let mutableData = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(mutableData as CFMutableData, typeIdentifier as CFString, count, nil) else { throw NSError(domain: "CGImageSource", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create image destination"])
        }
        var error: Unmanaged<CFError>?
        let success = withUnsafeMutablePointer(to: &error) { ptr in
            CGImageDestinationCopyImageSource(dest, cgImageSource, options.dictionary, ptr)
        }
        if !success {
            throw error!.takeRetainedValue()
        }
        return mutableData as Data
    }

    /// Writes a losslessly copied image to the specified URL, applying the given options.
    func write(to url: URL, applying options: CopyOptions = CopyOptions()) throws {
        guard let typeIdentifier = contentType?.identifier else {
            throw NSError(domain: "CGImageSource", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get image type"])
        }
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, typeIdentifier as CFString, count, nil) else {
            throw NSError(domain: "CGImageSource", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create image destination"])
        }
        var error: Unmanaged<CFError>?
        let success = withUnsafeMutablePointer(to: &error) { ptr in
            CGImageDestinationCopyImageSource(dest, cgImageSource, options.dictionary, ptr)
        }
        if !success {
            throw error!.takeRetainedValue()
        }
    }
    
    public struct CopyOptions {
        
        /// A Boolean value that indicates whether to exclude GPS metadata from EXIF data or the corresponding XMP tags.
        public var excludeGPS = false
        
        /// A Boolean value that indicates whether to exclude XMP data from the destination.
        public var excludeXMP = false
        
        /**
         The metadata tags to include with the image.
         
         When you specify this key, all EXIF, IPTC, and XMP metadata is overwritten.
         
         If you want to merge the new tags with the existing metadata, set ``mergeMetadata`` to true.
         */
        public var metadata: CGImageMetadata?
        
        /**
         A Boolean value that indicates whether to merge new metadata with the image’s existing metadata.
         
         If you set this property to `true`, the ``metadata`` is merged with the image’s existing metadata. Specifically, if a tag doesn’t exist in the image source, the destination adds it. If the tag exists in the source, the destination updates its value. To remove a tag, set the value of the appropriate key to `kCFNull`.
         */
        public var mergeMetadata = false
        
        /**
         The date and time information to associate with the image.
         
         This option is mutually exclusive with ``metadata``.
         */
        public var date: Date?
        
        /**
         The orientation of the image.
         
         This option is mutually exclusive with ``metadata``.
         */
        public var orientation: CGImagePropertyOrientation?
        
        var dictionary: CFDictionary {
            var dict = [CFString: Any]()
            if let metadata = metadata {
                dict[kCGImageDestinationMetadata] = metadata
                dict[kCGImageDestinationMergeMetadata] = mergeMetadata
            }
            dict[kCGImageDestinationOrientation] = orientation?.rawValue as CFNumber?
            dict[kCGImageMetadataShouldExcludeXMP] = excludeXMP
            dict[kCGImageMetadataShouldExcludeGPS] = excludeGPS
            dict[kCGImageDestinationDateTime] = date as CFDate?
            return dict as CFDictionary
        }
    }
}
