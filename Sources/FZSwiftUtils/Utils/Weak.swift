//
//  Weak.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation

/// A weak reference to an object.
public class Weak<Object: AnyObject>: Equatable, Hashable, WeakReference {
    /// The weakly stored object.
    public var object: Object? { _object }
    private weak var _object: Object?
    private let id = UUID()
    
    /// Creates a weak reference to the specified object.
    required public init(_ object: Object) {
        self._object = object
    }

    public static func == (lhs: Weak, rhs: Weak) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        if let object = object {
            hasher.combine(ObjectIdentifier(object))
        } else {
            hasher.combine(id)
        }
    }
}

/// A weak reference to an object.
public protocol WeakReference {
    associatedtype Object
    var object: Object? { get }
    init(_ object: Object)
}

public extension Sequence where Element: WeakReference {
    /// An array of all weak elements that aren't `nil`.
    var nonNil: [Element.Object] {
        compactMap({ $0.object })
    }
}

public extension Array where Element: WeakReference {
    /// Removes all weak objects that are `nil`.
    mutating func reap() {
        self = filter { $0.object != nil }
    }
}

public extension Set where Element: WeakReference {
    /// Removes all weak objects that are `nil`.
    mutating func reap() {
        self = filter { $0.object != nil }
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
}

public extension Dictionary where Key: WeakReference, Key.Object: Hashable {
    /// Removes all keys where the weak value is `nil`.
    mutating func reap() {
        self = filter { $0.key.object != nil }
    }
    
    /// The dictionary with keys whose weak object isn't `nil`.
    var nonNil: [Key.Object: Value] {
        compactMapKeys( { $0.object } )
    }
    
    subscript(key: Key.Object) -> Value? {
        get { first(where: {$0.key.object == key })?.value }
        set {
            if let key = first(where: {$0.key.object == key })?.key {
                self[key] = newValue
            } else {
                self[Key(key)] = newValue
            }
        }
    }
}
