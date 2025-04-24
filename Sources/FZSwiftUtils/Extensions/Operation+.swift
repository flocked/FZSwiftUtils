//
//  Operation+.swift
//
//
//  Created by Florian Zand on 07.07.24.
//

import Foundation

extension Operation {
    /// Sets the handler to execute after the operation’s main task is completed.
    public func completion(_ completion: (@Sendable () -> Void)?) -> Self {
        self.completionBlock = completion
        return self
    }
}

extension NSObjectProtocol where Self: Operation {
    /// Sets the handler to execute after the operation’s main task is completed.
    public func completion(_ completion: @escaping (@Sendable (Self) -> Void)) -> Self {
        self.completionBlock = {  completion(self) }
        return self
    }
}
