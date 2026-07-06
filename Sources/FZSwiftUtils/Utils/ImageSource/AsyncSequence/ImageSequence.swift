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
    public let count: Int
    private let imageAtIndex: (Int) async -> CGImage?

    init(count: Int, imageAtIndex: @escaping (Int) async -> CGImage?) {
        self.count = count
        self.imageAtIndex = imageAtIndex
    }
    
    #if os(macOS)
    init(_ representation: NSBitmapImageRep) {
        self.init(count: representation.frameCount) { index in
            representation.currentFrame = index
            return representation.cgImage
        }
    }
    #endif

    public func makeAsyncIterator() -> Iterator {
        Iterator(sequence: self)
    }

    public struct Iterator: AsyncIteratorProtocol {
        private var index = 0
        private let sequence: ImageSequence

        init(sequence: ImageSequence) {
            self.sequence = sequence
        }

        public mutating func next() async -> CGImage? {
            guard index < sequence.count else { return nil }
            defer { index += 1 }
            return await sequence.imageAtIndex(index)
        }
    }
}
