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
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed,
                              uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value]
    {
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
    
    /// The keys of the values that are different to the other dictionary.
    func difference(to dictionary: [Key : Value]) -> (removed: [Key], added: [Key], changed: [Key])  {
        let added: [Key] = self.keys.filter({ dictionary[$0] == nil })
        let removed: [Key] = dictionary.keys.filter({ self[$0] == nil })
        var changed: [Key] = []
        for val in dictionary {
            if let old = dictionary[val.key] as? (any Equatable), let new = self[val.key] as? (any Equatable), !old.isEqual(new) {
                changed.append(val.key)
            }
        }
        return (removed, added, changed)
    }
    
    /// Removes the values of the specified keys.
    mutating func remove<S: Sequence<Key>>(_ keys: S) {
        setValue(nil, for: keys)
    }
    
    /**
     Sets the value of the specified keys.
     
     - Parameters:
        - value: The new value.
        - keys: The keys.
     */
    mutating func setValue<S: Sequence<Key>>(_ value: Value?, for keys: S) {
        keys.forEach({ self[$0] = value })
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
