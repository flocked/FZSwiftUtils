//
//  Weak.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation

/// A weak reference to an object.
public struct Weak<T: AnyObject> {
    public weak var value : T?
    public init (_ value: T) {
        self.value = value
    }
}

extension Array where Element == Weak<AnyObject> {
    /// Removes all weak objects that are 'nil'.
    mutating func reap () {
        self = self.filter { nil != $0.value }
    }
}
