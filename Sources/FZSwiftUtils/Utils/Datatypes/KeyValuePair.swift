//
//  KeyValuePair.swift
//  
//
//  Created by Florian Zand on 24.09.26.
//

import Foundation

/// A key-value pair.
public struct KeyValuePair<Key, Value>: CustomStringConvertible, CustomDebugStringConvertible {
    /// The key of the pair.
    public let key: Key

    /// The value associated with the key.
    public let value: Value

    /// Creates a key-value pair with the specified key and value.
    public init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }

    /// Creates a key-value pair with the specified key and value.
    public init(_ key: Key, _ value: Value) {
        self.init(key: key, value: value)
    }

    /// Creates a key-value pair with the specified key and value.
    public init(_ keyValue: (key: Key, value: Value)) {
        self.init(key: keyValue.key, value: keyValue.value)
    }

    /// A textual representation of the key-value pair.
    public var description: String {
        "(key: \(key), value: \(value))"
    }

    /// A textual representation of the key-value pair, suitable for debugging.
    public var debugDescription: String {
        "(key: \(String(reflecting: key)), value: \(String(reflecting: value)))"
    }
}

extension KeyValuePair: Equatable where Key: Equatable, Value: Equatable {}
extension KeyValuePair: Hashable where Key: Hashable, Value: Hashable {}
extension KeyValuePair: Sendable where Key: Sendable, Value: Sendable {}
extension KeyValuePair: Encodable where Key: Encodable, Value: Encodable {}
extension KeyValuePair: Decodable where Key: Decodable, Value: Decodable {}
