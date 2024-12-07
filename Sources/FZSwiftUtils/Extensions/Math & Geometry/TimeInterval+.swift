//
//  TimeInterval+.swift
//
//
//  Created by Florian Zand on 26.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
import QuartzCore

public extension TimeInterval {
    /// The current time interval in seconds.
    static var now: TimeInterval {
        CACurrentMediaTime()
    }
}
#else
import Foundation

public extension TimeInterval {
    /// The current time interval in seconds.
    static var now: TimeInterval {
        var timebaseInfo = mach_timebase_info_data_t()
          mach_timebase_info(&timebaseInfo)
          let nanoseconds = mach_absolute_time() * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)
          return TimeInterval(nanoseconds) / 1_000_000_000
    }
}
#endif
