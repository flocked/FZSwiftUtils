//
//  8BIM.swift
//
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    /// Properties of an Adobe Photoshop image.
    struct A8BIM {
        /// The raw values.
        public let rawValues: [CFString: Any]

        /// The Adobe Photoshop resource version of the image.
        public let version: Int?
        /// The layer names stored in the Adobe Photoshop resource data.
        public let layerNames: [String]?

        init(a8bimData: [CFString: Any]) {
            rawValues = a8bimData
            version = a8bimData[typed: kCGImageProperty8BIMVersion]
            layerNames = a8bimData[typed: kCGImageProperty8BIMLayerNames]
        }
    }
}
