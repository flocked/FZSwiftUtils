//
//  ImageSource+Image.swift
//
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation

public extension ImageSource {
    /// Creates an image source for the specified image.
    convenience init?(image: CGImage) {
        guard let cgImageSource = image.cgImageSource else { return nil }
        self.init(cgImageSource)
    }
}

#if os(macOS)
import AppKit
public extension ImageSource {
    /// Creates an image source for the specified image.
    convenience init?(image: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        self.init(image: cgImage)
    }
}

public extension NSImage {
    /**
     Returns a new thumbnail image at the specified size.
     
     - Parameter size: The desired size of the thumbnail.
     - Returns: A new thumbnail image. Returns `nil` if the original image isn’t backed by a [CGImage](https://developer.apple.com/documentation/coregraphics/cgimage) or if the image data is corrupt or malformed.
     
     When displaying an image in a [NSImageView](https://developer.apple.com/documentation/AppKit/NSImageView) and the native image size is much larger than the bounds of the view, decoding the full size image creates unnecessary memory overhead. By creating a thumbnail image at a specified size with this method, you avoid the overhead of decoding the image at its full size.
     
     ```swift
     func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let musicAlbum = musicAlbums[indexPath.item]
        let item = collectionView.makeItem(withIdentifier: itemIdentifier, for: indexPath)
        item.textField?.stringValue = musicAlbum.name
        let thumbnail = musicAlbum.cover.preparingThumbnail(of: thumbnailSize)
        item.imageView?.image = thumbnail
        return item
     }
     ```
     */
    func preparingThumbnail(of size: CGSize) -> NSImage? {
        prepare(maxSize: Int(max(size.width, size.height)))
    }
    
    /**
     Creates a thumbnail image at the specified size asynchronously on a background thread.
     
     - Parameters:
        - size: The desired size of the thumbnail.
        - completionHandler: The completion handler to call when the thumbnail is ready. The handler executes on a background thread. It takes:
            - `thumbnail`:  A new thumbnail image. This parameter is nil if the original image isn’t backed by a CGImage or if the image data is corrupt or malformed.
     
     When displaying an image in a [NSImageView](https://developer.apple.com/documentation/AppKit/NSImageView) and the native image size is much larger than the bounds of the view, decoding the full size image creates unnecessary memory overhead. By creating a thumbnail image at a specified size with this method, you avoid the overhead of decoding the image at its full size.
     
     This method asynchronously creates the thumbnail image on a background thread and calls the completion handler on that thread. If your app updates the UI in the completion handler, schedule the UI update on the main thread.
     
     ```swift
     func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let musicAlbum = musicAlbums[indexPath.item]
        let item = collectionView.makeItem(withIdentifier: itemIdentifier, for: indexPath)
        item.textField?.stringValue = musicAlbum.name
        musicAlbum.cover.prepareThumbnail(of: thumbnailSize) { thumbnail in
            DispatchQueue.main.async {
                item.imageView?.image = thumbnail
            }
        }
        return item
     }
     ```
     */
    func prepareThumbnail(of size: CGSize, completionHandler: @escaping (_ thumbnail: NSImage?) -> Void) {
        DispatchQueue.background.async {
            completionHandler(self.preparingThumbnail(of: size))
        }
    }
    
    /**
     Creates a thumbnail image at the specified size asynchronously on a background thread.
     
     - Parameter size: The desired size of the thumbnail.
     - Returns: A new thumbnail image. Returns `nil` if the original image isn’t backed by a [CGImage](https://developer.apple.com/documentation/coregraphics/cgimage) or if the image data is corrupt or malformed.
     
     When displaying an image in a [NSImageView](https://developer.apple.com/documentation/AppKit/NSImageView) and the native image size is much larger than the bounds of the view, decoding the full size image creates unnecessary memory overhead. By creating a thumbnail image at a specified size with this method, you avoid the overhead of decoding the image at its full size.
     
     This method asynchronously creates the thumbnail image on a background thread. If your app updates the UI in the completion handler, schedule the UI update on the main thread.
     */
    func byPreparingThumbnail(of size: CGSize) async -> NSImage? {
        await withCheckedContinuation { continuation in
            prepareThumbnail(of: size) { continuation.resume(returning: $0) }
        }
    }
    
    /**
     Decodes an image synchronously and provides a new one for display in views and animations.
     
     - Returns: A new version of the image object for display. If the system can’t decode the image, this method returns `nil`.
     
     The Animation Hitches instrument measures system performance for multiple stages of preparing views for display. It can show you the exact cause of an animation hitch, which appears to the user as an interruption or jump in an animation that should be smooth. If Animation Hitches indicates that decoding an image takes too long and causes hitches, use this method to move the decoding work to the background. For more information on using Instruments, see Instruments Help.
     
     Avoid using this method on the main thread unless you previously started preparing an image with prepareForDisplay(completionHandler:). If you’re decoding many images, such as with a collection view, calling this method from a concurrent queue can degrade performance by demanding too many system threads. Use a serial queue instead.
     
     This method returns a new image object for efficient display by an image view. Assign the image object created by this method to the image property of the image view. If [NSImageView](https://developer.apple.com/documentation/AppKit/NSImageView) can render the image without decoding, this method returns a valid image without further processing. If the system can’t decode the image, such as an image created from a CIImage, the method returns `nil`.
          
     ```swift
     func collectionView(_ collectionView: NSCollectionView, willDisplay collectionViewItem: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        let musicAlbum = musicAlbums[indexPath.item]
        if let image = preparedImageCache.object(forKey: musicAlbum.id), collectionViewItem.identifier == musicAlbum.id {
            // Use a cached prepared image.
            collectionViewItem.imageView?.image = image
        } else {
            // If the data source didn't prefetch the music alnum cover, prepare the image on a serial dispatch queue.
            serialQueue.async { [weak preparedImageCache, placeholderImage] in
                let preparedImage = musicAlbum.cover.preparingForDisplay() ?? placeholderImage
                preparedImageCache?.setObject(preparedImage, forKey: musicAlbum.id)
                DispatchQueue.main.async {
                    if collectionViewItem.identifier == musicAlbum.id {
                        collectionViewItem.imageView?.image = preparedImage
                    }
                }
            }
        }
     }
     ```
     */
    func preparingForDisplay() -> NSImage? {
        prepare()
    }
    
    private func prepare(maxSize: Int? = nil) -> NSImage? {
        guard let imageSource = ImageSource(image: self) else { return nil }
        func image(at index: Int? = nil) -> CGImage? {
            if let maxSize = maxSize {
                return imageSource.thumbnail(at: index, options: .init(maxSize: maxSize, transformsIfNeeded: true))
            }
            return imageSource.thumbnail(at: index, options: .init(transformsIfNeeded: true))
            // return imageSource.image(at: index, options: .init(caches: true, decodesImmediately: true))
        }
        let data = NSMutableData()
        let imageCount = imageSource.count
        if imageCount > 1, let identifer = imageSource.contentType?.identifier.cfString, let destination = CGImageDestinationCreateWithData(data as CFMutableData, identifer, imageCount, nil) {
            if let properties = (CGImageSourceCopyProperties(imageSource.cgImageSource, nil) as? [CFString: Any] ?? [:]).loopProperties()?.cfDictionary {
                CGImageDestinationSetProperties(destination, properties)
            }
            for index in 0..<imageCount {
                /*
                var dicc = ImageSource.ImageOptions(caches: true, decodesImmediately: true).dictionary as! [CFString: Any]
                dicc[kCGImageDestinationImageMaxPixelSize] = maxSize
                dicc[kCGImageDestinationEmbedThumbnail] = true
                CGImageDestinationAddImageFromSource(destination, imageSource.cgImageSource, index, dicc.cfDictionary)
                 */
                if let image = image(at: index) {
                    CGImageDestinationAddImage(destination, image, CGImageSourceCopyPropertiesAtIndex(imageSource.cgImageSource, index, nil))
                }
            }
            CGImageDestinationFinalize(destination)
            return NSImage(data: data as Data)
        }
        guard let image = image() else { return nil }
        return NSImage(cgImage: image, size: .init(image.width, image.height))
    }
    
    /**
     Decodes an image asynchronously and provides a new one for display in views and animations.
     
     - Parameter completionHandler: The closure to call when the function finishes preparing the image. It takes:
        - image: A new version of the image object for display. If the system can’t decode the image, the parameter value is `nil`.
     
     The Animation Hitches instrument measures system performance for multiple stages of preparing views for display. It can show you the exact cause of an animation hitch, which appears to the user as an interruption or jump in an animation that should be smooth. If Animation Hitches indicates that decoding an image takes too long and causes hitches, use this method to move the decoding work to the background.
     
     This method creates a new image object and passes it to the completion handler. The new image is ready for efficient display by an image view. Assign the image this method creates to the image property of an image view. If [NSImageView](https://developer.apple.com/documentation/AppKit/NSImageView) can render the image without decoding, this method passes the completion handler a valid image without further processing. If the system can’t decode the image, such as an image created from a CIImage, the method passes `nil` to the completion handler.

     ```swift
     func collectionView(_ collectionView: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
         for path in indexPaths {
             let item = models[path.item]
             if preparedImageCache.object(forKey: item.id) == nil {
                 item.loadAsset()
                 item.image.prepareForDisplay { [weak preparedImageCache] preparedImage in
                     if let preparedImage = preparedImage {
                         preparedImageCache?.setObject(preparedImage, forKey: item.id)
                     }
                 }
             }
         }
     }
     ```
     */
    func preparingForDisplay(completionHandler: @escaping (_ image: NSImage?) -> Void) {
        DispatchQueue.background.async {
            completionHandler(self.preparingForDisplay())
        }
    }
    
    /**
     Decodes an image asynchronously and provides a new one for display in views and animations.
     
     - Returns: A new version of the image object for display. If the system can’t decode the image, this method returns `nil`.
     
     The Animation Hitches instrument measures system performance for multiple stages of preparing views for display. It can show you the exact cause of an animation hitch, which appears to the user as an interruption or jump in an animation that should be smooth. If Animation Hitches indicates that decoding an image takes too long and causes hitches, use this method to move the decoding work to the background.
     
     This method creates a new image object on a background thread. If your app updates the UI in the completion handler, schedule the UI update on the main thread.

     This method creates a new image object on a background thread. The new image is ready for efficient display by an image view. Assign the image this method creates to the image property of an image view. If [NSImageView](https://developer.apple.com/documentation/AppKit/NSImageView) can render the image without decoding, this method returns a valid image without further processing. If the system can’t decode the image, such as an image created from a `CIImage`, the method returns `nil`.
     */
    func byPreparingForDisplay() async -> NSImage? {
        await withCheckedContinuation { continuation in
            preparingForDisplay { continuation.resume(returning: $0) }
        }
    }
}
#elseif canImport(UIKit)
import UIKit
public extension ImageSource {
    /// Creates an image source for the specified image.
    convenience init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        self.init(image: cgImage)
    }
}
#endif

fileprivate extension CGImage {
    var cgImageSource: CGImageSource? {
        Self.imageSourceFunction?(self)?.takeUnretainedValue()
    }
    
    static let imageSourceFunction: (@convention(c) (CGImage) -> Unmanaged<CGImageSource>?)? = {
        guard let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "CGImageGetImageSource") else {
            return nil
        }
        return unsafeBitCast(symbol, to: (@convention(c) (CGImage) -> Unmanaged<CGImageSource>?).self)
    }()
}

fileprivate extension Dictionary where Key == CFString, Value == Any {
    static let loopCandidates: [(dictionaryKey: CFString, loopKey: CFString, extraKeys: [CFString])] = [
        (dictionaryKey: kCGImagePropertyGIFDictionary,
         loopKey: kCGImagePropertyGIFLoopCount,
        extraKeys: [kCGImagePropertyGIFHasGlobalColorMap]),
        (dictionaryKey: kCGImagePropertyHEICSDictionary,
         loopKey: kCGImagePropertyHEICSLoopCount,
        extraKeys: []),
        (dictionaryKey: kCGImagePropertyPNGDictionary,
         loopKey: kCGImagePropertyAPNGLoopCount,
        extraKeys: [])
    ]
    
    static let candidates: [(dictionaryKey: CFString, delayKey: CFString, unclampedKey: CFString, extraKeys: [CFString])] = [
        (dictionaryKey: kCGImagePropertyGIFDictionary,
        delayKey: kCGImagePropertyGIFDelayTime,
        unclampedKey: kCGImagePropertyGIFUnclampedDelayTime,
        extraKeys: [kCGImagePropertyGIFHasGlobalColorMap]),
        (dictionaryKey: kCGImagePropertyHEICSDictionary,
        delayKey: kCGImagePropertyHEICSDelayTime,
        unclampedKey: kCGImagePropertyHEICSUnclampedDelayTime,
        extraKeys: []),
        (dictionaryKey: kCGImagePropertyPNGDictionary,
        delayKey: kCGImagePropertyAPNGDelayTime,
        unclampedKey: kCGImagePropertyAPNGUnclampedDelayTime,
        extraKeys: [])
    ]

    func frameProperties() -> [CFString: Any]? {
        for candidate in Self.candidates {
            guard let nested = self[candidate.dictionaryKey] as? [CFString: Any] else {
                continue
            }
            var filtered: [CFString: Any] = [:]
            filtered[candidate.delayKey] = nested[candidate.delayKey]
            filtered[candidate.unclampedKey] = nested[candidate.unclampedKey]
            for key in candidate.extraKeys {
                filtered[key] = nested[key]
            }
            if !filtered.isEmpty {
                return [candidate.dictionaryKey: filtered]
            }
        }
        return nil
    }
    
    func loopProperties() -> [CFString: Any]? {
        for candidate in Self.loopCandidates {
            guard let nested = self[candidate.dictionaryKey] as? [CFString: Any] else {
                continue
            }
            var filtered: [CFString: Any] = [:]
            filtered[candidate.loopKey] = nested[candidate.loopKey]
            for key in candidate.extraKeys {
                filtered[key] = nested[key]
            }
            if !filtered.isEmpty {
                return [candidate.dictionaryKey: filtered]
            }
        }
        return nil
    }
}
