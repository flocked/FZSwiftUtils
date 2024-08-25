//
//  AsyncOperation.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

/// An asynchronous, pausable operation.
open class AsyncOperation: Operation, Pausable {
    /// The state of the operation.
    public enum State: String, Hashable {
        /// The operation is waiting to start.
        case waiting = "isWaiting"
        /// The operation is ready to start.
        case ready = "isReady"
        /// The operation is executing.
        case executing = "isExecuting"
        /// The operation is finished.
        case finished = "isFinished"
        /// The operation is cancelled.
        case cancelled = "isCancelled"
        /// The operation is paused.
        case paused = "isPaused"
    }

    /// The error, if the operation failed.
    open var error: Error?

    /// The state of the operation.
    open var state: State = .waiting {
        willSet {
            willChangeValue(forKey: State.ready.rawValue)
            willChangeValue(forKey: State.executing.rawValue)
            willChangeValue(forKey: State.finished.rawValue)
            willChangeValue(forKey: State.cancelled.rawValue)
        }
        didSet {
            switch state {
            case .waiting:
                assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(state)")
            case .ready:
                assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(state)")
            case .executing:
                assert( oldValue == .ready || oldValue == .waiting || oldValue == .paused, "Invalid change from \(oldValue) to \(state)")
            case .finished:
                assert(oldValue != .cancelled, "Invalid change from \(oldValue) to \(state)")
            case .cancelled:
                break
            case .paused:
                assert(oldValue == .executing, "Invalid change from \(oldValue) to \(state)")
            }
            didChangeValue(forKey: State.cancelled.rawValue)
            didChangeValue(forKey: State.finished.rawValue)
            didChangeValue(forKey: State.executing.rawValue)
            didChangeValue(forKey: State.ready.rawValue)
        }
    }

    override open var isReady: Bool {
        state == .waiting ? super.isReady : state == .ready
    }

    override open var isExecuting: Bool {
        state == .waiting ? super.isExecuting : state == .executing || state == .paused
    }

    override open var isFinished: Bool {
        state == .waiting ? super.isFinished : state == .finished
    }

    override open var isCancelled: Bool {
        state == .waiting ? super.isCancelled : state == .cancelled
    }

    /// A Boolean value indicating whether the operation has been paused.
    open var isPaused: Bool {
        state == .paused
    }

    /// Resumes the operation, if it's paused.
    open func resume() {
        guard isExecuting, state == .paused else { return }
        state = .executing
    }

    /// Pauses the operation.
    open func pause() {
        guard isExecuting, state != .paused else { return }
        state = .paused
    }

    /// Finishes executing the operation.
    open func finish() {
        guard isExecuting else { return }
        state = .finished
    }

    override open func cancel() {
        guard isExecuting else { return }
        state = .cancelled
    }

    override open var isAsynchronous: Bool {
        true
    }
}

/// A asynchronous, pausable operation executing a specifed handler.
open class AsyncBlockOperation: AsyncOperation {
    /// The handler to execute.
    public let closure: (AsyncBlockOperation) -> Void

    /**
     Initalize a new operation with the specified handler.

     - Parameter closure: The handler to execute.
     - Returns: A new `AsyncBlockOperation` object.
     */
    public init(closure: @escaping ((AsyncBlockOperation) -> Void)) {
        self.closure = closure
    }

    override open func start() {
        super.start()
        guard isExecuting, !isPaused else { return }
        closure(self)
        state = .finished
    }
    
    open override func resume() {
        super.resume()
        guard isExecuting, !isPaused else { return }
        start()
    }
}
