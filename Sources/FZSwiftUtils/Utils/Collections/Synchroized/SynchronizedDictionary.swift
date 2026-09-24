//
//  SynchronizedDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// A thread-safe, synchronized dictionary.
public final class SynchronizedDictionary<Key: Hashable, Value>: Collection, ExpressibleByDictionaryLiteral {
    private let storage: SynchronizedStorage<[Key: Value]>

    /// Creates an empty synchronized dictionary.
    public init(usingMutex: Bool = false) {
        storage = SynchronizedStorage([:], usingMutex: usingMutex)
    }

    /// Creates a synchronized dictionary from the specified dictionary.
    public init(_ dictionary: [Key: Value], usingMutex: Bool = false) {
        storage = SynchronizedStorage(dictionary, usingMutex: usingMutex)
    }

    /// Creates an empty synchronized dictionary with preallocated space for at least the specified number of elements.
    public init(minimumCapacity: Int, usingMutex: Bool = false) {
        storage = SynchronizedStorage(.init(minimumCapacity: minimumCapacity), usingMutex: usingMutex)
    }

    /// Creates a synchronized dictionary from the key-value pairs in the given sequence.
    public init<S>(uniqueKeysWithValues keysAndValues: S, usingMutex: Bool = false) where S: Sequence, S.Element == (Key, Value) {
        storage = SynchronizedStorage(.init(uniqueKeysWithValues: keysAndValues), usingMutex: usingMutex)
    }

    /**
     Creates a synchronized dictionary from the key-value pairs in the given sequence, using a combining closure to determine the value for duplicate keys.

     - Parameters:
       - keysAndValues: A sequence of key-value pairs to use for the new dictionary.
       - combine: A closure that combines values for duplicate keys.
       - usingMutex: A Boolean value indicating whether the dictionary uses a mutex instead of a concurrent dispatch queue for synchronization.
     */
    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value, usingMutex: Bool = false) rethrows where S: Sequence, S.Element == (Key, Value) {
        storage = SynchronizedStorage(try .init(keysAndValues, uniquingKeysWith: combine), usingMutex: usingMutex)
    }

    /**
     Creates a synchronized dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.

     - Parameters:
       - values: The values to group.
       - keyForValue: A closure that returns a key for each element.
       - usingMutex: A Boolean value indicating whether the dictionary uses a mutex instead of a concurrent dispatch queue for synchronization.
     */
    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key, usingMutex: Bool = false) rethrows where Value == [S.Element], S: Sequence {
        storage = SynchronizedStorage(try .init(grouping: values, by: keyForValue), usingMutex: usingMutex)
    }

    /// Creates a synchronized dictionary from the specified dictionary literal.
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        storage = SynchronizedStorage(.init(uniqueKeysWithValues: elements), usingMutex: false)
    }

    /// Creates a synchronized dictionary by decoding from the given decoder.
    public required init(from decoder: Decoder) throws where Key: Decodable, Value: Decodable {
        storage = SynchronizedStorage(try .init(from: decoder), usingMutex: false)
    }
}

public extension SynchronizedDictionary {
    /// The underlying dictionary.
    var synchronized: [Key: Value] {
        get { storage.read { $0 } }
        set { storage.write { $0 = newValue } }
    }

    /// Edits the underlying dictionary while holding exclusive access to its storage.
    func edit(_ edit: (inout [Key: Value]) throws -> Void) rethrows {
        try storage.write(edit)
    }

    /// The position of the first element in the dictionary.
    var startIndex: Dictionary<Key, Value>.Index {
        storage.read { $0.startIndex }
    }

    /// The dictionary's past-the-end position.
    var endIndex: Dictionary<Key, Value>.Index {
        storage.read { $0.endIndex }
    }

    /// A Boolean value indicating whether the dictionary is empty.
    var isEmpty: Bool {
        storage.read { $0.isEmpty }
    }

    /// The number of key-value pairs in the dictionary.
    var count: Int {
        storage.read { $0.count }
    }

    /// Calls the given closure on each element in the dictionary in the same order as a for-in loop.
    func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.read { try $0.forEach(body) }
    }

    /// Returns the position immediately after the given index.
    func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        storage.read { $0.index(after: i) }
    }

    /// Returns a new dictionary containing the key-value pairs that satisfy the given predicate.
    func filter(_ isIncluded: (_ key: Key, _ value: Value) throws -> Bool) rethrows -> [Key: Value] {
        try storage.read { try $0.filter(isIncluded) }
    }

    /// Returns an array containing the results of mapping the given closure over the dictionary's elements.
    func map(_ transform: (_ key: Key, _ value: Value) throws -> Value) rethrows -> [Value] {
        try storage.read { try $0.map(transform) }
    }

    /// An array containing the dictionary's keys.
    var keys: [Key] {
        storage.read { Array($0.keys) }
    }

    /// An array containing the dictionary's values.
    var values: [Value] {
        storage.read { Array($0.values) }
    }

    /// Accesses the value associated with the given key.
    subscript(key: Key) -> Value? {
        get { storage.read { $0[key] } }
        set { storage.write { $0[key] = newValue } }
    }

    /// Accesses the key-value pair at the specified position.
    subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        storage.read { $0[index] }
    }

    /// Accesses the value associated with the given key, returning the given default value if the key isn't found.
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get { storage.read { $0[key, default: defaultValue()] } }
        set { storage.write { $0[key, default: defaultValue()] = newValue } }
    }

    /// Returns the index for the given key, or `nil` if the key isn't present in the dictionary.
    func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        storage.read { $0.index(forKey: key) }
    }

    /// Removes the given key and its associated value from the dictionary and returns the removed value.
    @discardableResult
    func removeValue(forKey key: Key) -> Value? {
        storage.write { $0.removeValue(forKey: key) }
    }

    /// The first key-value pair of the dictionary, or `nil` if the dictionary is empty.
    var first: Element? {
        storage.read { $0.first }
    }

    /// Removes all key-value pairs from the dictionary, optionally keeping its underlying storage.
    func removeAll(keepingCapacity: Bool = false) {
        storage.write { $0.removeAll(keepingCapacity: keepingCapacity) }
    }

    /// Sets the value for the given key, or removes the value if the specified value is `nil`.
    func setValue(_ value: Value?, for key: Key) {
        storage.write { $0[key] = value }
    }

    /// Returns a random key-value pair from the dictionary, or `nil` if the dictionary is empty.
    func randomElement() -> Element? {
        storage.read { $0.randomElement() }
    }

    /// Returns a random key-value pair from the dictionary using the given generator, or `nil` if the dictionary is empty.
    func randomElement<T>(using generator: inout T) -> Element? where T: RandomNumberGenerator {
        storage.read { $0.randomElement(using: &generator) }
    }

    /// Reserves enough space to store the specified number of key-value pairs.
    func reserveCapacity(_ minimumCapacity: Int) {
        storage.write { $0.reserveCapacity(minimumCapacity) }
    }
}

extension SynchronizedDictionary: Equatable where Value: Equatable {
    /// Returns a Boolean value indicating whether two synchronized dictionaries contain the same key-value pairs.
    public static func == (lhs: SynchronizedDictionary<Key, Value>, rhs: SynchronizedDictionary<Key, Value>) -> Bool {
        lhs.synchronized == rhs.synchronized
    }
}

extension SynchronizedDictionary: @unchecked Sendable where Element: Sendable {}

extension SynchronizedDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// A mirror that reflects the underlying dictionary.
    public var customMirror: Mirror {
        synchronized.customMirror
    }

    /// A textual representation of the dictionary suitable for debugging.
    public var debugDescription: String {
        synchronized.debugDescription
    }

    /// A textual representation of the dictionary.
    public var description: String {
        synchronized.description
    }
}

extension SynchronizedDictionary: CVarArg {
    /// The dictionary's C variable argument encoding.
    public var _cVarArgEncoding: [Int] {
        synchronized._cVarArgEncoding
    }
}

extension SynchronizedDictionary: Decodable where Key: Decodable, Value: Decodable {}

extension SynchronizedDictionary: Encodable where Key: Encodable, Value: Encodable {
    /// Encodes the dictionary into the given encoder.
    public func encode(to encoder: Encoder) throws {
        try synchronized.encode(to: encoder)
    }
}

extension SynchronizedDictionary: _ObjectiveCBridgeable {
    public func _bridgeToObjectiveC() -> NSDictionary {
        synchronized._bridgeToObjectiveC()
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSDictionary, result: inout SynchronizedDictionary?) {
        var dictionary: [Key: Value]?
        [Key: Value]._forceBridgeFromObjectiveC(source, result: &dictionary)
        result = dictionary.map { .init($0) }
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSDictionary, result: inout SynchronizedDictionary?) -> Bool {
        var dictionary: [Key: Value]?
        guard [Key: Value]._conditionallyBridgeFromObjectiveC(source, result: &dictionary), let dictionary else {
            result = nil
            return false
        }
        result = .init(dictionary)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSDictionary?) -> SynchronizedDictionary {
        .init([Key: Value]._unconditionallyBridgeFromObjectiveC(source))
    }
}
