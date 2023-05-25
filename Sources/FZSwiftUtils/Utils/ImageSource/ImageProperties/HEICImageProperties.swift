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
        public var loopCount: Int?
        public var clampedDelayTime: Double?
        public var unclampedDelayTime: Double?
        public var canvasPixelHeight: Double?
        public var canvasPixelWidth: Double?

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
