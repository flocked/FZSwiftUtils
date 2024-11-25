//
//  MeasureTime.swift
//
//
//  Created by Florian Zand on 23.05.22.
//

import Foundation

///  Meassures the time.
public struct MeasureTime {
    /**
     Meassures the time executing the specified block.
     
     - Parameter block: The block to meassure.
     */
    public static func measure(block: () -> Void) -> TimeDuration {
        start()
        block()
        return stop()
    }
    
    /**
     Meassures the time executing the specified block and prints the duration.
     
     - Parameters:
        - title: An optional string for printing.
        - block: The block to meassure.
     */
    @discardableResult
    public static func measurePrinted(_ title: String? = nil, block: () -> Void) -> TimeDuration {
        start(title)
        block()
        return stopPrinted()
    }
    
    /**
     Starts a measurement.
     
     - Parameter title: An optional title for printing the measurement.
     */
    public static func start(_ title: String? = nil) {
        measurements.append((CFAbsoluteTimeGetCurrent(), title))
    }
    
    /// Stops the current measurement and returns it's duration.
    public static func stop() -> TimeDuration {
        current(remove: true, print: false, details: nil)
    }
    
    /**
     Stops the current measurement, prints it's duration and returns it.
     
     - Parameter details: An optional string for printing.
     */
    @discardableResult
    public static func stopPrinted(_ details: String? = nil) -> TimeDuration {
        current(remove: true, print: true, details: details)
    }
    
    /// Returns the duration of the current measurement.
    public static func log() -> TimeDuration {
        current(remove: false, print: false, details: nil)
    }
    
    /**
     Prints and returns the duration of the current measurement.
     
     - Parameter details: An optional string for printing.
     */
    public static func logPrinted(_ details: String? = nil) -> TimeDuration {
        current(remove: false, print: true, details: details)
    }
    
    private static var measurements = [(startTime: Double, title:String?)]()
    
    private static func current(remove: Bool, print: Bool, details: String?) -> TimeDuration {
        guard !measurements.isEmpty else { return .zero }
        let beginning = remove ? measurements.removeLast() : measurements.last!
        let timeElapsed = CFAbsoluteTimeGetCurrent() - beginning.startTime
        let duration = TimeDuration(Double(timeElapsed))
        if print {
            let indent = "\t".repeated(amount: remove ? measurements.count : measurements.count-1)
            let title = beginning.title == nil ? "" : " for \(beginning.title!)"
            let details = details == nil ? "" : " (\(details!))"
            Swift.print("\(indent)Time elapsed\(title): \(timeElapsed) s.\(details)")
        }
        return duration
    }
}
