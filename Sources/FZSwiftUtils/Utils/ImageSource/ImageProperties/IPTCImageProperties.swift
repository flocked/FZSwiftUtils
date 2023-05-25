//
//  TIFF.swift
//  ATest
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageProperties {
    public struct IPTC: Codable {
        public var orientation: Orientation?
        
        enum CodingKeys: String, CodingKey {
            case orientation = "ImageOrientation"
          }
    }
}
