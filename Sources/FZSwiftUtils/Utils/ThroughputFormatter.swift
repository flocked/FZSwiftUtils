//
//  ThroughputFormatter.swift
//
//
//  Created by Florian Zand on 18.04.25.
//

import Foundation

/// A formatter that creates string representations of a data throughput (bytes per second) (e.g. `14,66 MB/s`).
open class ThroughputFormatter: Formatter {
    private let formatter = NumberFormatter()

    /**
     The allowed units to be used for formatting.
     
     The default value is `all`.
     */
    open var units: Units = .all
    
    /**
     Sets the allowed units to be used for formatting.
     
     The default value is `all`.
     */
    @discardableResult
    open func units( _ units: Units) -> Self {
        self.units = units
        return self
    }
    
    /**
     The unit style.
     
     The default value is `short`.
     */
    open var unitStyle: Formatter.UnitStyle = .short
    
    /**
     Sets the unit style.
     
     The default value is `short`.
     */
    @discardableResult
    open func unitStyle(_ style: Formatter.UnitStyle) -> Self {
        unitStyle = style
        return self
    }
    
    /**
     The count style.
     
     The default value is `file`.
     */
    open var countStyle: ByteCountFormatter.CountStyle = .file
    
    /**
     Sets the count style.
     
     The default value is `file`.
     */
    @discardableResult
    open func countStyle(_ style: ByteCountFormatter.CountStyle) -> Self {
        countStyle = style
        return self
    }
    
    /**
     A Boolean value indicating whether to include the units in the resulting formatted string.
     
     The default value is `true`.
     */
    open var includesUnit: Bool = true
    
    /**
     Sets the Boolean value indicating whether to include the units in the resulting formatted string.
     
     The default value is `true`.
     */
    @discardableResult
    open func includesUnit( _ includes: Bool) -> Self {
        includesUnit = includes
        return self
    }
    
    /**
     A Boolean value indicating whether to include the count in the resulting formatted string.
     
     The default value is `true`.
     */
    open var includesCount: Bool = true
    
    /**
     Sets the Boolean value indicating whether to include the count in the resulting formatted string.
     
     The default value is `true`.
     */
    @discardableResult
    open func includesCount( _ includes: Bool) -> Self {
        includesCount = includes
        return self
    }
    
    /// The allowed number of digits after the decimal separator.
    open var fractionLength: NumberFormatter.DigitLength {
        get { formatter.fractionLength }
        set { formatter.fractionLength = newValue }
    }
    
    /// Sets the allowed number of digits after the decimal separator.
    @discardableResult
    open func fractionLength( _ length: NumberFormatter.DigitLength) -> Self {
        fractionLength = length
        return self
    }
    
    /**
     The locale of the formatter.
     
     The default value is `current`.
     */
    open var locale: Locale = .current
    
    /**
     Sets the locale of the formatter.
     
     The default value is `current`.
     */
    @discardableResult
    open func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// Creates a throughput formatter.
    public init(units: Units = .all, fractionLength: NumberFormatter.DigitLength = .max(2)) {
        super.init()
        self.units = units
        self.fractionLength = fractionLength
    }
    
    public required init?(coder: NSCoder) {
        units = coder.decode("units") ?? units
        unitStyle = coder.decode("unitStyle") ?? unitStyle
        countStyle = coder.decode("countStyle") ?? countStyle
        locale = coder.decode("locale") ?? locale
        includesCount = coder.decode("includesCount") ?? includesCount
        includesUnit = coder.decode("includesUnit") ?? includesUnit
        super.init(coder: coder)
        fractionLength = NumberFormatter.DigitLength(coder: coder) ?? fractionLength
    }
    
    public override func encode(with coder: NSCoder) {
        fractionLength.encode(with: coder)
        coder.encode(units, forKey: "units")
        coder.encode(locale, forKey: "locale")
        coder.encode(unitStyle, forKey: "unitStyle")
        coder.encode(countStyle, forKey: "countStyle")
        coder.encode(includesCount, forKey: "includesCount")
        coder.encode(includesUnit, forKey: "includesUnit")
    }
    
    /// The formatter string for the specified throughput (bytes per second).
    open func string(from dataSizePerSecond: DataSize) -> String {
        string(from: dataSizePerSecond.bytes)
    }
    
    /// The formatted string for the specified throughput (bytes per second).
    open func string<I: BinaryInteger>(from bytesPerSecond: I) -> String {
        if units.isEmpty {
            units = [.bytes]
            defer { units = [] }
            return string(from: bytesPerSecond)
        }
        let units = units.ordered
        var speed = Double(bytesPerSecond)
        var unitIndex = 0
        while unitIndex < units.count - 1, speed >= 1000 {
            speed /= Double(countStyle.factor)
            unitIndex += 1
        }
        var strings: [String] = []
        if includesCount {
            strings += formatter.string(from: speed)!
        }
        if includesUnit {
            strings += units[unitIndex].localized(to: locale, unitStyle: unitStyle) + "/s"
        }
        return strings.joined(separator: " ")
    }
    
    open override func string(for obj: Any?) -> String? {
        if let dataSizePerSecond = obj as? DataSize {
            return string(from: dataSizePerSecond)
        } else if let bytesPerSecond = obj as? any BinaryInteger {
            return string(from: bytesPerSecond)
        }
        return nil
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
        
        var ordered: [UnitInformationStorage] {
            var result: [UnitInformationStorage] = []
            if contains(.bytes) { result += .bytes }
            if contains(.kilobytes) { result += .kilobytes }
            if contains(.megabytes) { result += .megabytes }
            if contains(.gigabytes) { result += .gigabytes }
            if contains(.terabytes) { result += .terabytes }
            if contains(.petabytes) { result += .petabytes }
            if contains(.exabytes) { result += .exabytes }
            if contains(.zettabytes) { result += .zettabytes }
            if contains(.yottabytes) { result += .yottabytes }
            return result
        }
    }
}

public struct ThroughputFFormatStyle: FormatStyle {
    private static var formatter: NumberFormatter { NumberFormatter() }
    
    public var locale: Locale = .autoupdatingCurrent
    
    public func locale(_ locale: Locale) -> Self {
        var copy = self
        copy.locale = locale
        return copy
    }
    
    /**
     The allowed units to be used for formatting.
     
     The default value is `all`.
     */
    public var units: Units = .all
    
    /**
     Sets the allowed units to be used for formatting.
     
     The default value is `all`.
     */
    @discardableResult
    public func units( _ units: Units) -> Self {
        var copy = self
        copy.units = units
        return copy
    }
    
    /**
     The unit style.
     
     The default value is `short`.
     */
    public var unitStyle: UnitStyle = .short
    
    public enum UnitStyle: Int, Codable, Hashable {
        case short
        case medium
        case long
        
        var formatter: ByteCountFormatter.UnitStyle {
            switch self {
            case .short: .short
            case .medium: .medium
            case .long: .long
            }
        }
    }
    
    /**
     Sets the unit style.
     
     The default value is `short`.
     */
    @discardableResult
    public func unitStyle(_ style: UnitStyle) -> Self {
        var copy = self
        copy.unitStyle = style
        return copy
    }
    
    /**
     The count style.
     
     The default value is `file`.
     */
    public var countStyle: CountStyle = .file
    
    public enum CountStyle: Int, Codable, Hashable {
        case file
        case binary
        case memory
        case decimal
        
        var factor: Int {
            self == .binary ? 1024 : 1000
        }
    }
    
    /**
     Sets the count style.
     
     The default value is `file`.
     */
    @discardableResult
    public func countStyle(_ style: CountStyle) -> Self {
        var copy = self
        copy.countStyle = style
        return copy
    }
    
    /**
     A Boolean value indicating whether to include the units in the resulting formatted string.
     
     The default value is `true`.
     */
    public var includesUnit: Bool = true
    
    /**
     Sets the Boolean value indicating whether to include the units in the resulting formatted string.
     
     The default value is `true`.
     */
    @discardableResult
    public func includesUnit( _ includes: Bool) -> Self {
        var copy = self
        copy.includesUnit = includes
        return copy
    }
    
    /**
     A Boolean value indicating whether to include the count in the resulting formatted string.
     
     The default value is `true`.
     */
    public var includesCount: Bool = true
    
    /**
     Sets the Boolean value indicating whether to include the count in the resulting formatted string.
     
     The default value is `true`.
     */
    @discardableResult
    public func includesCount( _ includes: Bool) -> Self {
        var copy = self
        copy.includesCount = includes
        return copy
    }
    
    /// The allowed number of digits after the decimal separator.
    public var fractionLength: DigitLength = .range(1...6)
    
    /// Sets the allowed number of digits after the decimal separator.
    @discardableResult
    public func fractionLength( _ length: DigitLength) -> Self {
        var copy = self
        copy.fractionLength = length
        return copy
    }
    
    
    public struct DigitLength: ExpressibleByIntegerLiteral, CustomStringConvertible, Hashable, Codable {
        var minValue: Int
        var maxValue: Int
        
        init(_ minValue: Int, _ maxValue: Int) {
            self.minValue = minValue
            self.maxValue = maxValue
        }
        
        public init(integerLiteral value: Int) {
            self.init(value, value)
        }
        
        public static func fixed(_ value: Int) -> Self {
            Self(value, value)
        }
        
        public static func range(_ range: ClosedRange<Int>) -> Self {
            Self(range.lowerBound, range.upperBound)
        }
        
        public static func min(_ value: Int) -> Self {
            Self.init(0, value)
        }
        
        public static func max(_ value: Int) -> Self {
            Self(value, .max)
        }

        
        public var description: String {
            "[min: \(minValue), max: \(maxValue)]"
        }
    }
    
    /// Units for formatting data throughput.
    public struct Units: OptionSet, Codable, Hashable {
        /// Bytes per second (B/s)
        public static let bytes = Self(rawValue: 1 << 0)
        /// Kilobytes per second (KB/s)
        public static let kilobytes = Self(rawValue: 1 << 1)
        /// Megabytes per second (MB/s)
        public static let megabytes = Self(rawValue: 1 << 2)
        /// Gigabytes per second (GB/s)
        public static let gigabytes = Self(rawValue: 1 << 3)
        /// Terabytes per second (TB/s)
        public static let terabytes = Self(rawValue: 1 << 4)
        /// Petabytes per second (PB/s)
        public static let petabytes = Self(rawValue: 1 << 5)
        /// Exabytes per second (EB/s)
        public static let exabytes = Self(rawValue: 1 << 6)
        /// Zettabytes per second (ZB/s)
        public static let zettabytes = Self(rawValue: 1 << 7)
        /// Yottabytes per second (YB/s)
        public static let yottabytes = Self(rawValue: 1 << 8)

        /// All units.
        public static let all: Self = [.bytes, .kilobytes, .megabytes, .gigabytes, .terabytes, .petabytes, .exabytes, .zettabytes, .yottabytes]

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        var ordered: [UnitInformationStorage] {
            var result: [UnitInformationStorage] = []
            if contains(.bytes) { result += .bytes }
            if contains(.kilobytes) { result += .kilobytes }
            if contains(.megabytes) { result += .megabytes }
            if contains(.gigabytes) { result += .gigabytes }
            if contains(.terabytes) { result += .terabytes }
            if contains(.petabytes) { result += .petabytes }
            if contains(.exabytes) { result += .exabytes }
            if contains(.zettabytes) { result += .zettabytes }
            if contains(.yottabytes) { result += .yottabytes }
            return result
        }
    }
    
    public func format(_ bytesPerSecond: Int64) -> String {
        Self.formatter.minimumFractionDigits = fractionLength.minValue
        Self.formatter.maximumFractionDigits = fractionLength.maxValue
        let units = (units.isEmpty ? .bytes : units).ordered
        var speed = Double(bytesPerSecond)
        var unitIndex = 0
        while unitIndex < units.count - 1, speed >= 1000 {
            speed /= Double(countStyle.factor)
            unitIndex += 1
        }
        var strings: [String] = []
        if includesCount {
            strings += Self.formatter.string(from: speed)!
        }
        if includesUnit {
            strings += units[unitIndex].localized(to: locale, unitStyle: unitStyle.formatter) + "/s"
        }
        return strings.joined(separator: " ")
    }
}
