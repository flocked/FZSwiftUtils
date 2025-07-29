//
//  WeakDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation
import SwiftUI

struct WeakDictionary<Key: AnyObject & Hashable, Value>: Collection, Sequence, ExpressibleByDictionaryLiteral {
    public typealias Element = (key: Key, value: Value)

    var dictionary: [Weak<Key>: Value]

    public init(dictionaryLiteral elements: (Value, Key)...) {
        dictionary = [:]
        for element in elements {
            dictionary[Weak(element.1)] = element.0
        }
    }

    public init(dict: [Key: Value] = [Key: Value]()) {
        dictionary = dict.mapKeys({ Weak($0)})
    }

    public init() {
        dictionary = [:]
    }

    public init(minimumCapacity: Int) {
        dictionary = .init(minimumCapacity: minimumCapacity)
    }

    public init<S>(uniqueKeysWithValues keysAndValues: S) where S: Sequence, S.Element == (Key, Value) {
        dictionary = Dictionary(uniqueKeysWithValues: keysAndValues).mapKeys({ Weak($0)})
    }

    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        dictionary = try Dictionary(keysAndValues, uniquingKeysWith: combine).mapKeys({ Weak($0)})
    }

    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S: Sequence {
        dictionary = (try Dictionary(grouping: values, by: keyForValue)).mapKeys({ Weak($0)})
    }

    public mutating func edit(_ edit: @escaping (inout [Key: Value]) -> Void) {
        var dic = dictionary.nonNil
        edit(&dic)
        dictionary = dic.mapKeys({Weak($0)})
    }
    
    mutating func upateNonNil() {
        dictionary = dictionary.filter({$0.key.object != nil })
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
        dictionary.nonNil.startIndex
    }

    public var endIndex: Dictionary<Key, Value>.Index {
        dictionary.nonNil.endIndex
    }

    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        dictionary.nonNil.index(after: i)
    }

    public func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        dictionary.nonNil.index(forKey: key)
    }

    public subscript(position: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        dictionary.nonNil[position]
    }

    public subscript(key: Key) -> Value? {
        set(newValue) {
            if let key = dicKey(for: key) {
                dictionary[key] = newValue
            } else {
                dictionary[Weak(key)] = newValue
            }
        }
        get {
            guard let key = dicKey(for: key) else { return nil }
            return dictionary[key]
        }
    }

    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            if let key = dicKey(for: key) {
                return dictionary[key, default: defaultValue()]
            } else {
                return dictionary[Weak(key), default: defaultValue()]
            }
        }
        set {
            if let key = dicKey(for: key) {
                dictionary[key, default: defaultValue()] = newValue
            } else {
                dictionary[Weak(key), default: defaultValue()] = newValue
            }
        }
    }
    
    func dicKey(for key: Key) -> Weak<Key>? {
        dictionary.keys.first(where: {$0.object === key })
    }

    public var keys: [Key] {
        Array(dictionary.keys.compactMap({$0.object}))
    }

    public var values: [Value] {
        Array(dictionary.values)
    }

    public var first: WeakDictionary.Element? {
        guard let first = dictionary.first, let key = first.key.object else { return nil }
        return (key, first.value)
    }

    public mutating func removeValue(forKey key: Key) {
        guard let key = dicKey(for: key) else { return }
        dictionary.removeValue(forKey: key)
    }

    public mutating func removeAll(keepingCapacity: Bool = false) {
        dictionary.removeAll(keepingCapacity: keepingCapacity)
    }

    @discardableResult
    public mutating func remove(at index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        var dic = dictionary.nonNil
        let removed = dic.remove(at: index)
        dictionary = dic.mapKeys({Weak($0)})
        return removed
    }

    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        guard let key = dicKey(for: key) else { return nil }
        return dictionary.updateValue(value, forKey: key)
    }

    public mutating func merge(_ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        var dic = dictionary.nonNil
        try dic.merge(other, uniquingKeysWith: combine)
        dictionary = dic.mapKeys({Weak($0)})
    }

    public mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        var dic = dictionary.nonNil
        try dic.merge(other, uniquingKeysWith: combine)
        dictionary = dic.mapKeys({Weak($0)})
    }

    public func merging(_ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key: Value] {
        try dictionary.nonNil.merging(other, uniquingKeysWith: combine)
    }

    public func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key: Value] where S: Sequence, S.Element == (Key, Value) {
        try dictionary.nonNil.merging(other, uniquingKeysWith: combine)
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        dictionary.reserveCapacity(minimumCapacity)
    }
    
    /// Removes all keys where the weak value is `nil`.
    mutating func reap() {
        dictionary = dictionary.filter({$0.key.object != nil})
    }
    
    /// The dictionary with keys whose weak object isn't `nil`.
    var nonNil: [Key: Value] {
        dictionary.compactMapKeys({ $0.object })
    }
    
    /**
     Transforms keys without modifying values.

     - Parameter transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.

     - Note: The collection of transformed keys must not contain duplicates.
     */
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed) rethrows -> [Transformed: Value] {
        try .init(uniqueKeysWithValues: map { try (transform($0.key), $0.value) })
    }

    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value] {
        try .init(map { try (transform($0.key), $0.value) }, uniquingKeysWith: combine )
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - retainLastOccurences: A Boolean value indicating whether if an key occurs more than once, only the last instance will be included.
     */
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed, retainLastOccurences: Bool) rethrows -> [Transformed: Value] {
        try mapKeys(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }

    /**
     Transforms keys without modifying values. Drops (key, value) pairs where the transform results in a `nil` key.

     - Parameter transform: A closure that accepts each key of the dictionary as its parameter and returns a potential transformed key of the same or of a different type.

     - Note: The collection of transformed keys must not contain duplicates.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?) rethrows -> [Transformed: Value] {
        try .init(uniqueKeysWithValues: compactMap { key, value in try transform(key).map { ($0, value) } })
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value] {
        try .init(compactMap { if let key = try transform($0.key) { return (key, $0.value) } else { return nil } }, uniquingKeysWith: combine)
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - retainLastOccurences: A Boolean value indicating whether if an key occurs more than once, only the last instance will be included.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed, retainLastOccurences: Bool) rethrows -> [Transformed: Value] {
        try compactMapKeys(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /**
     Returns a new dictionary containing the keys of this dictionary with the values transformed by the given closure.
     
     - Parameter transform: A closure that transforms a value. transform accepts each value of the dictionary as its parameter and returns a transformed value of the same or of a different type.
     - Returns: A dictionary containing the keys and transformed values of this dictionary.
     */
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        try .init(uniqueKeysWithValues: map { key, val in (key, try transform(val))  } )
    }
    
    /**
     Returns a new dictionary containing the keys of this dictionary with the values transformed by the given closure.
     
     - Parameter transform: A closure that transforms a value. transform accepts each value of the dictionary as its parameter and returns a transformed value of the same or of a different type.
     - Returns: A dictionary containing the keys and transformed values of this dictionary.
     */
    func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        try .init(uniqueKeysWithValues: compactMap { key, value in try transform(value).map { (key, $0) } })
    }
    
    /**
     Transforms keys and values.
     
     - Parameter transform: A closure that accepts each key and value of the dictionary as its parameter and returns a transformed key and value.
     
     - Note: The collection of transformed keys must not contain duplicates.
     */
    func mapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V))) -> Dictionary<K, V> {
        Dictionary<K, V>(uniqueKeysWithValues: map(transform))
    }
    
    /**
     Transforms keys and values.

     - Parameters:
        - transform: A closure that accepts each key and value of the dictionary as its parameter and returns a transformed key and value.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func mapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)), uniquingKeysWith combine: (V, V) throws -> V) rethrows -> Dictionary<K, V> {
        try .init(map(transform), uniquingKeysWith: combine)
    }

    /**
     Transforms keys and values. Drops (key, value) pairs where the transform results in a `nil` key.
     
     - Parameter transform: A closure that accepts each key and value of the dictionary as its parameter and returns a potential transformed key and value.
     
     - Note: The collection of transformed keys must not contain duplicates.
     */
    func compactMapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)?)) -> Dictionary<K, V> {
        .init(uniqueKeysWithValues: compactMap(transform))
    }
    
    /**
     Transforms keys and values. Drops (key, value) pairs where the transform results in a `nil` key.

     - Parameters:
        - transform: A closure that accepts each key and value of the dictionary as its parameter and returns a potential transformed key and value.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func compactMapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)), uniquingKeysWith combine: (V, V) throws -> V) rethrows -> Dictionary<K, V> {
        try .init(compactMap(transform), uniquingKeysWith: combine)
    }
    
    /// Returns values for the specified keys.
    func values<S>(for keys: S) -> [(key: Key, value: Value)] where S: Sequence<Key> {
        keys.compactMap({ if let value = self[$0] { return ($0, value) } else { return nil } })
    }
    
    /// Returns keys for the specified values.
    func keys<S>(with values: S) -> [Key] where S: Sequence<Value>, Value: Equatable {
        filter({values.contains($0.value) }).compactMap({$0.key})
    }
    
    /// Returns keys for the specified values.
    func keys<S>(with values: S) -> [Key] where S: Sequence<Value>, Value: Equatable, Key: Comparable {
        filter({values.contains($0.value) }).compactMap({$0.key}).sorted()
    }
    
    /// Returns values for the specified keys.
    subscript(keys: [Key]) -> [(key: Key, value: Value)] {
        values(for: keys)
    }
    
    /// The keys of the values that are different to the other dictionary.
    func difference(to dictionary: [Key : Value]) -> (removed: [Key], added: [Key], changed: [Key])  {
        let checkChanged = ((dictionary.first?.value ?? first?.value) as? (any Equatable)) != nil
        let added: [Key] = self.keys.filter({ dictionary[$0] == nil })
        let removed: [Key] = dictionary.keys.filter({ self[$0] == nil })
        let changed = checkChanged ? reduce(into: [Key]()) { partialResult, val in
            if let old = dictionary[val.key] as? (any Equatable), let new = val.value as? (any Equatable), !old.isEqual(new) {
                partialResult.append(val.key)
            }
        } : []
        return (removed, added, changed)
    }
    
    /**
     Sets the specified value for the keys.
     
     - Parameters:
        - value: The new value.
        - keys: The keys for the new value
     */
    mutating func setValue<S>(_ value: Value?, for keys: S) where S: Sequence<Key> {
        keys.forEach({ self[$0] = value })
    }
    
    /// Removes the values of the specified keys.
    mutating func remove<S>(_ keys: S) where S: Sequence<Key>  {
        setValue(nil, for: keys)
    }
}

extension WeakDictionary: @unchecked Sendable where Element: Sendable {}
extension WeakDictionary: Equatable where Value: Equatable {}
extension WeakDictionary: Hashable where Value: Hashable {}
// extension WeakDictionary: Encodable where Key: Encodable, Value: Encodable {}
// extension WeakDictionary: Decodable where Key: Decodable, Value: Decodable {}

extension WeakDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
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

extension WeakDictionary: CVarArg {
    public var _cVarArgEncoding: [Int] {
        dictionary._cVarArgEncoding
    }
}
