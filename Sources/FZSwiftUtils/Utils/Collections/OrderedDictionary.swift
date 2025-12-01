//
//  OrderedDictionary.swift
//
//  Created by Florian Zand on 23.07.23.
//  Adopted from: Lukas Kubanek
//  OrderedDictionary - https://github.com/lukaskubanek/OrderedDictionary/
//

import Foundation

/**
 
 A ordered collection whose elements are key-value pairs.
 
 See the following example for a brief showcase including the initialization from a dictionary literal as well as iteration over its sorted key-value pairs:
 
 ```swift
 let orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

 for keyValuePair in orderedDictionary {
    print(keyValuePair)
 }
 // => (key: "a", value: 1)
 // => (key: "b", value: 2)
 // => (key: "c", value: 3)
 ```
 */
public struct OrderedDictionary<Key: Hashable, Value>: RandomAccessCollection, MutableCollection {
    
    // MARK: - fileprivate Storage
    
    /// The backing storage for the ordered keys.
    private var _orderedKeys: OrderedSet<Key>
    
    /// The backing storage for the mapping of keys to values.
    private var _keysToValues: [Key: Value]
    
    // MARK: - Type Aliases
    
    /// The type of the key-value pair stored in the ordered dictionary.
    public typealias Element = (key: Key, value: Value)
    

    // MARK: - Initialization
    
    /// Initializes an empty ordered dictionary.
    public init() {
        self.init(uniqueKeysWithValues: EmptyCollection<Element>())
    }
    
    /// Initializes an empty ordered dictionary with preallocated space for at least the specified number of elements.
    public init(minimumCapacity: Int) {
        _orderedKeys = .init(minimumCapacity: minimumCapacity)
        _keysToValues = .init(minimumCapacity: minimumCapacity)
    }
    
    /**
     Initializes an ordered dictionary from a regular unsorted dictionary by sorting it using the given sort function.

     - Parameters:
       - unsorted: The unsorted dictionary.
       - areInIncreasingOrder: The sort function which compares the key-value pairs.
     */
    public init(unsorted: Dictionary<Key, Value>, areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        let keysAndValues = try Array(unsorted).sorted(by: areInIncreasingOrder)
        self.init(uniqueKeysWithValues: keysAndValues, minimumCapacity: unsorted.count)
    }
    
    /**
     Initializes an ordered dictionary from a sequence of key-value pairs.

     - Parameter keysAndValues: A sequence of key-value pairs to use for the new ordered dictionary. Every key in `keysAndValues` must be unique.
     */
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S) where S.Element == Element {
        self.init(uniqueKeysWithValues: keysAndValues, minimumCapacity: keysAndValues.underestimatedCount)
    }
    
    /**
     Initializes an ordered dictionary from a sequence of key-value pairs.

     - Parameters:
        - keysAndValues: A sequence of key-value pairs to use for the new ordered dictionary. Every key in `keysAndValues` must be unique.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    public init<S: Sequence>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S.Element == Element {
        _orderedKeys = .init()
        _keysToValues = .init()
        for val in keysAndValues {
            if let value = _keysToValues[val.0] {
                _keysToValues[val.0] = try combine(value, val.1)
            } else {
                _orderedKeys.insert(val.0)
                _keysToValues[val.0] = val.1
            }
        }
    }
    
    /**
     Initializes an ordered dictionary from a sequence of key-value pairs.

     - Parameters:
        - keysAndValues: A sequence of key-value pairs to use for the new ordered dictionary. Every key in `keysAndValues` must be unique.
        - retainLastOccurences: A Boolean value indicating whether if an key occurs more than once, only the last instance will be included.
     */
    public init<S: Sequence>(_ keysAndValues: S, retainLastOccurences: Bool) where S.Element == Element {
        self = Self(keysAndValues) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    private init<S: Sequence>(uniqueKeysWithValues keysAndValues: S, minimumCapacity: Int? = nil) where S.Element == Element {
        defer { _assertInvariant() }
        _orderedKeys = .init(minimumCapacity: minimumCapacity ?? 0)
        _keysToValues = .init(minimumCapacity: minimumCapacity ?? 0)
        for (key, value) in keysAndValues {
            precondition(_keysToValues[key] == nil,
                         "[OrderedDictionary] Sequence of key-value pairs contains duplicate keys (\(key))")
            _orderedKeys.insert(key)
            _keysToValues[key] = value
        }
    }
    
    private init(orderedSet: OrderedSet<Key>, keysToValues: [Key: Value]) {
        _orderedKeys = orderedSet
        _keysToValues = keysToValues
    }
    
    // MARK: - Ordered Keys & Values
    
    /**
     An array containing just the keys of the ordered dictionary in the correct order.

     The following example shows how the ordered keys can be iterated over and accessed:
     
     ```swift
     let orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     print(orderedDictionary.orderedKeys)
     // => ["a", "b", "c"]
     ```
     */
    public var keys: [Key] {
        Array(_orderedKeys)
    }
    
    /**
     A lazily evaluated collection containing just the values of the ordered dictionary in the correct order.

     The following example shows how the ordered values can be iterated over and accessed. Note that the collection is of type `LazyValues` which wraps the `OrderedDictionary` as its base collection. Depending on the use case, it might be desirable to convert the collection to an `Array`, which creates a copy of the values.

     ```swift
     let orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     print(Array(orderedDictionary.orderedValues))
     // => [1, 2, 3]
     ```
     */
    public var values: [Value] {
        map { $0.value }
    }
    
    // MARK: - Unordered Dictionary
    
    /// Converts itself to a common unsorted dictionary.
    public var unordered: Dictionary<Key, Value> {
        _keysToValues
    }

    // MARK: - Indices
    
    /// The indices that are valid for subscripting the ordered dictionary.
    public var indices: CountableRange<Index> {
        _orderedKeys.indices
    }
    
    /// The position of the first key-value pair in a non-empty ordered dictionary.
    public var startIndex: Int {
        _orderedKeys.startIndex
    }
    
    /// The position which is one greater than the position of the last valid key-value pair
    /// in the ordered dictionary.
    public var endIndex: Int {
        _orderedKeys.endIndex
    }
    
    /// Returns the position immediately after the given index.
    public func index(after i: Int) -> Int {
        _orderedKeys.index(after: i)
    }
    
    /// Returns the position immediately before the given index.
    public func index(before i: Int) -> Int {
        _orderedKeys.index(before: i)
    }
    
    /**
     Returns the index for the given key.

     The following example shows how to get indices for given keys:
     
     ```swift
     var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     print(orderedDictionary.index(forKey: "a"))
     // => Optional(0)

     print(orderedDictionary.index(forKey: "x"))
     // => nil
     ```

     - Parameter key: The key to find in the ordered dictionary.
     - Returns: The index for `key` and its associated value if `key` is in the ordered dictionary; otherwise, `nil`.
     - Complexity: O(*n*), where *n* is the length of the ordered dictionary.
     */
    public func index(forKey key: Key) -> Int? {
        _orderedKeys.index(of: key)
    }
    
    // MARK: - Key-based Access
    
    /**
      Accesses the value associated with the given key for reading and writing.

      This key-based subscript returns the value for the given key if the key is found in the ordered dictionary, or `nil` if the key is not found.

      When you assign a value for a key and that key already exists, the ordered dictionary overwrites the existing value and preserves the index of the key-value pair. If the ordered dictionary does not contain the key, a new key-value pair is appended to the end of the ordered dictionary.

      When you assign `nil` as the value for the given key, the ordered dictionary removes that key and its associated value if it exists.

      See the following example that shows how to access and set values for keys:
     
      ```swift
      var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

      print(orderedDictionary["a"])
      // => Optional(1)

      print(orderedDictionary["x"])
     // => nil

     orderedDictionary["b"] = 42
     print(orderedDictionary["b"])
     // => Optional(42)
      ```

      - Parameter key: The key to find in the ordered dictionary.
      - Returns: The value associated with `key` if `key` is in the ordered dictionary; otherwise, `nil`.
      */
    public subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            if let newValue = newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    /**
     Returns whether the ordered dictionary contains the given key.

     - Parameter key: The key to be looked up.
     - Returns: `true` if the ordered dictionary contains the given key; otherwise, `false`.
     */
    public func containsKey(_ key: Key) -> Bool {
        _keysToValues[key] != nil
    }
    
    /**
      Returns the value associated with the given key if the key is found in the ordered dictionary, or `nil` if the key is not found.

      The following example shows how to access values for keys:

      ```swift
     var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     print(orderedDictionary.value(forKey: "a"))
     // => Optional(1)

     print(orderedDictionary.value(forKey: "x"))
     // => nil
      ```

      - Parameter key: The key to find in the ordered dictionary.
      - Returns: The value associated with `key` if `key` is in the ordered dictionary; otherwise, `nil`.
      */
    public func value(forKey key: Key) -> Value? {
        _keysToValues[key]
    }
    
    /**
      Updates the value stored in the ordered dictionary for the given key, or appends a new key-value pair if the key does not exist.

      The following example shows how to update the value for an existing key:

      ```swift
     var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     let previousValue = orderedDictionary.updateValue(42, forKey: "b")

     print(previousValue)
     // => Optional(2)

     print(orderedDictionary["b"])
     // => Optional(42)

     print(orderedDictionary)
     // => ["a": 1, "b": 42, "c": 3]
      ```

      See the second example for the case where the updated key is not yet present in the ordered dictionary:
     
      ```swift
     var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     let previousValue = orderedDictionary.updateValue(4, forKey: "d")

     print(previousValue)
     // => nil

     print(orderedDictionary["d"])
     // => Optional(4)

     print(orderedDictionary)
     // => ["a": 1, "b": 2, "c": 3, "d": 4]
      ```
     
      - Parameters:
        - value: The new value to add to the ordered dictionary.
        - key: The key to associate with `value`. If `key` already exists in the ordered dictionary, `value` replaces the existing associated value. If `key` is not yet a key of the ordered dictionary, the `(key, value)` pair is appended at the end of the ordered dictionary.
      */
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        defer { _assertInvariant() }
        
        if containsKey(key) {
            guard let currentValue = _keysToValues[key] else {
                fatalError("[OrderedDictionary] Inconsistency error")
            }
            
            _keysToValues[key] = value
            
            return currentValue
        } else {
            _orderedKeys.append(key)
            _keysToValues[key] = value
            
            return nil
        }
    }
    
    /**
      Removes the given key and its associated value from the ordered dictionary.

      If the key is found in the ordered dictionary, this method returns the key's associated value. On removal, the indices of the ordered dictionary are invalidated. If the key is not found in the ordered dictionary, this method returns `nil`.

      The following example shows how to remove a value for a key:
     
      ```swift
      var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     let removedValue = orderedDictionary.removeValue(forKey: "b")

     print(removedValue)
     // => Optional(2)

     print(orderedDictionary["b"])
     // => nil

     print(orderedDictionary)
     // => ["a": 1, "c": 3]
      ```

      - Parameter key: The key to remove along with its associated value.
      - Returns: The value that was removed, or `nil` if the key was not present in the ordered dictionary.
      */
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let currentValue = _keysToValues[key] else { return nil }
        guard let index = index(forKey: key) else { return nil }
        defer { _assertInvariant() }
        _orderedKeys.remove(at: index)
        _keysToValues[key] = nil
        return currentValue
    }
    
    /**
     Removes all key-value pairs from the ordered dictionary and invalidates all indices.

     - Parameter keepCapacity: Whether the ordered dictionary should keep its underlying storage. If you pass `true`, the operation preserves the storage capacity that the collection has, otherwise the underlying storage is released. The default is `false`.
     */
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        defer { _assertInvariant() }
        _orderedKeys.removeAll(keepingCapacity: keepCapacity)
        _keysToValues.removeAll(keepingCapacity: keepCapacity)
    }
    
    // MARK: - Index-based Access
    
    /**
      Accesses the key-value pair at the specified position for reading and writing. When accessing a key-value pair the given position must be a valid index of the ordered dictionary.

      When assigning a key-value pair for a particular position, the position must be either a valid index of the ordered dictionary or equal to `endIndex`. Furthermore, the given key must not be already present at a different position of the ordered dictionary. However, it is safe to set a key equal to the key that is currently present at that position.

      The following example shows how to access and set key-value pairs at specific indices:

      ```swift
     var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

     print(orderedDictionary[0])
     // => (key: "a", value: 1)

     orderedDictionary[1] = (key: "d", value: 42)
     print(orderedDictionary[1])
     // => (key: "d", value: 42)

     print(orderedDictionary)
     // => ["a": 1, "d": 42, "c": 3]

     orderedDictionary[0] = (key: "a", value: 5)
     print(orderedDictionary[0])
     // => (key: "a", value: 5)

     print(orderedDictionary)
     // => ["a": 5, "d": 42, "c": 3]
      ```

      - Parameter position: The position of the key-value pair to access. position must be a valid index of the ordered dictionary and not equal to endIndex.
      - Returns: A tuple containing the key-value pair corresponding to `position`.
      */
    public subscript(index: Int) -> Element {
        get {
            precondition( indices.contains(index), "[OrderedDictionary] Index is out of bounds")
            let key = _orderedKeys[index]
            guard let value = _keysToValues[key] else {
                fatalError("[OrderedDictionary] Inconsistency error")
            }
            return (key, value)
        }
        set { update(newValue, at: index) }
    }
    
    /**
     Returns the key-value pair at the specified index, or `nil` if there is no key-value pair at that index.

     - Parameter index: The index of the key-value pair to be looked up. `index` does not have to be a valid index.
     - Returns: A tuple containing the key-value pair corresponding to `index` if the index is valid; otherwise, `nil`.
     */
    public func element(at index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    /**
     Checks whether a key-value pair with the given key can be inserted into the ordered dictionary by validating its presence.

     - Parameter key: The key to be inserted into the ordered dictionary.
     - Returns: `true` if the key can safely be inserted; otherwise, `false`.
     */
    public func canInsert(key: Key) -> Bool {
        !containsKey(key)
    }
    
    /**
     Checks whether a new key-value pair can be inserted into the ordered dictionary at the given index.

     - Parameter index: The index the new key-value pair should be inserted at.
     - Returns: `true` if a new key-value pair can be inserted at the specified index; otherwise, `false`.
     */
    public func canInsert(at index: Int) -> Bool {
        index >= startIndex && index <= endIndex
    }
    
    /**
     Inserts a new key-value pair at the specified position.

     If the key of the inserted pair already exists in the ordered dictionary, a runtime error is triggered. Use `canInsert(_:)` for performing a check first, so that this method can be executed safely.

     - Parameters:
       - newElement: The new key-value pair to insert into the ordered dictionary. The key contained in the pair must not be already present in the ordered dictionary.
       - index: The position at which to insert the new key-value pair. `index` must be a valid index of the ordered dictionary or equal to `endIndex` property.
     */
    public mutating func insert(_ newElement: Element, at index: Int) {
        precondition(canInsert(key: newElement.key), "[OrderedDictionary] Cannot insert duplicate key")
        precondition(canInsert(at: index), "[OrderedDictionary] Cannot insert key-value pair at invalid index")
        defer { _assertInvariant() }
        _orderedKeys.insert(newElement.key, at: index)
        _keysToValues[newElement.key] = newElement.value
    }
    
    /**
     Checks whether the key-value pair at the given index can be updated with the given key-value pair. This is not the case if the key of the updated element is already present in the ordered dictionary and located at another index than the updated one.

     Although this is a checking method, a valid index has to be provided.

     - Parameters:
       - newElement: The key-value pair to be set at the specified position.
       - index: The position at which to set the key-value pair. `index` must be a valid index of the ordered dictionary.
     */
    public func canUpdate(_ newElement: Element, at index: Int) -> Bool {
        precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
        let newKey = newElement.key
        return (self[index].key == newKey) || !containsKey(newKey)
    }
    
    /**
     Updates the key-value pair located at the specified position.

     If the key of the updated pair already exists in the ordered dictionary *and* is located at a different position than the specified one, a runtime error is triggered.

     Use `canUpdate(_:at:)` to perform a check first, so that this method can be executed safely.

     - Parameters:
       - newElement: The key-value pair to be set at the specified position.
       - index: The position at which to set the key-value pair. `index` must be a valid index of the ordered dictionary.
     - Returns: A tuple containing the key-value pair previously associated with the `index`.
     */
    @discardableResult
    public mutating func update(_ newElement: Element, at index: Int) -> Element {
        precondition(indices.contains(index), "[OrderedDictionary] Index is out of bounds")
        defer { _assertInvariant() }
                
        let (newKey, newValue) = newElement
        
        let previousElement = self[index]
        let previousKey = self[index].key
        
        let isSameKey = previousKey == newKey
        let isExistingKey = containsKey(newKey)

        precondition( isSameKey || !isExistingKey, "[OrderedDictionary] Index-based update produced duplicate keys")
        
        if (!isSameKey) {
            _keysToValues[previousKey] = nil
        }
        
        _orderedKeys[index] = newKey
        _keysToValues[newKey] = newValue
        
        return previousElement
    }
    
    /**
     Removes and returns the key-value pair at the specified position if there is any key-value pair, or `nil` if there is none.

     The following example shows how to remove a key-value pair at a specific index:
     
     ```swift
     var orderedDictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
     
     let removedElement = orderedDictionary.remove(at: 1)
     
     print(removedElement)
     // => Optional((key: "b", value: 2))
     
     print(orderedDictionary)
     // => ["a": 1, "c": 3]
     ```
     
     - Parameter index: The position of the key-value pair to remove.
     - Returns: The element at the specified index, or `nil` if the position is not taken.
     */
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        let element = self[index]
        _orderedKeys.remove(at: index)
        _keysToValues[element.key] = nil
        return element
    }
    
    // MARK: - Removing First & Last Elements
    
    /// Removes and returns the first key-value pair of the ordered dictionary if it is not empty.
    public mutating func popFirst() -> Element? {
        isEmpty ? nil : remove(at: startIndex)
    }
    
    /// Removes and returns the last key-value pair of the ordered dictionary if it is not empty.
    public mutating func popLast() -> Element? {
        isEmpty ? nil : remove(at: index(before: endIndex))
    }
    
    /// Removes and returns the first key-value pair of the ordered dictionary.
    public mutating func removeFirst() -> Element {
        precondition(!isEmpty, "[OrderedDictionary] Cannot remove key-value pairs when empty")
        return remove(at: startIndex)
    }
    
    /// Removes and returns the last key-value pair of the ordered dictionary.
    public mutating func removeLast() -> Element {
        precondition(!isEmpty, "[OrderedDictionary] Cannot remove key-value pairs when empty")
        return remove(at: index(before: endIndex))
    }
    
    // MARK: - Sorting Elements
    
    /**
     Sorts the ordered dictionary in place, using the given predicate as the comparison between elements.

     The predicate must be a *strict weak ordering* over the elements.

     - Parameter areInIncreasingOrder: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     */
    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try _sort(in: indices, by: areInIncreasingOrder)
    }
    
    /**
     Returns a new ordered dictionary, sorted using the given predicate as the comparison between elements.

     The predicate must be a *strict weak ordering* over the elements.

     The following example shows how to sort an ordered dictionary according to the keys or values:
     
     ```swift
     let orderedDictionary: OrderedDictionary<String, Int> = ["c": 3, "d": 2, "b": 1, "a": 4]
     
     print(orderedDictionary.sorted { $0.key < $1.key })
     // => ["a": 1, "b": 2, "c": 3, "d": 4]
     
     print(orderedDictionary.sorted { $0.value < $1.value })
     // => ["b": 1, "d": 2, "c": 3, "a": 4]
     ```
     
     - Parameter areInIncreasingOrder: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     - Returns: A new ordered dictionary sorted according to the predicate.
     */
    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Self {
        var new = self
        try new.sort(by: areInIncreasingOrder)
        return new
    }
    
    /// Sorts the ordered dictionary in place, by the key.
    public mutating func sortByKey(_ order: SortOrder = .ascending) where Key: Comparable {
        sort(by: order == .ascending ? { $0.key < $1.key } : { $0.key > $1.key } )
    }
    
    /// Sorts the ordered dictionary in place, by the value.
    public mutating func sortByValue(_ order: SortOrder = .ascending) where Value: Comparable {
        sort(by: order == .ascending ? { $0.value < $1.value } : { $0.value > $1.value } )
    }
    
    /// Sorts the ordered dictionary in place, by the specified key property.
    public mutating func sortByKey<V: Comparable>(_ keyPath: KeyPath<Key, V>, _ order: SortOrder = .ascending) {
        sort(by: order == .ascending ? { $0.key[keyPath: keyPath] < $1.key[keyPath: keyPath] } : { $0.key[keyPath: keyPath] > $1.key[keyPath: keyPath] } )
    }
    
    /// Sorts the ordered dictionary in place, by the specified value property.
    public mutating func sortByValue<V: Comparable>(_ keyPath: KeyPath<Value, V>, _ order: SortOrder = .ascending) {
        sort(by: order == .ascending ? { $0.value[keyPath: keyPath] < $1.value[keyPath: keyPath] } : { $0.value[keyPath: keyPath] > $1.value[keyPath: keyPath] } )
    }
    
    /// Returns a new ordered dictionary, sorted by the key.
    public func sortedByKey(_ order: SortOrder = .ascending) -> Self where Key: Comparable {
        sorted(by: order == .ascending ? { $0.key < $1.key } : { $0.key > $1.key } )
    }
    
    /// Returns a new ordered dictionary, sorted by the value.
    public func sortedByValue(_ order: SortOrder = .ascending) -> Self where Value: Comparable {
        sorted(by: order == .ascending ? { $0.value < $1.value } : { $0.value > $1.value } )
    }
    
    /// Returns a new ordered dictionary, sorted by the specified key property.
    public func sortedByKey<V: Comparable>(_ keyPath: KeyPath<Key, V>, _ order: SortOrder = .ascending) -> Self {
        sorted(by: order == .ascending ? { $0.key[keyPath: keyPath] < $1.key[keyPath: keyPath] } : { $0.key[keyPath: keyPath] > $1.key[keyPath: keyPath] } )
    }
    
    /// Returns a new ordered dictionary, sorted by the specified value property.
    public func sortedByValue<V: Comparable>(_ keyPath: KeyPath<Value, V>, _ order: SortOrder = .ascending) -> Self {
        sorted(by: order == .ascending ? { $0.value[keyPath: keyPath] < $1.value[keyPath: keyPath] } : { $0.value[keyPath: keyPath] > $1.value[keyPath: keyPath] } )
    }
    
    fileprivate mutating func _sort(in range: Range<Int>, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        defer { _assertInvariant() }
        
        try _orderedKeys[range].sort { key1, key2 in
            let element1 = (key: key1, value: _keysToValues[key1]!)
            let element2 = (key: key2, value: _keysToValues[key2]!)
            return try areInIncreasingOrder(element1, element2)
        }
    }
    
    // MARK: - Reordering Elements
    
    /// Reverses the key-value pairs of the ordered dictionary in place.
    public mutating func reverse() {
        _reverse(in: indices)
    }

    fileprivate mutating func _reverse(in range: Range<Index>) {
        defer { _assertInvariant() }
        _orderedKeys[range].reverse()
    }
    
    /// Shuffles the ordered dictionary in place, using the given generator as a source for randomness.
    public mutating func shuffle<T>(using generator: inout T) where T: RandomNumberGenerator {
        _shuffle(in: indices, using: &generator)
    }
    
    public mutating func _shuffle<T>(in range: Range<Int>, using generator: inout T) where T: RandomNumberGenerator {
        defer { _assertInvariant() }
        _orderedKeys[range].shuffle(using: &generator)
    }
    
    /// Reorders the key-value pairs of the ordered dictionary such that all the key-value pairs that match the given predicate are after all the key-value pairs that do not match.
    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Index {
        return try _partition(in: indices, by: belongsInSecondPartition)
    }
    
    fileprivate mutating func _partition(in range: Range<Int>, by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Index {
        defer { _assertInvariant() }
        
        return try _orderedKeys[range].partition { key in
            let element = (key: key, value: _keysToValues[key]!)
            return try belongsInSecondPartition(element)
        }
    }
    
    /**
     Exchanges the elements at the specified indices.

     - Parameters:
       - i: The index of the first value to swap.
       - j: The index of the second value to swap.

     - Precondition: Both indices must be valid existing indices of the ordered dictionary.
     - Complexity: O(1)
     */
    public mutating func swapAt(_ i: Int, _ j: Int) {
        _orderedKeys.swapAt(i, j)
    }
    
    // MARK: - Transformations
    
    /// Returns a new ordered dictionary containing the keys of this ordered dictionary with the values transformed by the given closure while preserving the original order.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> OrderedDictionary<Key, T> {
        .init(orderedSet: _orderedKeys, keysToValues: try _keysToValues.mapValues(transform))
    }
    
    /// Returns a new ordered dictionary containing only the key-value pairs that have non-nil values as the result of transformation by the given closure while preserving the original order.
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> OrderedDictionary<Key, T> {
        .init(orderedSet: _orderedKeys, keysToValues: try _keysToValues.compactMapValues(transform))
    }
    
    /**
     Transforms keys without modifying values.

     - Parameter transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.

     - Note: The collection of transformed keys must not contain duplicates.
     */
    public func mapKeys<T>(_ transform: (Key) throws -> T) rethrows -> OrderedDictionary<T, Value> {
        try reduce(into: [:]) { $0[try transform($1.key)] = $1.value }
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    public func mapKeys<T>(_ transform: (Key) throws -> T, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<T, Value> {
        return try reduce(into: [:]) {
            let key = try transform($1.key)
            if let val = $0[key] {
                $0[key] = try combine(val, $1.value)
            } else {
                $0[key] = $1.value
            }
        }
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - retainLastOccurences: A Boolean value indicating whether if an key occurs more than once, only the last instance will be included.
     */
    public func mapKeys<T>(_ transform: (Key) throws -> T, retainLastOccurences: Bool) rethrows -> OrderedDictionary<T, Value> {
        try mapKeys(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /**
     Transforms keys without modifying values. Drops (key, value) pairs where the transform results in a `nil` key.

     - Parameter transform: A closure that accepts each key of the dictionary as its parameter and returns a potential transformed key of the same or of a different type.

     - Note: The collection of transformed keys must not contain duplicates.
     */
    public func compactMapKeys<T>(_ transform: (Key) throws -> T?) rethrows -> OrderedDictionary<T, Value> {
        try reduce(into: [:]) {
            guard let key = try transform($1.key) else { return }
            $0[key] = $1.value
        }
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    public func compactMapKeys<T>(_ transform: (Key) throws -> T?, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<T, Value> {
        try reduce(into: [:]) {
            guard let key = try transform($1.key) else { return }
            if let val = $0[key] {
                $0[key] = try combine(val, $1.value)
            } else {
                $0[key] = $1.value
            }
        }
    }
    
    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - retainLastOccurences: A Boolean value indicating whether if an key occurs more than once, only the last instance will be included.
     */
    public func compactMapKeys<T>(_ transform: (Key) throws -> T?, retainLastOccurences: Bool) rethrows -> OrderedDictionary<T, Value> {
        try compactMapKeys(transform) { val1, val2 in retainLastOccurences ? val2 : val1 }
    }
    
    /// Returns a new ordered dictionary container the key-value pairs that satisfy the given predicate while preserving the original order.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        Self(uniqueKeysWithValues: try lazy.filter(isIncluded))
    }
    
    // MARK: - Merge
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    public func merged(with other: [Key: Value], strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) -> Self {
        merged(with: other.map({$0}), strategy: strategy)
    }
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    public func merged(with other: Self, strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) -> Self {
        merged(with: other.map({$0}), strategy: strategy)
    }
    
    private func merged(with other: [Element], strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) -> Self {
        var merged = self
        for (key, value) in other {
            switch strategy.rawValue {
            case "keepOriginal":
                if merged[key] == nil {
                    merged[key] = value
                }
            case "custom":
                merged[key] = strategy.handler!(key, merged[key], value)
            default:
                merged[key] = value
            }
        }
        return merged
    }
    
    /**
     Merges the current dictionary with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    public mutating func merge(with other: [Key: Value], strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) {
        self = merged(with: other, strategy: strategy)
    }
    
    /**
     Merges the current dictionary with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    public mutating func merge(with other: Self, strategy: Dictionary<Key, Value>.MergeStrategy = .overwrite) {
        self = merged(with: other, strategy: strategy)
    }
    
    // MARK: - Capacity

    /// The total number of elements that the ordered dictionary can contain without allocating new storage.
    public var capacity: Int {
        Swift.min(_orderedKeys.capacity, _keysToValues.capacity)
    }

    /**
     Reserves enough space to store the specified number of elements, when appropriate for the underlying types.

     If you are adding a known number of elements to an ordered dictionary, use this method to avoid multiple reallocations. This method ensures that the underlying types of the ordered dictionary have space allocated for at least the requested number of elements.

     - Parameter minimumCapacity: The requested number of elements to store.
     */
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        defer { _assertInvariant() }
        _orderedKeys.reserveCapacity(minimumCapacity)
        _keysToValues.reserveCapacity(minimumCapacity)
    }
    
    // MARK: - Invariant
    
    /**
     Asserts whether the fileprivate invariant is met and traps in the debug mode otherwise.

     - Complexity: O(`count`)
     */
    private func _assertInvariant() {
        assert(
            _computeInvariant(),
            """
            [OrderedDictionary] Broken fileprivate invariant:
             orderedKeys(count: \(_orderedKeys.count)) = \(_orderedKeys)
             keysToValues(count: \(_keysToValues.count)) = \(_keysToValues)
            """
        )
    }
    
    /// Computes the fileprivate invariant for the count and key presence in the underlying storage, and returns `true` if the invariant is met.
    private func _computeInvariant() -> Bool {
        if _orderedKeys.count != _keysToValues.count { return false }
        
        for index in _orderedKeys.indices {
            let key = _orderedKeys[index]
            if _keysToValues[key] == nil { return false }
        }
        
        return true
    }
}

extension OrderedDictionary: Hashable where Value: Hashable {}
extension OrderedDictionary: Equatable where Value: Equatable {}

extension OrderedDictionary: ExpressibleByArrayLiteral {
    /// Initializes an ordered dictionary initialized from an array literal containing a list of key-value pairs. Every key in `elements` must be unique.
    public init(arrayLiteral elements: Element...) {
        self.init(uniqueKeysWithValues: elements)
    }
    
}

extension OrderedDictionary: ExpressibleByDictionaryLiteral {
    /// Initializes an ordered dictionary initialized from a dictionary literal. Every key in `elements` must be unique.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements )
    }
}

extension OrderedDictionary: Encodable where Key: Encodable, Value: Encodable {
    /// Encodes the contents of this ordered dictionary into the given encoder.
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
    /// Creates a new ordered dictionary by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let keysAndValues = try container.decode(ContiguousArray<KeyValuePair<Key, Value>>.self)
        self.init(uniqueKeysWithValues: keysAndValues.map({ ($0.key, $0.value) }))
    }
}

fileprivate struct KeyValuePair<Key, Value> {
    let key: Key
    let value: Value
}

extension KeyValuePair: Encodable where Key: Encodable, Value: Encodable { }
extension KeyValuePair: Decodable where Key: Decodable, Value: Decodable { }

extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible {
    /// A textual representation of the ordered dictionary.
    public var description: String {
        isEmpty ? "[:]" : "[\(map { "\($0): \(String(describing: $1))" }.joined(separator: ", "))]"
    }
    
    /// A textual representation of the ordered dictionary, suitable for debugging.
    public var debugDescription: String {
        isEmpty ? "[:]" : "[\(map { "\(String(reflecting: $0)): \(String(reflecting: $1))" }.joined(separator: ", "))]"
    }
}

/*
 public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
     var keys = _orderedKeys
     keys.remove(_orderedKeys[subrange])
     precondition( Set(newElements.map({$0.key})).isDisjoint(with: keys), "[OrderedDictionary] Cannot insert duplicate key")
     defer { _assertInvariant() }
     subrange.forEach({ _keysToValues[_orderedKeys[$0]] = nil })
     _orderedKeys.replaceSubrange(subrange, with: newElements.map({$0.key}))
     newElements.forEach({ _keysToValues[$0.key] = $0.value })
 }
 */
