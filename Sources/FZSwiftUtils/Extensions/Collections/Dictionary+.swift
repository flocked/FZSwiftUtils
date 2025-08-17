//
//  Dictionary+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Dictionary {
    /// Edits each value in the dictionary.
    mutating func editEach(_ body: (_ key: Key, _ value: inout Value) throws -> Void) rethrows {
        for keyVal in self {
            var value = keyVal.value
            try body(keyVal.key, &value)
            self[keyVal.key] = value
        }
    }
    
    subscript<RawKey: RawRepresentable>(key: RawKey) -> Value? where RawKey.RawValue == Dictionary.Key {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue  }
    }
    
    subscript<IdentifiableKey: Identifiable>(key: IdentifiableKey) -> Value? where IdentifiableKey.ID == Dictionary.Key {
        get { self[key.id] }
        set { self[key.id] = newValue  }
    }
    
    /**
     Initializes an ordered dictionary from a sequence of key-value pairs.

     - Parameters:
        - keysAndValues: A sequence of key-value pairs to use for the new ordered dictionary. Every key in `keysAndValues` must be unique.
        - retainLastOccurences: A Boolean value indicating whether if an key occurs more than once, only the last instance will be included.
     */
    init<S: Sequence>(_ keysAndValues: S, retainLastOccurences: Bool) where S.Element == (Key, Value) {
        self = Self(keysAndValues) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /// Returns values for the specified keys.
    subscript<S>(keys: S) -> [(key: Key, value: Value)] where S: Sequence<Key> {
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
     Transforms the keys of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - retainLastOccurences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and the same values.
     */
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed, retainLastOccurences: Bool = true) rethrows -> [Transformed: Value] {
        try mapKeys(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with transformed keys and combined values for duplicates.
     */
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value] {
        try .init(map { try (transform($0.key), $0.value) }, uniquingKeysWith: combine )
    }
    
    /**
     Transforms the keys of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - retainLastOccurences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and the same values.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?, retainLastOccurences: Bool = true) rethrows -> [Transformed: Value] {
        try compactMapKeys(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, discarding any keys that map to `nil` and combining values for duplicate keys.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with non-nil transformed keys and combined values for duplicates.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value] {
        try .init(compactMap { if let key = try transform($0.key) { return (key, $0.value) } else { return nil } }, uniquingKeysWith: combine)
    }
    
    /**
     Transforms the values of the dictionary using the given closure.

     - Parameter transform: The closure that transforms a value of the dictionary.
     - Returns: A new dictionary with the same keys and transformed values.
     */
    func mapValues<Transformed>(_ transform: (Value) throws -> Transformed) rethrows -> [Key: Transformed] {
        try .init(uniqueKeysWithValues: map { key, val in (key, try transform(val))  } )
    }
    

    /**
     Transforms the values of the dictionary using the given closure, discarding any values that map to `nil`.

     - Parameter transform: The closure that transforms a value of the dictionary.
     - Returns: A new dictionary with the same keys and non-nil transformed values.
     */
    func compactMapValues<Transformed>(_ transform: (Value) throws -> Transformed?) rethrows -> [Key: Transformed] {
        try .init(uniqueKeysWithValues: compactMap { key, value in try transform(value).map { (key, $0) } })
    }
    
    /**
     Transforms both keys and values of the dictionary.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - retainLastOccurences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and values.
     */
    func mapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)), retainLastOccurences: Bool = true) -> [K:V] {
        mapKeyValues(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /**
     Transforms both keys and values of the dictionary, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with transformed keys and values, combining duplicates as specified.
     */
    func mapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)), uniquingKeysWith combine: (V, V) throws -> V) rethrows -> [K:V] {
        try .init(map(transform), uniquingKeysWith: combine)
    }
    
    /**
     Transforms both keys and values of the dictionary.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - retainLastOccurences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and values.
     */
    func compactMapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)?), retainLastOccurences: Bool = true) -> [K:V] {
        compactMapKeyValues(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /**
     Transforms both keys and values of the dictionary, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with transformed keys and values, combining duplicates as specified.
     */
    func compactMapKeyValues<K: Hashable, V>(_ transform: ((key: Key, value: Value))->((K, V)?), uniquingKeysWith combine: (V, V) throws -> V) rethrows -> [K:V] {
        try .init(compactMap(transform), uniquingKeysWith: combine)
    }
    
    /// The keys of the values that are different to the other dictionary.
    func difference(to other: Self) -> (removed: [Key], added: [Key], changed: [Key])  {
        let checkChanged = ((other.first?.value ?? first?.value) as? (any Equatable)) != nil
        let added: [Key] = self.keys.filter({ other[$0] == nil })
        let removed: [Key] = other.keys.filter({ self[$0] == nil })
        let changed = checkChanged ? reduce(into: [Key]()) { partialResult, val in
            if let old = other[val.key] as? (any Equatable), let new = val.value as? (any Equatable), !old.isEqual(new) {
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
    
    /**
     Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
     
     - Parameters:
        - values: A sequence of values to group into a dictionary.
        - keyForValue: A closure that returns a potential key for each element in `values`.
     */
    init<S>(grouping values: S, byNonNil keyForValue: (S.Element) throws -> Key?) rethrows where Value == [S.Element], S : Sequence {
        self = try values.reduce(into: [:]) {
            if let key = try keyForValue($1) {
                $0[key, default: []].append($1)
            }
        }
    }
    
    /// The dictionary as `CFDictionary`.
    var cfDictionary: CFDictionary {
        self as CFDictionary
    }

    /// The dictionary as `NSDictionary`.
    var nsDictionary: NSDictionary {
        self as NSDictionary
    }
}

public extension Dictionary where Key: OptionalProtocol, Key.Wrapped: Hashable {
    /// Returns the dictionary with non optional keys.
    @_disfavoredOverload
    var nonNil: [Key.Wrapped: Value] {
        compactMapKeys({ $0.optional })
    }
}

public extension Dictionary where Value: OptionalProtocol {
    /// Returns the dictionary with non optional values.
    var nonNil: [Key: Value.Wrapped] {
        compactMapValues({ $0.optional })
    }
}

public extension Dictionary where Key: OptionalProtocol, Key.Wrapped: Hashable, Value: OptionalProtocol {
    /// Returns the dictionary with non optional keys and values
    var nonNil: [Key.Wrapped: Value.Wrapped] {
        compactMapKeys({ $0.optional }).compactMapValues({ $0.optional })
    }
}

public extension Dictionary where Value: Equatable {
    /// The keys of the values that are different to the other dictionary.
    func difference(to other: Self) -> (removed: [Key], added: [Key], changed: [Key]) {
        let added: [Key] = keys.filter({ other[$0] == nil })
        let removed: [Key] = other.keys.filter({ self[$0] == nil })
        let changed = keys.compactMap { key -> Key? in
            guard let otherValue = other[key] else { return nil }
            return (self[key] != otherValue) ? key : nil
        }
        return (removed, added, changed)
    }
}

extension Dictionary where Key: Identifiable {
    @_disfavoredOverload
    public subscript(key: Key.ID) -> Value? {
        first(where: { $0.key.id == key })?.value
    }
}

extension Dictionary where Key: RawRepresentable {
    @_disfavoredOverload
    public subscript(key: Key.RawValue) -> Value? {
        get {
            guard let key = Key(rawValue: key) else { return nil }
            return self[key]
        }
        set {
            guard let key = Key(rawValue: key) else { return }
            self[key] = newValue
        }
    }
}

public extension NSDictionary {
    /// The dictionary as `Dictionary`.
    func toDictionary() -> [String: Any] {
        reduce(into: [:]) {
            $0[$1.key as? String ?? "\($1.key)"] = $1.value
        }
    }

    /// The dictionary as `CFDictionary`.
    var cfDictionary: CFDictionary {
        self as CFDictionary
    }
}

extension Dictionary where Value == Any {
    /**
     A Boolean value indicating whether the dictionary is equatable to another dictionary.
     
     - Parameter other: The dictionary to compare.
     - Returns: Returns `true` if the dictionary is equal to the other dictionary; or `false` if it isn't equal.
     */
    public func isEqual(to other: Self) -> Bool {
        guard self.count == other.count else { return false }
        for (key, val1) in self {
            guard let val2 = other[key] else { return false }
            if let val1 = val1 as? (any Equatable), let val2 = val2 as? (any Equatable), !val1.isEqual(val2) {
                return false
            }
            return val1 as AnyObject !== val2 as AnyObject
        }
        return true
    }
}
