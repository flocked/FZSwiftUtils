//
//  JPEGImageProperties.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreGraphics
import Foundation

public extension ImageSource.ImageProperties {
    struct JPEG: Codable {
        public var xDensity: CGFloat?
        public var yDensity: CGFloat?
        public var orientation: Int?
        public var version: [Int]?
        public var densityUnit: Double?
        public var isProgressive: Bool?

        enum CodingKeys: String, CodingKey {
            case xDensity = "XDensity"
            case yDensity = "YDensity"
            case orientation = "Orientation"
            case version = "JFIFVersion"
            case densityUnit = "DensityUnit"
            case isProgressive = "IsProgressive"
        }
    }
}
