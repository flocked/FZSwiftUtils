//
//  AsyncOperation.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

/**
 An asynchronous, pausable operation.
 
 You have to override ``main()`` to perform your desired task and finish the operation by calling ``finish()``.
  
 Always call `super` when overriding ``start()``, ``cancel()`` ``finish(success:)``, ``pause()`` or ``resume()``.
 */
open class AsyncOperation: Operation, Pausable, @unchecked Sendable {
    
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier ?? Bundle.main.bundlePath + ".AsyncOperationState")
    private var _state: State = .ready
    private let pauseCondition = NSCondition()
    
    /// The handler that is called when the operation starts executing.
    open var startHandler: (()->())? = nil
    
    /// The maximum amount of retries.
    public var maximumRetries = 1

    /// The current retry attempt.
    public private(set) var currentAttempt = 0
    
    /// The state of the operation.
    @objc public enum State: Int, Hashable, CustomStringConvertible {
        /// The operation is ready to start.
        case ready
        /// The operation is executing.
        case executing
        /// The operation is finished.
        case finished
        /// The operation is cancelled.
        case cancelled
        /// The operation is paused.
        case paused
        /// The operation failed.
        case failed
        
        public var description: String {
            switch self {
            case .ready: return "ready"
            case .executing: return "executing"
            case .finished: return "finished"
            case .cancelled: return "cancelled"
            case .paused: return "paused"
            case .failed: return "failed"
            }
        }
    }
    
    /// The state of the operation.
    @objc dynamic public var state: State {
        stateQueue.sync { _state }
    }
        
    private func validateState(_ newState: State, from oldState: State) -> Bool {
        switch newState {
        case .ready:
            return false
        case .executing:
            return oldState == .ready || oldState == .paused
        case .finished:
            return oldState != .cancelled
        case .cancelled:
            return true
        case .paused:
            return oldState == .executing || oldState == .ready
        case .failed:
            return oldState == .executing || oldState == .ready
        }
    }
    
    private func setState(_ newState: State) {
        let oldState = state
        guard newState != oldState else { return }
        guard validateState(newState, from: oldState) else {
            debugPrint("\(String(describing: type(of: self))): Invalid change from `\(oldState)` to `\(newState)`")
            return
        }
        
        var changedKeyPaths = ["state"]
        (operationKeyPaths(for: oldState) + operationKeyPaths(for: newState)).forEach {
            if !changedKeyPaths.contains($0) {
                changedKeyPaths.append($0)
            }
        }
        changedKeyPaths.forEach { willChangeValue(forKey: $0) }
        stateQueue.sync { _state = newState }
        changedKeyPaths.reversed().forEach { didChangeValue(forKey: $0) }
    }
    
    private func operationKeyPaths(for state: State) -> [String] {
        switch state {
        case .ready:
            return ["isReady"]
        case .executing, .paused:
            return ["isExecuting"]
        case .finished, .failed:
            return ["isFinished"]
        case .cancelled:
            return ["isFinished"]
        }
    }
    
    override public var isReady: Bool {
        super.isReady && state == .ready
    }

    override public var isExecuting: Bool {
        state == .executing || state == .paused
    }

    override public var isFinished: Bool {
        state == .finished || state == .cancelled || state == .failed
    }
    
    override public var isAsynchronous: Bool {
        true
    }
    
    /// A Boolean value indicating whether the operation has been paused.
    public var isPaused: Bool {
        state == .paused
    }
    
    /**
     Starts the operation.
     
     If you overwrite this method, call `super.start()`.
     */
    override open func start() {
        guard !isCancelled, !isExecuting, !isFinished else { return }
        setState(.executing)
        currentAttempt = 1
        startHandler?()
        main()
    }
    
    override open func main() {
      fatalError("Subclasses of `AsyncOperation` must implement `main()`.")
    }
    
    /**
     Cancels the operation.
     
     If you overwrite this method, call `super.cancel()`.
     */
    override open func cancel() {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        let shouldSignalPause = state == .paused
        guard !isFinished else { return }
        super.cancel()
        setState(.cancelled)
        if shouldSignalPause {
            pauseCondition.signal()
        }
    }
    
    /**
     Finishes the operation.
     
     If you overwrite this method, call `super.finish(success: sucess)`.
     
     - Parameter success: A Boolean value indicating whether the operation finished successfully.
            
        - If `sucess` is `true`, the operation's state is set to `finish`.
        - If `false`, the operation may retry if the maximum amount of retries isn't reached (``maximumRetries``), otherwise the state is set to `failed`.
     */
    open func finish(success: Bool = true) {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        guard isExecuting, state != .paused else { return }
        if success {
            setState(.finished)
        } else if currentAttempt < maximumRetries {
            currentAttempt += 1
            main()
        } else {
            setState(.failed)
        }
    }

    /**
     Pauses the operation.
     
     If you overwrite this method, call `super.pause()`.
     */
    open func pause() {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        guard isExecuting, state != .paused else { return }
        setState(.paused)
    }
    
    /**
     Resumes the operation, if it's paused.
     
     If you overwrite this method, call `super.resume()`.
     */
    open func resume() {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        guard isExecuting, state == .paused else { return }
        setState(.executing)
        pauseCondition.signal()
    }
    
    /**
     Conditionally blocks the current thread if the operation is paused, and waits until it is resumed or cancelled.

     Use this method within your `main()` implementation to handle scenarios where the operation might be paused. If the operation is not paused, this method returns immediately.
     
     Example usage:
     
     ```swift
     override func main() {
         while someCondition {
            // Pause execution if the operation is paused
            waitIfPaused()
     
            // Perform a unit of work
            processWorkUnit()
         }
        finish()
     }
     ```
     */
    open func waitIfPaused() {
        pauseCondition.lock()
        while state == .paused && !isCancelled {
            pauseCondition.wait()
        }
        pauseCondition.unlock()
    }
}

/// An asynchronous, pausable operation executing a specifed handler.
open class AsyncBlockOperation: AsyncOperation, @unchecked Sendable {
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
    
    override public func main() {
        closure(self)
        finish()
    }
}
