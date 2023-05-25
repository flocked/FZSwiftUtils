//
//  AsyncOperation.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

open class AsyncOperation: Operation, Pausable {
    public enum State: String {
        case waiting = "isWaiting"
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
        case cancelled = "isCancelled"
        case paused = "isPaused"
    }

    open var onStateChange: ((State) -> Void)? = nil
    open var error: Error? = nil

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

    open var isPaused: Bool {
        return self.state == .paused
    }

    open func resume() {
        if isExecuting && state == .paused {
            state = .executing
        }
    }

    open func pause() {
        if isExecuting && state != .paused {
            state = .paused
        }
    }

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

open class AsyncBlockOperation: AsyncOperation {
    public typealias Closure = (AsyncBlockOperation) -> Void

    let closure: Closure

    public init(closure: @escaping Closure) {
        self.closure = closure
    }

    override open func start() {
        super.start()
        guard isExecuting else { return }
        closure(self)
    }
}

/*
 open dynamic var state: State {
     get { return stateQueue.sync { rawState } }
     set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
 }

 private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)

 private var rawState: State = .ready {
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
         if (oldValue != self.state) {
             self.onStateChange?(self.state)
         }
     }
 }

 */
