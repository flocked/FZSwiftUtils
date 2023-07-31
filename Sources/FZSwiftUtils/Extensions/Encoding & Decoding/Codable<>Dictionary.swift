//
//  Codable<>Dictionary.swift
//
//
//  Created by Guerson Perez on 21/07/20.
//

import Foundation

public extension Encodable {
    /**
     Converts the encodable object to a CFDictionary.
     
     - Returns: A `CFDictionary` representation of the encodable object.
     */
    func toCFDictionary() -> CFDictionary {
        return (toDictionary(encoder: .init()) as [CFString: Any]) as CFDictionary
    }

    /**
     Converts the encodable object to a dictionary.
     
     - Returns: A `[String: Any]` representation of the encodable object.
     */
    func toDictionary() -> [String: Any] {
        return toDictionary(encoder: .init())
    }

    /**
      Converts the encodable object to a dictionary using the specified JSON encoder.
      
      - Parameter encoder: The JSON encoder to use for encoding the object. Default is a new instance of `JSONEncoder`.
      - Returns: A `[String: Any]` representation of the encodable object.
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

public extension CFDictionary {
    /**
     Converts the dictionary to a model object of the specified type.
     
     - Parameter type: The type of the model object to decode. Default is inferred from the context.
     - Parameter decoder: The JSON decoder to use for decoding the data. Default is a new instance of `JSONDecoder`.
     - Returns: A model object of the specified type, or `nil` if the decoding fails.
     */
    func toModel<T: Codable>() -> T? {
        return toModel(T.self, decoder: .init())
    }

    /**
     Converts the dictionary to a model object of the specified type using the specified JSON decoder.
     
     - Parameter type: The type of the model object to decode. Default is inferred from the context.
     - Parameter decoder: The JSON decoder to use for decoding the data.
     - Returns: A model object of the specified type, or `nil` if the decoding fails.
     */
    func toModel<T: Codable>(_ type: T.Type = T.self, decoder: JSONDecoder) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let obj = try decoder.decode(type, from: data)
            return obj
        } catch {
            Swift.debugPrint(error)
            return nil
        }
    }
}

public extension Dictionary {
    /**
     Converts the dictionary to a model object of the specified type.
     
     - Parameter type: The type of the model object to decode. Default is inferred from the context.
     - Parameter decoder: The JSON decoder to use for decoding the data. Default is a new instance of `JSONDecoder`.
     - Returns: A model object of the specified type, or `nil` if the decoding fails.
     */
    func toModel<T: Codable>() -> T? {
        return toModel(T.self, decoder: .init())
    }
    
    /**
     Converts the dictionary to a model object of the specified type using the specified JSON decoder.
     
     - Parameter type: The type of the model object to decode. Default is inferred from the context.
     - Parameter decoder: The JSON decoder to use for decoding the data. Default is a new instance of `JSONDecoder`.
     - Returns: A model object of the specified type, or `nil` if the decoding fails.
     */
    func toModel<T: Codable>(_ type: T.Type = T.self, decoder: JSONDecoder = .init()) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let obj = try decoder.decode(type, from: data)
            return obj
        } catch {
            Swift.debugPrint(error)
            return nil
        }
    }
}
