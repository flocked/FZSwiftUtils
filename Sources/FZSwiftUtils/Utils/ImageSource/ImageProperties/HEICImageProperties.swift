//
//  Gif.swift
//  ATest
//
//  Created by Florian Zand on 02.06.22.
//

import CoreGraphics
import Foundation

public extension ImageProperties {
    struct HEIC: Codable {
        /**
         The number of times that an animated image should play through its frames before stopping.
         
         A value of 0 means the animated image repeats forever.
         */
        public var loopCount: Int?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.
         
         The value of this key is never less than 50 millseconds, and the system adjusts values less than that amount to 50 milliseconds, as needed. See kCGImagePropertyAPNGUnclampedDelayTime.
         */
        public var clampedDelayTime: Double?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.
         
         This value may be 0 milliseconds or higher. Unlike the `clampedDelayTime` property, this value is not clamped at the low end of the range.
         */
        public var unclampedDelayTime: Double?
        /// The height of the main image, in pixels.
        public var canvasPixelHeight: Double?
        /// The width of the main image, in pixels.
        public var canvasPixelWidth: Double?
        /// The size of the main image, in pixels.
        public var canvasPixelSize: CGSize? {
            guard let width = canvasPixelWidth, let height = canvasPixelHeight else { return nil }
            return CGSize(width: width, height: height)
        }

        public var delayTime: Double? {
            return unclampedDelayTime ?? clampedDelayTime
        }

        enum CodingKeys: String, CodingKey {
            case loopCount = "LoopCount"
            case clampedDelayTime = "DelayTime"
            case unclampedDelayTime = "UnclampedDelayTime"
            case canvasPixelHeight = "CanvasPixelHeight"
            case canvasPixelWidth = "CanvasPixelWidth"
        }
    }
}
