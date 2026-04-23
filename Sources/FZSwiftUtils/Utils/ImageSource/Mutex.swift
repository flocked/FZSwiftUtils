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
public struct Mutex<Value>: @unchecked Sendable {
    private let storage: Storage

    /**
     Initializes a value of this mutex with the given initial state.
     
     - Parameter initalValue: The initial value to give to the mutex.
     */
    public init(_ initalValue: Value) {
        self.storage = Storage(value: initalValue)
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
    public borrowing func withLock<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result {
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
    public borrowing func withLockIfAvailable<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result? {
        guard storage.tryLock() else { return nil }
        defer { storage.unlock() }
        return try body(&storage.value)
    }
}

extension Mutex {
    private final class Storage {
        
        private let unfairLock = os_unfair_lock_t.allocate(capacity: 1)
        
        var value: Value
        
        init(value: consuming Value) {
            self.value = value
            unfairLock.initialize(to: os_unfair_lock())
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
