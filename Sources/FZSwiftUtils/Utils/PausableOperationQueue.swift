//
//  PausableOperationQueue.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

/// A type that can be paused.
public protocol Pausable {
    /// Pauses the object.
    func pause()
    /// Resumes the object.
    func resume()
    /// A Boolean value indicating whether the object is paused.
    var isPaused: Bool { get }
}

/**
 A pausable queue that regulates the execution of operations.
 
 Operations conforming to ``Pausable`` can be paused by pausing the operation queue via ``pause()``.
 */
open class PausableOperationQueue: OperationQueue {
    /// The operations currently in the queue.
    open private(set) var pausableOperations: [Pausable & Operation] = []
    
    let sequentialOperationQueue = OperationQueue(maxConcurrentOperationCount: 1)

    let _progress = MutableProgress()

    /**
     An object that represents the total progress of the operations executing in the queue.
     
     Returns a ``MutableProgress``.
     */
    override open var progress: Progress { _progress }

    override open func addOperation(_ op: Operation) {
        addOperations([op], waitUntilFinished: false)
    }

    override open func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        for operation in ops {
            if let operation = operation as? ProgressReporting & Operation {
                _progress.addChild(operation.progress)
                operation.progress.autoUpdateEstimatedTimeRemaining = true
            } else {
                progress.totalUnitCount += 1
                let completionBlock = operation.completionBlock
                operation.completionBlock = {
                    if operation.isCancelled {
                        self.progress.totalUnitCount -= 1
                    } else {
                        self.progress.completedUnitCount += 1
                    }
                    completionBlock?()
                }
            }
        }
        
        ops.compactMap { $0 as? (Pausable & Operation) }.forEach { operation in
            let completionBlock = operation.completionBlock
            operation.completionBlock = {
                self.sequentialOperationQueue.addOperation {
                    if let index = self.pausableOperations.firstIndex(where: { $0 == operation }) {
                        self.pausableOperations.remove(at: index)
                    }
                }
                completionBlock?()
            }
            sequentialOperationQueue.addOperation {
                self.pausableOperations.append(operation)
            }
        }
        super.addOperations(ops, waitUntilFinished: wait)
    }
    
    /// A Boolean value indicating whether the queue is paused.
    open var isPaused: Bool = false {
        didSet {
            guard oldValue != isPaused else { return }
            isSuspended = isPaused
            sequentialOperationQueue.addOperation {
                self.pausableOperations.filter(\.isExecuting).forEach { 
                    if self.isPaused { $0.pause() } else { $0.resume() }
                }
            }
        }
    }

    /// Pauses the queue.
    open func pause() {
        isPaused = true
    }

    /// Resumes the queue.
    open func resume() {
        isPaused = false
    }

    override open func cancelAllOperations() {
        super.cancelAllOperations()
        sequentialOperationQueue.addOperation {
            self.pausableOperations.removeAll()
        }
    }
}
