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
    public enum State: String, Hashable, CustomStringConvertible {
        public var description: String {
            switch self {
            case .ready: return "ready"
            case .executing: return "executing"
            case .finished: return "finished"
            case .cancelled: return "cancelled"
            case .paused: return "paused"
            }
        }
        
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

    /// The handler that gets called when the state changes.
    open var onStateChange: ((State) -> Void)?

    /// The error, if the operation failed.
    open var error: Error?

    /// The state of the operation.
    open var state: State = .ready {
        willSet {
            willChangeValue(for: \.state)
        }
        didSet {
            switch state {
            case .executing:
                assert(oldValue == .ready || oldValue == .paused, "Invalid change from \(oldValue) to \(state)")
            case .finished:
                assert(oldValue != .cancelled, "Invalid change from \(oldValue) to \(state)")
            case .paused:
                assert(oldValue == .executing, "Invalid change from \(oldValue) to \(state)")
            default: break
            }
            didChangeValue(for: \.state)
            if oldValue != state {
                onStateChange?(state)
            }
        }
    }

    override open var isReady: Bool {
        state == .ready
    }

    override open var isExecuting: Bool {
        state == .executing || state == .paused
    }

    override open var isFinished: Bool {
        state == .finished
    }

    override open var isCancelled: Bool {
        state == .cancelled
    }

    /// A Boolean value indicating whether the operation has been paused.
    open var isPaused: Bool {
        state == .paused
    }

    /// Resumes the operation, if it's paused.
    open func resume() {
        if isExecuting, state == .paused {
            state = .executing
        }
    }

    /// Pauses the operation.
    open func pause() {
        if isExecuting, state != .paused {
            state = .paused
        }
    }

    /// Finishes executing the operation.
    open func finish() {
        if isExecuting {
            state = .finished
        }
    }

    override open func cancel() {
        if isExecuting {
            state = .cancelled
        }
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
        guard isExecuting else { return }
        closure(self)
    }
}
