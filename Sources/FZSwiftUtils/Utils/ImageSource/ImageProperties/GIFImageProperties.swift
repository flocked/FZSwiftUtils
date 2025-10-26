//
//  GIFImageProperties.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension ImageSource.ImageProperties {
    struct GIF: Codable {
        /**
         The number of times that an animated image should play through its frames before stopping.

         A value of 0 means the animated image repeats forever.
         */
        public var loopCount: Int?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         The value of this key is never less than 100 millseconds, and the system adjusts values less than that amount to 100 milliseconds, as needed. See ``unclampedDelayTime`` for the unclamped delay time.
         */
        public var clampedDelayTime: Double?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         This value may be 0 milliseconds or higher. Unlike the ``unclampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public var unclampedDelayTime: Double?
        /// A Boolean value indicating whether the GIF has a global color map.
        public var hasGlobalColorMap: Bool?

        /// The number of seconds to wait before displaying the next image in an animated sequence.
        public var delayTime: Double? {
            unclampedDelayTime ?? clampedDelayTime
        }
        
        /// The width of the main image, in pixels.
        public var canvasPixelWidth: CGFloat?

        /// The height of the main image, in pixels.
        public var canvasPixelHeight: CGFloat?
        
        /// The size of the main image, in pixels.
        public var canvasPixelSize: CGSize? {
            guard let width = canvasPixelWidth, let height = canvasPixelHeight else { return nil }
            return CGSize(width, height)
        }
        
        /// The clamped and unclamped delay times of each frame.
        public var framesInfo: [FrameInfo]?
        
        /*
        /// The image color map.
        public var colorMap: Any?
         */

        enum CodingKeys: String, CodingKey {
            case canvasPixelWidth = "CanvasPixelWidth"
            case canvasPixelHeight = "CanvasPixelHeight"
            case loopCount = "LoopCount"
            case clampedDelayTime = "DelayTime"
            case unclampedDelayTime = "UnclampedDelayTime"
            case hasGlobalColorMap = "HasGlobalColorMap"
            case framesInfo = "FrameInfoArray"
            /*
            case colorMap = "ImageColorMap"
             */
        }
    }
}
