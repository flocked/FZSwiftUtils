//
//  DispatchWorkItem+.swift
//
//
//  Created by Florian Zand on 14.04.24.
//

import Foundation

extension DispatchWorkItem {
    /// Executes the work item's block asynchronously after the specified delay on the current thread.
    @discardableResult
    public func perform(after delay: TimeInterval) -> Self {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: self)
        return self
    }
}
