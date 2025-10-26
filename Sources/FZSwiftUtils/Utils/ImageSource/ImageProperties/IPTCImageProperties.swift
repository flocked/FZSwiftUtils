//
//  IPTCImageProperties.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    struct IPTC: Codable {
        public var orientation: CGImagePropertyOrientation?

        enum CodingKeys: String, CodingKey {
            case orientation = "ImageOrientation"
        }
    }
}
