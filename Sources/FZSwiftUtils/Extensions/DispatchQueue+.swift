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
        .global(qos: .background)
    }
    
    /// The global system queue for tasks that the user does not track actively.
    static var utility: DispatchQueue {
        .global(qos: .utility)
    }
    
    /// The global system queue for tasks that prevent the user from actively using your app.
    static var userInitiated: DispatchQueue {
        .global(qos: .userInitiated)
    }
    
    /// The global system queue for user-interactive tasks, such as animations, event handling, or updating your app’s user interface.
    static var userInteractive: DispatchQueue {
        .global(qos: .userInteractive)
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
     Registers a queue so that it can later be detected as the current executing queue.

     By default, the system queues (`.main`, and all global QoS queues) are automatically registered. Use this method to register additional custom queues for detection.

     - Parameter queue: The dispatch queue to register.
     */
    public static func registerDetection(of queue: DispatchQueue) {
        _registerDetection(of: [queue], key: key)
    }
    
    /**
     The dispatch queue currently executing.
     
     Returns `nil` if the current queue has not been registered.
     
     A dispatch queues needs to be registered first using ``registerDetection(of:)`` in order to be detectable. By default, the system queues (`.main`, and all global QoS queues) are automatically registered.
     */
    public static var current: DispatchQueue? { getSpecific(key: key)?.queue }
    
    /**
     A Boolean value indicating whether the current code is executing on the specified dispatch queue.
     
     - Note: The dispatch queue must first be registered using ``registerDetection(of:)`` in order to be detectable.
     */
    public static func isExecuting(in queue: DispatchQueue) -> Bool {
        DispatchQueue.current == queue
    }
    
    private struct QueueReference { weak var queue: DispatchQueue? }
    
    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        setupSystemQueuesDetection(key: key)
        return key
    }()
    
    private static func _registerDetection(of queues: [DispatchQueue], key: DispatchSpecificKey<QueueReference>) {
        queues.forEach { $0.setSpecific(key: key, value: QueueReference(queue: $0)) }
    }
    
    private static func setupSystemQueuesDetection(key: DispatchSpecificKey<QueueReference>) {
        _registerDetection(of: [.main, .background, .global(qos: .default), .global(qos: .unspecified), .userInitiated, .userInteractive, .utility], key: key)
    }
    
    /**
     Executes the provided `DispatchWorkItem` synchronously on the queue, but avoids deadlock by performing the work item directly if already on the queue.

     - Parameter workItem: The `DispatchWorkItem` to execute.
     */
    public func syncSafely(execute workItem: DispatchWorkItem) {
        if DispatchQueue.isExecuting(in: self) {
            workItem.perform()
        } else {
            sync(execute: workItem)
        }
    }
    
    /**
     Executes the provided closure synchronously on the queue, but avoids deadlock by executing the closure directly if already on the queue.

     - Parameter block: The block that contains the work to perform.
     */
    public func syncSafely(execute block: () -> Void) {
        if DispatchQueue.isExecuting(in: self) {
            block()
        } else {
            sync(execute: block)
        }
    }
    
    /**
     Executes the provided throwing closure synchronously on the queue, avoiding deadlock by executing it directly if already on the queue.

     - Parameter work: The closure to execute.
     - Returns: The result of the closure.
     */
    public func syncSafely<T>(execute work: () throws -> T) rethrows -> T {
        if DispatchQueue.isExecuting(in: self) {
            return try work()
        } else {
            return try sync(execute: work)
        }
    }
    
    /**
     Executes the provided throwing closure synchronously on the queue using the specified flags, avoiding deadlock by executing it directly if already on the queue.

     - Parameters:
        - flags: Additional attributes to apply when executing the block.
        - work: The closure to execute.
     - Returns: The result of the closure.
     */
    public func syncSafely<T>(flags: DispatchWorkItemFlags, execute work: () throws -> T) rethrows -> T {
        if DispatchQueue.isExecuting(in: self) {
            return try work()
        } else {
            return try sync(flags: flags, execute: work)
        }
    }
}

extension DispatchQueue {
    /**
     Submits a single block to the dispatch queue and causes the block to be executed the specified number of times.
     
     This method implements an efficient parallel for-loop. The dispatch queue executes the submitted block the specified number of times and waits for all iterations to complete before returning. If the target queue is a concurrent queue, the blocks run in parallel and must therefore be reentrant-safe.
     
     - Parameters:
        - iterations: The number of times to execute the block. Higher iteration values give the system the ability to balance more efficiently across multiple cores. To get the maximum benefit of this function, configure the number of iterations to be at least three times the number of available cores.
        - work: The block to execute in parallel. The block's iteration parameter specifies the current iteration index.
        - progress: A handler that is called after each iteration.
        - completion: A handler to execute when all iterations finished.
     */
    @_disfavoredOverload
    public class func concurrentPerform(iterations: Int, execute work: ((_ iteration: Int) -> Void), progress: ((_ finished: Int)->())? = nil, completion: (()->())? = nil) {
        guard progress != nil || completion != nil else {
            DispatchQueue.concurrentPerform(iterations: iterations, execute: work)
            return
        }
        let lock = NSLock()
        var completed = 0
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            work(index)
            lock.lock()
            completed += 1
            let count = completed
            lock.unlock()
            
            if let progress = progress {
                DispatchQueue.main.async {
                    progress(count)
                }
            }
            
            if count == iterations {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
    
    /**
     Executes the given closure concurrently for each element the specified collection.

     The order of execution of the `work` closure is not guaranteed because operations are performed concurrently.
     
     The `progress` and `completion` closures are always called on the main thread.
     
     - Parameters:
       - collection: The collection of elements to process concurrently.
       - work: A closure that is executed for each element of the collection.
       - progress: A handler that is called after each element completes.
       - completion: A handler that is called after all elements have been processed.

    Example usage:
     
     ```swift
     let numbers = [1, 2, 3, 4, 5]
     DispatchQueue.concurrentPerform(on: numbers, execute: { number in
         print("Processing \(number)")
     }, progress: { finished in
         print("\(finished) items finished")
     }, completion: {
         print("All items processed")
     })
     ```
     */
    public class func concurrentPerform<C: RandomAccessCollection>(_ collection: C, execute work: ((_ element: C.Element) -> Void), progress: ((_ finished: Int)->())? = nil, completion: (()->())? = nil) {
        concurrentPerform(iterations: collection.count, execute: { index in
            work(collection[collection.index(collection.startIndex, offsetBy: index)])
        }, progress: progress, completion: completion)
    }
    
    /**
     Executes the given closure concurrently for each element the specified sequence.

     The order of execution of the `work` closure is not guaranteed because operations are performed concurrently.
     
     The `progress` and `completion` closures are always called on the main thread.
     
     - Parameters:
       - sequence: The sequence of elements to process concurrently.
       - work: A closure that is executed for each element of the collection.
       - progress: A handler that is called after each element completes.
       - completion: A handler that is called after all elements have been processed.

    Example usage:
     
     ```swift
     let numbers = [1, 2, 3, 4, 5]
     DispatchQueue.concurrentPerform(on: numbers, execute: { number in
         print("Processing \(number)")
     }, progress: { finished in
         print("\(finished) items finished")
     }, completion: {
         print("All items processed")
     })
     ```
     */
    public class func concurrentPerform<S: Sequence>(_ sequence: S, execute work: ((_ element: S.Element) -> Void), progress: ((_ finished: Int)->())? = nil, completion: (()->())? = nil) {
        concurrentPerform(Array(sequence), execute: work, progress: progress, completion: completion)
    }
}

/*
extension DispatchQueue {
    public func asyncSafely(execute workItem: DispatchWorkItem) {
        if DispatchQueue.isExecuting(in: self) {
            workItem.perform()
        } else {
            async(execute: workItem)
        }
    }
    
    public func asyncSafely(execute block: @escaping () -> Void) {
        if DispatchQueue.isExecuting(in: self) {
            block()
        } else {
            async {
                block()
            }
        }
    }
    
    /**
     Executes a block immediately if already running on this queue, otherwise dispatches it asynchronously on this queue.

     - Parameter work: The block to execute.
     */
    public func execOrAsync(execute work: @escaping @convention(block) () -> Void) {
        if DispatchQueue.isExecuting(in: self) {
            work()
        } else {
            async {
                work()
            }
        }
    }
    
    /**
     Executes a block immediately if already running on this queue, otherwise dispatches it synchronously on this queue.

     This method prevents deadlocks by skipping `sync` if the current queue is already the same.

     - Parameter work: The block to execute.
     */
    public func execOrSync(execute work: @convention(block) () -> Void) {
        if DispatchQueue.isExecuting(in: self) {
            work()
        } else {
            sync {
                work()
            }
        }
    }
}
*/
