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
}
