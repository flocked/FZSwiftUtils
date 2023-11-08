//
//  BaseDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation
import SwiftUI

/// A synchronized dictionary.
public struct BaseDictionary< Key: Hashable, Value>: Collection, Sequence, ExpressibleByDictionaryLiteral {
    public typealias Element = (key: Key, value: Value)

    
    public init(dictionaryLiteral elements: (Value, Key)...) {
        self.dictionary = [:]
        for element in elements {
            self.dictionary[element.1] = element.0
        }
    }
    
    public init(dict: [Key: Value] = [Key:Value]()) {
        self.dictionary = dict
    }
    
    public init() {
        self.dictionary = [:]
    }
    
    public init(minimumCapacity: Int) {
        self.dictionary = .init(minimumCapacity: minimumCapacity)
    }
    
    public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value) {
        self.dictionary = .init(uniqueKeysWithValues: keysAndValues)
    }
    
    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        self.dictionary = try .init(keysAndValues, uniquingKeysWith: combine)
    }
    
    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S : Sequence {
        self.dictionary = try .init(grouping: values, by: keyForValue)
    }

    private var dictionary: [Key:Value]
}

public extension BaseDictionary {
    mutating func edit(_ edit: @escaping (inout [Key:Value])->()) {
        edit(&self.dictionary)
    }
    
    var startIndex: Dictionary<Key, Value>.Index {
        return self.dictionary.startIndex
    }
    
    var endIndex: Dictionary<Key, Value>.Index {
        return self.dictionary.endIndex
    }
    
    var isEmpty: Bool {
        return self.dictionary.isEmpty
    }
    
    var count: Int {
        return self.dictionary.count
    }
    
    var capacity: Int {
        self.dictionary.capacity
    }
    
    func forEach(_ body: ((key: Key, value: Value)) throws -> Void) rethrows {
        try self.dictionary.forEach(body)
    }
    
    func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        return self.dictionary.index(after: i)
    }
    
    func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        return self.dictionary.index(forKey: key)
    }
    
    subscript(position: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        self.dictionary[position]
    }

    func filter(_ isIncluded: ((_ key: Key, _ value: Value) throws -> Bool)) rethrows -> [Key: Value] {
        return try self.dictionary.filter(isIncluded)
    }
    
    func map(_ transform: ((_ key: Key, _ value: Value) throws -> Value)) rethrows -> [Value] {
        return try self.dictionary.map(transform)
    }
    
    var keys: [Key] {
        Array(self.dictionary.keys)
    }
    
    var values: [Value] {
        Array(self.dictionary.values)
    }

    subscript(key: Key) -> Value? {
        set(newValue) {
            self.dictionary[key] = newValue
        }
        get {
            return self.dictionary[key]
        }
    }
    
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get { self.dictionary[key, default: defaultValue()] }
        set { self.dictionary[key, default: defaultValue()] = newValue }
    }
    
    mutating func removeValue(forKey key: Key) {
        self.dictionary.removeValue(forKey: key)
    }

    mutating func removeAll(keepingCapacity: Bool = false) {
        self.dictionary.removeAll(keepingCapacity: keepingCapacity)
    }
    
    @discardableResult
    mutating func remove(at index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        self.dictionary.remove(at: index)
    }
    
    var first: BaseDictionary.Element? {
        self.dictionary.first
    }
    
    func randomElement() -> Self.Element? {
        self.dictionary.randomElement()
    }
    func randomElement<T>(using generator: inout T) -> Self.Element? where T : RandomNumberGenerator {
        self.dictionary.randomElement(using: &generator)
    }
    
    @discardableResult
    mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        dictionary.updateValue(value, forKey: key)
    }
    
    mutating func merge(_ other: [Key : Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try dictionary.merge(other, uniquingKeysWith: combine)
    }
    
    mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        try dictionary.merge(other, uniquingKeysWith: combine)
    }
    
    func merging(_ other: [Key : Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key : Value] {
        try dictionary.merging(other, uniquingKeysWith: combine)
    }
    
    func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key : Value] where S : Sequence, S.Element == (Key, Value) {
        try dictionary.merging(other, uniquingKeysWith: combine)
    }
    
    mutating func reserveCapacity(_ minimumCapacity: Int) {
        dictionary.reserveCapacity(minimumCapacity)
    }
}

extension BaseDictionary: @unchecked Sendable where Element: Sendable { }

extension BaseDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        return dictionary.customMirror
    }

    public var debugDescription: String {
        return dictionary.debugDescription
    }
    
    public var description: String {
        return dictionary.description
    }
}

extension BaseDictionary: Equatable where Value: Equatable { }
extension BaseDictionary: Hashable where Value: Hashable { }

extension BaseDictionary: Encodable where Key: Encodable, Value: Encodable { }
extension BaseDictionary: Decodable where Key: Decodable, Value: Decodable { }

extension BaseDictionary: CVarArg {
    public var _cVarArgEncoding: [Int] {
        return dictionary._cVarArgEncoding
    }
}
