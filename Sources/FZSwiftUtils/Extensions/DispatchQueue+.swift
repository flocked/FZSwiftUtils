//
//  DispatchQueue+.swift
//
//
//  Created by Florian Zand on 08.11.23.
//

import Foundation

public extension DispatchQueue {
    /**
     Schedules a work item for execution at the specified time interval, and returns immediately.
     
     - Parameters:
        - timeInterval: The time interval (in seconds) at which to schedule the work item for execution.
        - execute: The work item containing the task to execute.
     */
    func async(after timeInterval: TimeInterval, execute: DispatchWorkItem) {
        asyncAfter(deadline: .now() + timeInterval, execute: execute)
    }
    
    /**
     Schedules a work item for execution at the specified time interval, and returns immediately.
     
     - Parameters:
        - timeInterval: The time interval at which to schedule the work item for execution.
        - execute: The work item containing the task to execute.
     */
    @_disfavoredOverload
    func async(after timeInterval: TimeDuration, execute: DispatchWorkItem) {
        asyncAfter(deadline: .now() + timeInterval.seconds, execute: execute)
    }
    
    /**
     Schedules a block for execution using the specified attributes, and returns immediately.
     
     - Parameters:
        - timeInterval: The time interval (in seconds) at which to schedule the block for execution.
        - qos: The quality-of-service class to use when executing the block. This parameter determines the priority with which the block is scheduled and executed.
        - flags: Additional attributes to apply when executing the block.
        - work: The block containing the work to perform. This block has no return value and no parameters.
     */
    @preconcurrency
    func async(after timeInterval: TimeInterval, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @Sendable () -> Void) {
        asyncAfter(deadline: .now() + timeInterval, qos: qos, flags: flags, execute: work)
    }
    
    /**
     Schedules a block for execution using the specified attributes, and returns immediately.
     
     - Parameters:
        - timeInterval: The time interval at which to schedule the block for execution.
        - qos: The quality-of-service class to use when executing the block. This parameter determines the priority with which the block is scheduled and executed.
        - flags: Additional attributes to apply when executing the block.
        - work: The block containing the work to perform. This block has no return value and no parameters.
     */
    @preconcurrency
    @_disfavoredOverload
    func async(after timeInterval: TimeDuration, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @Sendable () -> Void) {
        asyncAfter(deadline: .now() + timeInterval.seconds, qos: qos, flags: flags, execute: work)
    }
    
    /**
     Schedules a work item for execution at the specified date, and returns immediately.

     - Parameters:
        - date: The date at which to schedule the work item for execution.
        - execute: The work item containing the task to execute.
     */
    func async(at date: Date,  execute: DispatchWorkItem) {
        asyncAfter(wallDeadline: DispatchWallTime(date: date), execute: execute)
    }
    
    /**
     Schedules a block for execution using the specified attributes, and returns immediately.

     - Parameters:
        - date: The date  at which to schedule the block for execution.
        - qos: The quality-of-service class to use when executing the block. This parameter determines the priority with which the block is scheduled and executed.
        - flags: Additional attributes to apply when executing the block.
        - work: The block containing the work to perform. This block has no return value and no parameters.
     */
    func async(at date: Date, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @Sendable () -> Void) {
        asyncAfter(wallDeadline: DispatchWallTime(date: date), qos: qos, flags: flags, execute: work)
    }
    
    /// The global system queue for maintenance or cleanup tasks that you create.
    static var background: DispatchQueue {
        DispatchQueue.global(qos: .background)
    }
    
    /// The global system queue for tasks that the user does not track actively.
    static var utility: DispatchQueue {
        DispatchQueue.global(qos: .utility)
    }
    
    /// The global system queue for tasks that prevent the user from actively using your app.
    static var userInitiated: DispatchQueue {
        DispatchQueue.global(qos: .userInitiated)
    }
    
    /// The global system queue for user-interactive tasks, such as animations, event handling, or updating your app’s user interface.
    static var userInteractive: DispatchQueue {
        DispatchQueue.global(qos: .userInteractive)
    }
}

public extension DispatchWallTime {
    /// Creates an absolute time for a specified date.
    init(date: Date) {
        let seconds = Int(date.timeIntervalSince1970)
        let nanoseconds = Int((date.timeIntervalSince1970 - Double(seconds)) * 1_000_000_000)
        self = DispatchWallTime(timespec: timespec(tv_sec: seconds, tv_nsec: nanoseconds))
    }
}

extension DispatchQueue {
    /**
     Executes the provided `DispatchWorkItem` synchronously on the queue, but avoids deadlock by performing
     the work item directly if already on the queue.

     - Parameter workItem: The `DispatchWorkItem` to execute.
     */
    public func syncSafely(execute workItem: DispatchWorkItem) {
        setKeyIfNeeded()
        if DispatchQueue.getSpecific(key: safeKey) != nil {
            workItem.perform()
        } else {
            sync(execute: workItem)
        }
    }
    
    /**
     Executes the provided closure synchronously on the queue, but avoids deadlock by executing the closure
     directly if already on the queue.

     - Parameter block: The closure to execute.
     */
    public func syncSafely(execute block: () -> Void) {
        setKeyIfNeeded()
        if DispatchQueue.getSpecific(key: safeKey) != nil {
            block()
        } else {
            sync(execute: block)
        }
    }
    
    /**
     Executes the provided throwing closure synchronously on the queue, avoiding deadlock by executing
     it directly if already on the queue.

     - Parameter work: The closure to execute.
     - Returns: The result of the closure.
     - Throws: Rethrows any error thrown by the closure.
     */
    public func syncSafely<T>(execute work: () throws -> T) rethrows -> T {
        setKeyIfNeeded()
        if DispatchQueue.getSpecific(key: safeKey) != nil {
            return try work()
        } else {
            return try sync(execute: work)
        }
    }
    
    /**
     Executes the provided throwing closure synchronously on the queue using the specified flags, avoiding
     deadlock by executing it directly if already on the queue.

     - Parameters:
       - flags: Flags to use for the sync call (e.g., `.barrier`, `.noQoS`).
       - work: The closure to execute.
     - Returns: The result of the closure.
     - Throws: Rethrows any error thrown by the closure.
     */
    public func syncSafely<T>(flags: DispatchWorkItemFlags, execute work: () throws -> T) rethrows -> T {
        setKeyIfNeeded()
        if DispatchQueue.getSpecific(key: safeKey) != nil {
            return try work()
        } else {
            return try sync(flags: flags, execute: work)
        }
    }
    
    private var didSetSafeKey: Bool {
        get { getAssociatedValue("didSetSafeKey") ?? false }
        set { setAssociatedValue(newValue, key: "didSetSafeKey") }
    }
    
    private var safeKey: DispatchSpecificKey<Void> {
        getAssociatedValue("safeKey", initialValue: DispatchSpecificKey<Void>())
    }
    
    private func setKeyIfNeeded() {
        guard !didSetSafeKey else { return }
        setSpecific(key: safeKey, value: ())
        didSetSafeKey = true
    }
    
    /**
     Submits a single block to the dispatch queue and causes the block to be executed the specified number of times.
     
     This method implements an efficient parallel for-loop. The dispatch queue executes the submitted block the specified number of times and waits for all iterations to complete before returning. If the target queue is a concurrent queue, the blocks run in parallel and must therefore be reentrant-safe.
     
     - Parameters:
        - iterations: The number of times to execute the block. Higher iteration values give the system the ability to balance more efficiently across multiple cores. To get the maximum benefit of this function, configure the number of iterations to be at least three times the number of available cores.
        - work: The block to execute in parallel. The block's iteration parameter specifies the current iteration index.
        - progress: The block with the finished iterations count.
        - completion: The block to execute when all iterations finished.
     */
    @_disfavoredOverload
    public class func concurrentPerform(iterations: Int, execute work: ((_ iteration: Int) -> Void), progress: ((_ finished: Int)->())? = nil, completion: (()->())? = nil) {
        if progress != nil || completion != nil {
            var completed = 0
            let lock = DispatchQueue(label: "DispatchQueue.concurrentPerform.")
            DispatchQueue.concurrentPerform(iterations: iterations) { index in
                work(index)
                lock.sync {
                    completed += 1
                    DispatchQueue.main.async {
                        progress?(completed)
                    }
                    if completed == iterations {
                        DispatchQueue.main.async {
                            completion?()
                        }
                    }
                }
            }
        } else {
            DispatchQueue.concurrentPerform(iterations: iterations, execute: work)
        }
    }
}


/*
 public struct Dispatch {
     public static var main: Queue {
         Queue(.main)
     }
    
     public static var background: Queue {
         Queue(.global(qos: .background))
     }
    
     public static var userInteractive: Queue {
         Queue(.global(qos: .userInteractive))
     }
    
     public static var userInitiated: Queue {
         Queue(.global(qos: .userInitiated))
     }
    
     public static var utility: Queue {
         Queue(.global(qos: .utility))
     }
    
     public struct Queue {
         let queue: DispatchQueue
        
         init(_ queue: DispatchQueue) {
             self.queue = queue
         }
        
         public func callAsFunction(execute: @escaping ()->()) {
             queue.async(execute: execute)
         }
        
         public func sync(execute: DispatchWorkItem) {
             queue.sync(execute: execute)
         }
        
         public func sync(execute block: () -> Void) {
             queue.sync(execute: block)
         }
        
         public func asyncAndWait(execute block: () -> Void) {
             queue.asyncAndWait(execute: block)
         }
        
         public func after(_ timeInterval: TimeInterval, execute: DispatchWorkItem) {
             queue.asyncAfter(timeInterval, execute: execute)
         }
        
         @_disfavoredOverload
         public func after(_ timeDuration: TimeDuration, execute: DispatchWorkItem) {
             queue.asyncAfter(timeDuration, execute: execute)
         }
        
         public func after(_ timeInterval: TimeInterval, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute: @escaping @Sendable ()->()) {
             queue.asyncAfter(timeInterval, qos: qos, flags: flags, execute: execute)
         }
        
         @_disfavoredOverload
         public func after(_ timeDuration: TimeDuration, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute: @escaping @Sendable ()->()) {
             queue.asyncAfter(timeDuration, qos: qos, flags: flags, execute: execute)
         }
        
         public func async(at date: Date, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @Sendable () -> Void) {
             queue.async(at: date, qos: qos, flags: flags, execute: work)
         }
        
         public func async(at date: Date,  execute: DispatchWorkItem) {
             queue.async(at: date, execute: execute)
         }
     }
 }
 */
