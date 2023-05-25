//
//  TIFF.swift
//  ATest
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageProperties {
    public struct TIFF: Codable {
        public var xResolution: Int?
        public var yResolution: Int?
        public var orientation: Orientation?
        public var timestamp: Date?
        public var cameraMaker: String?
        public var cameraModel: String?

        enum CodingKeys: String, CodingKey {
            case xResolution = "XResolution"
            case yResolution = "YResolution"
            case orientation = "Orientation"
            case timestamp = "DateTime"
            case cameraMaker = "Make"
            case cameraModel = "Model"

          }
    }
}
