//
//  CGImageSource+.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 27.07.26.
//

import Foundation
import ImageIO

public extension CGImageSource {
    /// The content type of the image.
    var typeIdentifier: String? {
        CGImageSourceGetType(self) as String?
    }
    
    /// The number of images (not including thumbnails) in the image source.
    var count: Int {
        CGImageSourceGetCount(self)
    }
    
    /// The current status of the image source.
    var status: CGImageSourceStatus {
        CGImageSourceGetStatus(self)
    }
    
    /// Returns the current status of an image at the specified index in the image source.
    func status(at index: Int) -> CGImageSourceStatus {
        CGImageSourceGetStatusAtIndex(self, index)
    }
    
    /// Returns the index of the primary image for an HEIF image, or `0` for any other image format.
    var primaryImageIndex: Int {
        CGImageSourceGetPrimaryImageIndex(self)
    }
    
    /// Returns the metadata of the image at the specified index.
    func metadata(at index: Int? = nil) -> CGImageMetadata? {
        CGImageSourceCopyMetadataAtIndex(self, index ?? primaryImageIndex, nil)
    }
    
    /// Returns the properties of the image source.
    func properties() -> [CFString: Any]? {
        CGImageSourceCopyProperties(self, nil) as? [CFString: Any]
    }
    
    /// Returns the properties of the image at a specified location in an image source.
    func imageProperties(at index: Int? = nil) -> [CFString: Any]? {
        CGImageSourceCopyPropertiesAtIndex(self, index ?? primaryImageIndex, nil) as? [CFString: Any]
    }
    
    /**
     Returns the image at the specified index in the image source.
     
     - Parameters:
        - index: The index of the image, or `nil` to use the primary image index.
        - options: A dictionary that specifies additional creation options.
     */
    func image(at index: Int? = nil, options: [CFString: Any]? = nil) -> CGImage? {
        try? ObjCRuntime.catchException { CGImageSourceCreateImageAtIndex(self, index ?? primaryImageIndex, options as CFDictionary?)
        }
    }
    
    /**
     Returns the thumbnail at the specified index in the image source.
     
     - Parameters:
        - index: The index of the image, or `nil` to use the primary image index.
        - options: A dictionary that specifies additional creation options.
     */
    func thumbnail(at index: Int? = nil, options: [CFString: Any]? = nil) -> CGImage? {
        try? ObjCRuntime.catchException { CGImageSourceCreateThumbnailAtIndex(self, index ?? primaryImageIndex, options as CFDictionary?)
        }
    }
    
    /**
     Updates the data in an incremental image source.

     This method updates the state of the image source and its contained images. Call this method one or more times to update the contents of an incremental data source. Each time you call the method, you must specify all of the accumulated image data, not just the new data you received.

     - Parameters:
        - data: The updated data for the image source. Each time you call this function, specify all of the accumulated image data so far.
        - isFinal: A Boolean value that indicates whether the data parameter represents the complete data set. Specify `true` if the data is complete or `false` if it isn’t.
     */
    func updateDate(_ data: Data, isFinal: Bool) {
        CGImageSourceUpdateData(self, data as CFData, isFinal)
    }
    
    /// Removes any cache for the image at the specified index.
    func removeCache(at index: Int) {
        CGImageSourceRemoveCacheAtIndex(self, index)
    }
    
    /// Removes the cache for all images of the image data source.
    func removeCache() {
        (0 ..< count).forEach { removeCache(at: $0) }
    }

    
    /// Returns an array of uniform type identifiers that are supported for image sources.
    static var supportedTypeIdentifiers: [String] {
        CGImageSourceCopyTypeIdentifiers() as? [String] ?? []
    }
    
    /**
     Restricts which image formats can be decoded in the current process.
     
     - Parameter allowableTypes:The Uniform Type Identifiers (UTIs) of allowed image formats.
     
     When this method has been called, ImageIO will only decode images whose format matches one of the entries in the allow list for the remaining lifetime of the process.
     
     If `allowableTypes` is empty, all image parsing is disabled. Unknown format identifiers are ignored. The method can only be called once per process; subsequent calls are ignored.
     */
    @available(macOS 14.2, iOS 17.2, tvOS 17.2, watchOS 10.2, visionOS 1.0, *)
    static func setAllowedTypes(_ allowableTypes: [String]) {
        CGImageSourceSetAllowableTypes(allowableTypes as CFArray)
    }
    
    /// Creates an empty image source that you can use to accumulate incremental image data.
    static func incremental() -> CGImageSource {
        CGImageSourceCreateIncremental(nil)
    }
}

public extension CFType where Self == CGImageSource {
    /**
     Creates an image source that reads from data.

     - Parameters:
        - data: The data of the image.
        - typeIdentifierHint: The uniform type identifier representing the most likely image type.
     */
    init?(data: Data, typeIdentifierHint: String? = nil) {
        guard let cgImageSource = CGImageSourceCreateWithData(data as CFData, typeIdentifierHint.map { [kCGImageSourceTypeIdentifierHint: $0 as CFString] } as CFDictionary?) else { return nil }
        self = cgImageSource
    }
    
    /**
     Creates an image source that reads from a location specified by a URL.

     - Parameters:
        - url: The URL of the image.
        - typeIdentifierHint: The uniform type identifier representing the most likely image type.
     */
    init?(url: URL, typeIdentifierHint: String? = nil) {
        guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, typeIdentifierHint.map { [kCGImageSourceTypeIdentifierHint: $0 as CFString] } as CFDictionary?) else { return nil }
        self = cgImageSource
    }
}
