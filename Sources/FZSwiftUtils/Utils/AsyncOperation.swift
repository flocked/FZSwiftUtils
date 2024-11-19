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
    
    open var startHandler: (()->())? = nil
    
    private let pauseSemaphore = DispatchSemaphore(value: 0) // Semaphore to pause/resume

    /// The state of the operation.
    open var state: State {
        get { _state }
        set {
            guard newValue != state else { return }
            if validateState(newValue) {
                willChangeValue(for: \.isReady)
                willChangeValue(for: \.isExecuting)
                willChangeValue(for: \.isFinished)
                willChangeValue(for: \.isCancelled)
                _state = newValue
                didChangeValue(for: \.isReady)
                didChangeValue(for: \.isExecuting)
                didChangeValue(for: \.isFinished)
                didChangeValue(for: \.isCancelled)
            } else {
                debugPrint("Invalid change from \(_state) to \(newValue)")
            }
        }
    }
    var _state: State = .waiting
        
    func validateState(_ newState: State) -> Bool {
        switch newState {
        case .waiting, .ready:
            return state == .waiting
        case .executing:
            return state == .ready || state == .waiting || state == .paused
        case .finished:
            return state != .cancelled
        case .cancelled:
            return true
        case .paused:
            return state != .cancelled && state != .finished
        }
    }

    override open var isReady: Bool {
        state == .waiting ? super.isReady : state == .ready
    }

    override open var isExecuting: Bool {
        state == .waiting ? super.isExecuting : state == .executing || state == .paused
    }

    override open var isFinished: Bool {
        state == .waiting ? super.isFinished : state == .finished || state == .cancelled
    }

    override open var isCancelled: Bool {
        state == .waiting ? super.isCancelled : state == .cancelled
    }

    /// A Boolean value indicating whether the operation has been paused.
    open var isPaused: Bool {
        state == .paused
    }
    
    open override func start() {
        guard !isCancelled, !isExecuting, !isFinished else { return }
        state = .executing
        startHandler?()
        main()
    }
    
    override open func cancel() {
        guard isExecuting else { return }
        if isPaused {
            pauseSemaphore.signal()
        }
        state = .cancelled
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
    
    /**
     Pauses the current execution if the operation is paused.
     
     Use it in your `main()` method to stop the remaining execution, if the operation is paused.
     */
    open func pauseExecutionIfPaused() {
        guard isPaused else { return }
        pauseSemaphore.wait()
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
