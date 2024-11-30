//
//  DispatchWorkItem+.swift
//
//
//  Created by Florian Zand on 14.04.24.
//

import Foundation

extension DispatchWorkItem {
    /// Executes the work item's block asynchronously on the main thread after the specified delay.
    @discardableResult
    public func perform(after delay: TimeInterval) -> Self {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the background thread after the specified delay.
    @discardableResult
    public func performBackground(after delay: TimeInterval) -> Self {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: self)
        return self
    }
}
