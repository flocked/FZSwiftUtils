//
//  Thottler.swift
//
//
//  Created by Florian Zand on 13.12.25.
//

import Foundation

/// A utility class that limits the frequency at which a closure can be executed.
open class Throttler {
    /// The throttling mode.
    public enum Mode {
        /**
         Executes closures at a fixed interval from the last execution.
                  
         Repeated calls within the interval will be coalesced into the next scheduled execution.
         */
        case fixed
        /**
         Executing closures is deferred until the interval has passed since the last execution.
         The next execution is deferred until the interval has passed since the last execution.
         
         Executes closures only after no new calls have occurred within the interval.
         
         This is similar to a "debounce" behavior, delaying execution until calls settle.
         */
        case deferred
    }
    
    /// The minimum time interval between successive executions.
    public var interval: TimeDuration

    /// A Boolean value indicating whether the first execution should occur immediately when throttling.
    public var firesImmediately: Bool
    
    /// The throttling mode.
    public var mode: Mode

    /// The dispatch queue on which scheduled closures are executed.
    public let queue: DispatchQueue
    
    private var callback: (() -> ())?
    private var callbackJob: DispatchWorkItem?
    private var nextScheduledTime: DispatchTime?
    private var lastExecutionTime: DispatchTime?
    private let stateQueue = DispatchQueue(label: "com.FZSwiftUtils.throttler")

    /**
     Initializes a new `Throttler`.
     
     - Parameters:
       - interval: The minimum time interval between successive executions.
       - queue: The dispatch queue on which scheduled closures are executed.
       - mode: The throttling mode,
       - firesImmediately: A Boolean value indicating whether the first execution should occur immediately.
     */
    public init(interval: TimeDuration, queue: DispatchQueue = .main, mode: Mode = .fixed, firesImmediately: Bool = false) {
        self.interval = interval
        self.queue = queue
        self.mode = mode
        self.firesImmediately = firesImmediately
    }

    /// Schedules to run the specified block.
    public func throttle(_ block: @escaping ()->()) {
        callbackJob?.cancel()
        callback = block
        let dispatchTime = calculateDispatchTime()
        nextScheduledTime = dispatchTime
        callbackJob = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.stateQueue.sync {
                self.lastExecutionTime = .now()
                self.nextScheduledTime = nil
                self.callback?()
                self.callback = nil
                self.callbackJob = nil
            }
        }.perform(at: dispatchTime, on: queue)
    }
    
    public func callAsFunction(_ block: @escaping ()->()) {
        throttle(block)
    }
    
    /// Cancels any pending throttled execution.
    public func cancel() {
        stateQueue.sync {
            callbackJob?.cancel()
            callbackJob = nil
            callback = nil
            nextScheduledTime = nil
        }
    }
    
    /// Immediately executes the currently scheduled closure.
    public func flush() {
        stateQueue.sync {
            callbackJob?.perform()
        }
    }
    
    private func calculateDispatchTime() -> DispatchTime {
        let now = DispatchTime.now()
        // If last execution + interval is still in the future, schedule after that.
        if let last = lastExecutionTime {
            let candidate = last + interval
            if candidate > now {
                return candidate
            }
        }
        // Immediate first fire if nothing is scheduled.
        if callbackJob == nil, firesImmediately {
            return now
        }
        switch mode {
        case .fixed:
            // If already scheduled, use the previous scheduled time
            if let next = nextScheduledTime, next > now {
                return next
            }
            return now
        case .deferred:
            // Schedule interval after now; this ensures each new call resets the debounce timer
            return now + interval
        }
    }
    
    deinit {
        cancel()
    }
}

/// A timer that throttles execution of a closure to at most once per interval.
class _Throttler {
    
    /// The minimum time between executions.
    public var interval: TimeDuration
    
    /// A Boolean value indicating whether to execute immediately or at the end.
    public var leading: Bool
    
    private let queue: DispatchQueue
    private var lastFireTime: DispatchTime?
    private var workItem: DispatchWorkItem?
    
    /**
     Creates a throttle timer.
     
     - Parameters:
       - interval: The minimum time between executions.
       - queue: The queue to execute on.
       - leading: A Boolean value indicating whether to execute immediately or at the end.
     */
    public init(interval: TimeDuration, queue: DispatchQueue = .main, leading: Bool = true) {
        self.interval = interval
        self.queue = queue
        self.leading = leading
    }
    
    /**
     Schedules an action to run according to the throttle rules.
     
     - Parameter action: Closure to execute.
     
     If enough time has passed since the last execution, the action will execute immediately (if `leading` is true) or schedule for trailing execution.
     */
    public func throttle(_ action: @escaping () -> Void) {
        workItem?.cancel()
        let now = DispatchTime.now()
        if let lastTime = lastFireTime {
            let elapsed = now.uptimeNanoseconds - lastTime.uptimeNanoseconds
            let intervalNs = UInt64(interval.seconds * 1_000_000_000)

            if elapsed >= intervalNs {
                lastFireTime = now
                if leading {
                    action()
                } else {
                    scheduleTrailing(action)
                }
            } else if !leading {
                scheduleTrailing(action, delay: Double(intervalNs - elapsed) / 1_000_000_000)
            }
        } else {
            lastFireTime = now
            if leading {
                action()
            } else {
                scheduleTrailing(action, delay: interval.seconds)
            }
        }
    }
    
    public func callAsFunction(_ action: @escaping () -> Void) {
        throttle(action)
    }
    
    /// Cancels any pending action.
    public func cancel() {
        workItem?.cancel()
        workItem = nil
    }
    
    deinit {
        cancel()
    }
        
    private func scheduleTrailing(_ action: @escaping () -> Void, delay: TimeInterval? = nil) {
        workItem = DispatchWorkItem { [weak self] in
            self?.lastFireTime = DispatchTime.now()
            action()
        }.perform(after: delay ?? interval.seconds, on: queue)
    }
}
