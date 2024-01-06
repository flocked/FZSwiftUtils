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

    /// The handler that gets called when the state changes.
    open var onStateChange: ((State) -> Void)? = nil
    
    /// The error, if the operation failed.
    open var error: Error? = nil

    /// The state of the operation.
    open var state: State = .waiting {
        willSet {
            willChangeValue(forKey: State.ready.rawValue)
            willChangeValue(forKey: State.executing.rawValue)
            willChangeValue(forKey: State.finished.rawValue)
            willChangeValue(forKey: State.cancelled.rawValue)
        }
        didSet {
            switch self.state {
            case .waiting:
                assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .ready:
                assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .executing:
                assert(
                    oldValue == .ready || oldValue == .waiting || oldValue == .paused,
                    "Invalid change from \(oldValue) to \(self.state)"
                )
            case .finished:
                assert(oldValue != .cancelled, "Invalid change from \(oldValue) to \(self.state)")
            case .cancelled:
                break
            case .paused:
                assert(oldValue == .executing, "Invalid change from \(oldValue) to \(self.state)")
            }

            didChangeValue(forKey: State.cancelled.rawValue)
            didChangeValue(forKey: State.finished.rawValue)
            didChangeValue(forKey: State.executing.rawValue)
            didChangeValue(forKey: State.ready.rawValue)
            if oldValue != self.state {
                self.onStateChange?(self.state)
            }
        }
    }

    override open var isReady: Bool {
        if self.state == .waiting {
            return super.isReady
        } else {
            return self.state == .ready
        }
    }

    override open var isExecuting: Bool {
        if self.state == .waiting {
            return super.isExecuting
        } else {
            return self.state == .executing || self.state == .paused
        }
    }

    override open var isFinished: Bool {
        if self.state == .waiting {
            return super.isFinished
        } else {
            return self.state == .finished
        }
    }

    override open var isCancelled: Bool {
        if self.state == .waiting {
            return super.isCancelled
        } else {
            return self.state == .cancelled
        }
    }

    /// A Boolean value indicating whether the operation has been paused.
    open var isPaused: Bool {
        return self.state == .paused
    }

    /// Resumes the operation, if it's paused.
    open func resume() {
        if isExecuting && state == .paused {
            state = .executing
        }
    }

    /// Pauses the operation.
    open func pause() {
        if isExecuting && state != .paused {
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
        return true
    }
}

/// A asynchronous, pausable operation executing a specifed handler.
open class AsyncBlockOperation: AsyncOperation {
    /// The handler to execute.
    public let closure: ((AsyncBlockOperation) -> ())

    /**
     Initalize a new operation with the specified handler.
     
     - Parameter closure: The handler to execute.
     - Returns: A new `AsyncBlockOperation` object.
     */
    public init(closure: @escaping ((AsyncBlockOperation) -> ())) {
        self.closure = closure
    }

    override open func start() {
        super.start()
        guard isExecuting else { return }
        closure(self)
    }
}
