//
//  SynchronizedDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// A synchronized dictionary.
public class SynchronizedDictionary<Key: Hashable, Value>: Collection, ExpressibleByDictionaryLiteral {
    public typealias Element = (key: Key, value: Value)

    public required init(dictionaryLiteral elements: (Value, Key)...) {
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

    private var dictionary: [Key: Value]
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedDictionary",
                                      attributes: .concurrent)
}

public extension SynchronizedDictionary {
    var synchronized: [Key: Value] {
        var dictionary: [Key: Value] = [:]
        queue.sync {
            dictionary = self.dictionary
        }
        return dictionary
    }

    func edit(_ edit: @escaping (inout [Key: Value]) -> Void) {
        queue.async(flags: .barrier) {
            edit(&self.dictionary)
        }
    }

    var startIndex: Dictionary<Key, Value>.Index {
        queue.sync {
            self.dictionary.startIndex
        }
    }

    var endIndex: Dictionary<Key, Value>.Index {
        queue.sync {
            self.dictionary.endIndex
        }
    }

    var isEmpty: Bool {
        queue.sync {
            self.dictionary.isEmpty
        }
    }

    var count: Int {
        queue.sync {
            self.dictionary.count
        }
    }

    func forEach(_ body: ((key: Key, value: Value)) throws -> Void) rethrows {
        try queue.sync {
            try self.dictionary.forEach(body)
        }
    }

    func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        queue.sync {
            self.dictionary.index(after: i)
        }
    }

    func filter(_ isIncluded: (_ key: Key, _ value: Value) throws -> Bool) rethrows -> [Key: Value] {
        try queue.sync {
            try self.dictionary.filter(isIncluded)
        }
    }

    func map(_ transform: (_ key: Key, _ value: Value) throws -> Value) rethrows -> [Value] {
        try queue.sync {
            try self.dictionary.map(transform)
        }
    }

    var keys: [Key] {
        queue.sync { Array(self.dictionary.keys) }
    }

    var values: [Value] {
        queue.sync {
            Array(self.dictionary.values)
        }
    }

    subscript(key: Key) -> Value? {
        get {
            queue.sync {
                self.dictionary[key]
            }
        }
        set(newValue) {
            queue.async(flags: .barrier) { [weak self] in
                self?.dictionary[key] = newValue
            }
        }
    }

    subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        queue.sync {
            self.dictionary[index]
        }
    }

    subscript(key: Key, default defaultValue: @autoclosure @escaping () -> Value) -> Value {
        get {
            queue.sync {
                self.dictionary[key, default: defaultValue()]
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.dictionary[key, default: defaultValue()] = newValue
            }
        }
    }

    func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        queue.sync {
            self.dictionary.index(forKey: key)
        }
    }

    func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    var first: SynchronizedDictionary.Element? {
        queue.sync {
            self.dictionary.first
        }
    }

    func removeAll(keepingCapacity: Bool = false) {
        queue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeAll(keepingCapacity: keepingCapacity)
        }
    }

    func randomElement() -> SynchronizedDictionary.Element? {
        queue.sync {
            self.dictionary.randomElement()
        }
    }

    func randomElement<T>(using generator: inout T) -> SynchronizedDictionary.Element? where T: RandomNumberGenerator {
        queue.sync {
            self.dictionary.randomElement(using: &generator)
        }
    }

    func reserveCapacity(_ minimumCapacity: Int) {
        queue.async(flags: .barrier) { [weak self] in
            self?.dictionary.reserveCapacity(minimumCapacity)
        }
    }
}

extension SynchronizedDictionary: @unchecked Sendable where Element: Sendable {}

extension SynchronizedDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        synchronized.customMirror
    }

    public var debugDescription: String {
        synchronized.debugDescription
    }

    public var description: String {
        synchronized.description
    }
}
