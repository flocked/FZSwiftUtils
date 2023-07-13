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
     
     - Parameter value: The encodable object to encode.
     - Parameter options: The reading options for deserializing the JSON data. Default is an empty set of options.
     - Returns: The encoded JSON object.
     - Throws: An error if encoding fails.
     */
    func encodeJSONObject<T: Encodable>(_ value: T, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        let data = try encode(value)
        return try JSONSerialization.jsonObject(with: data, options: opt)
    }
}

public extension JSONDecoder {
    /**
     Decodes a JSON object to a model object of the specified type.
     
     - Parameter type: The type of the model object to decode.
     - Parameter object: The JSON object to decode.
     - Parameter options: The writing options for serializing the JSON data. Default is an empty set of options.
     - Returns: A model object of the specified type.
     - Throws: An error if decoding fails.
     */
    func decode<T: Decodable>(_: T.Type, withJSONObject object: Any, options opt: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: opt)
        return try decode(T.self, from: data)
    }
}
