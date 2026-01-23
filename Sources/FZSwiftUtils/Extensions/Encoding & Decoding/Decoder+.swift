//
//  Decoder+.swift
//
//
//  Created by Florian Zand on 16.07.25.
//

public extension Decoder {
    /**
     Decodes a single value from the decoder's single value container.

     - Parameter type: The type of the value to decode.
     - Returns: A decoded value of the specified type.
     - Throws: An error if decoding fails, or if the container does not contain a single value of the expected type.

     This is a convenience method to simplify decoding a single value without manually creating the container.
     */
    func decodeSingle<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        try singleValueContainer().decode(type)
    }
}

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
