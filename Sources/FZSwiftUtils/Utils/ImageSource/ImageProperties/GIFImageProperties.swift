//
//  Gif.swift
//  ATest
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageProperties {
    public struct GIF: Codable {
        public var loopCount: Int?
        public var clampedDelayTime: Double?
        public var unclampedDelayTime: Double?
        public var hasGlobalColorMap: Bool?
        public var delayTime: Double? {
            return self.unclampedDelayTime ?? self.clampedDelayTime
        }
        
        enum CodingKeys: String, CodingKey {
            case loopCount = "LoopCount"
            case clampedDelayTime = "DelayTime"
            case unclampedDelayTime = "UnclampedDelayTime"
            case hasGlobalColorMap = "HasGlobalColorMap"
          }
    }
}

