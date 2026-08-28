//
//  OrderedDictionary.swift
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// An ordered collection of key-value pairs with unique keys.
public struct OrderedDictionary<Key: Hashable, Value>: RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    private var orderedKeys: OrderedSet<Key>
    private var orderedValues: ContiguousArray<Value>

    public typealias Element = (key: Key, value: Value)

    public init() {
        orderedKeys = []
        orderedValues = []
    }

    public init(minimumCapacity: Int) {
        self.init()
        reserveCapacity(minimumCapacity)
    }

    public init(unsorted: Dictionary<Key, Value>, areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try self.init(uniqueKeysWithValues: Array(unsorted).sorted(by: areInIncreasingOrder))
    }

    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S) where S.Element == Element {
        self.init(uniqueKeysWithValues: keysAndValues, minimumCapacity: keysAndValues.underestimatedCount)
    }

    public init<S: Sequence>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S.Element == Element {
        self.init(minimumCapacity: keysAndValues.underestimatedCount)
        for (key, value) in keysAndValues {
            if let index = orderedKeys.index(of: key) {
                orderedValues[index] = try combine(orderedValues[index], value)
            } else {
                orderedKeys.append(key)
                orderedValues.append(value)
            }
        }
        _assertInvariant()
    }

    public init<S: Sequence>(_ keysAndValues: S, retainLastOccurrences: Bool) where S.Element == Element {
        self = Self(keysAndValues) { first, last in retainLastOccurrences ? last : first }
    }

    private init<S: Sequence>(uniqueKeysWithValues keysAndValues: S, minimumCapacity: Int? = nil) where S.Element == Element {
        self.init(minimumCapacity: minimumCapacity ?? keysAndValues.underestimatedCount)
        for (key, value) in keysAndValues {
            precondition(!orderedKeys.contains(key), "[OrderedDictionary] Sequence contains duplicate key (\(key))")
            orderedKeys.append(key)
            orderedValues.append(value)
        }
        _assertInvariant()
    }

    private init(keys: OrderedSet<Key>, values: ContiguousArray<Value>) {
        orderedKeys = keys
        orderedValues = values
        _assertInvariant()
    }

    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }

    public init(arrayLiteral elements: Element...) {
        self.init(uniqueKeysWithValues: elements)
    }

    public var startIndex: Int { orderedKeys.startIndex }
    public var endIndex: Int { orderedKeys.endIndex }
    public var count: Int { orderedKeys.count }
    public var isEmpty: Bool { orderedKeys.isEmpty }
    public var indices: CountableRange<Int> { startIndex..<endIndex }

    public func index(after i: Int) -> Int {
        orderedKeys.index(after: i)
    }

    public func index(before i: Int) -> Int {
        orderedKeys.index(before: i)
    }

    public subscript(index: Int) -> Element {
        get {
            precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
            return (orderedKeys[index], orderedValues[index])
        }
        set {
            update(newValue, at: index)
        }
    }

    public var keys: [Key] {
        orderedKeys.array
    }

    public var values: [Value] {
        Array(orderedValues)
    }

    public var unordered: Dictionary<Key, Value> {
        reduce(into: [:]) { $0[$1.key] = $1.value }
    }

    public var capacity: Int {
        Swift.min(orderedKeys.capacity, orderedValues.capacity)
    }

    public subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            if let newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }

    public func containsKey(_ key: Key) -> Bool {
        orderedKeys.contains(key)
    }

    public func index(forKey key: Key) -> Int? {
        orderedKeys.index(of: key)
    }

    public func value(forKey key: Key) -> Value? {
        guard let index = orderedKeys.index(of: key) else { return nil }
        return orderedValues[index]
    }

    public func element(at index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        orderedKeys.reserveCapacity(minimumCapacity)
        orderedValues.reserveCapacity(minimumCapacity)
    }

    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        if let index = orderedKeys.index(of: key) {
            let oldValue = orderedValues[index]
            orderedValues[index] = value
            _assertInvariant()
            return oldValue
        }

        orderedKeys.append(key)
        orderedValues.append(value)
        _assertInvariant()
        return nil
    }
    
    @discardableResult
    public mutating func updateValue(_ value: Value?, forKey key: Key) -> Value? {
        if let value {
            return updateValue(value, forKey: key)
        } else {
            return removeValue(forKey: key)
        }
    }

    public func canInsert(key: Key) -> Bool {
        !orderedKeys.contains(key)
    }

    public func canInsert(at index: Int) -> Bool {
        index >= startIndex && index <= endIndex
    }

    public mutating func insert(_ newElement: Element, at index: Int) {
        precondition(canInsert(key: newElement.key), "[OrderedDictionary] Cannot insert duplicate key")
        precondition(canInsert(at: index), "[OrderedDictionary] Index is out of bounds")
        orderedKeys.insert(newElement.key, at: index)
        orderedValues.insert(newElement.value, at: index)
        _assertInvariant()
    }

    public func canUpdate(_ newElement: Element, at index: Int) -> Bool {
        precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
        return orderedKeys[index] == newElement.key || !orderedKeys.contains(newElement.key)
    }

    @discardableResult
    public mutating func update(_ newElement: Element, at index: Int) -> Element {
        precondition(canUpdate(newElement, at: index), "[OrderedDictionary] Cannot update with duplicate key")
        let oldElement = self[index]
        if oldElement.key != newElement.key {
            orderedKeys.update(newElement.key, at: index)
        }
        orderedValues[index] = newElement.value
        _assertInvariant()
        return oldElement
    }

    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let index = orderedKeys.index(of: key) else { return nil }
        return remove(at: index).value
    }

    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
        let key = orderedKeys.remove(at: index)
        let value = orderedValues.remove(at: index)
        _assertInvariant()
        return (key, value)
    }

    public mutating func popFirst() -> Element? {
        isEmpty ? nil : remove(at: startIndex)
    }

    public mutating func popLast() -> Element? {
        isEmpty ? nil : remove(at: index(before: endIndex))
    }

    public mutating func removeFirst() -> Element {
        precondition(!isEmpty, "[OrderedDictionary] Cannot remove from an empty dictionary")
        return remove(at: startIndex)
    }

    public mutating func removeLast() -> Element {
        precondition(!isEmpty, "[OrderedDictionary] Cannot remove from an empty dictionary")
        return remove(at: index(before: endIndex))
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        orderedKeys.removeAll(keepingCapacity: keepCapacity)
        orderedValues.removeAll(keepingCapacity: keepCapacity)
        _assertInvariant()
    }

    public mutating func swapAt(_ i: Int, _ j: Int) {
        orderedKeys.swapAt(i, j)
        orderedValues.swapAt(i, j)
        _assertInvariant()
    }

    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        self = try Self(uniqueKeysWithValues: map { $0 }.sorted(by: areInIncreasingOrder))
    }

    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Self {
        var copy = self
        try copy.sort(by: areInIncreasingOrder)
        return copy
    }

    public mutating func sortByKey(_ order: SortOrder = .ascending) where Key: Comparable {
        sort(by: order == .ascending ? { $0.key < $1.key } : { $0.key > $1.key })
    }

    public mutating func sortByValue(_ order: SortOrder = .ascending) where Value: Comparable {
        sort(by: order == .ascending ? { $0.value < $1.value } : { $0.value > $1.value })
    }

    public mutating func sortByKey<V: Comparable>(_ keyPath: KeyPath<Key, V>, _ order: SortOrder = .ascending) {
        sort(by: order == .ascending ? { $0.key[keyPath: keyPath] < $1.key[keyPath: keyPath] } : { $0.key[keyPath: keyPath] > $1.key[keyPath: keyPath] })
    }

    public mutating func sortByValue<V: Comparable>(_ keyPath: KeyPath<Value, V>, _ order: SortOrder = .ascending) {
        sort(by: order == .ascending ? { $0.value[keyPath: keyPath] < $1.value[keyPath: keyPath] } : { $0.value[keyPath: keyPath] > $1.value[keyPath: keyPath] })
    }

    public func sortedByKey(_ order: SortOrder = .ascending) -> Self where Key: Comparable {
        sorted(by: order == .ascending ? { $0.key < $1.key } : { $0.key > $1.key })
    }

    public func sortedByValue(_ order: SortOrder = .ascending) -> Self where Value: Comparable {
        sorted(by: order == .ascending ? { $0.value < $1.value } : { $0.value > $1.value })
    }

    public func sortedByKey<V: Comparable>(_ keyPath: KeyPath<Key, V>, _ order: SortOrder = .ascending) -> Self {
        sorted(by: order == .ascending ? { $0.key[keyPath: keyPath] < $1.key[keyPath: keyPath] } : { $0.key[keyPath: keyPath] > $1.key[keyPath: keyPath] })
    }

    public func sortedByValue<V: Comparable>(_ keyPath: KeyPath<Value, V>, _ order: SortOrder = .ascending) -> Self {
        sorted(by: order == .ascending ? { $0.value[keyPath: keyPath] < $1.value[keyPath: keyPath] } : { $0.value[keyPath: keyPath] > $1.value[keyPath: keyPath] })
    }

    public mutating func reverse() {
        orderedKeys.reverse()
        orderedValues.reverse()
        _assertInvariant()
    }

    public mutating func shuffle<T: RandomNumberGenerator>(using generator: inout T) {
        self = Self(uniqueKeysWithValues: indices.shuffled(using: &generator).map { self[$0] })
    }

    public mutating func shuffle() {
        var generator = SystemRandomNumberGenerator()
        shuffle(using: &generator)
    }

    @discardableResult
    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        let split = try map { (element: $0, belongsInSecond: try belongsInSecondPartition($0)) }
        let partitionIndex = split.filter { !$0.belongsInSecond }.count
        let partitioned = split.filter { !$0.belongsInSecond }.map(\.element) + split.filter(\.belongsInSecond).map(\.element)
        self = Self(uniqueKeysWithValues: partitioned)
        return partitionIndex
    }

    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> OrderedDictionary<Key, T> {
        try OrderedDictionary<Key, T>(keys: orderedKeys, values: ContiguousArray(orderedValues.map(transform)))
    }

    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> OrderedDictionary<Key, T> {
        try OrderedDictionary<Key, T>(uniqueKeysWithValues: compactMap {
            guard let value = try transform($0.value) else { return nil }
            return ($0.key, value)
        })
    }

    public func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(uniqueKeysWithValues: map { (try transform($0.key), $0.value) })
    }

    public func mapKeys<T: Hashable>(_ transform: (Key) throws -> T, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(map { (try transform($0.key), $0.value) }, uniquingKeysWith: combine)
    }

    public func mapKeys<T: Hashable>(_ transform: (Key) throws -> T, retainLastOccurrences: Bool) rethrows -> OrderedDictionary<T, Value> {
        try mapKeys(transform) { first, last in retainLastOccurrences ? last : first }
    }

    public func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(uniqueKeysWithValues: compactMap {
            guard let key = try transform($0.key) else { return nil }
            return (key, $0.value)
        })
    }

    public func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(compactMap {
            guard let key = try transform($0.key) else { return nil }
            return (key, $0.value)
        }, uniquingKeysWith: combine)
    }

    public func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?, retainLastOccurrences: Bool) rethrows -> OrderedDictionary<T, Value> {
        try compactMapKeys(transform) { first, last in retainLastOccurrences ? last : first }
    }

    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        try Self(uniqueKeysWithValues: compactMap { try isIncluded($0) ? $0 : nil })
    }

    public func merging(_ other: [Key: Value], strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) -> Self {
        var merged = self
        merged.merge(other, strategy: strategy)
        return merged
    }

    public func merging(_ other: Self, strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) -> Self {
        var merged = self
        merged.merge(other, strategy: strategy)
        return merged
    }

    public mutating func merge(_ other: [Key: Value], strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) {
        for (key, newValue) in other {
            if let oldValue = self[key] {
                self[key] = strategy.handler(oldValue, newValue)
            } else {
                self[key] = newValue
            }
        }
    }

    public mutating func merge(_ other: Self, strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) {
        for (key, newValue) in other {
            if let oldValue = self[key] {
                self[key] = strategy.handler(oldValue, newValue)
            } else {
                self[key] = newValue
            }
        }
    }

    private func _assertInvariant() {
        assert(_computeInvariant(), "[OrderedDictionary] Broken invariant: keys=\(orderedKeys), values=\(orderedValues)")
    }

    private func _computeInvariant() -> Bool {
        orderedKeys.count == orderedValues.count
    }
}

extension OrderedDictionary: Hashable where Value: Hashable {}
extension OrderedDictionary: Equatable where Value: Equatable {}

extension OrderedDictionary: Encodable where Key: Encodable, Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var elements = ContiguousArray<KeyValuePair<Key, Value>>()
        elements.reserveCapacity(count)
        for (key, value) in self {
            elements.append(KeyValuePair(key: key, value: value))
        }
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

extension OrderedDictionary: Decodable where Key: Decodable, Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let elements = try container.decode(ContiguousArray<KeyValuePair<Key, Value>>.self)
        self.init(uniqueKeysWithValues: elements.map { ($0.key, $0.value) })
    }
}

private struct KeyValuePair<Key, Value> {
    let key: Key
    let value: Value
}

extension KeyValuePair: Encodable where Key: Encodable, Value: Encodable {}
extension KeyValuePair: Decodable where Key: Decodable, Value: Decodable {}

extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        isEmpty ? "[:]" : "[\(map { "\($0.key): \(String(describing: $0.value))" }.joined(separator: ", "))]"
    }

    public var debugDescription: String {
        isEmpty ? "[:]" : "[\(map { "\(String(reflecting: $0.key)): \(String(reflecting: $0.value))" }.joined(separator: ", "))]"
    }
}
