//
//  Dictionary+Codable.swift
//
//
//  Created by Guerson Perez on 21/07/20.
//

import Foundation

public extension Encodable {
    /**
     Converts the encodable type to a dictionary using the specified JSON encoder.

     - Parameter encoder: The JSON encoder to use for encoding the type. Default is a new instance of `JSONEncoder`.
     - Returns: A `[String: Any]` representation of the encodable type.
     */
    func toDictionary(encoder: JSONEncoder? = nil) -> [String: Any] {
        let encoder = encoder ?? JSONEncoder()
        do {
            let data = try encoder.encode(self)
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return dict
            }
        } catch {
            print(error)
        }
        return [:]
    }
}

public extension Dictionary {
    /**
     Decodes the dictionary into the specified `Decodable` type.

     This method converts the dictionary into JSON data using `JSONSerialization` and then attempts to decode it into the specified type using a configured `JSONDecoder`.

     - Parameters:
        - type: The concrete `Decodable` type to decode to.
        - dateDecodingStrategy: The strategy used to decode `Date` values.
        - keyDecodingStrategy: The strategy used to decode keys.
        - dataDecodingStrategy: The strategy used to decode `Data` values.
     - Returns: An instance of `T`.
     */
    func decode<T: Decodable>(as type: T.Type = T.self, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: [])
        return try JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy).decode(type, from: data)
    }
    
    /**
     Decodes the dictionary into the specified `Decodable` type using the specified JSON decoder.

     This method converts the dictionary into JSON data using `JSONSerialization` and then attempts to decode it into the specified type using the specified JSON decoder.

     - Parameters:
        - type: The concrete `Decodable` type to decode to.
        - decoder: The JSON decoder to use.
     - Returns: An instance of `T`.
     */
    func decode<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: [])
        return try decoder.decode(type, from: data)
    }
}
