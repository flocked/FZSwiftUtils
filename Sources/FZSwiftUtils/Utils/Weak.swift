//
//  Weak.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation

/// A weak reference to an object.
public struct Weak<T: AnyObject>: Equatable, Hashable, WeakReference {
    public weak var object: T?
    public init(_ object: T) {
        self.object = object
    }

    public static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        if let object = object {
            hasher.combine(ObjectIdentifier(object))
        } else {
            hasher.combine(0)
        }
    }
}

/// A weak reference to an object.
public protocol WeakReference {
    associatedtype T
    var object: T? { get set }
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
