//
//  ColorModel.swift
//  
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageSource.ImageProperties {
    struct ColorModel {
        var RGB: String?
        var Gray: String?
        var CMYK: String?
        var Lab: String?

        enum CodingKeys: String, CodingKey {
            case RGB
            case Gray
            case CMYK
            case Lab
        }
    }
}
