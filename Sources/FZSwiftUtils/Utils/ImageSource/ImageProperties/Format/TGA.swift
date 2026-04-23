//
//  TGA.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    struct TGA: Codable {
        public var compression: CGImagePropertyTGACompression?
        
        enum CodingKeys: String, CodingKey {
            case compression = "Compression"
        }
    }
}

extension CGImagePropertyTGACompression: Swift.Encodable, Swift.Decodable { }
