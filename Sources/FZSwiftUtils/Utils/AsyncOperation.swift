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
    open var onStateChange: ((State)->())? = nil
    open var error: Error? = nil
    
    open var state: State = State.waiting {
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
        
    open override var isReady: Bool {
        if self.state == .waiting {
            return super.isReady
        } else {
            return self.state == .ready
        }
    }

    open override var isExecuting: Bool {
        if self.state == .waiting {
            return super.isExecuting
        } else {
            return self.state == .executing || self.state == .paused
        }
    }

    open override var isFinished: Bool {
        if self.state == .waiting {
            return super.isFinished
        } else {
            return self.state == .finished
        }
    }

    open override var isCancelled: Bool {
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
        if (self.isExecuting && self.state == .paused) {
            self.state = .executing
        }
    }
    
    open func pause() {
        if (self.isExecuting && self.state != .paused) {
            self.state = .paused
        }
    }
    
    open func finish() {
        if isExecuting {
            self.state = .finished
        }
    }
    
    open override func cancel() {
        if isExecuting {
            self.state = .cancelled
        }
    }

    open override var isAsynchronous: Bool {
        return true
    }
}

open class AsyncBlockOperation: AsyncOperation {
    public typealias Closure = (AsyncBlockOperation) -> ()

    let closure: Closure

    public init(closure: @escaping Closure) {
        self.closure = closure
    }
    
    open override func start() {
        super.start()
        guard self.isExecuting else { return }
        self.closure(self)
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
