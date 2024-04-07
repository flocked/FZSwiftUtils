//
//  ImageSequence.swift
//
//
//  Created by Florian Zand on 03.06.22.
//

import Combine
import Foundation
import ImageIO
#if os(macOS)
import AppKit
#endif

public struct ImageSequence: AsyncSequence {
    public typealias Element = CGImage
    
    enum ImageType {
        case image
        case thumbnail
    }
    
    let source: ImageSource?
    let type: ImageType
    let imageOptions: ImageSource.ImageOptions?
    let thumbnailOptions: ImageSource.ThumbnailOptions?
    #if os(macOS)
    let representation: NSBitmapImageRep?
    #endif
    
    public let count: Int
    
    init(source: ImageSource, type: ImageType, imageOptions: ImageSource.ImageOptions? = nil, thumbnailOptions: ImageSource.ThumbnailOptions? = nil) {
        self.source = source
        self.type = type
        self.imageOptions = imageOptions
        self.thumbnailOptions = thumbnailOptions
        self.count = source.count
        #if os(macOS)
        self.representation = nil
        #endif
    }
    
    #if os(macOS)
    init(_ representation: NSBitmapImageRep) {
        self.representation = representation
        self.count = representation.frameCount
        self.type = .image
        self.imageOptions = nil
        self.thumbnailOptions = nil
        self.source = nil
    }
    #endif
    
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
            if let source = sequence.source {
                switch sequence.type {
                case .image:
                    return await source.image(at: index, options:  sequence.imageOptions)
                case .thumbnail:
                    return await source.thumbnail(at: index, options:  sequence.thumbnailOptions)
                }
            }
            #if os(macOS)
            if let representation = sequence.representation {
                representation.currentFrame = index
                return representation.cgImage
            }
            #endif
            return nil
        }
    }
}

