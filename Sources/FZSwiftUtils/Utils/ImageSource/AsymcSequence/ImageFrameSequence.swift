//
//  FrameSequence.swift
//  ATest
//
//  Created by Florian Zand on 03.06.22.
//

import Foundation
import ImageIO

public struct ImageFrameSequence: AsyncSequence {
    public typealias Element = CGImageFrame
    public typealias ThumbnailOptions = ImageSource.ThumbnailOptions
    public typealias ImageOptions = ImageSource.ImageOptions

    public enum ImageType {
        case image
        case thumbnail
    }

    public let source: ImageSource
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
    }

    public func makeAsyncIterator() -> ImageFrameIterator {
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
        public let source: ImageSource
        public let type: FrameType
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
            frameCount = source.count
            currentFrame = 0
            self.loop = loop
            self.type = type
            self.thumbnailOptions = thumbnailOptions
            self.imageOptions = imageOptions
        }

        func nextImage() async -> CGImage? {
            switch type {
            case .image:
                return await source.image(at: currentFrame, options: imageOptions)
            case .thumbnail:
                return await source.thumbnail(at: currentFrame, options: thumbnailOptions)
            }
        }

        public mutating func next() async -> CGImageFrame? {
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
    }
}
