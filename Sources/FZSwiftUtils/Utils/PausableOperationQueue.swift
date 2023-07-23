//
//  PausableOperation.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

/// A protocol that represents a pausable object.
public protocol Pausable {
    /// Pauses the object.
    func pause()
    /// Resumes the object.
    func resume()
    /// A Boolean value indicating whether the object is paused.
    var isPaused: Bool { get }
}

/// A pausable queue that regulates the execution of operations.
open class PausableOperationQueue: OperationQueue {
    
    /// The operations currently in the queue.
    open private(set)var pausableOperations: [(Pausable & Operation)] = []
    
    internal lazy var sequentialOperationsQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override open func addOperation(_ op: Operation) {
        let completionBlock = op.completionBlock
        if let pausableOperation = op as? (Pausable & Operation) {
            op.completionBlock = {
                self.sequentialOperationsQueue.addOperation {
                    if let index = self.pausableOperations.firstIndex(where: {$0 == op}) {
                        self.pausableOperations.remove(at: index)
                    }
                }
                completionBlock?()
            }
            self.sequentialOperationsQueue.addOperation {
                self.pausableOperations.append(pausableOperation)
            }
        }
        super.addOperation(op)
    }

    override open func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        let pausableOperations = ops.compactMap { $0 as?  (Pausable & Operation) }
        pausableOperations.forEach({ operation in
            let completionBlock = operation.completionBlock
            operation.completionBlock = {
                self.sequentialOperationsQueue.addOperation {
                    if let index = self.pausableOperations.firstIndex(where: {$0 == operation}) {
                        self.pausableOperations.remove(at: index)
                    }
                }
                completionBlock?()
            }

        })
        self.sequentialOperationsQueue.addOperation {
            self.pausableOperations.append(contentsOf: pausableOperations)
        }
        super.addOperations(ops, waitUntilFinished: wait)
    }

    /// Pauses the queue.
    open func pause() {
        isSuspended = true
        self.sequentialOperationsQueue.addOperation {
            self.pausableOperations.filter({$0.isExecuting}).forEach { $0.pause() }
        }
    }

    /// Resznes the queue.
    open func resume() {
        isSuspended = false
        self.sequentialOperationsQueue.addOperation {
            self.pausableOperations.filter({$0.isExecuting}).forEach { $0.resume() }
        }
    }

    override open func cancelAllOperations() {
        super.cancelAllOperations()
        self.sequentialOperationsQueue.addOperation {
            self.pausableOperations.removeAll()
        }
    }
}
