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
        public typealias Element = CGImage
        
        enum ImageType {
            case image
            case thumbnail
        }
        
        let source: ImageSource
        let type: ImageType
        let imageOptions: ImageOptions?
        let thumbnailOptions: ThumbnailOptions?
        public let count: Int

        init(source: ImageSource, type: ImageType, imageOptions: ImageOptions? = nil, thumbnailOptions: ThumbnailOptions? = nil) {
            self.source = source
            self.type = type
            self.imageOptions = imageOptions
            self.thumbnailOptions = thumbnailOptions
            self.count = source.count
        }

        public func makeAsyncIterator() -> Iterator {
            Iterator(self)
        }
        
        public struct Iterator: AsyncIteratorProtocol {
            var index: Int = -1
            let sequence: ImageSequence

            init(_ sequence: ImageSequence) {
                self.sequence = sequence
            }

            public mutating func next() async -> CGImage? {
                index = index + 1
                guard index < sequence.count else { return nil }
                switch sequence.type {
                case .image:
                    return await  sequence.source.image(at: index, options:  sequence.imageOptions)
                case .thumbnail:
                    return await  sequence.source.thumbnail(at: index, options:  sequence.thumbnailOptions)
                }
            }
        }
    }
}

public extension ImageSource {

}
