//
//  Weak.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation

/// A weak reference to an object.
public struct Weak<T: AnyObject>: Equatable, Hashable {
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

extension Array where Element == Weak<AnyObject> {
    /// Removes all weak objects that are 'nil'.
    mutating func reap () {
        self = self.filter { nil != $0.value }
    }
}
