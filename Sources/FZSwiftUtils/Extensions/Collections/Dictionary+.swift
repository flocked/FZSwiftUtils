//
//  Dictionary+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

/// The differences between two dictionaries.
public struct KeyValueDifference<Key: Hashable, Value: Equatable> {
    /// The key-value pairs that were removed.
    public let removed: [Key: Value]
    /// The key-value pairs that were added.
    public let added: [Key: Value]
    /// The key-value pairs whose values changed.
    public let changed: [Key: Change]
    
    /// The old and new values of a changed key-value pair.
    public struct Change {
        /// The previous value.
        public let oldValue: Value
        /// The new value.
        public let newValue: Value
        
        public init(oldValue: Value, newValue: Value) {
            self.oldValue = oldValue
            self.newValue = newValue
        }
    }
    
    /// A Boolean value indicating whether no differences were found.
    public var isEmpty: Bool {
        removed.isEmpty && added.isEmpty && changed.isEmpty
    }
    
    public init(removed: [Key: Value], added: [Key: Value], changed: [Key: Change]) {
        self.removed = removed
        self.added = added
        self.changed = changed
    }
}

extension KeyValueDifference.Change: Equatable where Value: Equatable {}
extension KeyValueDifference.Change: Hashable where Value: Hashable {}
extension KeyValueDifference.Change: Codable where Value: Codable {}
extension KeyValueDifference.Change: Sendable where Value: Sendable {}

extension KeyValueDifference: Equatable where Value: Equatable {}
extension KeyValueDifference: Hashable where Value: Hashable {}
extension KeyValueDifference: Codable where Key: Codable, Value: Codable {}
extension KeyValueDifference: Sendable where Key: Sendable, Value: Sendable {}

extension KeyValueDifference.Change: CustomStringConvertible {
    public var description: String {
        "\(oldValue) -> \(newValue)"
    }
}

extension KeyValueDifference: CustomStringConvertible {
    public var description: String {
        """
        removed: \(removed)
        added: \(added)
        changed: \(changed)
        """
    }
}

public extension Dictionary {
    /**
     Removes all key-value pairs that satisfy the given predicate.

     - Parameter shouldBeRemoved: A closure that takes a key-value pair as its argument and returns `true` if the pair should be removed.
     */
    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        self = try filter { try !shouldBeRemoved($0) }
    }
    
    /// Removes all key-value pairs whose values are empty.
    mutating func removeEmptyValues() where Value: Collection {
        removeAll(where: { $0.value.isEmpty })
    }
    
    /**
     Updates the value stored in the dictionary for the given key, or adds a new key-value pair if the key does not exist.
     
     - Parameters:
        - value: The new value to add to the dictionary, or `nil` to remove any current value for the key.
        - key: The key to associate with `value`. If key already exists in the dictionary, `value` replaces the existing associated value. If `key` isn’t already a key of the dictionary, the `(key, value)` pair is added.
     - Returns: The value that was replaced or removed, or `nil` if the key did not previously exist.
     */
    @_disfavoredOverload
    mutating func updateValue(_ value: Value?, forKey key: Key) -> Value? {
        if let value = value {
            return updateValue(value, forKey: key)
        }
        return removeValue(forKey: key)
    }
    
    /// Edits each value in the dictionary.
    mutating func editEach(_ transform: (_ key: Key, _ value: inout Value) throws -> Void) rethrows {
        for (key, var value) in self {
            try transform(key, &value)
            self[key] = value
        }
    }
    
    /// Accesses the value associated with the key for the given value identifier.
    subscript<KeyIdentifier: Identifiable>(key: KeyIdentifier) -> Value? where KeyIdentifier.ID == Dictionary.Key {
        get { self[key.id] }
        set { self[key.id] = newValue }
    }
    
    /// Accesses the value associated with the key containing the
    @_disfavoredOverload
    subscript(key: Key.ID) -> Value? where Key: Identifiable {
        first(where: { $0.key.id == key })?.value
    }
    
    /// Accesses the value associated with the key for the given raw value.
    subscript<KeyRawValue: RawRepresentable>(key: KeyRawValue) -> Value? where KeyRawValue.RawValue == Dictionary.Key {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
    
    /// Accesses the value associated with the key for the given raw value.
    @_disfavoredOverload
    subscript(key: Key.RawValue) -> Value? where Key: RawRepresentable {
        get {
            guard let key = Key(rawValue: key) else { return nil }
            return self[key]
        }
        set {
            guard let key = Key(rawValue: key) else { return }
            self[key] = newValue
        }
    }
    
    /// Accesses the value with the given key, falling back to an empty collection if the key isn’t found.
    subscript(default key: Key) -> Value where Value: ExpressibleByArrayLiteral {
        get { self[key, default: []] }
        set { self[key] = newValue }
    }
    
    /// Accesses the value with the given key, falling back to an empty dictionary if the key isn’t found.
    subscript(default key: Key) -> Value where Value: ExpressibleByDictionaryLiteral {
        get { self[key, default: [:]] }
        set { self[key] = newValue }
    }
    
    /**
     Initializes an ordered dictionary from a sequence of key-value pairs.

     - Parameters:
        - keysAndValues: A sequence of key-value pairs to use for the new ordered dictionary. Every key in `keysAndValues` must be unique.
        - retainLastOccurrences: A Boolean value indicating whether if an key occurs more than once, only the last instance will be included.
     */
    init<S: Sequence>(_ keysAndValues: S, retainLastOccurrences: Bool = false) where S.Element == (Key, Value) {
        self = Self(keysAndValues) { val1, val2 in retainLastOccurrences ? val2 : val1 }
    }
        
    /// Returns values for the specified keys.
    subscript<S>(keys: S) -> [(key: Key, value: Value)] where S: Sequence<Key> {
        values(for: keys)
    }
    
    /**
     Accesses the value associated with the given `key` if it exists, otherwise inserts and returns `initialValue`.

     - Parameters:
        - key: The key to find in the dictionary.
        - initialValue: The initial value that is evaluated if `key` is not already present.
     */
    subscript(key: Key, initial initialValue: @autoclosure () -> Value) -> Value {
        mutating get {
            if let existing = self[key] { return existing }
            let value = initialValue()
            self[key] = value
            return value
        }
        set {
            self[key] = newValue
        }
    }
    
    /**
     Accesses the value associated with the given `key` if it exists, otherwise inserts and returns `initialValue`.

     - Parameters:
        - key: The key to find in the dictionary.
        - initialValue: The initial value that is evaluated if `key` is not already present.
     */
    subscript(key: Key, initial initialValue: () -> Value) -> Value {
        mutating get {
            if let existing = self[key] { return existing }
            let value = initialValue()
            self[key] = value
            return value
        }
        set {
            self[key] = newValue
        }
    }
    
    /// Returns values for the specified keys.
    func values<S: Sequence<Key>>(for keys: S) -> [(key: Key, value: Value)] {
        keys.compactMap { if let value = self[$0] { return ($0, value) } else { return nil } }
    }
    
    /// Returns keys for the specified values.
    func keys<S: Sequence<Value>>(with values: S) -> [Key] where Value: Equatable {
        filter { values.contains($0.value) }.compactMap { $0.key }
    }
    
    /// Returns keys for the specified values.
    func keys<S: Sequence<Value>>(with values: S) -> [Key] where Value: Equatable, Key: Comparable {
        filter { values.contains($0.value) }.compactMap { $0.key }.sorted()
    }

    /**
     Transforms the keys of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and the same values.
     */
    func mapKeys<NewKey>(_ transform: (Key) throws -> NewKey, retainLastOccurrences: Bool = true) rethrows -> [NewKey: Value] {
        try mapKeys(transform) { val1, val2 in retainLastOccurrences ? val2 : val1 }
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with transformed keys and combined values for duplicates.
     */
    func mapKeys<NewKey>(_ transform: (Key) throws -> NewKey, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [NewKey: Value] {
        try .init(map { try (transform($0.key), $0.value) }, uniquingKeysWith: combine)
    }
    
    /**
     Transforms the keys of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and the same values.
     */
    func compactMapKeys<NewKey>(_ transform: (Key) throws -> NewKey?, retainLastOccurrences: Bool = true) rethrows -> [NewKey: Value] {
        try compactMapKeys(transform) { val1, val2 in retainLastOccurrences ? val2 : val1 }
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, discarding any keys that map to `nil` and combining values for duplicate keys.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with non-nil transformed keys and combined values for duplicates.
     */
    func compactMapKeys<NewKey>(_ transform: (Key) throws -> NewKey?, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [NewKey: Value] {
        return try .init(compactMap {
            guard let key = try transform($0.key) else { return nil }
            return (key, $0.value) }, uniquingKeysWith: combine)
    }
    
    /**
     Transforms both keys and values of the dictionary.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and values.
     */
    func mapKeyValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> ((K, V)), retainLastOccurrences: Bool = true) rethrows -> [K: V] {
        try .init(map(transform), retainLastOccurrences: retainLastOccurrences)
    }
    
    /**
     Transforms both keys and values of the dictionary, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with transformed keys and values, combining duplicates as specified.
     */
    func mapKeyValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> ((K, V)), uniquingKeysWith combine: (V, V) throws -> V) rethrows -> [K: V] {
        try .init(map(transform), uniquingKeysWith: combine)
    }
    
    /**
     Transforms both keys and values of the dictionary.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to keep the last occurrence when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and values.
     */
    func compactMapKeyValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> ((K, V)?), retainLastOccurrences: Bool = true) rethrows -> [K: V] {
        try .init(compactMap(transform), retainLastOccurrences: retainLastOccurrences)
    }
    
    /**
     Transforms both keys and values of the dictionary, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - combine: A closure that takes two values for a duplicate key and returns a single value.
     - Returns: A new dictionary with transformed keys and values, combining duplicates as specified.
     */
    func compactMapKeyValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> ((K, V)?), uniquingKeysWith combine: (V, V) throws -> V) rethrows -> [K: V] {
        try .init(compactMap(transform), uniquingKeysWith: combine)
    }
    
    /**
     Sets the specified value for the keys.
     
     - Parameters:
        - value: The new value.
        - keys: The keys for the new value
     */
    mutating func setValue<S: Sequence<Key>>(_ value: Value?, for keys: S) {
        keys.forEach { self[$0] = value }
    }
    
    /**
     Removes the values of the specified keys and returns a dictionary with the removed values.
     
     - Parameter keys: The keys to remove along with their associated values.
     - Returns: The keys and values that were removed.
     */
    @discardableResult
    mutating func remove<S: Sequence<Key>>(_ keys: S) -> Self {
        var removed = Self()
        for key in Set(keys) {
            removed[key] = removeValue(forKey: key)
        }
        return removed
    }
    
    /**
     Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
     
     - Parameters:
        - values: A sequence of values to group into a dictionary.
        - keyForValue: A closure that returns a potential key for each element in `values`.
     */
    init<S>(grouping values: S, byNonNil keyForValue: (S.Element) throws -> Key?) rethrows where Value == [S.Element], S: Sequence {
        self = try values.reduce(into: [:]) {
            if let key = try keyForValue($1) {
                $0[key, default: []].append($1)
            }
        }
    }

    /// Returns an array with the elements of the dictionary.
    var elements: [Element] {
        map { $0 }
    }
    
    /// Returns an array with the elements of the dictionary sorted by key.
    func sorted(_ sortOrder: SortOrder = .forward) -> [Element] where Key: Comparable {
        sorted(by: \.key, sortOrder)
    }
    
    /// Returns an array with the elements of the dictionary sorted by key.
    func sorted<Wrapped: Comparable>(_ sortOrder: SortOrder = .forward) -> [Element] where Key == Wrapped? {
        sorted(by: \.key, sortOrder)
    }
    
    /// Returns an array with the elements of the dictionary sorted by key.
    func sorted(options: String.CompareOptions = [], range: Range<Key.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .forward) -> [Element] where Key: StringProtocol {
        sorted(by: \.key, options: options, range: range, locale: locale, order)
    }
    
    /// Returns an array with the elements of the dictionary sorted by key.
    func sorted<Wrapped: StringProtocol>(options: String.CompareOptions = [], range: Range<Wrapped.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .forward) -> [Element] where Key == Wrapped? {
        sorted(by: \.key, options: options, range: range, locale: locale, order)
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

public extension Dictionary where Value: Collection {
    /// A dictionary containing only the key-value pairs whose values aren't empty.
    var nonEmpty: Self {
        filter({ !$0.value.isEmpty })
    }
}

public extension Dictionary where Key: OptionalProtocol, Key.Wrapped: Hashable {
    /// Returns the dictionary with non optional keys.
    @_disfavoredOverload
    var nonNil: [Key.Wrapped: Value] {
        compactMapKeys { $0.optional }
    }
}

public extension Dictionary where Value: OptionalProtocol {
    /// Returns the dictionary with non optional values.
    @_disfavoredOverload
    var nonNil: [Key: Value.Wrapped] {
        compactMapValues { $0.optional }
    }
}

public extension Dictionary where Key: OptionalProtocol, Key.Wrapped: Hashable, Value: OptionalProtocol {
    /// Returns the dictionary with non optional keys and values
    var nonNil: [Key.Wrapped: Value.Wrapped] {
        compactMapKeys { $0.optional }.compactMapValues { $0.optional }
    }
}

public extension Dictionary where Value: Equatable {
    /**
     Returns the differences needed to transform this dictionary into the specified dictionary.

     - Parameter other: The dictionary to compare against.
     - Returns: The removed, added, and changed key-value pairs.
     */
    func difference(to other: Self) -> KeyValueDifference<Key, Value> {
        var removed: [Key: Value] = [:]
        var added: [Key: Value] = [:]
        var changed: [Key: KeyValueDifference<Key, Value>.Change] = [:]

        for (key, oldValue) in self {
            guard let newValue = other[key] else {
                removed[key] = oldValue
                continue
            }
            if oldValue != newValue {
                changed[key] = .init(oldValue: oldValue, newValue: newValue)
            }
        }
        for (key, newValue) in other where self[key] == nil {
            added[key] = newValue
        }
        return .init(removed: removed, added: added, changed: changed)
    }
}

public extension Dictionary where Value == Any {
    /// Returns the value for the specified key cast to the requested type.
    subscript<T>(typed key: Key) -> T? {
        get {
            guard let value = self[key] else { return nil }
            guard let value = value as? T else {
                log("Wrong type for key: \(key). Expected: \(T.self), got: \(type(of: value)).")
                return nil
            }
            return value
        }
        set { self[key] = newValue }
    }
    
    /**
     Returns the value for the specified key after converting it using the specified strategy.

     - Parameters:
       - key: The key whose associated value to retrieve.
       - strategy: A closure that converts the stored value to the requested type.
     - Returns: The converted value, or `nil` if the key is missing or the conversion fails.
     */
    subscript<T>(typed key: Key, strategy strategy: (Any) -> T?) -> T? {
        get { self[key].flatMap(strategy) }
        set { self[key] = newValue }
    }

    /**
     Returns the value for the specified key cast to the requested type, or the default value if the key is missing or is a different type.

     - Parameters:
       - key: The key whose associated value to retrieve.
       - defaultValue: The value to return if the key is missing or the stored value cannot be cast to the requested type.
     - Returns: The value cast to the requested type, or `defaultValue` if the key is missing or the cast fails.
     */
    subscript<T>(typed key: Key, default defaultValue: @autoclosure () -> T) -> T {
        get { self[key] as? T ?? defaultValue() }
        set { self[key] = newValue }
    }
    
    /**
     Returns the value for the specified key after converting it using the specified strategy, or the default value if the key is missing or the conversion fails.

     - Parameters:
       - key: The key whose associated value to retrieve.
       - defaultValue: The value to return if the key is missing or the conversion fails.
       - strategy: A closure that attempts to convert the stored value to the requested type.
     - Returns: The converted value, or `defaultValue` if the key is missing or the strategy returns `nil`.
     */
    subscript<T>(typed key: Key, default defaultValue: @autoclosure () -> T, strategy strategy: (Any) -> T?) -> T {
        get { self[typed: key, strategy: strategy] ?? defaultValue() }
        set { self[key] = newValue }
    }
    
    /**
     Returns the value for the specified key cast to the requested type, or the default value if the key is missing or is a different type.

     - Parameters:
       - key: The key whose associated value to retrieve.
       - defaultValue: The value to return if the key is missing or the stored value cannot be cast to the requested type.
     - Returns: The value cast to the requested type, or `defaultValue` if the key is missing or the cast fails.
     */
    subscript<T>(typed key: Key, default defaultValue: () -> T) -> T {
        get { (self[key] as? T) ?? defaultValue() }
        set { self[key] = newValue }
    }
    
    /**
     Returns the value for the specified key after converting it using the specified strategy, or the default value if the key is missing or the conversion fails.

     - Parameters:
       - key: The key whose associated value to retrieve.
       - defaultValue: The value to return if the key is missing or the conversion fails.
       - strategy: A closure that attempts to convert the stored value to the requested type.
     - Returns: The converted value, or `defaultValue` if the key is missing or the strategy returns `nil`.
     */
    subscript<T>(typed key: Key, default defaultValue: () -> T, strategy strategy: (Any) -> T?) -> T {
        get { self[typed: key, strategy: strategy] ?? defaultValue() }
        set { self[key] = newValue }
    }
    
    /// Returns the value for the specified key cast to the requested type.
    subscript<T>(typed key: Key) -> T? where T: RawRepresentable {
        get {
            guard let value = self[key] else { return nil }
            if let value = value as? T { return value }
            guard let rawValue = value as? T.RawValue, let value = T(rawValue: rawValue) else {
                log("Wrong type for key: \(key). Expected: \(T.self), got: \(type(of: value)).")
                return nil
            }
            return value
        }
    }
    
    /// Returns the value for the specified key as a date using the specified date formatter.
    subscript(typed key: Key, using dateFormatter: DateFormatter) -> Date? {
        guard let value = self[key] else { return nil }
        if let date = value as? Date { return date }
        guard let dateString = value as? String else {
            log("Wrong type for key: \(key). Expected: \(Date.self), got: \(type(of: value)).")
            return nil
        }
        guard let date = dateFormatter.date(from: dateString) else {
            log("Wrong date string for key: \(key). Got: \(dateString).")
            return nil
        }
        return date
    }
    
    /**
     Returns the value for the specified key decoded using the specified JSON decoder.

     - Parameters:
       - key: The key whose associated value to retrieve.
       - jsonDecoder: The JSON decoder used to decode the stored data.
     - Returns: The decoded value, or `nil` if the key is missing, the stored value is not `Data`, or decoding fails.
     */
    subscript<T: Decodable>(typed key: Key, using jsonDecoder: JSONDecoder) -> T? {
        self[typed: key].flatMap( { try? jsonDecoder.decode($0) } )
    }
    
    private func log(_ message: String) {
        guard DictionaryDebug.isEnabled else { return }
        Swift.print(message)
    }
}

enum DictionaryDebug {
    static var isEnabled = false
}

public extension NSDictionary {
    /// The dictionary as `Dictionary`.
    func toDictionary() -> [String: Any] {
        reduce(into: [:]) { $0[$1.key as? String ?? "\($1.key)"] = $1.value }
    }

    /// The dictionary as `CFDictionary`.
    var cfDictionary: CFDictionary {
        self as CFDictionary
    }
}


extension Dictionary where Value == Any {
    /// A Boolean value indicating whether the dictionary is equatable to another dictionary.
    public func isEqual(to other: Self) -> Bool {
        count == other.count && Set(keys) == Set(other.keys) && allSatisfy { key, value in
            guard let otherValue = other[key] else { return false }
            return FZSwiftUtils.isEqual(value, otherValue)
        }
    }
    
    fileprivate func isEqual(to other: Any) -> Bool {
        guard let other = other as? Self else { return false }
        return isEqual(to: other)
    }
}

extension Array where Element == Any {
    /// A Boolean value indicating whether the array is equatable to another array.
    public func isEqual(to other: Self) -> Bool {
        count == other.count &&  zip(self, other).allSatisfy(FZSwiftUtils.isEqual)
    }
    
    fileprivate func isEqual(to other: Any) -> Bool {
        guard let other = other as? Self else { return false }
        return isEqual(to: other)
    }
}

fileprivate func isEqual(_ val1: Any, _ val2: Any) -> Bool {
    if let val1 = val1 as? (any Equatable) {
        guard val1.isEqual(val2 as? (any Equatable)) else { return false }
    } else if let val1 = val1 as? AnyEquatableContainer {
        guard val1.isEqual(to: val2) else { return false }
    } else if val1 as AnyObject !== val2 as AnyObject {
        return false
    }
    return true
}

fileprivate protocol AnyEquatableContainer {
    func isEqual(to other: Any) -> Bool
}

extension Dictionary: AnyEquatableContainer where Value == Any { }
extension Array: AnyEquatableContainer where Element == Any { }

public struct ValueStrategy<Output> {
    public let transform: (Any) -> Output?

    public init(_ transform: @escaping (Any) -> Output?) {
        self.transform = transform
    }

    public func callAsFunction(_ value: Any) -> Output? {
        transform(value)
    }
}

public extension Dictionary where Value == Any {
    subscript<V>(
        typed key: Key,
        as type: V.Type = V.self,
        strategy: ValueStrategy<V>
    ) -> V? {
        self[key].flatMap { strategy($0) }
    }
}

extension ValueStrategy where Output == Date {
    public static func formatted(
        _ format: String,
        locale: Locale = .current
    ) -> Self {
        .init { value in
            guard let string = value as? String else { return nil }

            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = locale
            return formatter.date(from: string)
        }
    }
}
