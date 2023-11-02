//
//  ImageFrameSequence.swift
//  
//
//  Created by Florian Zand on 03.06.22.
//

import Foundation
import ImageIO
#if os(macOS)
import AppKit
#endif

public struct ImageFrameSequence: AsyncSequence {
    public typealias Element = CGImageFrame
    public typealias ThumbnailOptions = ImageSource.ThumbnailOptions
    public typealias ImageOptions = ImageSource.ImageOptions

    public enum ImageType {
        case image
        case thumbnail
    }

    public let source: ImageSource?
    #if os(macOS)
    public let representation: NSBitmapImageRep?
    #endif
    public let thumbnailOptions: ThumbnailOptions?
    public let imageOptions: ImageOptions?
    public let loop: Bool
    public let type: ImageType

    public static func thumbnail(_ source: ImageSource, options: ThumbnailOptions? = nil, loop: Bool = false) -> ImageFrameSequence {
        ImageFrameSequence(source, type: .thumbnail, thumbnailOptions: options, loop: loop)
    }

    public static func image(_ source: ImageSource, options: ImageOptions? = nil, loop: Bool = false) -> ImageFrameSequence {
        ImageFrameSequence(source, type: .image, imageOptions: options, loop: loop)
    }

    public init(_ source: ImageSource, type: ImageType, imageOptions: ImageOptions? = nil, thumbnailOptions: ThumbnailOptions? = .init(), loop: Bool = false) {
        self.source = source
        self.imageOptions = imageOptions
        self.thumbnailOptions = thumbnailOptions
        self.type = type
        self.loop = loop
        #if os(macOS)
        self.representation = nil
        #endif
    }
    
    #if os(macOS)
    public init(_ representation: NSBitmapImageRep, loop: Bool = false) {
        self.representation = representation
        self.type = .image
        self.imageOptions = nil
        self.thumbnailOptions = nil
        self.source = nil
        self.loop = loop
    }
    #endif


    public func makeAsyncIterator() -> ImageFrameIterator {
        #if os(macOS)
        if let representation = representation {
            return ImageFrameIterator(representation, loop: loop)
        }
        #endif
        let source = self.source!
        switch type {
        case .image:
            return ImageFrameIterator.image(source: source, options: imageOptions, loop: loop)
        case .thumbnail:
            return ImageFrameIterator.thumbnail(source: source, options: thumbnailOptions, loop: loop)
        }
    }
}

public extension ImageFrameSequence {
    struct ImageFrameIterator: AsyncIteratorProtocol {
        public let loop: Bool
        public let frameCount: Int
        public private(set) var currentFrame: Int
        public let source: ImageSource?
        public let type: FrameType
        #if os(macOS)
        public let representation: NSBitmapImageRep?
        #endif
        public let thumbnailOptions: ThumbnailOptions?
        public let imageOptions: ImageOptions?
        public enum FrameType {
            case image
            case thumbnail
        }

        public static func thumbnail(source: ImageSource, options: ThumbnailOptions? = nil, loop _: Bool = false) -> ImageFrameIterator {
            return ImageFrameIterator(source: source, type: .thumbnail, thumbnailOptions: options, imageOptions: nil)
        }

        public static func image(source: ImageSource, options: ImageOptions? = nil, loop _: Bool = false) -> ImageFrameIterator {
            return ImageFrameIterator(source: source, type: .thumbnail, thumbnailOptions: nil, imageOptions: options)
        }

        public init(source: ImageSource, type: FrameType, thumbnailOptions: ThumbnailOptions?, imageOptions: ImageOptions?, loop: Bool = false) {
            self.source = source
            self.frameCount = source.count
            self.currentFrame = 0
            self.loop = loop
            self.type = type
            self.thumbnailOptions = thumbnailOptions
            self.imageOptions = imageOptions
            #if os(macOS)
            self.representation = nil
            #endif
        }
        
        #if os(macOS)
        public init(_ representation: NSBitmapImageRep, loop: Bool = false) {
            self.representation = representation
            self.source = nil
            self.frameCount = representation.frameCount
            self.type = .image
            self.loop = loop
            self.thumbnailOptions = nil
            self.imageOptions = nil
            self.currentFrame = 0
        }
        #endif

        func nextImage() async -> CGImage? {
            if let source = source {
                switch type {
                case .image:
                    return await source.image(at: currentFrame, options: imageOptions)
                case .thumbnail:
                    return await source.thumbnail(at: currentFrame, options: thumbnailOptions)
                }
            }
            return nil
        }

        public mutating func next() async -> CGImageFrame? {
            if let source = source {
                if currentFrame >= frameCount {
                    if loop { currentFrame = 0 }
                    else { return nil }
                }
                let duration = source.properties(at: currentFrame)?.delayTime
                let image = await nextImage()
                currentFrame = currentFrame + 1
                var imageFrame: CGImageFrame? = nil
                if let image = image {
                    imageFrame = CGImageFrame(image, duration)
                }
                return imageFrame
            }
            #if os(macOS)
            if let representation = representation {
                if currentFrame >= frameCount {
                    if loop { currentFrame = 0 } else {
                        return nil }
                }
                var imageFrame: CGImageFrame? = nil
                representation.currentFrame = self.currentFrame
                if let image = representation.cgImage {
                    let duration = representation.currentFrameDuration
                    imageFrame = CGImageFrame(image, duration)
                }
                currentFrame = currentFrame + 1
                return imageFrame
            }
            #endif
            return nil
        }
    }
}

#if os(macOS)
fileprivate extension NSBitmapImageRep {
    /// The number of frames in an animated GIF image, or `1` if the image isn't a GIF.
    var frameCount: Int {
        (self.value(forProperty: .frameCount) as? Int) ?? 1
    }
    
    /// The the current frame for an animated GIF image, or `0` if the image isn't a GIF.
    var currentFrame: Int {
        get { (self.value(forProperty: .currentFrame) as? Int) ?? 0 }
        set { self.setProperty(.currentFrame, withValue: newValue) }
    }
    
    /// The duration (in seconds) of the current frame for an animated GIF image, or `0` if the image isn't a GIF.
    var currentFrameDuration: TimeInterval {
        get { (self.value(forProperty: .currentFrameDuration) as? TimeInterval) ?? 0.0 }
    }
    
    /// The number of loops to make when animating a GIF image, or `0` if the image isn't a GIF.
    var loopCount: Int {
        (self.value(forProperty: .loopCount) as? Int) ?? 0
    }
}
#endif
