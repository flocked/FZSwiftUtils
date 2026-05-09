//
//  TGA.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct TGA: RawRepresentable {
        /// The raw values.
        public let rawValue: [CFString: Any]

        /// The compression of the image.
        public let compression: CGImagePropertyTGACompression?

        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            compression = rawValue[typed: kCGImagePropertyTGACompression]
        }
    }
}

extension CGImagePropertyTGACompression: Swift.Encodable, Swift.Decodable { }
