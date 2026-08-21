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
     Decodes the dictionary into the specified `Decodable` type using the specified JSON decoder.

     This method converts the dictionary into JSON data using `JSONSerialization` and then attempts to decode it into the specified type using the specified JSON decoder.

     - Parameters:
        - type: The concrete `Decodable` type to decode to.
        - decoder: The JSON decoder to use.
     - Returns: An instance of `T`.
     */
    func decode<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = .init()) throws -> T {
        try PropertyListDecoder().decode(T.self, from: PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: 0))
        // return try decoder.decode(type, from: JSONSerialization.data(withJSONObject: self, options: []))
    }
}
