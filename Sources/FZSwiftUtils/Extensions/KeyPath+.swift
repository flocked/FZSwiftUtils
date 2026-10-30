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
    
    /// The name of the key path.
    var stringValue: String {
        if let keyPath = kvcStringValue { return keyPath }
        let keyPath = String(describing: self)
        guard keyPath.hasPrefix("\\"), let split = keyPath.split(separator: ".", maxSplits: 1)[safe: 1] else { return keyPath }
        return String(split)
    }
}
