//
//  CGImageFrame.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public struct CGImageFrame {
    /// The image of the frame.
    public let image: CGImage
    
    /**
     The duration of the frame.
     
     The value is clamped to a minimum of`100` millseconds for optimal playback. Use ``unclampedDuration`` to access the original duration.
     */
    public let duration: TimeInterval?
    
    /**
     The original duration of the frame without applying minimum-duration clamping.

     This value may be `0` milliseconds or greater.
     */
    public let unclampedDuration: TimeInterval?
    
    public init(image: CGImage, duration: TimeInterval? = nil) {
        self.image = image
        self.duration = duration?.clamped(min: 0.1)
        self.unclampedDuration = duration?.clamped(min: 0.0)
    }
    
    init(_ image: CGImage, _ durations: (duration: TimeInterval, unclampedDuration: TimeInterval)?) {
        self.image = image
        self.duration = durations?.duration
        self.unclampedDuration = durations?.unclampedDuration
    }
}

/*
public struct CGImageFrame {
    public let image: CGImage
    public let duration: TimeInterval?
    public init(_ image: CGImage, _ duration: TimeInterval?) {
        self.image = image
        self.duration = duration
    }
}
 */

public struct ImageFrame {
    public let image: NSUIImage
    public let duration: TimeInterval?
    public init(_ image: NSUIImage, _ duration: TimeInterval?) {
        self.image = image
        self.duration = duration
    }
}
