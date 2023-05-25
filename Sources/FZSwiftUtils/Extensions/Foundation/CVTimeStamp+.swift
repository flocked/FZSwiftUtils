//
//  File.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import CoreVideo
import Foundation

public extension CVTimeStamp {
    var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }

    var fps: TimeInterval {
        return TimeInterval(videoTimeScale) / TimeInterval(videoRefreshPeriod)
    }

    var frame: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoRefreshPeriod)
    }

    var seconds: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }

    var rootTotalSeconds: TimeInterval {
        return TimeInterval(hostTime)
    }

    var rootDays: TimeInterval {
        return TimeInterval(hostTime) / (1_000_000_000 * 60 * 60 * 24).truncatingRemainder(dividingBy: 365)
    }

    var rootHours: TimeInterval {
        return TimeInterval(hostTime) / (1_000_000_000 * 60 * 60).truncatingRemainder(dividingBy: 24)
    }

    var rootMinutes: TimeInterval {
        return TimeInterval(hostTime) / (1_000_000_000 * 60).truncatingRemainder(dividingBy: 60)
    }

    var rootSeconds: TimeInterval {
        return TimeInterval(hostTime) / 1_000_000_000.truncatingRemainder(dividingBy: 60)
    }

    var totalSeconds: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }

    var days: TimeInterval {
        return (totalSeconds / (60 * 60 * 24)).truncatingRemainder(dividingBy: 365)
    }

    var hours: TimeInterval {
        return (totalSeconds / (60 * 60)).truncatingRemainder(dividingBy: 24)
    }

    var minutes: TimeInterval {
        return (totalSeconds / 60).truncatingRemainder(dividingBy: 60)
    }

    /*
     var seconds: TimeInterval {
     return totalSeconds.truncatingRemainder(dividingBy: 60)
     }
     */
}
