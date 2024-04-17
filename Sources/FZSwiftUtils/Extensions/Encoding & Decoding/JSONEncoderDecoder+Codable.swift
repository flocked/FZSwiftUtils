//
//  JSONCodable+JSONObjects.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

import Foundation

public extension JSONEncoder {
    /**
     Encodes the specified encodable object to a JSON object.

     - Parameters:
        - value: The encodable object to encode.
        - options: The reading options for deserializing the JSON data.
     - Returns: The encoded JSON object.
     - Throws: An error if encoding fails.
     */
    func encodeJSONObject<V: Encodable>(_ value: V, options: JSONSerialization.ReadingOptions = []) throws -> Any {
        let data = try encode(value)
        return try JSONSerialization.jsonObject(with: data, options: options)
    }
}

public extension JSONDecoder {
    /**
     Decodes a JSON object to a model object of the specified type.

     - Parameters:
        - type: The type of the model object to decode.
        - object: The JSON object to decode.
        - options: The writing options for serializing the JSON data.
     - Returns: A model object of the specified type.
     - Throws: An error if decoding fails.
     */
    func decode<T: Decodable>(_: T.Type, withJSONObject object: Any, options: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: options)
        return try decode(T.self, from: data)
    }
    
    /**
     Decodes a JSON object to a model object of the specified type.

     - Parameters:
        - object: The JSON object to decode.
        - options: The writing options for serializing the JSON data.
     - Returns: A model object of the specified type.
     - Throws: An error if decoding fails.
     */
    func decode<T: Decodable>(_ object: Any, options: JSONSerialization.WritingOptions = []) throws -> T {
        try decode(T.self, withJSONObject: object, options: options)
    }
}
