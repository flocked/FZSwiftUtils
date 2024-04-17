//
//  Collection+Decode.swift
//
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension Collection where Element: Any {
    /**
     Converts the array to an array with the specified codable type.

     - Returns: An array with the specified codable type.
     */
    func toModel<T: Decodable>() -> [T] {
        toModel(T.self)
    }
    
    /**
     Converts the array to an array with the specified codable type.

     - Parameter type: The type of the model object to decode.
     - Parameter decoder: The JSON decoder to use for decoding the data.
     - Returns: An array with the specified codable type.
     */
    func toModel<T: Decodable>(_ type: T.Type = T.self, decoder: JSONDecoder? = nil) -> [T] {
        var objects: [T] = []
        let decoder = decoder ?? JSONDecoder()
        for element in self {
            if let data = try? JSONSerialization.data(withJSONObject: element, options: .prettyPrinted), let object = try? decoder.decode(type, from: data) {
                objects.append(object)
            }
        }
        return objects
    }
}
