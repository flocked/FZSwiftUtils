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

    override open func addOperation(_ op: Operation) {
        super.addOperation(op)
        if let pausableOperation = op as? Pausable {
            _operations.append(pausableOperation)
        }
    }

    override open func addOperation(_ block: @escaping () -> Void) {
        super.addOperation(block)
    }

    override open func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        super.addOperations(ops, waitUntilFinished: wait)
        _operations.append(contentsOf: ops.compactMap { $0 as? Pausable })
    }

    open func pause() {
        isSuspended = true
        _operations.forEach { $0.pause() }
    }

    open func resume() {
        isSuspended = false
        _operations.forEach { $0.resume() }
    }

    override open func cancelAllOperations() {
        super.cancelAllOperations()
        _operations.removeAll()
    }
}
