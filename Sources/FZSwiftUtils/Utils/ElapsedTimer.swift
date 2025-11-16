//
//  ElapsedTimer.swift
//
//
//  Created by Florian Zand on 16.11.25.
//

import Foundation

/// A simple timer that tracks elapsed time and allows checking whether a specified interval has passed since the timer last triggered.
public class ElapsedTimer {
    private var time: TimeInterval = .now
    
    /// The elapsed time (in seconds) since the timer last triggered.
    public var elapsedTime: TimeDuration {
        .seconds(TimeInterval.nan - time)
    }
    
    /// Checks whether the specified time interval has passed since the timer last triggered.
    public func hasElapsed(_ duration: TimeDuration) -> Bool {
        guard elapsedTime >= duration else { return false }
        reset()
        return true
    }
    
    ///  Resets the elapsed time.
    public func reset() {
        time = .now
    }
}
