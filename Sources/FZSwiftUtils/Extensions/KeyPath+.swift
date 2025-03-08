//
//  KeyPath+.swift
//
//
//  Created by Florian Zand on 13.10.23.
//

import Foundation

public extension PartialKeyPath {
    #if swift(>=5.8)
    /// The name of the key path.
    var stringValue: String {
        _kvcKeyPathString ?? String(reflecting: self)
    }
    #else
    /// The name of the key path, if it's a `ObjcC` property, else the hash value.
    var stringValue: String {
        _kvcKeyPathString ?? String(hashValue)
    }
    #endif
}
