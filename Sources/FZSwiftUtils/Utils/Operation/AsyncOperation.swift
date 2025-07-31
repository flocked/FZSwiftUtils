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
  
 Always call `super` when overriding `start()`, `cancel()`, `finish()`, `pause()` or `resume()`.
 */
open class AsyncOperation: Operation, Pausable {
    
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier ?? Bundle.main.bundlePath + ".AsyncOperationState", attributes: .concurrent)
    private var _state: State = .ready
    private let pauseCondition = NSCondition()
    
    /// The handler that is called when the operation starts executing.
    open var startHandler: (()->())? = nil
    
    /// The maximum amount of retries.
    open var maximumRetries = 1

    /// The current retry attempt.
    open private(set) var currentAttempt = 0
    
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
    @objc dynamic open internal(set) var state: State {
        get { stateQueue.sync { _state } }
        set {
            guard newValue != _state else { return }
            if validateState(newValue) {
                stateQueue.async(flags: .barrier) { self._state = newValue }
            } else {
                debugPrint("\(String(describing: type(of: self))): Invalid change from `\(state)` to `\(newValue)`")
            }
        }
    }
        
    private func validateState(_ newState: State) -> Bool {
        switch newState {
        case .ready:
            return false
        case .executing:
            return state == .ready || state == .paused
        case .finished:
            return state != .cancelled
        case .cancelled:
            return true
        case .paused:
            return state == .executing || state == .ready
        case .failed:
            return state == .executing || state == .ready
        }
    }
    
    override open var isReady: Bool {
        state == .ready
    }

    override open var isExecuting: Bool {
        state == .executing || state == .paused
    }

    override open var isFinished: Bool {
        state == .finished || state == .cancelled || state == .failed
    }
    
    override open var isAsynchronous: Bool {
        true
    }
    
    /// A Boolean value indicating whether the operation has been paused.
    open var isPaused: Bool {
        state == .paused
    }
    
    /// Starts the operation,
    override open func start() {
        guard !isCancelled, !isExecuting, !isFinished else { return }
        state = .executing
        currentAttempt = 1
        startHandler?()
        main()
    }
    
    override open func main() {
      fatalError("Subclasses of `AsyncOperation` must implement `main()`.")
    }
    
    /// Cancels the operation.
    override open func cancel() {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        if state == .ready {
            state = .executing
        }
        super.cancel()
        if state == .paused {
            pauseCondition.signal()
        }
        state = .cancelled
    }
    
    /**
     Finishes the operation.
     
     - Parameter success: A Boolean value indicating whether the operation finished successfully.
     
     - If `success` is `true`, the operation's state is set to `finish`.
     - If `false`, the operation may retry if the maximum amount of retries isn't reached, otherwise the state is set to `failed`.
     */
    open func finish(success: Bool = true) {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        guard isExecuting, state != .paused else { return }
        if success {
            state = .finished
        } else if currentAttempt < maximumRetries {
            currentAttempt += 1
            main()
        } else {
            state = .failed
        }
    }

    /// Pauses the operation.
    open func pause() {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        guard isExecuting, state != .paused else { return }
        state = .paused
    }
    
    /// Resumes the operation, if it's paused.
    open func resume() {
        pauseCondition.lock()
        defer { pauseCondition.unlock() }
        guard isExecuting, state == .paused else { return }
        state = .executing
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
    
    override open class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return ["state"]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
}


/// An asynchronous, pausable operation executing a specifed handler.
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
    
    override public func main() {
        closure(self)
        finish()
    }
}
