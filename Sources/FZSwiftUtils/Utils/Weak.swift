//
//  Weak.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation

/// A weak reference to an object.
public final class Weak<Object: AnyObject>: Hashable, WeakReference {
    /// The weakly stored object.
    public var object: Object? { weakObject }
    private weak var weakObject: Object?
    /// The identifier of the object.
    public let objectID: ObjectIdentifier
    
    /// Creates a weak reference to the specified object.
    public init(_ object: Object) {
        self.weakObject = object
        self.objectID = ObjectIdentifier(object)
    }

    public static func == (lhs: Weak, rhs: Weak) -> Bool {
        lhs.objectID == rhs.objectID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
    }
}

extension Weak: @unchecked Sendable where Object: Sendable {}

/// A weak reference to an object.
public protocol WeakReference: Hashable {
    /// The object type of the weak reference.
    associatedtype Object: AnyObject
    /// The weakly stored object.
    var object: Object? { get }
    /// The identifier of the object.
    var objectID: ObjectIdentifier { get }
    /// Creates a weak reference to the specified object.
    init(_ object: Object)
}

public extension Sequence where Element: WeakReference {
    /// An array of all weak elements that aren't `nil`.
    var nonNil: [Element.Object] {
        compactMap({ $0.object })
    }
}

public extension RangeReplaceableCollection where Element: WeakReference {
    /// Removes all weak objects that are `nil`.
    mutating func reap() {
        self = filter { $0.object != nil }
    }
    
    /**
     Creates an array containing the elements of a sequence.
     
     - Parameter elements: The sequence of elements to turn into an array.
     */
    init<S: Sequence<Element.Object>>(_ elements: S) {
        self.init(elements.lazy.map(Element.init))
    }
}

public extension Set where Element: WeakReference {
    /// Removes all weak objects that are `nil`.
    mutating func reap() {
        self = filter { $0.object != nil }
    }
    
    /**
     Creates a set containing the elements of a sequence.
     
     - Parameter elements: The sequence of elements to turn into a set.
     */
    init<S: Sequence<Element.Object>>(_ elements: S) {
        self = Self(elements.map({Element($0)}))
    }
    
    /**
     Inserts the given element in the set if it is not already present.
     
     - Parameter newMember: An element to insert into the set.
     - Returns: `(true, newMember)` if `newMember` was not contained in the set. If an element equal to newMember was already contained in the set, the method returns `(false, oldMember)`, where `oldMember` is the element that was equal to `newMember`. In some cases, `oldMember` may be distinguishable from `newMember` by identity comparison or some other means.
     */
    @discardableResult
    mutating func insert(_ newMember: Element.Object) -> (inserted: Bool, memberAfterInsert: Element.Object) {
        let id = ObjectIdentifier(newMember)
        if let oldMember = first(where: {$0.objectID == id})?.object {
            return (false, oldMember)
        }
        insert(Element(newMember))
        return (true, newMember)
    }
    
    /**
     Inserts the given elements in the set if it is not already present.
     
     - Parameters: The elemerts to insert into the set.
     */
    mutating func insert<S: Sequence<Element.Object>>(_ elements: S) {
        elements.forEach({ insert($0) })
    }
    
    /**
     Removes the specified element from the set.
     
     - Parameter member: The element to remove from the set.
     - Returns: The value of the `member` parameter if it was a member of the set; otherwise, `nil`.
     */
    @discardableResult
    mutating func remove(_ member: Element.Object) -> Element.Object? {
        let id = ObjectIdentifier(member)
        guard let reference = first(where: { $0.objectID == id }) else {
            return nil
        }
        remove(reference)
        return reference.object
    }
    
    /**
     Removes the specified elements from the set.
     
     - Parameter elements: The elements to remove from the set.
     */
    mutating func remove<S: Sequence<Element.Object>>(_ elements: S) {
        elements.forEach({ remove($0) })
    }
    
    /**
     Returns a Boolean value indicating whether the given element exists in the set.
     
     - Parameter member: An element to look for in the set.
     - Returns: `true` if `member` exists in the set; otherwise, `false`.
     */
    func contains(_ member: Element.Object) -> Bool {
        contains(where: { $0.object === member })
    }
}

public extension Dictionary where Value: WeakReference {
    /// Removes all values where the weak value is `nil`.
    mutating func reap() {
        self = filter { $0.value.object != nil }
    }
    
    /// The dictionary with values whose weak object isn't `nil`.
    var nonNil: [Key: Value.Object] {
        compactMapValues({ $0.object })
    }
    
    /**
     Creates a new dictionary from the key-value pairs in the given sequence.
     
     - Parameter keysAndValues: A sequence of key-value pairs to use for the new dictionary. Every key in keysAndValues must be unique.
     */
    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value.Object) {
        self = Self(uniqueKeysWithValues: keysAndValues.map({ ($0.0, Value($0.1)) }))
    }
    
    /**
     Creates a new dictionary from the key-value pairs in the given sequence, using a combining closure to determine the value for any duplicate keys.
     
     - Parameters:
        - keysAndValues: A sequence of key-value pairs to use for the new dictionary.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value.Object, Value.Object) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value.Object) {
        var result: [Key: Value] = [:]
        for (key, object) in keysAndValues {
            if let existing = result[key]?.object {
                result[key] = try combine(existing, object)
            } else {
                result[key] = Value(object)
            }
        }
        self = result
    }
}

public extension Dictionary where Key: WeakReference {
    /**
     Creates a new dictionary from the key-value pairs in the given sequence.
     
     - Parameter keysAndValues: A sequence of key-value pairs to use for the new dictionary. Every key in keysAndValues must be unique.
     */
    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key.Object, Value) {
        self = Self(uniqueKeysWithValues: keysAndValues.map({ (Key($0.0), $0.1) }))
    }
    
    /**
     Creates a new dictionary from the key-value pairs in the given sequence, using a combining closure to determine the value for any duplicate keys.
     
     - Parameters:
        - keysAndValues: A sequence of key-value pairs to use for the new dictionary.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key.Object, Value) {
        self = try Self(keysAndValues.map({ (Key($0.0), $0.1) }), uniquingKeysWith: combine)
    }
    
    /**
     Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
     
     - Parameters:
        - values: A sequence of values to group into a dictionary.
        - keyForValue: A closure that returns a key for each element in values.
     */
    init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key.Object
    ) rethrows where Value == [S.Element], S : Sequence {
        self.init()
        for value in values {
            self[Key(try keyForValue(value)), default: []].append(value)
        }
    }
}

public extension Dictionary where Key: WeakReference {
    /// Removes all keys where the weak value is `nil`.
    mutating func reap() {
        self = filter { $0.key.object != nil }
    }
    
    subscript(key: Key.Object) -> Value? {
        get {
            let id = ObjectIdentifier(key)
            return first(where: {$0.key.objectID == id })?.value
        }
        set {
            let id = ObjectIdentifier(key)
            if let key = first(where: {$0.key.objectID == id })?.key {
                self[key] = newValue
            } else {
                self[Key(key)] = newValue
            }
        }
    }
}

public extension Dictionary where Key: WeakReference, Key.Object: Hashable {
    /// The dictionary with keys whose weak object isn't `nil`.
    var nonNil: [Key.Object: Value] {
        compactMapKeys( { $0.object } )
    }
}

public extension Dictionary where Key: WeakReference, Value: WeakReference {
    /// Removes all keys where the weak value is `nil`.
    mutating func reap() {
        self = filter { $0.key.object != nil && $0.value.object != nil }
    }
}

public extension Dictionary where Key: WeakReference, Key.Object: Hashable, Value: WeakReference {
    /// The dictionary with keys and objects whose weak object isn't `nil`.
    var nonNil: [Key.Object: Value.Object] {
        compactMapKeyValues({
            guard let key = $0.key.object, let value = $0.value.object else { return nil }
            return (key, value)
        })
    }
}
