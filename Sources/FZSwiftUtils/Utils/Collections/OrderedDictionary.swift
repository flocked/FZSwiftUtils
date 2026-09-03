//
//  OrderedDictionary.swift
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// An ordered collection of key-value pairs with unique keys.
public struct OrderedDictionary<Key: Hashable, Value>: RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    private var orderedKeys: OrderedSet<Key>
    @usableFromInline
    var orderedValues: ContiguousArray<Value>

    /// A key-value pair stored in an ordered dictionary.
    public typealias Element = (key: Key, value: Value)

    /// Creates an empty ordered dictionary.
    public init() {
        orderedKeys = []
        orderedValues = []
    }

    /// Creates an empty ordered dictionary and reserves storage for at least the specified number of elements.
    public init(minimumCapacity: Int) {
        self.init()
        reserveCapacity(minimumCapacity)
    }

    /// Creates an ordered dictionary from an unordered dictionary sorted by the specified predicate.
    public init(unsorted: Dictionary<Key, Value>, areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try self.init(uniqueKeysWithValues: Array(unsorted).sorted(by: areInIncreasingOrder))
    }

    /**
     Creates an ordered dictionary from a sequence of unique key-value pairs.

     The initializer traps if the sequence contains duplicate keys.
     */
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S) where S.Element == Element {
        self.init(uniqueKeysWithValues: keysAndValues, minimumCapacity: keysAndValues.underestimatedCount)
    }

    /// Creates an ordered dictionary from key-value pairs, combining duplicate keys with the specified closure.
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
    }

    /// Creates an ordered dictionary from key-value pairs, choosing either the first or last value for duplicate keys.
    public init<S: Sequence>(_ keysAndValues: S, retainLastOccurrences: Bool) where S.Element == Element {
        self = Self(keysAndValues) { first, last in retainLastOccurrences ? last : first }
    }

    /// Creates an ordered dictionary that groups sequence elements by a derived key.
    public init<S: Sequence>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element] {
        self.init(minimumCapacity: values.underestimatedCount)
        for value in values {
            let key = try keyForValue(value)
            self[key, default: []].append(value)
        }
    }

    private init<S: Sequence>(uniqueKeysWithValues keysAndValues: S, minimumCapacity: Int? = nil) where S.Element == Element {
        self.init(minimumCapacity: minimumCapacity ?? keysAndValues.underestimatedCount)
        for (key, value) in keysAndValues {
            precondition(!orderedKeys.contains(key), "[OrderedDictionary] Sequence contains duplicate key (\(key))")
            orderedKeys.append(key)
            orderedValues.append(value)
        }
    }

    private init(keys: OrderedSet<Key>, values: ContiguousArray<Value>) {
        orderedKeys = keys
        orderedValues = values
        _assertInvariant()
    }

    /// Creates an ordered dictionary from a dictionary literal.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }

    /// Creates an ordered dictionary from an array literal of key-value pairs.
    public init(arrayLiteral elements: Element...) {
        self.init(uniqueKeysWithValues: elements)
    }

    /// The position of the first element.
    public var startIndex: Int { orderedKeys.startIndex }
    /// The position one past the last element.
    public var endIndex: Int { orderedKeys.endIndex }
    /// The number of key-value pairs in the ordered dictionary.
    public var count: Int { orderedKeys.count }
    /// A Boolean value indicating whether the ordered dictionary is empty.
    public var isEmpty: Bool { orderedKeys.isEmpty }
    /// The valid index range for the ordered dictionary.
    public var indices: CountableRange<Int> { startIndex..<endIndex }

    /// Returns the position immediately after the specified index.
    public func index(after i: Int) -> Int {
        orderedKeys.index(after: i)
    }

    /// Returns the position immediately before the specified index.
    public func index(before i: Int) -> Int {
        orderedKeys.index(before: i)
    }

    /// Accesses the key-value pair at the specified position.
    public subscript(index: Int) -> Element {
        get {
            precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
            return (orderedKeys[index], orderedValues[index])
        }
        set {
            update(newValue, at: index)
        }
    }

    /// The keys in their stored order.
    public var keys: OrderedSet<Key> {
        orderedKeys
    }

    /// The keys as an array in their stored order.
    public var keyArray: [Key] {
        keys.array
    }

    /// A mutable collection view of the values in key order.
    @inlinable
    @inline(__always)
    public var values: Values {
        get { Values(_base: self) }
        @inline(__always) // https://github.com/apple/swift-collections/issues/164
        _modify {
            var values = Values(_base: self)
            self = [:]
            defer { self = values._base }
            yield &values
        }
    }

    /// The values as an array snapshot in key order.
    public var valueArray: [Value] {
        Array(orderedValues)
    }

    /// The contents as an unordered dictionary.
    public var unordered: Dictionary<Key, Value> {
        reduce(into: [:]) { $0[$1.key] = $1.value }
    }

    /// The current reserved capacity of the ordered dictionary.
    public var capacity: Int {
        Swift.min(orderedKeys.capacity, orderedValues.capacity)
    }

    /// Accesses the value for a key.
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

    /**
     Accesses the value for a key, inserting the default value when the key is missing.

     This matches `Dictionary`'s defaulted subscript behavior and supports in-place mutation of the stored value.
     */
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get { value(forKey: key) ?? defaultValue() }
        _modify {
            if let index = orderedKeys.index(of: key) {
                defer { _assertInvariant() }
                yield &orderedValues[index]
            } else {
                let index = orderedValues.endIndex
                orderedKeys.append(key)
                orderedValues.append(defaultValue())
                defer { _assertInvariant() }
                yield &orderedValues[index]
            }
        }
    }

    /// Returns whether the ordered dictionary contains the specified key.
    public func containsKey(_ key: Key) -> Bool {
        orderedKeys.contains(key)
    }

    /// Returns the position for a key, or `nil` if the key is not present.
    public func index(forKey key: Key) -> Int? {
        orderedKeys.index(of: key)
    }

    /// Returns the value for a key, or `nil` if the key is not present.
    public func value(forKey key: Key) -> Value? {
        guard let index = orderedKeys.index(of: key) else { return nil }
        return orderedValues[index]
    }

    /// Returns the key-value pair at the specified position, or `nil` if the index is out of bounds.
    public func element(at index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Reserves enough space to store the specified number of key-value pairs.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        orderedKeys.reserveCapacity(minimumCapacity)
        orderedValues.reserveCapacity(minimumCapacity)
    }

    /// Updates the value for a key or appends a new key-value pair if the key is missing.
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        if let index = orderedKeys.index(of: key) {
            let oldValue = orderedValues[index]
            orderedValues[index] = value
            return oldValue
        }

        orderedKeys.append(key)
        orderedValues.append(value)
        return nil
    }

    /// Updates or removes the value for a key depending on whether the new value is `nil`.
    @discardableResult
    public mutating func updateValue(_ value: Value?, forKey key: Key) -> Value? {
        if let value {
            return updateValue(value, forKey: key)
        } else {
            return removeValue(forKey: key)
        }
    }

    /// Mutates the value for a key in place, inserting the default value first when the key is missing.
    @discardableResult
    public mutating func updateValue<R>(forKey key: Key, default defaultValue: @autoclosure () -> Value, with body: (inout Value) throws -> R) rethrows -> R {
        let index: Int
        if let existingIndex = orderedKeys.index(of: key) {
            index = existingIndex
        } else {
            index = orderedValues.endIndex
            orderedKeys.append(key)
            orderedValues.append(defaultValue())
        }

        defer { _assertInvariant() }
        return try body(&orderedValues[index])
    }

    /// Returns whether a key can be inserted.
    public func canInsert(key: Key) -> Bool {
        !orderedKeys.contains(key)
    }

    /// Returns whether an insertion can be performed at the specified position.
    public func canInsert(at index: Int) -> Bool {
        index >= startIndex && index <= endIndex
    }

    /// Inserts a key-value pair at the specified position.
    public mutating func insert(_ newElement: Element, at index: Int) {
        precondition(canInsert(key: newElement.key), "[OrderedDictionary] Cannot insert duplicate key")
        precondition(canInsert(at: index), "[OrderedDictionary] Index is out of bounds")
        orderedKeys.insert(newElement.key, at: index)
        orderedValues.insert(newElement.value, at: index)
    }

    /// Returns whether the element at the specified position can be replaced with the new key-value pair.
    public func canUpdate(_ newElement: Element, at index: Int) -> Bool {
        precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
        return orderedKeys[index] == newElement.key || !orderedKeys.contains(newElement.key)
    }

    /// Replaces the key-value pair at the specified position.
    @discardableResult
    public mutating func update(_ newElement: Element, at index: Int) -> Element {
        precondition(canUpdate(newElement, at: index), "[OrderedDictionary] Cannot update with duplicate key")
        let oldElement = self[index]
        if oldElement.key != newElement.key {
            orderedKeys.update(newElement.key, at: index)
        }
        orderedValues[index] = newElement.value
        return oldElement
    }

    /// Removes the value for a key if it is present.
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let index = orderedKeys.index(of: key) else { return nil }
        return remove(at: index).value
    }

    /// Removes and returns the key-value pair at the specified position.
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
        let key = orderedKeys.remove(at: index)
        let value = orderedValues.remove(at: index)
        return (key, value)
    }

    /// Removes and returns the first key-value pair, or `nil` when the dictionary is empty.
    public mutating func popFirst() -> Element? {
        isEmpty ? nil : remove(at: startIndex)
    }

    /// Removes and returns the last key-value pair, or `nil` when the dictionary is empty.
    public mutating func popLast() -> Element? {
        isEmpty ? nil : remove(at: index(before: endIndex))
    }

    /// Removes and returns the first key-value pair.
    public mutating func removeFirst() -> Element {
        precondition(!isEmpty, "[OrderedDictionary] Cannot remove from an empty dictionary")
        return remove(at: startIndex)
    }

    /// Removes and returns the last key-value pair.
    public mutating func removeLast() -> Element {
        precondition(!isEmpty, "[OrderedDictionary] Cannot remove from an empty dictionary")
        return remove(at: index(before: endIndex))
    }

    /// Removes all key-value pairs, optionally preserving allocated storage.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        orderedKeys.removeAll(keepingCapacity: keepCapacity)
        orderedValues.removeAll(keepingCapacity: keepCapacity)
    }

    /// Removes every key-value pair that satisfies the specified predicate.
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        var keys = OrderedSet<Key>(minimumCapacity: count)
        var values = ContiguousArray<Value>()
        values.reserveCapacity(count)

        for element in self where try !shouldBeRemoved(element) {
            keys.append(element.key)
            values.append(element.value)
        }

        orderedKeys = keys
        orderedValues = values
        _assertInvariant()
    }

    /// Exchanges the key-value pairs at the specified positions.
    public mutating func swapAt(_ i: Int, _ j: Int) {
        orderedKeys.swapAt(i, j)
        orderedValues.swapAt(i, j)
        _assertInvariant()
    }

    /// Moves the key-value pair at `source` to `destination`.
    public mutating func move(from source: Int, to destination: Int) {
        precondition(indices.contains(source), "[OrderedDictionary] Source index is out of bounds")
        precondition(destination >= startIndex && destination <= endIndex, "[OrderedDictionary] Destination index is out of bounds")
        guard source != destination && source + 1 != destination else { return }

        orderedKeys.move(from: source, to: destination)
        let value = orderedValues.remove(at: source)
        orderedValues.insert(value, at: destination > source ? destination - 1 : destination)
        _assertInvariant()
    }

    /// Moves the key-value pairs at the specified offsets to a destination offset.
    public mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        precondition(source.allSatisfy { indices.contains($0) }, "[OrderedDictionary] Source contains out of bounds indexes")
        precondition(destination >= startIndex && destination <= endIndex, "[OrderedDictionary] Destination index is out of bounds")
        guard !source.isEmpty else { return }

        orderedKeys.move(fromOffsets: source, toOffset: destination)
        let movingValues = source.sorted().map { orderedValues[$0] }
        for index in source.sorted(by: >) {
            orderedValues.remove(at: index)
        }
        let lowerRemovedBeforeDestination = source.filter { $0 < destination }.count
        orderedValues.insert(contentsOf: movingValues, at: destination - lowerRemovedBeforeDestination)
        _assertInvariant()
    }

    /// Sorts the ordered dictionary in place using the specified predicate.
    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        let elements = try map { $0 }.sorted(by: areInIncreasingOrder)
        self = Self(
            keys: OrderedSet(uncheckedUniqueElements: elements.map(\.key)),
            values: ContiguousArray(elements.map(\.value))
        )
    }

    /// Returns a sorted ordered dictionary using the specified predicate.
    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Self {
        var copy = self
        try copy.sort(by: areInIncreasingOrder)
        return copy
    }

    /// Sorts the ordered dictionary in place by key.
    public mutating func sortByKey(_ order: SortOrder = .ascending) where Key: Comparable {
        sort(by: order == .ascending ? { $0.key < $1.key } : { $0.key > $1.key })
    }

    /// Sorts the ordered dictionary in place by value.
    public mutating func sortByValue(_ order: SortOrder = .ascending) where Value: Comparable {
        sort(by: order == .ascending ? { $0.value < $1.value } : { $0.value > $1.value })
    }

    /// Sorts the ordered dictionary in place by a comparable key property.
    public mutating func sortByKey<V: Comparable>(_ keyPath: KeyPath<Key, V>, _ order: SortOrder = .ascending) {
        sort(by: order == .ascending ? { $0.key[keyPath: keyPath] < $1.key[keyPath: keyPath] } : { $0.key[keyPath: keyPath] > $1.key[keyPath: keyPath] })
    }

    /// Sorts the ordered dictionary in place by a comparable value property.
    public mutating func sortByValue<V: Comparable>(_ keyPath: KeyPath<Value, V>, _ order: SortOrder = .ascending) {
        sort(by: order == .ascending ? { $0.value[keyPath: keyPath] < $1.value[keyPath: keyPath] } : { $0.value[keyPath: keyPath] > $1.value[keyPath: keyPath] })
    }

    /// Returns an ordered dictionary sorted by key.
    public func sortedByKey(_ order: SortOrder = .ascending) -> Self where Key: Comparable {
        sorted(by: order == .ascending ? { $0.key < $1.key } : { $0.key > $1.key })
    }

    /// Returns an ordered dictionary sorted by value.
    public func sortedByValue(_ order: SortOrder = .ascending) -> Self where Value: Comparable {
        sorted(by: order == .ascending ? { $0.value < $1.value } : { $0.value > $1.value })
    }

    /// Returns an ordered dictionary sorted by a comparable key property.
    public func sortedByKey<V: Comparable>(_ keyPath: KeyPath<Key, V>, _ order: SortOrder = .ascending) -> Self {
        sorted(by: order == .ascending ? { $0.key[keyPath: keyPath] < $1.key[keyPath: keyPath] } : { $0.key[keyPath: keyPath] > $1.key[keyPath: keyPath] })
    }

    /// Returns an ordered dictionary sorted by a comparable value property.
    public func sortedByValue<V: Comparable>(_ keyPath: KeyPath<Value, V>, _ order: SortOrder = .ascending) -> Self {
        sorted(by: order == .ascending ? { $0.value[keyPath: keyPath] < $1.value[keyPath: keyPath] } : { $0.value[keyPath: keyPath] > $1.value[keyPath: keyPath] })
    }

    /// Reverses the order of the key-value pairs in place.
    public mutating func reverse() {
        orderedKeys.reverse()
        orderedValues.reverse()
    }

    /// Shuffles the key-value pairs in place using the specified random number generator.
    public mutating func shuffle<T: RandomNumberGenerator>(using generator: inout T) {
        self = Self(uniqueKeysWithValues: indices.shuffled(using: &generator).map { self[$0] })
    }

    /// Shuffles the key-value pairs in place.
    public mutating func shuffle() {
        var generator = SystemRandomNumberGenerator()
        shuffle(using: &generator)
    }

    /// Reorders the key-value pairs so matching pairs are after nonmatching pairs and returns the partition index.
    @discardableResult
    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        let split = try map { (element: $0, belongsInSecond: try belongsInSecondPartition($0)) }
        let partitionIndex = split.filter { !$0.belongsInSecond }.count
        let partitioned = split.filter { !$0.belongsInSecond }.map(\.element) + split.filter(\.belongsInSecond).map(\.element)
        self = Self(uniqueKeysWithValues: partitioned)
        return partitionIndex
    }

    /// Returns a new ordered dictionary by applying the specified collection difference.
    public func applying(_ difference: CollectionDifference<Element>) -> Self {
        guard let elements = Array(self).applying(difference) else {
            preconditionFailure("[OrderedDictionary] Difference is incompatible with this ordered dictionary")
        }
        return Self(uniqueKeysWithValues: elements)
    }

    /// Returns an ordered dictionary by transforming each value.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> OrderedDictionary<Key, T> {
        try OrderedDictionary<Key, T>(keys: orderedKeys, values: ContiguousArray(orderedValues.map(transform)))
    }

    /// Returns an ordered dictionary by transforming each value and discarding nil results.
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> OrderedDictionary<Key, T> {
        try OrderedDictionary<Key, T>(uniqueKeysWithValues: compactMap {
            guard let value = try transform($0.value) else { return nil }
            return ($0.key, value)
        })
    }

    /// Returns an ordered dictionary by transforming each key.
    public func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(uniqueKeysWithValues: map { (try transform($0.key), $0.value) })
    }

    /// Returns an ordered dictionary by transforming each key and combining duplicate transformed keys.
    public func mapKeys<T: Hashable>(_ transform: (Key) throws -> T, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(map { (try transform($0.key), $0.value) }, uniquingKeysWith: combine)
    }

    /// Returns an ordered dictionary by transforming each key, choosing either first or last values for duplicate transformed keys.
    public func mapKeys<T: Hashable>(_ transform: (Key) throws -> T, retainLastOccurrences: Bool) rethrows -> OrderedDictionary<T, Value> {
        try mapKeys(transform) { first, last in retainLastOccurrences ? last : first }
    }

    /// Returns an ordered dictionary by transforming each key and discarding nil transformed keys.
    public func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(uniqueKeysWithValues: compactMap {
            guard let key = try transform($0.key) else { return nil }
            return (key, $0.value)
        })
    }

    /// Returns an ordered dictionary by transforming each key, discarding nil transformed keys, and combining duplicates.
    public func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<T, Value> {
        try OrderedDictionary<T, Value>(compactMap {
            guard let key = try transform($0.key) else { return nil }
            return (key, $0.value)
        }, uniquingKeysWith: combine)
    }

    /// Returns an ordered dictionary by transforming each key, discarding nil transformed keys, and choosing either first or last values for duplicates.
    public func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?, retainLastOccurrences: Bool) rethrows -> OrderedDictionary<T, Value> {
        try compactMapKeys(transform) { first, last in retainLastOccurrences ? last : first }
    }

    /// Returns an ordered dictionary containing the key-value pairs that satisfy the specified predicate.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        let elements = try compactMap { try isIncluded($0) ? $0 : nil }
        return Self(
            keys: OrderedSet(uncheckedUniqueElements: elements.map(\.key)),
            values: ContiguousArray(elements.map(\.value))
        )
    }

    /// Returns a new ordered dictionary by merging another dictionary into this one.
    public func merging(_ other: [Key: Value], strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) -> Self {
        var merged = self
        merged.merge(other, strategy: strategy)
        return merged
    }

    /// Returns a new ordered dictionary by merging another ordered dictionary into this one.
    public func merging(_ other: Self, strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) -> Self {
        var merged = self
        merged.merge(other, strategy: strategy)
        return merged
    }

    /// Merges another dictionary into this ordered dictionary.
    public mutating func merge(_ other: [Key: Value], strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) {
        for (key, newValue) in other {
            if let oldValue = self[key] {
                self[key] = strategy.handler(oldValue, newValue)
            } else {
                self[key] = newValue
            }
        }
    }

    /// Merges another ordered dictionary into this ordered dictionary.
    public mutating func merge(_ other: Self, strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) {
        for (key, newValue) in other {
            if let oldValue = self[key] {
                self[key] = strategy.handler(oldValue, newValue)
            } else {
                self[key] = newValue
            }
        }
    }

    #if DEBUG
    private func _assertInvariant() {
        assert(_computeInvariant(), "[OrderedDictionary] Broken invariant: keys=\(orderedKeys), values=\(orderedValues)")
    }
    #else
    private func _assertInvariant() {}
    #endif

    private func _computeInvariant() -> Bool {
        orderedKeys.count == orderedValues.count
    }
}

extension OrderedDictionary: Hashable where Value: Hashable {}
extension OrderedDictionary: Equatable where Value: Equatable {}
extension OrderedDictionary: Sendable where Key: Sendable, Value: Sendable {}

extension OrderedDictionary: Encodable where Key: Encodable, Value: Encodable {
    /// Encodes the ordered dictionary as an ordered sequence of key-value pairs.
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
    /// Decodes an ordered dictionary from an ordered sequence of key-value pairs.
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

extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// A textual representation of the ordered dictionary.
    public var description: String {
        isEmpty ? "[:]" : "[\(map { "\($0.key): \(String(describing: $0.value))" }.joined(separator: ", "))]"
    }

    /// A debug textual representation of the ordered dictionary.
    public var debugDescription: String {
        isEmpty ? "[:]" : "[\(map { "\(String(reflecting: $0.key)): \(String(reflecting: $0.value))" }.joined(separator: ", "))]"
    }

    /// A mirror that reflects the ordered dictionary as key-value pairs.
    public var customMirror: Mirror {
        Mirror(self, unlabeledChildren: map { $0 }, displayStyle: .dictionary)
    }
}


extension OrderedDictionary {
  /// A view of an ordered dictionary's values as a standalone collection.
  @frozen
  public struct Values {
    @usableFromInline
    internal var _base: OrderedDictionary

    @inlinable
    @inline(__always)
    internal init(_base: OrderedDictionary) {
      self._base = _base
    }
  }
}

extension OrderedDictionary.Values: Sendable
where Key: Sendable, Value: Sendable {}

#if !$Embedded
extension OrderedDictionary.Values: CustomStringConvertible {
  /// A textual representation of the values.
  public var description: String {
    _arrayDescription(for: self)
  }
}

extension OrderedDictionary.Values: CustomDebugStringConvertible {
  /// A debug textual representation of the values.
  public var debugDescription: String {
    description
  }
}
#endif

extension OrderedDictionary.Values {
  /// The values as an array snapshot.
  @inlinable
  @inline(__always)
  public var elements: Array<Value> {
      _base.valueArray
  }
}

extension OrderedDictionary.Values {
  /// Calls a closure with an unsafe buffer pointer to the values.
  @inlinable
  @inline(__always)
  public func withUnsafeBufferPointer<R>(
    _ body: (UnsafeBufferPointer<Value>) throws -> R
  ) rethrows -> R {
    try _base.orderedValues.withUnsafeBufferPointer(body)
  }

  /// Calls a closure with an unsafe mutable buffer pointer to the values.
  @inlinable
  @inline(__always)
  public mutating func withUnsafeMutableBufferPointer<R>(
    _ body: (inout UnsafeMutableBufferPointer<Value>) throws -> R
  ) rethrows -> R {
    try _base.orderedValues.withUnsafeMutableBufferPointer(body)
  }
}

extension OrderedDictionary.Values: Sequence {
  /// The element type of the values view.
  public typealias Element = Value

  /// The iterator type for the values view.
  public typealias Iterator = IndexingIterator<Self>
}

extension OrderedDictionary.Values: RandomAccessCollection {
  /// The index type for the values view.
  public typealias Index = Int

  /// The valid indices for the values view.
  public typealias Indices = Range<Int>

  /// The position of the first value.
  @inlinable
  @inline(__always)
  public var startIndex: Int { 0 }

  /// The position one past the last value.
  @inlinable
  @inline(__always)
  public var endIndex: Int { _base.orderedValues.count }

  /// Returns the position immediately after the specified index.
  @inlinable
  @inline(__always)
  public func index(after i: Int) -> Int { i + 1 }

  /// Returns the position immediately before the specified index.
  @inlinable
  @inline(__always)
  public func index(before i: Int) -> Int { i - 1 }

  /// Replaces the specified index with its successor.
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Int) { i += 1 }

  /// Replaces the specified index with its predecessor.
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Int) { i -= 1 }

  /// Returns an index offset by the specified distance.
  @inlinable
  @inline(__always)
  public func index(_ i: Int, offsetBy distance: Int) -> Int {
    i + distance
  }

  /// Returns an index offset by the specified distance unless it passes the limit.
  @inlinable
  @inline(__always)
  public func index(
    _ i: Int,
    offsetBy distance: Int,
    limitedBy limit: Int
  ) -> Int? {
    _base.orderedValues.index(i, offsetBy: distance, limitedBy: limit)
  }

  /// Returns the distance between two indices.
  @inlinable
  @inline(__always)
  public func distance(from start: Int, to end: Int) -> Int {
    end - start
  }

  /// Calls a closure with a contiguous buffer pointer to the values when available.
  @inlinable
  @inline(__always)
  public func withContiguousStorageIfAvailable<R>(
    _ body: (UnsafeBufferPointer<Value>) throws -> R
  ) rethrows -> R? {
    try _base.orderedValues.withUnsafeBufferPointer(body)
  }
}

extension OrderedDictionary.Values: MutableCollection {
  /// Accesses the value at the specified position.
  @inlinable
  @inline(__always)
  public subscript(position: Int) -> Value {
    get {
      _base.orderedValues[position]
    }
    @inline(__always) // https://github.com/apple/swift-collections/issues/164
    _modify {
      yield &_base.orderedValues[position]
    }
  }

  /// Exchanges the values at the specified positions without moving their keys.
  @inlinable
  @inline(__always)
  public mutating func swapAt(_ i: Int, _ j: Int) {
    _base.orderedValues.swapAt(i, j)
  }

  /// Partitions the values in place without moving their keys.
  @inlinable
  @inline(__always)
  public mutating func partition(
    by belongsInSecondPartition: (Value) throws -> Bool
  ) rethrows -> Int {
    try _base.orderedValues.partition(by: belongsInSecondPartition)
  }

  /// Calls a closure with a mutable contiguous buffer pointer to the values when available.
  @inlinable
  @inline(__always)
  public mutating func withContiguousMutableStorageIfAvailable<R>(
    _ body: (inout UnsafeMutableBufferPointer<Value>) throws -> R
  ) rethrows -> R? {
    try _base.orderedValues.withUnsafeMutableBufferPointer(body)
  }
}

extension OrderedDictionary.Values: Equatable where Value: Equatable {
  /// Returns whether two values views contain the same values in the same order.
  @inlinable
  public static func ==(left: Self, right: Self) -> Bool {
    left._base.orderedValues == right._base.orderedValues
  }
}

extension OrderedDictionary.Values: Hashable where Value: Hashable {
  /// Hashes the values in order.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(count) // Discriminator
    for item in self {
      hasher.combine(item)
    }
  }
}

private func _arrayDescription<C: Collection>(
  for elements: C
) -> String {
  var result = "["
  var first = true
  for item in elements {
    if first {
      first = false
    } else {
      result += ", "
    }
    debugPrint(item, terminator: "", to: &result)
  }
  result += "]"
  return result
}


