//
//  KeyPath+.swift
//
//
//  Created by Florian Zand on 13.10.23.
//

import Foundation

public extension PartialKeyPath {
    /// The name of the key path, if it's a @objc property, else the hash value.
    var stringValue: String {
        if let string = _kvcKeyPathString {
            return string
        }
        return String(hashValue)
    }
}
