//
//  8BIM.swift
//
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageProperties {
    /// Properties of an Adobe Photoshop image.
    struct A8BIM: RawRepresentable {
        /// The raw values.
        public let rawValue: [CFString: Any]

        /// The Adobe Photoshop resource version of the image.
        public let version: Int?
        /// The layer names stored in the Adobe Photoshop resource data.
        public let layerNames: [String]?

        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            version = rawValue[typed: kCGImageProperty8BIMVersion]
            layerNames = rawValue[typed: kCGImageProperty8BIMLayerNames]
        }
    }
}
