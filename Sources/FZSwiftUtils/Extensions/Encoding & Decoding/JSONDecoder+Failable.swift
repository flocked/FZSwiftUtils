//
//  JSONDecoder+Failable.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 22.08.26.
//

import Foundation

// MARK: - FailableDecodable

/// A container that stores a decoded value, or `nil` if the value fails to decode.
public struct FailableDecodable<Value: Decodable>: Decodable {
    /// The decoded value, or `nil` if decoding failed.
    public let value: Value?

    /// Creates a new instance by decoding a value, storing `nil` if the value fails to decode.
    public init(from decoder: Decoder) throws {
        value = try decoder.failableValue()
    }
}

extension FailableDecodable: Equatable where Value: Equatable {}
extension FailableDecodable: Hashable where Value: Hashable {}
extension FailableDecodable: Sendable where Value: Sendable {}

private struct FailableDictionaryKey<Value: Decodable>: Decodable {
    let value: Value?

    init(from decoder: Decoder) throws {
        value = try decoder.failableValue(isDictionaryKey: true)
    }
}

extension FailableDictionaryKey: Equatable where Value: Equatable {}
extension FailableDictionaryKey: Hashable where Value: Hashable {}

fileprivate extension Decoder {
    func failableValue<V: Decodable>(isDictionaryKey: Bool = false) throws -> V? {
        do {
            return try singleValueContainer().decode(V.self)
        } catch {
            let strategy = userInfo[isDictionaryKey ? .failedDictionaryKeyDecodingStrategy : .failedDecodingStrategy]
            if strategy is ThrowFailedDecoding {
                throw error
            }
            return try (strategy as? (@Sendable (any Decoder) throws -> V))?(self)
        }
    }
}

private struct ThrowFailedDecoding: Sendable { }

private extension CodingUserInfoKey {
    static let failedDecodingStrategy = Self(rawValue: "failedDecodingStrategy")!
    static let failedDictionaryKeyDecodingStrategy = Self(rawValue: "failedDictionaryKeyDecodingStrategy")!
}

public extension JSONDecoder {
    /// The strategy to use when an element of a sequence fails to decode.
    enum InvalidElementDecodingStrategy<Value> {
        /// Throws upon encountering an element that fails to decode.
        case `throw`
        /// Ignores elements that fail to decode.
        case skip
        /// Replaces elements that fail to decode with the specified value.
        case defaultValue(Value)
        /// Handles elements that fail to decode using the specified closure.
        @preconcurrency
        case custom(@Sendable (any Decoder) throws -> Value)
    }
    
    func decode<T>(_ type: T.Type, from data: Data, invalidElementDecodingStrategy strategy: InvalidElementDecodingStrategy<T.Element>) throws -> T where T: Decodable & RangeReplaceableCollection, T.Element: Decodable {
        switch strategy {
        case .throw:
            return try decode(type, from: data)
        case .skip:
            return try T(decode([FailableDecodable<T.Element>].self, from: data)
                    .compactMap(\.value))
        case .defaultValue(let defaultValue):
            return try T(decode([FailableDecodable<T.Element>].self, from: data)
                .map { $0.value ?? defaultValue })
        case .custom(let handler):
            defer { userInfo[.failedDecodingStrategy] = nil }
            userInfo[.failedDecodingStrategy] = handler
            return try T(decode([FailableDecodable<T.Element>].self, from: data)
                    .compactMap(\.value))
        }
    }

    func decode<T>(_ type: Set<T>.Type, from data: Data, invalidElementDecodingStrategy strategy: InvalidElementDecodingStrategy<T>) throws -> Set<T> where T: Decodable & Hashable {
        if case .throw = strategy {
            return try decode(type, from: data)
        }
        return try Set(decode([T].self, from: data, invalidElementDecodingStrategy: strategy))
    }

    func decode<Key, Value>(_ type: [Key: Value].Type, from data: Data, invalidKeyDecodingStrategy keyStrategy: InvalidElementDecodingStrategy<Key> = .throw, invalidValueDecodingStrategy valueStrategy: InvalidElementDecodingStrategy<Value> = .throw) throws -> [Key: Value] where Key: Codable & Hashable, Value: Decodable {
        if case .throw = keyStrategy, case .throw = valueStrategy {
            return try decode(type, from: data)
        }
        
        defer {
            userInfo[.failedDictionaryKeyDecodingStrategy] = nil
            userInfo[.failedDecodingStrategy] = nil
        }
        
        var defaultKey: Key?
        var defaultValue: Value?
        switch keyStrategy {
        case .throw:
            userInfo[.failedDictionaryKeyDecodingStrategy] = ThrowFailedDecoding()
        case .skip:
            break
        case .defaultValue(let value):
            defaultKey = value
        case .custom(let handler):
            userInfo[.failedDictionaryKeyDecodingStrategy] = handler
        }

        switch valueStrategy {
        case .throw:
            userInfo[.failedDecodingStrategy] = ThrowFailedDecoding()
        case .skip:
            break
        case .defaultValue(let value):
            defaultValue = value
        case .custom(let handler):
            userInfo[.failedDecodingStrategy] = handler
        }
        return try decode([FailableDictionaryKey<Key>: FailableDecodable<Value>].self, from: data).compactMapKeyValues {
            guard let key = $0.key.value ?? defaultKey,
                  let value = $0.value.value ?? defaultValue else {
                return nil
            }
            return (key, value)
        }
    }
}
