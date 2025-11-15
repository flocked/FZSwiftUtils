//
//  Decodable+.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

import Foundation

public extension SingleValueDecodingContainer {
    /// Decodes a single value of the given type.
    func decode<T: Decodable>() throws -> T {
        try decode(T.self)
    }
}

public extension KeyedDecodingContainer {
    /**
     Decodes a value of the given type for the given key.
     
     - Parameter key: The key that the decoded value is associated with.
     */
    func decode<T: Decodable>(_ key: Key) throws -> T {
        try decode(T.self, forKey: key)
    }
    
    /**
     Decodes a value of the given type for the given key, if present.
     
     - Parameter key: The key that the decoded value is associated with.
     */
    func decodeIfPresent<T: Decodable>(_ key: Key) throws -> T? {
        try decodeIfPresent(T.self, forKey: key)
    }
}

struct _EmptyDecodable: Decodable { }

public extension UnkeyedDecodingContainer {
    /// Skips decoding.
    mutating func skip() throws {
        _ = try decode(_EmptyDecodable.self)
    }
}
