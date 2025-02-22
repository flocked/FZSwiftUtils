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
    
    public init(_ object: Object) {
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
}

public extension Array where Element: WeakReference {
    /// Removes all weak objects that are 'nil'.
    mutating func reap() {
        self = filter { $0.object != nil }
    }
}

public extension Set where Element: WeakReference {
    /// Removes all weak objects that are 'nil'.
    mutating func reap() {
        self = filter { $0.object != nil }
    }
}

public extension Dictionary where Value: WeakReference {
    /// Removes all weak objects that are 'nil'.
    mutating func reap() {
        self = filter { $0.value.object != nil }
    }
}
