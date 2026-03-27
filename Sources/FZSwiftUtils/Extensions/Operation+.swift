//
//  Operation+.swift
//
//
//  Created by Florian Zand on 07.07.24.
//

import Foundation

extension Operation {
    /// Sets the handler to execute after the operation’s main task is completed.
    @discardableResult
    public func completion(_ completion: (@Sendable ()->())?) -> Self {
        completionBlock = completion
        return self
    }
    
    /// Sets the handler to execute after the operation’s main task is completed.
    @discardableResult
    public func completion(_ completion: @Sendable @escaping (_ operation: Self)->()) -> Self {
        completionBlock = { completion(self) }
        return self
    }
}
