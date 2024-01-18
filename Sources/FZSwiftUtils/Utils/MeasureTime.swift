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
public struct MeasureTime {
    /**
     Meassures the time executing a block and printing it's result.
     
     - Parameters:
        - operation: The block to meassure.
        - title: The title used for printing.
     */
    @discardableResult
    public static func printTimeElapsed(title: String, running operation: () -> Void) -> TimeDuration {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(title): \(timeElapsed) s.")
        return TimeDuration(Double(timeElapsed))
    }

    /**
     Meassures the time executing a block.
     - Parameter operation: The block to meassure.
     */
    public static func timeElapsed(running operation: () -> Void) -> TimeDuration {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return TimeDuration(Double(timeElapsed))
    }
}
