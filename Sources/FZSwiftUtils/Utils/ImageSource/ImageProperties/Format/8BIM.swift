//
//  8BIM.swift
//
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation

public extension ImageSource.ImageProperties {
    /// Properties of an Adobe Photoshop image.
    struct A8BIM: Codable {
        /// The Adobe Photoshop resource version of the image.
        public var version: Int?
        /// The layer names stored in the Adobe Photoshop resource data.
        public var layerNames: [String]?

        enum CodingKeys: String, CodingKey {
            case version = "Version"
            case layerNames = "LayerNames"
        }
    }
}
