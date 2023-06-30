//
//  MeasureTime.swift
//  MeasureTime
//
//  Created by Florian Zand on 23.05.22.
//

import Foundation

/**
 Meassures the time of executing a closure block.
 */
public class MeasureTime {
    /**
     Meassures the time executing a closure block and printing it's result.
     - Parameters operation: The closure block to meassure.
     - Parameters title: The title used for printing.
     */
    @discardableResult
    public class func printTimeElapsed(title: String, running operation: () -> Void) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(title): \(timeElapsed) s.")
        return Double(timeElapsed)
    }

    /**
     Meassures the time executing a closure block.
     - Parameters operation: The closure block to meassure.
     */
    public class func timeElapsed(running operation: () -> Void) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return Double(timeElapsed)
    }
}
