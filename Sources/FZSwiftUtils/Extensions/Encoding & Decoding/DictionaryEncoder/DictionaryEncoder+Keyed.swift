//
//  DictionaryEncoder+Keyed.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

import Foundation

internal extension DictionaryEncoder {
    final class Keyed<Key: CodingKey>: KeyedEncodingContainerProtocol, ComponentEncoder {
        let storage: KeyedStorage
        
        var strategies: Strategies {
            storage.strategies
        }
        
        var userInfo: [CodingUserInfoKey: Any] {
            storage.userInfo
        }
        
        var codingPath: [CodingKey] {
            storage.codingPath
        }
                
        init(storage: KeyedStorage) {
            self.storage = storage
        }
                
        func encodeNil(forKey key: Key) throws {
            storage[key] = encodeNil(at: codingPath + key)
        }
        
        func encode(_ value: Bool, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: Int, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: Int8, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: Int16, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: Int32, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: Int64, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: UInt, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: UInt8, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: UInt16, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: UInt32, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: UInt64, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode(_ value: Double, forKey key: Key) throws {
            storage[key] = try encode(value, at: codingPath + key)
        }
        
        func encode(_ value: Float, forKey key: Key) throws {
            storage[key] = try encode(value, at: codingPath + key)
        }
        
        func encode(_ value: String, forKey key: Key) throws {
            storage[key] = encode(value, at: codingPath + key)
        }
        
        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            storage[key] = try encode(value, at: codingPath + key)
        }
        
        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            storage.nestedContainer(keyedBy: keyType, forKey: key)
        }
        
        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            storage.nestedUnkeyedContainer(forKey: key)
        }
        
        func superEncoder(forKey key: Key) -> Encoder {
            storage.superEncoder(forKey: key)
        }
        
        func superEncoder() -> Encoder {
            storage.superEncoder(forKey: AnyCodingKey("super"))
        }
    }
}
