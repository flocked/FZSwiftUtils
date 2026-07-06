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
    
    /// Creates an image frame with the specified image and duration.
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

#if os(macOS)
public struct NSImageFrame {
    /// The image of the frame.
    public let image: NSImage
    
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
    
    /// Creates an image frame with the specified image and duration.
    public init(image: NSImage, duration: TimeInterval? = nil) {
        self.image = image
        self.duration = duration?.clamped(min: 0.1)
        self.unclampedDuration = duration?.clamped(min: 0.0)
    }
}
#else
public struct UIImageFrame {
    /// The image of the frame.
    public let image: UIImage
    
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
    
    /// Creates an image frame with the specified image and duration.
    public init(image: UIImage, duration: TimeInterval? = nil) {
        self.image = image
        self.duration = duration?.clamped(min: 0.1)
        self.unclampedDuration = duration?.clamped(min: 0.0)
    }
}
#endif
