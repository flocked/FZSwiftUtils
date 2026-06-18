//
//  PropertyListEncoder+.swift
//
//
//  Created by Florian Zand on 18.06.26.
//

import Foundation

public extension PropertyListEncoder {
    /// Creates a new, reusable property list encoder with the specified output format.
    convenience init(format: PropertyListDecoder.PropertyListFormat) {
        self.init()
        self.outputFormat = format
    }
}
