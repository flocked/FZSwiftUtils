//
//  UnfairLock.swift
//  
//
//  Created by Florian Zand on 18.09.26.
//

import Foundation
import struct os.os_unfair_lock
import func os.os_unfair_lock_lock
import struct os.os_unfair_lock_t
import func os.os_unfair_lock_trylock
import func os.os_unfair_lock_unlock

/// A lock that provides mutual exclusion using an unfair locking policy.
public final class UnfairLock: NSLocking, Hashable, CustomStringConvertible, CustomDebugStringConvertible, @unchecked Sendable {
    private let unfairLock: UnsafeMutablePointer<os_unfair_lock>
    
    /// The name associated with the lock.
    public let name: String?

    /// Creates an unlocked unfair lock with the specified name.
    public init(name: String? = nil) {
        self.name = name
        self.unfairLock = .allocate(capacity: 1)
        self.unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    /// Acquires the lock, blocking the current thread until the lock is available.
    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    /// Releases the lock.
    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }

    /**
     Attempts to acquire the lock without blocking.

     - Returns: `true` if the lock was acquired; otherwise, `false`.
     */
    public func tryLock() -> Bool {
        os_unfair_lock_trylock(unfairLock)
    }

    /**
     Executes a closure while holding the lock.

     - Parameter body: The closure to execute while holding the lock.
     - Returns: The value returned by the closure.
     */
    @discardableResult
    public func withLock<Result, E: Error>( _ body: () throws(E) -> Result) throws(E) -> Result {
        lock()
        defer { unlock() }
        return try body()
    }

    /**
     Executes a closure while holding the lock if the lock can be acquired without blocking.

     - Parameter body: The closure to execute while holding the lock.
     - Returns: The value returned by the closure, or `nil` if the lock couldn't be acquired.
     */
    @discardableResult
    public func withLockIfAvailable<Result, E: Error>(_ body: () throws(E) -> Result) throws(E) -> Result? {
        guard tryLock() else { return nil }
        defer { unlock() }
        return try body()
    }
    
    public static func == (lhs: UnfairLock, rhs: UnfairLock) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
    
    public var description: String {
        "<\(Self.self): 0x\(String(UInt(bitPattern: Unmanaged.passUnretained(self).toOpaque()), radix: 16))>{name = \(name ?? "nil")}"
    }
    
    public var debugDescription: String {
        description
    }
}

/*
 NSLock conforms to the following:
 CVarArg
 CustomDebugStringConvertible
 CustomStringConvertible
 NSLocking
 SendableMetatype
 
 Should I add conformance to those too?
 */
