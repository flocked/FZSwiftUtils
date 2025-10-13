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
    public static func timeElapsed(block: () -> Void) -> TimeDuration {
        start()
        block()
        return stop()
    }
    
    /**
     Meassures the time executing the specified block for a number of times.
     
     - Parameters:
        - iterations: The number of times to execute the block.
        - block: The block to meassure.
     - Returns: The average duration of executing the block and the total time to execute the block several times.
     */
    public static func timeElapsed(iterations: Int, block: () -> Void) -> (average: TimeDuration, standardDeviation: TimeDuration, total: TimeDuration) {
        guard iterations > 0 else { return (.zero, .zero, .zero) }
        let measurements = (0..<iterations).map({ _ in timeElapsed(block: block)  })
        let average = measurements.average().seconds
        let varianceSum = measurements.reduce(.zero) { $0 + ($1.seconds - average) * ($1.seconds - average) }
        let standardDeviation = TimeDuration(sqrt(varianceSum / Double(iterations)))
        return (TimeDuration(average), standardDeviation, measurements.sum())
    }
    
    /*
    // IterationResult.init(average: TimeDuration(average), standardDeviation: standardDeviation, totalDuration: measurements.sum(), iterationDurations: measurements)
    public struct IterationResult: Hashable, Codable {
        /// The average duration of executing the block.
        let average: TimeDuration
        /// The standardDeviation.
        let standardDeviation: TimeDuration
        /// The total duration.
        let totalDuration: TimeDuration
        /// The duration of each iteration.
        let iterationDurations: [TimeDuration]
    }
     */
    
    /**
     Meassures the time executing the specified block and prints the duration.
     
     - Parameters:
        - title: An optional string for printing.
        - block: The block to meassure.
     - Returns: The duration of executing the block.
     */
    @discardableResult
    public static func printTimeElapsed(_ title: String? = nil, block: () -> Void) -> TimeDuration {
        start(title)
        block()
        return stopPrinted()
    }
    
    /**
     Meassures the time executing the specified block for a number of times.
     
     - Parameters:
        - title: An optional string for printing.
        - iterations: The number of times to execute the block.
        - block: The block to meassure.
     - Returns: The average duration of executing the block and the total time to execute the block several times.
     */
    @discardableResult
    public static func printTimeElapsed(_ title: String? = nil, iterations: Int, block: () -> Void) -> (average: TimeDuration, standardDeviation: TimeDuration, total: TimeDuration)  {
        let measurement = timeElapsed(iterations: iterations, block: block)
        let indent = String(repeating: "\t", count: measurements.count)
        let title = title == nil ? "" : " for \(title!)"
        Swift.print("\(indent)Average time elapsed\(title): \(measurement.average.seconds) s.")
        Swift.print("\(indent)- STD Dev.: \(measurement.standardDeviation.seconds) s.")
        Swift.print("\(indent)- Total: \(measurement.total.seconds) s.")
        return measurement
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
        if print {
            let indent = String(repeating: "\t", count: remove ? measurements.count : measurements.count-1)
            let title = beginning.title == nil ? "" : " for \(beginning.title!)"
            let details = details == nil ? "" : " (\(details!))"
            Swift.print("\(indent)Time elapsed\(title): \(timeElapsed) s. \(details)")
        }
        return TimeDuration(timeElapsed)
    }
}

/*
struct TimeMess {
    static var measurements: [String: [TimeStamp]] = [:]
    
    static func start(_ id: String) {
        measurements[id] = [TimeStamp()]
    }
    
    static func stop(_ id: String) {
        guard var timeStamps = measurements[id], !timeStamps.isEmpty else { return }
        measurements[id] = nil
        timeStamps += TimeStamp()
    }
    
    static func log(_ id: String, details: String? = nil) {
        measurements[id]?.append(TimeStamp(title: details))
    }
}
*/
