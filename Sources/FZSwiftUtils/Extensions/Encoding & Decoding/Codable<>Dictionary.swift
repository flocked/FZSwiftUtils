//
//  Codable<>Dictionary.swift
//
//
//  Created by Guerson Perez on 21/07/20.
//

import Foundation

public extension Encodable {
    /**
     Converts the encodable type to a dictionary.

     - Returns: A `[String: Any]` representation of the encodable type.
     */
    func toDictionary() -> [String: Any] {
        toDictionary(encoder: .init())
    }

    /**
     Converts the encodable type to a dictionary using the specified JSON encoder.

     - Parameter encoder: The JSON encoder to use for encoding the type. Default is a new instance of `JSONEncoder`.
     - Returns: A `[String: Any]` representation of the encodable type.
     */
    func toDictionary(encoder: JSONEncoder) -> [String: Any] {
        do {
            let data = try encoder.encode(self)
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return dict
            }
        } catch {
            print("ERROR Converting model to dict")
        }
        return [:]
    }
}

public extension Dictionary {
    /**
     Converts the dictionary to a model object of the specified decodable type.

     - Parameter type: The type of the model object to decode. Default is inferred from the context.
     - Parameter decoder: The JSON decoder to use for decoding the data. Default is a new instance of `JSONDecoder`.
     - Returns: A model object of the specified type, or `nil` if the decoding fails.
     */
    func toModel<T: Decodable>() -> T? {
        toModel(T.self, decoder: .init())
    }

    /**
     Converts the dictionary to a model object of the specified decodable type using the specified JSON decoder.

     - Parameters:
        - type: The type of the model object to decode. Default is inferred from the context.
        - decoder: The JSON decoder to use for decoding the data. Default is a new instance of `JSONDecoder`.
     - Returns: A model object of the specified type, or `nil` if the decoding fails.
     */
    func toModel<T: Decodable>(_ type: T.Type = T.self, decoder: JSONDecoder = .init()) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let obj = try decoder.decode(type, from: data)
            return obj
        } catch {
            debugPrint(error)
            return nil
        }
    }
}
