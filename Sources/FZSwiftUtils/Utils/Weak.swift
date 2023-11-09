//
//  Weak.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation

/// A weak reference to an object.
public struct Weak<T: AnyObject>: Equatable, Hashable, WeakReference {
    public weak var value : T?
    public init (_ value: T) {
        self.value = value
    }
    
    public static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        if let value = value {
            hasher.combine(ObjectIdentifier(value))
        } else {
            hasher.combine(0)
        }
    }
}

public protocol WeakReference {
    associatedtype T
    var value : T? { get set }
}

extension Array where Element: WeakReference {
    /// Removes all weak objects that are 'nil'.
    public  mutating func reap () {
        self = self.filter { nil != $0.value }
    }
}
