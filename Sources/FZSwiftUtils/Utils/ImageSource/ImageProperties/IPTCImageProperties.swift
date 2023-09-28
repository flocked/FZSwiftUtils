//
//  IPTCImageProperties.swift
//  
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension ImageSource.ImageProperties {
    struct IPTC: Codable {
        public var orientation: Orientation?

        enum CodingKeys: String, CodingKey {
            case orientation = "ImageOrientation"
        }
    }
}
