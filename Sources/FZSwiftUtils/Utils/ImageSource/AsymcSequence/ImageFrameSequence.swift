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

    enum ImageType {
        case image
        case thumbnail
    }

    let source: ImageSource?
    let thumbnailOptions: ImageSource.ThumbnailOptions?
    let imageOptions: ImageSource.ImageOptions?
    let type: ImageType
    public let count: Int
    #if os(macOS)
    let representation: NSBitmapImageRep?
    #endif

    init(source: ImageSource, type: ImageType, imageOptions: ImageSource.ImageOptions? = nil, thumbnailOptions: ImageSource.ThumbnailOptions? = nil) {
        self.source = source
        self.imageOptions = imageOptions
        self.thumbnailOptions = thumbnailOptions
        self.type = type
        self.count = source.count
        #if os(macOS)
            representation = nil
        #endif
    }

    #if os(macOS)
        init(_ representation: NSBitmapImageRep) {
            self.representation = representation
            type = .image
            imageOptions = nil
            thumbnailOptions = nil
            count = representation.frameCount
            source = nil
        }
    #endif

    public func makeAsyncIterator() -> Iterator {
        Iterator(self)
    }
    
    public struct Iterator: AsyncIteratorProtocol {
        var index = -1
        let sequence: ImageFrameSequence

        init(_ sequence: ImageFrameSequence) {
            self.sequence = sequence
        }

        public mutating func next() async -> CGImageFrame? {
            index += 1
            guard index < sequence.count else { return nil }
            if let source = sequence.source {
                switch sequence.type {
                case .image:
                    guard let image = await source.image(at: index, options: sequence.imageOptions) else { return nil }
                    return CGImageFrame(image, source.properties(at: index)?.delayTime)
                case .thumbnail:
                    guard let image = await source.thumbnail(at: index, options: sequence.thumbnailOptions) else { return nil }
                    return CGImageFrame(image, source.properties(at: index)?.delayTime)
                }
            }
            #if os(macOS)
            if let representation = sequence.representation {
                representation.currentFrame = index
                guard let image = representation.cgImage else { return nil }
                return CGImageFrame(image, representation.currentFrameDuration)
            }
            #endif
            return nil
        }
    }
}

#if os(macOS)
    extension NSBitmapImageRep {
        /// The frames of an animated (e.g. GIF) image.
        public var frames: ImageFrameSequence {
            ImageFrameSequence(self)
        }
        
        public func getFrames() -> [CGImageFrame] {
            (try? frames.collect()) ?? []
        }
        
        /// The number of frames in an animated GIF image, or `1` if the image isn't a GIF.
        var frameCount: Int {
            (value(forProperty: .frameCount) as? Int) ?? 1
        }

        /// The the current frame for an animated GIF image, or `0` if the image isn't a GIF.
        var currentFrame: Int {
            get { (value(forProperty: .currentFrame) as? Int) ?? 0 }
            set { setProperty(.currentFrame, withValue: newValue) }
        }

        /// The duration (in seconds) of the current frame for an animated GIF image, or `0` if the image isn't a GIF.
        var currentFrameDuration: TimeInterval { (value(forProperty: .currentFrameDuration) as? TimeInterval) ?? 0.0 }

        /// The number of loops to make when animating a GIF image, or `0` if the image isn't a GIF.
        var loopCount: Int {
            (value(forProperty: .loopCount) as? Int) ?? 0
        }
    }
#endif
