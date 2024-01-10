//
//  BaseDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation
import SwiftUI

/// A synchronized dictionary.
public struct BaseDictionary<Key: Hashable, Value>: Collection, Sequence, ExpressibleByDictionaryLiteral {
    public typealias Element = (key: Key, value: Value)

    var dictionary: [Key: Value]

    public init(dictionaryLiteral elements: (Value, Key)...) {
        dictionary = [:]
        for element in elements {
            dictionary[element.1] = element.0
        }
    }

    public init(dict: [Key: Value] = [Key: Value]()) {
        dictionary = dict
    }

    public init() {
        dictionary = [:]
    }

    public init(minimumCapacity: Int) {
        dictionary = .init(minimumCapacity: minimumCapacity)
    }

    public init<S>(uniqueKeysWithValues keysAndValues: S) where S: Sequence, S.Element == (Key, Value) {
        dictionary = .init(uniqueKeysWithValues: keysAndValues)
    }

    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        dictionary = try .init(keysAndValues, uniquingKeysWith: combine)
    }

    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S: Sequence {
        dictionary = try .init(grouping: values, by: keyForValue)
    }

    public mutating func edit(_ edit: @escaping (inout [Key: Value]) -> Void) {
        edit(&dictionary)
    }

    public var isEmpty: Bool {
        dictionary.isEmpty
    }

    public var count: Int {
        dictionary.count
    }

    public var capacity: Int {
        dictionary.capacity
    }

    public var startIndex: Dictionary<Key, Value>.Index {
        dictionary.startIndex
    }

    public var endIndex: Dictionary<Key, Value>.Index {
        dictionary.endIndex
    }

    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        dictionary.index(after: i)
    }

    public func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        dictionary.index(forKey: key)
    }

    public subscript(position: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        dictionary[position]
    }

    public subscript(key: Key) -> Value? {
        set(newValue) { dictionary[key] = newValue }
        get { dictionary[key] }
    }

    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get { dictionary[key, default: defaultValue()] }
        set { dictionary[key, default: defaultValue()] = newValue }
    }

    public var keys: [Key] {
        Array(dictionary.keys)
    }

    public var values: [Value] {
        Array(dictionary.values)
    }

    public var first: BaseDictionary.Element? {
        dictionary.first
    }

    public mutating func removeValue(forKey key: Key) {
        dictionary.removeValue(forKey: key)
    }

    public mutating func removeAll(keepingCapacity: Bool = false) {
        dictionary.removeAll(keepingCapacity: keepingCapacity)
    }

    @discardableResult
    public mutating func remove(at index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        dictionary.remove(at: index)
    }

    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        dictionary.updateValue(value, forKey: key)
    }

    public mutating func merge(_ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try dictionary.merge(other, uniquingKeysWith: combine)
    }

    public mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        try dictionary.merge(other, uniquingKeysWith: combine)
    }

    public func merging(_ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key: Value] {
        try dictionary.merging(other, uniquingKeysWith: combine)
    }

    public func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key: Value] where S: Sequence, S.Element == (Key, Value) {
        try dictionary.merging(other, uniquingKeysWith: combine)
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        dictionary.reserveCapacity(minimumCapacity)
    }
}

extension BaseDictionary: @unchecked Sendable where Element: Sendable {}
extension BaseDictionary: Equatable where Value: Equatable {}
extension BaseDictionary: Hashable where Value: Hashable {}
extension BaseDictionary: Encodable where Key: Encodable, Value: Encodable {}
extension BaseDictionary: Decodable where Key: Decodable, Value: Decodable {}

extension BaseDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        dictionary.customMirror
    }

    public var debugDescription: String {
        dictionary.debugDescription
    }

    public var description: String {
        dictionary.description
    }
}

extension BaseDictionary: CVarArg {
    public var _cVarArgEncoding: [Int] {
        dictionary._cVarArgEncoding
    }
}
