//
//  Debouncer.swift
//
//
//  Created by Florian Zand on 13.12.25.
//

import Foundation

/// A class that delays execution of a closure until a period of inactivity has passed.
public final class Debouncer {
    
    /// The debounce interval.
    public var delay: TimeDuration
    
    /// The dispatch queue on which scheduled closures are executed.
    public let queue: DispatchQueue
    
    private var workItem: DispatchWorkItem?
    private let stateQueue = DispatchQueue(label: "com.FZSwiftUtils.deboucer")
    
    /**
     Creates a debounce timer.
     
     - Parameters:
       - delay: The debounce interval.
       - queue: The dispatch queue on which scheduled closures are executed.
     */
    public init(delay: TimeDuration, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }
    
    /**
     Schedules the specified closure to run after the debounce delay.
     
     If the method is called again before the delay elapsed, the previous scheduled closure execution is cancelled and the delay restarts.
     
     - Parameter action: The closure to execute.
     */
    public func debounce(_ action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            action()
            self.stateQueue.sync {
                self.workItem = nil
            }
        }.perform(after: delay, on: queue)
    }
    
    public func callAsFunction(_ action: @escaping () -> Void) {
        debounce(action)
    }
    
    /// Cancels any pending execution.
    public func cancel() {
        stateQueue.sync {
            workItem?.cancel()
            workItem = nil
        }
    }
    
    /// Immediately executes the currently scheduled closure.
    public func flush() {
        stateQueue.sync {
            workItem?.perform()
        }
    }
    
    deinit {
        cancel()
    }
}
