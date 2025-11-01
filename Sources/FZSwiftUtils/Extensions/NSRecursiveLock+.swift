//
//  NSRecursiveLock+.swift
//
//
//  Created by Florian Zand on 01.11.25.
//

import Foundation

extension NSRecursiveLock {
    /// Execute the specified block while holding the lock.
    public func locked(_ block: ()->()) {
        lock()
        block()
        unlock()
    }
    
    /// Execute the specified block while holding the lock.
    func locked<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}

