//
//  MeasureTime.swift
//  
//
//  Created by Florian Zand on 23.05.22.
//

import Foundation

/**
 Meassures the time executing a block.
 */
public class MeasureTime {
    /**
     Meassures the time executing a block and printing it's result.
     - Parameters operation: The block to meassure.
     - Parameters title: The title used for printing.
     */
    @discardableResult
    public class func printTimeElapsed(title: String, running operation: () -> Void) -> TimeDuration {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(title): \(timeElapsed) s.")
        return TimeDuration(Double(timeElapsed))
    }

    /**
     Meassures the time executing a block.
     - Parameters operation: The block to meassure.
     */
    public class func timeElapsed(running operation: () -> Void) -> TimeDuration {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return TimeDuration(Double(timeElapsed))
    }
}
