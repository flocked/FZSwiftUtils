//
//  TimeInterval+.swift
//
//
//  Created by Florian Zand on 26.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import QuartzCore

public extension TimeInterval {
    /// The current time interval in seconds.
    static var now: TimeInterval {
        return CACurrentMediaTime()
    }
}
#endif
