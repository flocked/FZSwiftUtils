//
//  DispatchWorkItem+.swift
//
//
//  Created by Florian Zand on 14.04.24.
//

import Foundation

extension DispatchWorkItem {
    /// Executes the work item's block asynchronously on the background thread.
    @discardableResult
    public func perform() -> Self {
        DispatchQueue.main.async(execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the background thread.
    @discardableResult
    public func performBackground(qos: DispatchQoS.QoSClass = .default) -> Self {
        DispatchQueue.global(qos: qos).async(execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the main thread after the specified delay.
    @discardableResult
    public func perform(after delay: TimeInterval) -> Self {
        DispatchQueue.main.asyncAfter(.seconds(delay), execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the main thread after the specified delay.
    @discardableResult
    @_disfavoredOverload
    public func perform(after delay: TimeDuration) -> Self {
        DispatchQueue.main.asyncAfter(delay, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the background thread after the specified delay.
    @discardableResult
    public func performBackground(after delay: TimeInterval, qos: DispatchQoS.QoSClass = .default) -> Self {
        DispatchQueue.global(qos: qos).asyncAfter(delay, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the background thread after the specified delay.
    @discardableResult
    @_disfavoredOverload
    public func performBackground(after delay: TimeDuration, qos: DispatchQoS.QoSClass = .default) -> Self {
        DispatchQueue.global(qos: qos).asyncAfter(delay, execute: self)
        return self
    }
    
    
    /// Executes the work item's block asynchronously on the main thread after at the specified date.
    @discardableResult
    public func perform(at date: Date) -> Self {
        DispatchQueue.main.async(at: date, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the background thread at the specified date.
    @discardableResult
    public func performBackground(at date: Date, qos: DispatchQoS.QoSClass = .default) -> Self {
        DispatchQueue.global(qos: qos).async(at: date, execute: self)
        return self
    }
}
