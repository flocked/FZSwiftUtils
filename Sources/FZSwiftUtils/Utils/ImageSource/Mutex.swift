//
//  Mutex.swift
//
//
//  Created by Florian Zand on 11.01.26.
//

import Foundation
import struct os.os_unfair_lock_t
import struct os.os_unfair_lock
import func os.os_unfair_lock_lock
import func os.os_unfair_lock_unlock
import func os.os_unfair_lock_trylock

/**
 A synchronization primitive that protects shared mutable state via mutual exclusion.
 
 The `Mutex` type offers non-recursive exclusive access to the state it is protecting by blocking threads attempting to acquire the lock. Only one execution context at a time has access to the value stored within the Mutex allowing for exclusive access.
 
 An example use of Mutex in a class used simultaneously by many threads protecting a Dictionary value:
 ```swift
 class Manager {
   let cache = Mutex<[Key: Resource]>([:])

   func saveResource(_ resource: Resource, as key: Key) {
     cache.withLock {
       $0[key] = resource
     }
   }
 }
 ```
 */
public struct Mutex<Value: ~Copyable>: ~Copyable {
    private let storage: Storage

    /**
     Initializes a value of this mutex with the given initial state.
     
     - Parameter initalValue: The initial value to give to the mutex.
     */
    public init(_ initialValue: consuming sending Value) {
        self.storage = Storage(value: initialValue)
    }

    /**
     Calls the given closure after acquiring the lock and then releases ownership.
     
     - Parameter body: A closure with a parameter of Value that has exclusive access to the value being stored within this mutex. This closure is considered the critical section as it will only be executed once the calling thread has acquired the lock.
     - Returns: The return value, if any, of the body closure parameter.
     
     This method is equivalent to the following sequence of code:
     ```swift
     mutex.lock()
     defer {
       mutex.unlock()
     }
     return try body(&value)
     ```
     
     - Warning: Recursive calls to `withLock` within the closure parameter has behavior that is platform dependent. Some platforms may choose to panic the process, deadlock, or leave this behavior unspecified. This will never reacquire the lock however.
    */
    public borrowing func withLock<Result: ~Copyable, E: Error>(_ body: (inout sending Value) throws(E) -> sending Result) throws(E) -> sending Result {
        storage.lock()
        defer { storage.unlock() }
        return try body(&storage.value)
    }

    /**
     Attempts to acquire the lock and then calls the given closure if successful.
     
     - Parameter body: A closure with a parameter of Value that has exclusive access to the value being stored within this mutex. This closure is considered the critical section as it will only be executed if the calling thread acquires the lock.
     - Returns: The return value, if any, of the body closure parameter or nil if the lock couldn’t be acquired.
     
     If the calling thread was successful in acquiring the lock, the closure will be executed and then immediately after it will release ownership of the lock. If we were unable to acquire the lock, this will return nil.
     
     This method is equivalent to the following sequence of code:
     ```swift
     guard mutex.tryLock() else {
       return nil
     }
     defer {
       mutex.unlock()
     }
     return try body(&value)
     ```
     */
    public borrowing func withLockIfAvailable<Result: ~Copyable, E: Error>(_ body: (inout sending Value) throws(E) -> sending Result) throws(E) -> sending Result? {
        guard storage.tryLock() else { return nil }
        defer { storage.unlock() }
        return try body(&storage.value)
    }

    private final class Storage: @unchecked Sendable {
        private let unfairLock: UnsafeMutablePointer<os_unfair_lock>
        var value: Value

        init(value: consuming Value) {
            self.value = value
            self.unfairLock = .allocate(capacity: 1)
            self.unfairLock.initialize(to: os_unfair_lock())
        }

        deinit {
            unfairLock.deinitialize(count: 1)
            unfairLock.deallocate()
        }

        func lock() {
            os_unfair_lock_lock(unfairLock)
        }

        func unlock() {
            os_unfair_lock_unlock(unfairLock)
        }

        func tryLock() -> Bool {
            os_unfair_lock_trylock(unfairLock)
        }
    }
}

extension Mutex: Sendable where Value: Escapable { }
extension Mutex: SendableMetatype where Value: Escapable { }

extension Mutex where Value : Sendable {
    private struct LockResult<T: ~Copyable, V: ~Copyable>: ~Copyable {
        let bodyResult: T
        let extendedValue: V
    }

    package func withLockExtendingLifetimeOfState<Result: ~Copyable, E>(_ body: (inout sending Value) throws(E) -> sending Result) throws(E) -> sending Result {
        let result = try self.withLock { value throws(E) in
            let copyToExtend = value
            return LockResult(
                bodyResult: try body(&value),
                extendedValue: copyToExtend
            )
        }
        _fixLifetime(result.extendedValue)
        return result.bodyResult
    }
}
