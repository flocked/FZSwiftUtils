//
//  KeyPath+.swift
//
//
//  Created by Florian Zand on 13.10.23.
//

import Foundation

public extension PartialKeyPath {
    /// The `KVO` name of the key path, or `nil` if the property isn't key value observable.
    var kvcStringValue: String? {
        _kvcKeyPathString
    }
    
    #if swift(>=5.8)
    /// The name of the key path.
    var stringValue: String {
        if let keyPath = kvcStringValue {
            return keyPath
        }
        let keyPath = String(describing: self)
        return keyPath.hasPrefix("\\") ? keyPath.components(separatedBy: ".")[safe: 1...].joined(separator: ".") : keyPath
    }
    #else
    /// The name of the key path if it's a `ObjC` property, else the hash value.
    var stringValue: String {
        kvcStringValue ?? String(hashValue)
    }
    #endif
}

public extension Selector {
    /// `String` representation of the selector.
    var string: String {
        NSStringFromSelector(self)
    }
}
