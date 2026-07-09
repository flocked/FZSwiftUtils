//
//  WEBP.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct WEBP: RawRepresentable {
        /// The raw values.
        public var rawValue: [CFString: Any]
        /**
         The number of times that an animated image should play through its frames before stopping.

         A value of `0` means the animated image repeats forever.
         */
        public var loopCount: Int?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         The value of this key is never less than `100` millseconds, and the system adjusts values less than that amount to `100` milliseconds, as needed. Use ``unclampedDelayTime`` for the unclamped delay time.
         */
        public var clampedDelayTime: Double?
        /**
         The number of seconds to wait before displaying the next image in an animated sequence.

         This value may be `0` milliseconds or higher. Unlike the ``unclampedDelayTime`` property, this value is not clamped at the low end of the range.
         */
        public var unclampedDelayTime: Double?
        
        /// The number of seconds to wait before displaying the next image in an animated sequence.
        public var delayTime: Double? {
            unclampedDelayTime ?? clampedDelayTime
        }
        
        /// The pixel width of the main image.
        public var canvasPixelWidth: Double?
        
        /// The pixel height of the main image.
        public var canvasPixelHeight: Double?
        
        /// The pixel size of the main image.
        public var canvasPixelSize: CGSize? {
            guard let width = canvasPixelWidth, let height = canvasPixelHeight else { return nil }
            return CGSize(width: width, height: height)
        }
        
        /// The clamped and unclamped delay times for each frame, representing the number of seconds to wait before displaying the next image in an animated sequence.
        public var framesInfo: [FrameInfo]?
        
        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            
            canvasPixelWidth = rawValue[typed: kCGImagePropertyWebPCanvasPixelWidth]
            canvasPixelHeight = rawValue[typed: kCGImagePropertyWebPCanvasPixelHeight]
            loopCount = rawValue[typed: kCGImagePropertyWebPLoopCount]
            clampedDelayTime = rawValue[typed: kCGImagePropertyWebPDelayTime]
            unclampedDelayTime = rawValue[typed: kCGImagePropertyWebPUnclampedDelayTime]
            framesInfo = (rawValue[typed: kCGImagePropertyWebPFrameInfoArray] as [[CFString: Any]]?)?.map(FrameInfo.init(rawValue:))
        }
    }
}
