//
//  PausableOperation.swift
//  PausableOperation
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

public protocol Pausable {
    func pause()
    func resume()
    var isPaused: Bool { get }
}

open class PausableOperationQueue: OperationQueue {
    open var _operations: [Pausable] = []
    
    open override func addOperation(_ op: Operation) {
        super.addOperation(op)
        if let pausableOperation = op as? Pausable {
            _operations.append(pausableOperation)
        }
    }
    
    open override func addOperation(_ block: @escaping () -> Void) {
        super.addOperation(block)
    }
    
    open override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        super.addOperations(ops, waitUntilFinished: wait)
        self._operations.append(contentsOf: ops.compactMap({$0 as? Pausable}))
    }

    open func pause() {
        self.isSuspended = true
        _operations.forEach({$0.pause()})
    }
    
    open func resume() {
        self.isSuspended = false
        _operations.forEach({$0.resume()})
    }
    
    open override func cancelAllOperations() {
        super.cancelAllOperations()
        _operations.removeAll()
    }
}
