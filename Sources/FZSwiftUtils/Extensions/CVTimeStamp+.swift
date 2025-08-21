//
//  CVTimeStamp+.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import CoreVideo
import Foundation

public extension CVTimeStamp {
    /// The time interval represented by the time stamp.
    var timeInterval: TimeInterval {
        TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }

    /// The frames per second (FPS).
    var fps: TimeInterval {
        TimeInterval(videoTimeScale) / TimeInterval(videoRefreshPeriod)
    }

    /// The frame duration in seconds.
    var duration: TimeInterval {
        TimeInterval(videoRefreshPeriod) / TimeInterval(videoTimeScale)
    }

    /// The root timestamp in seconds.
    var rootTotalSeconds: TimeInterval {
        TimeInterval(hostTime) / 1_000_000_000
    }

    /// The root timestamp in seconds.
    var rootSeconds: TimeInterval {
        rootTotalSeconds.truncatingRemainder(dividingBy: 60)
    }
    
    /// The root timestamp in minutes.
    var rootMinutes: TimeInterval {
        (rootTotalSeconds / 60).truncatingRemainder(dividingBy: 60)
    }

    
    /// The root timestamp in hours.
    var rootHours: TimeInterval {
        (rootTotalSeconds / 3600).truncatingRemainder(dividingBy: 24)
    }
    
    /// The root timestamp in days.
    var rootDays: TimeInterval {
        (rootTotalSeconds / 86_400).truncatingRemainder(dividingBy: 365)
    }

    /// The total timestamp in seconds.
    var totalSeconds: TimeInterval {
        TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }
    
    /// The timestamp in seconds.
    var seconds: TimeInterval {
        timeInterval.truncatingRemainder(dividingBy: 60)
    }

    /// The timestamp in minutes.
    var minutes: TimeInterval {
        (timeInterval / 60).truncatingRemainder(dividingBy: 60)
    }
    
    /// The timestamp in hours.
    var hours: TimeInterval {
        (timeInterval / 3600).truncatingRemainder(dividingBy: 24)
    }

    /// The timestamp in days.
    var days: TimeInterval {
        (timeInterval / 86_400).truncatingRemainder(dividingBy: 365)
    }
}
