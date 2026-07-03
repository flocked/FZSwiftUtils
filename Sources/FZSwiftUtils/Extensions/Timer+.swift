//
//  Timer+.swift
//
//
//  Created by Florian Zand on 03.07.26.
//

import Foundation


public extension Timer {
    /**
     Schedules the timer on the specified run loop in the given run loop mode.

     Use this method to schedule a timer in a run loop mode other than the default, such as [eventTracking](https://developer.apple.com/documentation/foundation/runloop/mode/eventtracking) to allow the timer to continue firing while tracking mouse events.

     - Parameters:
       - runLoop: The run loop on which to schedule the timer. The default value is the main run loop.
       - mode: The run loop mode in which to schedule the timer.
     */
    func schedule(to runLoop: RunLoop = .main, in mode: RunLoop.Mode) {
        runLoop.add(self, forMode: mode)
    }
}
