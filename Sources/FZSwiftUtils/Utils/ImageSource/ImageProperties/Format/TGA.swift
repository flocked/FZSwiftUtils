//
//  TGA.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct TGA {
        /// The raw values.
        public let rawValues: [CFString: Any]

        /// The compression of the image.
        public let compression: CGImagePropertyTGACompression?

        init(tgaData: [CFString: Any]) {
            rawValues = tgaData
            compression = tgaData[typed: kCGImagePropertyTGACompression]
        }
    }
}

extension CGImagePropertyTGACompression: Swift.Encodable, Swift.Decodable { }
