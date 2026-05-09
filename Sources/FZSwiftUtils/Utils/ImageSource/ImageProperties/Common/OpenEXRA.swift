//
//  OpenEXRA.swift
//
//
//  Created by Florian Zand on 01.05.26.
//

import Foundation
import ImageIO

extension ImageProperties {
    public struct OpenEXRA: RawRepresentable {
        /// The raw values.
        public let rawValue: [CFString: Any]
        
        /// The aspect ratio of the image.
        public let aspectRatio: Double?
        
        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            self.aspectRatio = rawValue[typed: kCGImagePropertyOpenEXRAspectRatio]
        }
    }
}
