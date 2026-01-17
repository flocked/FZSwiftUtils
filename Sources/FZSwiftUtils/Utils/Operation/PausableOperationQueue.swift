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
open class PausableOperationQueue: OperationQueue, @unchecked Sendable {
    var allOperations: SynchronizedArray<Operation> = []
    
    var pausableOperations: [Pausable & Operation] {
        allOperations.compactMap({ $0 as? Pausable & Operation })
    }
        
    let _progress = MutableProgress()
    
    /**
     An object that represents the total progress of the operations executing in the queue.
     
     Returns a ``MutableProgress``.
     */
    override open var progress: Progress { _progress }
    
    override open func addOperation(_ op: Operation) {
        allOperations.append(op)
        setupOperation(op)
        super.addOperation(op)
    }
    
    override open func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        allOperations.append(contentsOf: ops)
        ops.forEach({ setupOperation($0) })
        super.addOperations(ops, waitUntilFinished: wait)
    }
    
    override open func addOperation(_ block: @escaping () -> Void) {
        addOperation(BlockOperation(block))
    }
    
    func setupOperation(_ operation: Operation) {
        let completionBlock = operation.completionBlock
        if let operation = operation as? ProgressReporting & Operation {
            _progress.addChild(operation.progress)
            operation.progress.autoUpdateEstimatedTimeRemaining = true
            operation.completionBlock = { [weak self] in
                completionBlock?()
                guard let self = self else { return }
                self.allOperations.removeFirst(where: { $0 === operation })
            }
        } else {
            progress.totalUnitCount += 1
            operation.completionBlock = { [weak self] in
                completionBlock?()
                guard let self = self else { return }
                self.allOperations.removeFirst(where: { $0 === operation })
                if operation.isCancelled {
                    self.progress.totalUnitCount -= 1
                } else {
                    self.progress.completedUnitCount += 1
                }
            }
        }
    }
    
    /// A Boolean value indicating whether the queue is paused.
    open var isPaused: Bool = false {
        didSet {
            guard oldValue != isPaused else { return }
            isSuspended = isPaused
            pausableOperations.filter({ $0.isExecuting }).forEach({
                if self.isPaused { $0.pause() } else { $0.resume() }
            })
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
    
    internal class BlockOperation: Operation, @unchecked Sendable {
        let block: ()->()
        init(_ block: @escaping () -> Void) {
            self.block = block
        }
        
        override func main() {
            block()
        }
    }
}

/*
 extension OperationQueue {
     /**
      A Boolean value indicating whether operations are paused if the queue is suspended.
      
      If set to `true`, operations conforming to ``Pausable`` are paused/resumed depending on `isSuspended`.
      */
     public var autoPauseOperations: Bool {
         get { getAssociatedValue("autoPauseOperations") ?? false }
         set {
             guard newValue != autoPauseOperations else { return }
             setAssociatedValue(newValue, key: "autoPauseOperations")
             if newValue {
                 isSuspendedObservation = observeChanges(for: \.isSuspended) { [weak self] old, new in
                     guard let self = self else { return }
                     self.pauseOperations()
                 }
                 pauseOperations()
             } else {
                 isSuspendedObservation = nil
             }
         }
     }
     
     func pauseOperations() {
         let isSuspended = isSuspended
         operations.compactMap({ $0 as? Pausable & Operation }).filter({ $0.isExecuting }).forEach({
             if isSuspended { $0.pause() } else { $0.resume() } })
     }
     
     var isSuspendedObservation: KeyValueObservation? {
         get { getAssociatedValue("isSuspendedObservation") }
         set { setAssociatedValue(newValue, key: "isSuspendedObservation") }
     }
     
     var _pausableOperations: [Pausable & Operation] {
         operations.compactMap({ $0 as? Pausable & Operation })
     }
 }
 */
