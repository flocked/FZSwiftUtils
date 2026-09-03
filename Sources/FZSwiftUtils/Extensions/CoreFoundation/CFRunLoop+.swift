//
//  CFRunLoop+.swift
//
//
//  Created by Florian Zand on 03.09.26.
//

import Foundation

public extension CFRunLoop {
    /// The run loop for the current thread.
    static var current: CFRunLoop {
        CFRunLoopGetCurrent()
    }
    
    /// The main run loop.
    static var main: CFRunLoop {
        CFRunLoopGetMain()
    }
    
    /// A Boolean value indicating whether the run loop is waiting for an event.
    var isWaiting: Bool {
        CFRunLoopIsWaiting(self)
    }
    
    /// All modes currently defined for the run loop.
    var modes: [CFRunLoopMode] {
        (CFRunLoopCopyAllModes(self) as? [CFRunLoopMode]) ?? []
    }
    
    /// The mode in which the run loop is currently running, or `nil` if the run loop isn't running.
    var currentMode: CFRunLoopMode? {
        CFRunLoopCopyCurrentMode(self)
    }
    
    /**
     Runs the current thread's run loop in the specified mode for a limited amount of time.

     You can run a run loop recursively by calling this method from within a run loop callout. Each call creates a nested run loop activation on the current thread's call stack and can run in any available mode, including a mode that's already running higher in the call stack.

     Don't specify [commonModes](https://developer.apple.com/documentation/corefoundation/cfrunloopmode/commonmodes) for `mode`. A run loop always runs in a specific mode; common modes are used when configuring run loop sources, timers, and observers to operate in multiple modes.

     - Parameters:
        - mode: The run loop mode to run. The mode must contain at least one source or timer for the run loop to run.
        - duration: The maximum amount of time, in seconds, to run the run loop. Specify `0` to perform a single pass through the run loop.
        - returnAfterSourceHandled: A Boolean value that indicates whether the run loop returns after processing a source. If `false`, the run loop continues processing events until `duration` elapses or another condition causes it to exit.
     - Returns: A value that indicates why the run loop exited.
     */
    @discardableResult
    static func run(mode: CFRunLoopMode = .defaultMode, duration: CFTimeInterval, returnAfterSourceHandled: Bool = false) -> CFRunLoopRunResult {
        CFRunLoopRunInMode(mode, duration, returnAfterSourceHandled)
    }
    
    /// Wakes the run loop if it is waiting.
    func wakeUp() {
        CFRunLoopWakeUp(self)
    }
    
    /// Stops the run loop from running.
    func stop() {
        CFRunLoopStop(self)
    }
    
    /**
     Adds a run loop source to the specified mode.
     
     - Parameters:
        - source: The run loop source to add.
        - mode: The run loop mode in which to add the source.
     */
    func addSource(_ source: CFRunLoopSource, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopAddSource(self, source, mode)
    }
    
    /**
     Returns a Boolean value indicating whether the specified source is registered in the specified mode.
     
     - Parameters:
        - source: The run loop source to examine.
        - mode: The run loop mode to examine.
     */
    func containsSource(_ source: CFRunLoopSource, mode: CFRunLoopMode = .commonModes) -> Bool {
        CFRunLoopContainsSource(self, source, mode)
    }
    
    /**
     Removes a run loop source from the specified mode.
     
     - Parameters:
        - source: The run loop source to remove.
        - mode: The run loop mode from which to remove the source.
     */
    func removeSource(_ source: CFRunLoopSource, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopRemoveSource(self, source, mode)
    }
    
    /**
     Adds the specified observer to the given mode.
     
     - Parameters:
        - observer: The run loop observer to add.
        - mode: The run loop mode to which to add observer.
     
     A run loop observer can be registered in only one run loop at a time, although it can be added to multiple run loop modes within that run loop. If `observer` already contains observer in mode, this function does nothing.
     */
    func addObserver(_ observer: CFRunLoopObserver, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopAddObserver(self, observer, mode)
    }
    
    /**
     Removes an observer from the run loop for the specified mode.

     Removing an observer from one mode doesn't remove it from any other modes in which it is registered.

     - Parameters:
        - observer: The run loop observer to remove.
        - mode: The run loop mode from which to remove the observer.
     */
    func removeObserver(_ observer: CFRunLoopObserver, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopRemoveObserver(self, observer, mode)
    }
    
    /**
     Returns a Boolean value indicating whether the specified observer is registered in the specified mode.
     
     - Parameters:
        - observer: The run loop observer to examine.
        - mode: The run loop mode to examine.
     */
    func containsObserver(_ observer: CFRunLoopObserver, mode: CFRunLoopMode = .commonModes) -> Bool {
        CFRunLoopContainsObserver(self, observer, mode)
    }
    
    /**
     Adds a mode to the set of common run loop modes.
     
     - Parameter mode: The run loop mode to add.
     */
    func addCommonMode(_ mode: CFRunLoopMode) {
        CFRunLoopAddCommonMode(self, mode)
    }
    
    /**
     Adds a timer to the specified run loop mode.
     
     - Parameters:
        - timer: The run loop timer to add.
        - mode: The run loop mode in which to add the timer.
     */
    func addTimer(_ timer: CFRunLoopTimer, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopAddTimer(self, timer, mode)
    }
    
    /**
     Returns a Boolean value indicating whether the specified timer is registered in the specified mode.
     
     - Parameters:
        - timer: The run loop timer to examine.
        - mode: The run loop mode to examine.
     */
    func containsTimer(_ timer: CFRunLoopTimer, mode: CFRunLoopMode = .commonModes) -> Bool {
        CFRunLoopContainsTimer(self, timer, mode)
    }
    
    /**
     Removes a timer from the specified run loop mode.
     
     - Parameters:
        - timer: The run loop timer to remove.
        - mode: The run loop mode from which to remove the timer.
     */
    func removeTimer(_ timer: CFRunLoopTimer, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopRemoveTimer(self, timer, mode)
    }
    
    /**
     Returns the absolute time at which the next timer in the specified mode will fire.
     
     - Parameter mode: The run loop mode to examine.
     - Returns: The absolute time at which the next timer will fire.
     */
    func nextTimerFireDate(mode: CFRunLoopMode = .defaultMode) -> CFAbsoluteTime {
        CFRunLoopGetNextTimerFireDate(self, mode)
    }
    
    /**
     Enqueues a handler to be executed when the run loop cycles in the specified mode.
     
     The method only enqueues the handler and doesn't wake the run loop. Call ``wakeUp()`` to wake the run loop after scheduling the handler.
     
     - Parameters:
        - mode: The run loop mode in which to perform the handler.
        - handler: The handler to execute.
     */
    func perform(mode: CFRunLoopMode = .defaultMode, handler: @escaping () -> Void) {
        CFRunLoopPerformBlock(self, mode.rawValue, handler)
    }
    
    /**
     Enqueues a handler to be executed when the run loop cycles in any of the specified modes.
     
     The method only enqueues the handler and doesn't wake the run loop. Call ``wakeUp()`` to wake the run loop after scheduling the handler.
     
     - Parameters:
        - modes: The run loop modes in which to perform the handler.
        - handler: The handler to execute.
     */
    func perform(modes: [CFRunLoopMode], handler: @escaping () -> Void) {
        CFRunLoopPerformBlock(self, modes.map(\.rawValue) as CFArray, handler)
    }
}
