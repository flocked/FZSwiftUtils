//
//  Dictionary+Difference.swift
//
//
//  Created by Florian Zand on 24.09.26.
//

import Foundation

public extension Dictionary where Value: Equatable {
    /**
     Returns the differences needed to transform this dictionary into the specified dictionary.

     - Parameter other: The dictionary to compare against.
     - Returns: The removed, added, and changed key-value pairs.
     */
    func difference(to other: Self) -> DictionaryDifference<Key, Value> {
        var removed: [Key: Value] = [:]
        var added: [Key: Value] = [:]
        var changed: [Key: DictionaryDifference<Key, Value>.Change] = [:]

        for (key, oldValue) in self {
            guard let newValue = other[key] else {
                removed[key] = oldValue
                continue
            }
            guard oldValue != newValue else { continue }
            changed[key] = .init(oldValue: oldValue, newValue: newValue)
        }

        for (key, newValue) in other where self[key] == nil {
            added[key] = newValue
        }

        return DictionaryDifference(removed: removed, added: added, changed: changed)
    }
    
    /// Returns a new dictionary by applying the specified difference.
    func applying(_ difference: DictionaryDifference<Key, Value>) -> Self {
        var result = self
        for key in difference.removed.keys {
            result.removeValue(forKey: key)
        }
        for (key, value) in difference.added {
            result[key] = value
        }
        for (key, change) in difference.changed {
            result[key] = change.newValue
        }
        return result
    }
}

/// The differences between two dictionaries.
public struct DictionaryDifference<Key: Hashable, Value: Equatable>: CustomStringConvertible, CustomDebugStringConvertible, Equatable {
    /// The key-value pairs that were removed.
    public let removed: [Key: Value]
    /// The key-value pairs that were added.
    public let added: [Key: Value]
    /// The key-value pairs whose values changed.
    public let changed: [Key: Change]
    
    /// The old and new values of a changed key-value pair.
    public struct Change: CustomStringConvertible, CustomDebugStringConvertible, Equatable {
        /// The previous value.
        public let oldValue: Value
        /// The new value.
        public let newValue: Value
        
        /// Creates a change with the specified old and new value.
        public init(oldValue: Value, newValue: Value) {
            self.oldValue = oldValue
            self.newValue = newValue
        }
        
        public var description: String {
            "\(oldValue) -> \(newValue)"
        }
        
        public var debugDescription: String {
            "\(String(reflecting: oldValue)) -> \(String(reflecting: newValue))"
        }
    }
    
    /// A Boolean value indicating whether no differences were found.
    public var isEmpty: Bool {
        removed.isEmpty && added.isEmpty && changed.isEmpty
    }
    
    /// Creates a dictionary difference with the specified removed, added, and changed key-value pairs.
    public init(removed: [Key: Value] = [:], added: [Key: Value] = [:], changed: [Key: Change] = [:]) {
        self.removed = removed
        self.added = added
        self.changed = changed
    }
    
    public var description: String {
        "(removed: \(removed), added: \(added), changed: \(changed))"
    }
    
    public var debugDescription: String {
        "(removed: \(String(reflecting: removed)), added: \(String(reflecting: added)), changed: \(String(reflecting: changed)))"
    }
}

extension DictionaryDifference: Hashable where Value: Hashable {}
extension DictionaryDifference: Encodable where Key: Encodable, Value: Encodable {}
extension DictionaryDifference: Decodable where Key: Decodable, Value: Decodable {}
extension DictionaryDifference: Sendable where Key: Sendable, Value: Sendable {}

extension DictionaryDifference.Change: Hashable where Value: Hashable { }
extension DictionaryDifference.Change: Encodable where Value: Encodable { }
extension DictionaryDifference.Change: Decodable where Value: Decodable { }
extension DictionaryDifference.Change: Sendable where Value: Sendable { }
