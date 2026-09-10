//
//  SynchronizedDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// A thread-safe, synchronized dictionary.
public final class SynchronizedDictionary<Key: Hashable, Value>: Collection, ExpressibleByDictionaryLiteral {
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedDictionary", attributes: .concurrent)
    private var dictionary: [Key: Value]

    /// Creates a synchronized dictionary.
    public init() {
        dictionary = [:]
    }

    /// Creates a synchronized dictionary from the specified dictionary.
    public init(_ dictionary: [Key: Value]) {
        self.dictionary = dictionary
    }

    /// Creates an empty dictionary with preallocated space for at least the specified number of elements.
    public init(minimumCapacity: Int) {
        dictionary = .init(minimumCapacity: minimumCapacity)
    }

    /// Creates a new dictionary from the key-value pairs in the given sequence.
    public init<S>(uniqueKeysWithValues keysAndValues: S) where S: Sequence, S.Element == (Key, Value) {
        dictionary = .init(uniqueKeysWithValues: keysAndValues)
    }

    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        dictionary = try .init(keysAndValues, uniquingKeysWith: combine)
    }

    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S: Sequence {
        dictionary = try .init(grouping: values, by: keyForValue)
    }
    
    /// Creates a new dictionary from the key-value pairs in the given sequence.
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        dictionary = .init(uniqueKeysWithValues: elements)
    }
    
    /// Creates a new synchronized array by decoding from the given decoder.
    public required init(from decoder: Decoder) throws where Key: Decodable, Value: Decodable {
        dictionary = try .init(from: decoder)
    }
}

public extension SynchronizedDictionary {
    /// Returns the dictionary synchronious.
    var synchronized: [Key: Value] {
        get { queue.sync { self.dictionary } }
        set { queue.async(flags: .barrier) { self.dictionary = newValue } }
    }

    /// Edits each elements in the dictionary.
    func edit(_ edit: @escaping (inout [Key: Value]) -> Void) {
        queue.async(flags: .barrier) { edit(&self.dictionary) }
    }

    var startIndex: Dictionary<Key, Value>.Index {
        queue.sync { self.dictionary.startIndex }
    }

    var endIndex: Dictionary<Key, Value>.Index {
        queue.sync { self.dictionary.endIndex }
    }

    var isEmpty: Bool {
        queue.sync { self.dictionary.isEmpty }
    }

    var count: Int {
        queue.sync { self.dictionary.count }
    }
    
    func forEach(_ body: (Element) throws -> Void) rethrows {
        try queue.sync { try self.dictionary.forEach(body) }
    }

    func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        queue.sync { self.dictionary.index(after: i) }
    }

    func filter(_ isIncluded: (_ key: Key, _ value: Value) throws -> Bool) rethrows -> [Key: Value] {
        try queue.sync { try self.dictionary.filter(isIncluded) }
    }

    func map(_ transform: (_ key: Key, _ value: Value) throws -> Value) rethrows -> [Value] {
        try queue.sync { try self.dictionary.map(transform) }
    }

    var keys: [Key] {
        queue.sync { Array(self.dictionary.keys) }
    }

    var values: [Value] {
        queue.sync { Array(self.dictionary.values) }
    }

    subscript(key: Key) -> Value? {
        get { queue.sync { self.dictionary[key] } }
        set { queue.async(flags: .barrier) { [weak self] in self?.dictionary[key] = newValue } }
    }

    subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        queue.sync { self.dictionary[index] }
    }

    subscript(key: Key, default defaultValue: @autoclosure @escaping () -> Value) -> Value {
        get { queue.sync { self.dictionary[key, default: defaultValue()] } }
        set { queue.async(flags: .barrier) { [weak self] in self?.dictionary[key, default: defaultValue()] = newValue } }
    }

    func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        queue.sync { self.dictionary.index(forKey: key) }
    }

    func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) { [weak self] in self?.dictionary.removeValue(forKey: key) }
    }

    var first: Element? {
        queue.sync { self.dictionary.first }
    }

    func removeAll(keepingCapacity: Bool = false) {
        queue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeAll(keepingCapacity: keepingCapacity)
        }
    }
    
    func removeAll(keepingCapacity: Bool = false, completion: @escaping ()->()) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.dictionary.removeAll(keepingCapacity: keepingCapacity)
            DispatchQueue.main.async { completion() }
        }
    }
    
    func setValue(_ value: Value?, for key: Key, completion: (()->())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.dictionary[key] = value
            DispatchQueue.main.async { completion?() }
        }
    }

    func randomElement() -> Element? {
        queue.sync { self.dictionary.randomElement() }
    }

    func randomElement<T>(using generator: inout T) -> Element? where T: RandomNumberGenerator {
        queue.sync { self.dictionary.randomElement(using: &generator) }
    }

    func reserveCapacity(_ minimumCapacity: Int) {
        queue.async(flags: .barrier) { [weak self] in self?.dictionary.reserveCapacity(minimumCapacity) }
    }
}

extension SynchronizedDictionary: Equatable where Value: Equatable {
    public static func == (lhs: SynchronizedDictionary<Key, Value>, rhs: SynchronizedDictionary<Key, Value>) -> Bool {
        lhs.synchronized == rhs.synchronized
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

extension SynchronizedDictionary: CVarArg {
    public var _cVarArgEncoding: [Int] {
        synchronized._cVarArgEncoding
    }
}

extension SynchronizedDictionary: _ObjectiveCBridgeable {
    public func _bridgeToObjectiveC() -> NSDictionary {
        dictionary._bridgeToObjectiveC()
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSDictionary, result: inout SynchronizedDictionary?) {
        var dictionary: [Key: Value]?
        [Key: Value]._forceBridgeFromObjectiveC(source, result: &dictionary)
        result = dictionary.map { .init($0) }
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSDictionary, result: inout SynchronizedDictionary?) -> Bool {
        var dictionary: [Key: Value]?
        guard [Key: Value]._conditionallyBridgeFromObjectiveC(source, result: &dictionary),
              let dictionary else {
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

extension SynchronizedDictionary: Decodable where Key: Decodable, Value: Decodable { }
extension SynchronizedDictionary: Encodable where Key: Encodable, Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        try synchronized.encode(to: encoder)
    }
}
