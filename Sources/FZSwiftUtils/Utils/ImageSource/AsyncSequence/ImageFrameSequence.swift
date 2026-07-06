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
    public let count: Int
    private let frameAtIndex: (Int) async -> CGImageFrame?

    init(count: Int, frameAtIndex: @escaping (Int) async -> CGImageFrame?) {
        self.count = count
        self.frameAtIndex = frameAtIndex
    }
    
    #if os(macOS)
    init(_ representation: NSBitmapImageRep) {
        self.init(count: representation.frameCount) { index in
            representation.currentFrame = index
            guard let image = representation.cgImage else { return nil }
            return CGImageFrame(image: image, duration: representation.currentFrameDuration)
        }
    }
    #endif

    public func makeAsyncIterator() -> Iterator {
        Iterator(sequence: self)
    }

    public struct Iterator: AsyncIteratorProtocol {
        private var index = 0
        private let sequence: ImageFrameSequence

        init(sequence: ImageFrameSequence) {
            self.sequence = sequence
        }

        public mutating func next() async -> CGImageFrame? {
            guard index < sequence.count else { return nil }
            defer { index += 1 }
            return await sequence.frameAtIndex(index)
        }
    }
}

#if os(macOS)
extension NSBitmapImageRep {
    /// The frames of an animated (e.g. GIF) image asynchronously.
    public var frames: ImageFrameSequence {
        ImageFrameSequence(self)
    }
        
    /// The frames of an animated (e.g. GIF) image.
    public func getFrames() -> [CGImageFrame] {
        (try? frames.collect()) ?? []
    }
        
    /// The images of an animated (e.g. GIF) image asynchronously.
    public var images: ImageSequence {
        ImageSequence(self)
    }
        
    /// The images of an animated (e.g. GIF) image.
    public func getImages() -> [CGImage] {
        (try? images.collect()) ?? []
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
    var currentFrameDuration: TimeInterval {
        (value(forProperty: .currentFrameDuration) as? TimeInterval) ?? 0.0
    }

    /// The number of loops to make when animating a GIF image, or `0` if the image isn't a GIF.
    var loopCount: Int {
        (value(forProperty: .loopCount) as? Int) ?? 0
    }
}
#endif
