//
//  Collection+Decode.swift
//
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension Collection where Element: Any {
    /**
     Decodes the collection into the specified `Decodable` type.

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
     Decodes the collection into the specified `Decodable` type using the specified JSON decoder.

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
