//
//  OperationQueue+.swift
//
//
//  Created by Florian Zand on 31.07.23.
//

import Foundation

public extension OperationQueue {
    /**
     Initalizes an operation queue with the specified maximum number of queued operations that can run at the same time.

     - Parameter maxConcurrentOperationCount: The maximum number of queued operations that can run at the same time.
     - Returns: A new `OperationQueue` object.
     */
    convenience init(maxConcurrentOperationCount: Int) {
        self.init()
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
    
    /// Sets the maximum number of queued operations that can run at the same time.
    @discardableResult
    func maxConcurrentOperationCount(_ value: Int) -> Self {
        maxConcurrentOperationCount = value
        return self
    }
    
    /// Sets the default service level to apply to operations that the queue invokes.
    @discardableResult
    func qualityOfService(_ qualityOfService: QualityOfService) -> Self {
        self.qualityOfService = qualityOfService
        return self
    }
        
    /// Sets the name of the operation queue.
    @discardableResult
    func name(_ name: String?) -> Self {
        self.name = name
        return self
    }
}
