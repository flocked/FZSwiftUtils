//
//  MeasureMemoryUsage.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 14.06.26.
//

import Foundation

/// Measures memory usage.
public struct MeasureMemoryUsage {
    /**
     Measures the memory usage while executing the specified block.

     - Parameter block: The block to measure.
     */
    public static func memoryUsage(block: () -> Void) -> DataSize {
        start()
        block()
        return stop()
    }

    /**
     Measures the memory usage while executing the specified block for a number of times.

     - Parameters:
        - iterations: The number of times to execute the block.
        - block: The block to measure.
     - Returns: The average memory usage, the standard deviation, and the total memory usage.
     */
    public static func memoryUsage(iterations: Int, block: () -> Void) -> (average: DataSize, standardDeviation: DataSize, total: DataSize) {
        guard iterations > 0 else { return (.zero, .zero, .zero) }

        let measurements = (0..<iterations).map { _ in memoryUsage(block: block) }
        let average = measurements.average().bytes
        let varianceSum = measurements.reduce(0.0) { $0 + pow(Double($1.bytes - average), 2) }
        let standardDeviation = DataSize(bytes: UInt64(sqrt(varianceSum / Double(iterations))))

        return (DataSize(bytes: average), standardDeviation, measurements.sum())
    }

    /**
     Measures the memory usage while executing the specified block and prints the result.

     - Parameters:
        - title: An optional string for printing.
        - block: The block to measure.
     - Returns: The memory usage while executing the block.
     */
    @discardableResult
    public static func printMemoryUsage(_ title: String? = nil, block: () -> Void) -> DataSize {
        start(title)
        block()
        return stopPrinted()
    }

    /**
     Measures the memory usage while executing the specified block for a number of times and prints the result.

     - Parameters:
        - title: An optional string for printing.
        - iterations: The number of times to execute the block.
        - block: The block to measure.
     - Returns: The average memory usage, the standard deviation, and the total memory usage.
     */
    @discardableResult
    public static func printMemoryUsage(_ title: String? = nil, iterations: Int, block: () -> Void) -> (average: DataSize, standardDeviation: DataSize, total: DataSize) {
        let measurement = memoryUsage(iterations: iterations, block: block)
        let indent = String(repeating: "\t", count: measurements.count)
        let title = title == nil ? "" : " for \(title!)"

        Swift.print("\(indent)Average memory usage\(title): \(measurement.average).")
        Swift.print("\(indent)- STD Dev.: \(measurement.standardDeviation).")
        Swift.print("\(indent)- Total: \(measurement.total).")

        return measurement
    }

    /**
     Starts a measurement.

     - Parameter title: An optional title for printing the measurement.
     */
    public static func start(_ title: String? = nil) {
        measurements.append((ProcessInfo.processInfo.physicalMemoryUsage, title))
    }

    /// Stops the current measurement and returns its memory usage.
    public static func stop() -> DataSize {
        current(remove: true, print: false, details: nil)
    }

    /**
     Stops the current measurement, prints its memory usage and returns it.

     - Parameter details: An optional string for printing.
     */
    @discardableResult
    public static func stopPrinted(_ details: String? = nil) -> DataSize {
        current(remove: true, print: true, details: details)
    }

    /// Returns the memory usage of the current measurement.
    public static func log() -> DataSize {
        current(remove: false, print: false, details: nil)
    }

    /**
     Prints and returns the memory usage of the current measurement.

     - Parameter details: An optional string for printing.
     */
    public static func logPrinted(_ details: String? = nil) -> DataSize {
        current(remove: false, print: true, details: details)
    }

    private static var measurements = [(startMemoryUsage: DataSize, title: String?)]()

    private static func current(remove: Bool, print: Bool, details: String?) -> DataSize {
        guard !measurements.isEmpty else { return .zero }

        let beginning = remove ? measurements.removeLast() : measurements.last!
        let current = ProcessInfo.processInfo.physicalMemoryUsage
        let memoryUsage = ProcessInfo.processInfo.physicalMemoryUsage - beginning.startMemoryUsage

        if print {
            let indent = String(repeating: "\t", count: remove ? measurements.count : measurements.count - 1)
            let title = beginning.title == nil ? "" : " for \(beginning.title!)"
            let details = details == nil ? "" : " (\(details!))"
            Swift.print("\(indent)Memory usage\(title): \(memoryUsage).\(details)")
        }

        return memoryUsage
    }
}
