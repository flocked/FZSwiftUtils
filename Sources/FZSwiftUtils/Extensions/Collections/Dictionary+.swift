//
//  Dictionary+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Dictionary {
    /// Edits all values.
    mutating func editEach(_ body: (_ key: Key, _ value: inout Value) throws -> Void) rethrows {
        for keyVal in self {
            var value = keyVal.value
            try body(keyVal.key, &value)
            self[keyVal.key] = value
        }
    }
    
    
    /// Returns values for the specified keys.
    subscript(keys: [Key]) -> [(key: Key, value: Value)] {
        values(for: keys)
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
        try .init(
            map { try (transform($0.key), $0.value) },
            uniquingKeysWith: combine
        )
    }

    /**
     Transforms keys without modifying values. Drops (key, value) pairs where the transform results in a `nil` key.

     - Parameter transform: A closure that accepts each key of the dictionary as its parameter and returns a potential transformed key of the same or of a different type.

     - Note: The collection of transformed keys must not contain duplicates.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?) rethrows -> [Transformed: Value] {
        try .init(
            uniqueKeysWithValues: compactMap { key, value in
                try transform(key).map { ($0, value) }
            }
        )
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value] {
        try .init(compactMap { if let key = try transform($0.key) { return (key, $0.value) } else { return nil } }, uniquingKeysWith: combine
        )
    }
    
    /**
     Returns a new dictionary containing the keys of this dictionary with the values transformed by the given closure.
     
     - Parameter transform: A closure that transforms a value. transform accepts each value of the dictionary as its parameter and returns a transformed value of the same or of a different type.
     - Returns: A dictionary containing the keys and transformed values of this dictionary.
     */
    func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> Dictionary<Key, T> {
        try .init(
            uniqueKeysWithValues: compactMap { key, value in
                try transform(value).map { (key, $0) }
            }
        )
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
        try Dictionary<K, V>(map(transform), uniquingKeysWith: combine)
    }

    /**
     Transforms keys and values. Drops (key, value) pairs where the transform results in a `nil` key.
     
     - Parameter transform: A closure that accepts each key and value of the dictionary as its parameter and returns a potential transformed key and value.
     
     - Note: The collection of transformed keys must not contain duplicates.
     */
    func compactMapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)?)) -> Dictionary<K, V> {
        Dictionary<K, V>(uniqueKeysWithValues: compactMap(transform))
    }
    
    /**
     Transforms keys and values. Drops (key, value) pairs where the transform results in a `nil` key.

     - Parameters:
        - transform: A closure that accepts each key and value of the dictionary as its parameter and returns a potential transformed key and value.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func compactMapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)), uniquingKeysWith combine: (V, V) throws -> V) rethrows -> Dictionary<K, V> {
        try Dictionary<K, V>(compactMap(transform), uniquingKeysWith: combine)
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

public extension Dictionary where Value: Equatable {
    /// The keys of the values that are different to the other dictionary.
    func difference(to dictionary: [Key : Value]) -> (removed: [Key], added: [Key], changed: [Key]) {
        let added: [Key] = self.keys.filter({ dictionary[$0] == nil })
        let removed: [Key] = dictionary.keys.filter({ self[$0] == nil })
        var changed: [Key] = []
        for val in dictionary {
            if let old = dictionary[val.key], let new = self[val.key], old != new {
                changed.append(val.key)
            }
        }
        return (removed, added, changed)
    }
}

public extension Dictionary {
    /// The dictionary as `CFDictionary`.
    var cfDictionary: CFDictionary {
        self as CFDictionary
    }

    /// The dictionary as `NSDictionary`.
    var nsDictionary: NSDictionary {
        self as NSDictionary
    }
}

public extension NSDictionary {
    /// The dictionary as `Dictionary`.
    func toDictionary() -> [String: Any] {
        var swiftDictionary = [String: Any]()
        for key: Any in allKeys {
            let stringKey = key as! String
            if let keyValue = value(forKey: stringKey) {
                swiftDictionary[stringKey] = keyValue
            }
        }
        return swiftDictionary
    }

    /// The dictionary as `CFDictionary`.
    var cfDictionary: CFDictionary {
        self as CFDictionary
    }
}
