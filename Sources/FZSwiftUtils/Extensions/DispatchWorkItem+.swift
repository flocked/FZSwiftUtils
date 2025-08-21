//
//  DispatchWorkItem+.swift
//
//
//  Created by Florian Zand on 14.04.24.
//

import Foundation

extension DispatchWorkItem {
    /// Executes the work item’s block synchronously on the specified thread.
    public func perform(on queue: DispatchQueue) {
        queue.sync(execute: self)
    }
    
    /// Executes the work item's block asynchronously on the main thread after the specified delay.
    @discardableResult
    public func perform(after delay: TimeDuration) -> Self {
        DispatchQueue.main.async(after: delay, execute: self)
        return self
    }
        
    /// Executes the work item's block asynchronously on the main thread at the specified date.
    @discardableResult
    public func perform(at date: Date) -> Self {
        DispatchQueue.main.async(at: date, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the given thread after the specified delay.
    @discardableResult
    public func perform(after delay: TimeDuration, on queue: DispatchQueue) -> Self {
        queue.async(after: delay, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the given thread  at the specified date.
    @discardableResult
    public func perform(at date: Date, on queue: DispatchQueue) -> Self {
        queue.async(at: date, execute: self)
        return self
    }
}
