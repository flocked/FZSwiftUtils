//
//  ImageSequence.swift
//
//
//  Created by Florian Zand on 03.06.22.
//

import Combine
import Foundation
import ImageIO

public extension ImageSource {
    struct ImageSequence: AsyncSequence {
        public enum ImageType {
            case image
            case thumbnail
        }

        public typealias Element = CGImage
        public let source: ImageSource
        public let type: ImageType
        public let imageOptions: ImageOptions?
        public let thumbnailOptions: ThumbnailOptions?
        public let loop: Bool

        static func thumbnail(_ source: ImageSource, options: ThumbnailOptions? = nil, loop: Bool = false) -> ImageSequence {
            ImageSequence(source: source, type: .thumbnail, thumbnailOptions: options, loop: loop)
        }

        static func image(_ source: ImageSource, options: ImageOptions? = nil, loop: Bool = false) -> ImageSequence {
            ImageSequence(source: source, type: .image, imageOptions: options, loop: loop)
        }

        init(source: ImageSource, type: ImageType, imageOptions: ImageOptions? = nil, thumbnailOptions: ThumbnailOptions? = nil, loop: Bool = false) {
            self.source = source
            self.type = type
            self.imageOptions = imageOptions
            self.thumbnailOptions = thumbnailOptions
            self.loop = loop
        }

        public func makeAsyncIterator() -> ImageIterator {
            switch type {
            case .image:
                return ImageIterator.image(source: source, options: imageOptions, loop: loop)
            case .thumbnail:
                return ImageIterator.thumbnail(source: source, options: thumbnailOptions, loop: loop)
            }
        }
    }
}

public extension ImageSource {
    struct ImageIterator: AsyncIteratorProtocol {
        public let loop: Bool
        public let frameCount: Int
        public private(set) var currentFrame: Int
        public let source: ImageSource
        public let thumbnailOptions: ThumbnailOptions?
        public let imageOptions: ImageOptions?
        public let type: ImageType
        public enum ImageType {
            case image
            case thumbnail
        }

        public static func thumbnail(source: ImageSource, options: ThumbnailOptions? = nil, loop _: Bool = false) -> ImageIterator {
            ImageIterator(source: source, type: .thumbnail, thumbnailOptions: options, imageOptions: nil)
        }

        public static func image(source: ImageSource, options: ImageOptions? = nil, loop _: Bool = false) -> ImageIterator {
            ImageIterator(source: source, type: .thumbnail, thumbnailOptions: nil, imageOptions: options)
        }

        public init(source: ImageSource, type: ImageType, thumbnailOptions: ThumbnailOptions?, imageOptions: ImageOptions?, loop: Bool = false) {
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

        public mutating func next() async -> CGImage? {
            Swift.print("next", currentFrame, currentFrame >= frameCount ,  await nextImage() != nil)
            if currentFrame >= frameCount {
                if loop { currentFrame = 0 } else { return nil }
            }
            let image = await nextImage()
            currentFrame = currentFrame + 1
            return image
        }
    }
}
