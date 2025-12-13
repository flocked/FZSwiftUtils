//
//  ElapsedTimer.swift
//
//
//  Created by Florian Zand on 16.11.25.
//

import Foundation

/// A simple timer that tracks elapsed time and allows checking whether a specified interval has passed since the timer last triggered.
public class ElapsedTimer {
    private var startTime: TimeInterval = .now
    
    /// The elapsed time (in seconds) since the timer last triggered.
    public var elapsedTime: TimeDuration {
        .seconds(.now - startTime)
    }
    
    /**
     Checks whether the specified time interval has passed since the timer last triggered.
     
     - Parameter resetIfReached: A Boolean value indicating whether the timer should be reset if the timer has elapsed the specified duration.
     */
    public func hasElapsed(_ duration: TimeDuration, resetIfReached: Bool = true) -> Bool {
        guard elapsedTime >= duration else { return false }
        if resetIfReached {
            reset()
        }
        return true
    }
    
    /**
     The remaining time for the specified duration.
     
     If the timer has elapsed the specified duration, `zero` is returned.
     
     - Parameter resetIfReached: A Boolean value indicating whether the timer should be reset if the timer has elapsed the specified duration.
     */
    public func remainingTime(for duration: TimeDuration, resetIfReached: Bool = true) -> TimeDuration {
        if elapsedTime >= duration {
            if resetIfReached {
                reset()
            }
            return .zero
        }
       return duration-elapsedTime
    }
    
    /**
     The remaining time for the specified duration.
     
     If the timer has elapsed the specified duration, `zero` is returned.
     
     - Parameter resetIfReached: A Boolean value indicating whether the timer should be reset if the timer has elapsed the specified duration.
     */
    public func debouncedTime(for duration: TimeDuration, resetIfReached: Bool = true) -> TimeDuration {
        if elapsedTime >= duration {
            if resetIfReached {
                startTime = .now - (.now-startTime).truncatingRemainder(dividingBy: duration.seconds)
            }
            return .zero
        }
       return duration-elapsedTime
    }
    
    ///  Resets the elapsed time.
    public func reset() {
        startTime = .now
    }
}
