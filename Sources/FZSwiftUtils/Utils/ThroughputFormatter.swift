//
//  ThroughputFormatter.swift
//
//
//  Created by Florian Zand on 18.04.25.
//

import Foundation

/// A formatter that creates string representations of a data throughput (bytes per second).
public class ThroughputFormatter {
    private let formatter = NumberFormatter.decimal

    /// The allowed units to be used for formatting.
    public var units: Units = .all
    
    /// Sets the allowed units to be used for formatting.
    @discardableResult
    public func units( _ units: Units) -> Self {
        self.units = units
        return self
    }
    
    /// A Boolean value indicating whether to include the units in the resulting formatted string.
    public var includesUnit: Bool = true
    
    /// Sets the Boolean value indicating whether to include the units in the resulting formatted string.
    @discardableResult
    public func includesUnit( _ includes: Bool) -> Self {
        includesUnit = includes
        return self
    }
    
    /// A Boolean value indicating whether to include the count in the resulting formatted string.
    public var includesCount: Bool = true
    
    /// Sets the Boolean value indicating whether to include the count in the resulting formatted string.
    @discardableResult
    public func includesCount( _ includes: Bool) -> Self {
        includesCount = includes
        return self
    }
    
    /// The allowed number of digits after the decimal separator.
    public var fractionLength: NumberFormatter.DigitLength {
        get { formatter.fractionLength }
        set { formatter.fractionLength = newValue }
    }
    
    /// Sets the allowed number of digits after the decimal separator.
    @discardableResult
    public func fractionLength( _ length: NumberFormatter.DigitLength) -> Self {
        fractionLength = length
        return self
    }
    
    /// Creates a throughput formatter.
    public init(units: Units = .all, fractionLength: NumberFormatter.DigitLength = .max(2)) {
        self.units = units
        self.fractionLength = fractionLength
    }
            
    /// The formatter string for the specified throughput (bytes per second).
    public func string(for dataSizePerSecond: DataSize) -> String {
        string(for: dataSizePerSecond.bytes)
    }
    
    /// The formatted string for the specified throughput (bytes per second).
    public func string<I: BinaryInteger>(for bytesPerSecond: I) -> String {
        let units = units.ordered
        guard !units.isEmpty else { return "\(bytesPerSecond) B/s" }
        var speed = Double(bytesPerSecond)
        var unitIndex = 0
        while unitIndex < units.count - 1, speed >= 1000 {
            speed /= 1000
            unitIndex += 1
        }
        var strings: [String] = []
        if includesCount {
            strings += formatter.string(from: NSNumber(value: speed)) ?? "\(speed)"
        }
        if includesUnit {
            strings += "\(units[unitIndex].string)"
        }
        return strings.joined(separator: " ")
    }
    
    /// Units for formatting data throughput.
    public struct Units: OptionSet {
        /// Bytes per second (B/s)
        public static let bytes = Units(rawValue: 1 << 0)
        /// Kilobytes per second (KB/s)
        public static let kilobytes = Units(rawValue: 1 << 1)
        /// Megabytes per second (MB/s)
        public static let megabytes = Units(rawValue: 1 << 2)
        /// Gigabytes per second (GB/s)
        public static let gigabytes = Units(rawValue: 1 << 3)
        /// Terabytes per second (TB/s)
        public static let terabytes = Units(rawValue: 1 << 4)
        /// Petabytes per second (PB/s)
        public static let petabytes = Units(rawValue: 1 << 5)
        /// Exabytes per second (EB/s)
        public static let exabytes = Units(rawValue: 1 << 6)
        /// Zettabytes per second (ZB/s)
        public static let zettabytes = Units(rawValue: 1 << 7)
        /// Yottabytes per second (YB/s)
        public static let yottabytes = Units(rawValue: 1 << 8)

        /// All units.
        public static let all: Units = [.bytes, .kilobytes, .megabytes, .gigabytes, .terabytes, .petabytes, .exabytes, .zettabytes, .yottabytes]

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        var ordered: [(unit: Units, string: String)] {
            var result: [(Units, String)] = []
            if contains(.bytes) { result.append((.bytes, "B/s")) }
            if contains(.kilobytes) { result.append((.kilobytes, "KB/s")) }
            if contains(.megabytes) { result.append((.megabytes, "MB/s")) }
            if contains(.gigabytes) { result.append((.gigabytes, "GB/s")) }
            if contains(.terabytes) { result.append((.terabytes, "TB/s")) }
            if contains(.petabytes) { result.append((.petabytes, "PB/s")) }
            if contains(.exabytes) { result.append((.exabytes, "EB/s")) }
            if contains(.zettabytes) { result.append((.zettabytes, "ZB/s"))}
            if contains(.yottabytes) { result.append((.yottabytes, "YB/s"))}
            return result
        }
    }
}
