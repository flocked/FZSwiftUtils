//
//  MeasureTime.swift
//
//
//  Created by Florian Zand on 23.05.22.
//

import Foundation

///  Meassures the time executing a block.
public struct MeasureTime {
    
    /**
     Meassures the time executing a block and prints the result.
     
     - Parameters:
        - operation: The block to meassure.
        - title: The title used for printing.
     */
    @discardableResult
    public static func printTimeElapsed(title: String? = nil, running operation: () -> Void) -> TimeDuration {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        if let title = title {
            print("Time elapsed for \(title): \(timeElapsed) s.")
        } else {
            print("Time elapsed: \(timeElapsed) s.")
        }
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
