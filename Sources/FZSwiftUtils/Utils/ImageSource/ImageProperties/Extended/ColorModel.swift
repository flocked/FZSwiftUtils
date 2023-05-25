//
//  ColorModel.swift
//  ATest
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageProperties {
struct ColorModel {
    var RGB: String?
    var Gray: String?
    var CMYK: String?
    var Lab: String?

    enum CodingKeys: String, CodingKey {
        case RGB = "RGB"
        case Gray = "Gray"
        case CMYK = "CMYK"
        case Lab = "Lab"
    }
}
}
