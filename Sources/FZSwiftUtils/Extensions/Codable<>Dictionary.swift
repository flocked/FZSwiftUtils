//
//  File.swift
//
//
//  Created by Guerson Perez on 21/07/20.
//

import Foundation

public extension Encodable {
    func toCFDictionary() -> CFDictionary {
        return (toDictionary(encoder: .init()) as [CFString: Any]) as CFDictionary
    }

    func toDictionary() -> [String: Any] {
        return toDictionary(encoder: .init())
    }

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
    func toModel<T: Codable>() -> T? {
        return toModel(T.self, decoder: .init())
    }

    func toModel<T: Codable>(_ type: T.Type = T.self, decoder: JSONDecoder) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let obj = try decoder.decode(type, from: data)
            return obj
        } catch {
            Swift.print(error)
            return nil
        }
    }
}

public extension Dictionary {
    func toModel<T: Codable>(_ type: T.Type = T.self, decoder: JSONDecoder = .init()) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let obj = try decoder.decode(type, from: data)
            return obj
        } catch {
            Swift.print(error)
            return nil
        }
    }
}
