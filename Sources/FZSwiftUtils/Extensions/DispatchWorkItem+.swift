//
//  DispatchWorkItem+.swift
//
//
//  Created by Florian Zand on 14.04.24.
//

import Foundation

extension DispatchWorkItem {
    /// Executes the work item’s block synchronously on the specified thread.
    @discardableResult
    public func perform(on queue: DispatchQueue) -> Self {
        queue.sync(execute: self)
        return self
    }
    
    /// Executes the work item’s block asynchronously on the specified thread.
    @discardableResult
    public func performAsync(on queue: DispatchQueue = .main) -> Self {
        queue.async(execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the main thread after the specified delay.
    @discardableResult
    public func perform(after delay: TimeDuration) -> Self {
        perform(after: delay, on: .main)
    }
    
    /// Executes the work item's block asynchronously on the given thread after the specified delay.
    @discardableResult
    public func perform(after delay: TimeDuration, on queue: DispatchQueue) -> Self {
        queue.async(after: delay, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the main thread after the specified delay.
    @_disfavoredOverload
    @discardableResult
    public func perform(after delay: TimeInterval) -> Self {
        perform(after: delay, on: .main)
    }
    
    /// Executes the work item's block asynchronously on the given thread after the specified delay.
    @_disfavoredOverload
    @discardableResult
    public func perform(after delay: TimeInterval, on queue: DispatchQueue) -> Self {
        queue.async(after: delay, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the main thread at the specified date.
    @_disfavoredOverload
    @discardableResult
    public func perform(at date: Date) -> Self {
        perform(at: date, on: .main)
    }
    
    /// Executes the work item's block asynchronously on the given thread  at the specified date.
    @_disfavoredOverload
    @discardableResult
    public func perform(at date: Date, on queue: DispatchQueue) -> Self {
        queue.async(at: date, execute: self)
        return self
    }
    
    /// Executes the work item's block asynchronously on the given thread  at the specified time.
    @discardableResult
    public func perform(at time: DispatchTime) -> Self {
        perform(at: time, on: .main)
    }
    
    /// Executes the work item's block asynchronously on the given thread  at the specified time.
    @discardableResult
    public func perform(at time: DispatchTime, on queue: DispatchQueue) -> Self {
        queue.asyncAfter(deadline: time, execute: self)
        return self
    }
}

public extension DispatchTime {
    /// Returns the duration since boot, excluding any time the system spent asleep.
    var uptime: TimeDuration {
        .init(nanoseconds: Double(uptimeNanoseconds))
    }
    
    /**
     Creates a time relative to `now` from the specified  wall-clock date.
     
     If the date is in the past, the resulting time will be `.now()`.
     
     - Parameter date: The target wall-clock date.
     */
    init(date: Date) {
        self = .now() + max(0, date.timeIntervalSinceNow)
    }
}

public extension DispatchTimeInterval {
    /// The duration of the time interval.
    var duration: TimeDuration? {
        switch self {
        case .seconds(let v):      return .seconds(Double(v))
        case .milliseconds(let v): return .milliseconds(Double(v))
        case .microseconds(let v): return .nanoseconds(Double(v))
        case .nanoseconds(let v):  return .nanoseconds(Double(v))
        default:                   return nil
        }
    }
}
