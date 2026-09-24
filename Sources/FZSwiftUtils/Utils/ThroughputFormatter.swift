//
//  ThroughputFormatter.swift
//
//
//  Created by Florian Zand on 18.04.25.
//

import Foundation

/// A formatter that creates string representations of data throughput in bytes per second, such as `14.66 MB/s`.
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
    open func units(_ units: Units) -> Self {
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
     A Boolean value indicating whether to include the unit in the resulting formatted string.
     
     The default value is `true`.
     */
    open var includesUnit: Bool = true
    
    /**
     Sets whether to include the unit in the resulting formatted string.
     
     The default value is `true`.
     */
    @discardableResult
    open func includesUnit(_ includes: Bool) -> Self {
        includesUnit = includes
        return self
    }
    
    /**
     A Boolean value indicating whether to include the count in the resulting formatted string.
     
     The default value is `true`.
     */
    open var includesCount: Bool = true
    
    /**
     Sets whether to include the count in the resulting formatted string.
     
     The default value is `true`.
     */
    @discardableResult
    open func includesCount(_ includes: Bool) -> Self {
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
    open func fractionLength(_ length: NumberFormatter.DigitLength) -> Self {
        fractionLength = length
        return self
    }
    
    /**
     The locale of the formatter.
     
     The default value is `current`.
     */
    open var locale: Locale {
        get { formatter.locale }
        set { formatter.locale = newValue }
    }
    
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
        includesCount = coder.decode("includesCount") ?? includesCount
        includesUnit = coder.decode("includesUnit") ?? includesUnit
        super.init(coder: coder)
        locale = coder.decode("locale") ?? .current
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
        super.encode(with: coder)
    }
    
    /// Returns the formatted string for the specified throughput in bytes per second.
    open func string(from throughputPerSecond: DataSize) -> String {
        string(from: throughputPerSecond.bytes)
    }
    
    /// Returns the formatted string for the specified throughput in bytes per second.
    open func string<I: BinaryInteger>(from bytesPerSecond: I) -> String {
        let allowedUnits = units.isEmpty ? Units.bytes : units
        let availableUnits = Units.orderedUnits.filter { allowedUnits.contains($0.unit) }
        let factor = Double(countStyle.factor)
        let bytesPerSecond = Double(bytesPerSecond)
        let magnitude = abs(bytesPerSecond)
        
        let selected = availableUnits.last(where: {
            magnitude >= pow(factor, Double($0.exponent))
        }) ?? availableUnits[0]
        
        let value = bytesPerSecond / pow(factor, Double(selected.exponent))
        var strings: [String] = []
        
        if includesCount {
            strings.append(formatter.string(from: value)!)
        }
        
        if includesUnit {
            strings.append(selected.storage.localized(to: locale, unitStyle: unitStyle) + "/s")
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
    
    /// Returns an attributed string for the specified throughput in bytes per second.
    open func attributedString<I: BinaryInteger>(from bytesPerSecond: I) -> AttributedString {
        let allowedUnits = units.isEmpty ? Units.bytes : units
        let availableUnits = Units.orderedUnits.filter { allowedUnits.contains($0.unit) }
        let factor = Double(countStyle.factor)
        let bytesPerSecond = Double(bytesPerSecond)
        let magnitude = abs(bytesPerSecond)
        let selected = availableUnits.last(where: { magnitude >= pow(factor, Double($0.exponent)) }) ?? availableUnits[0]
        let value = bytesPerSecond / pow(factor, Double(selected.exponent))
        let count = AttributedString(formatter.string(from: value)!) { $0.throughput = .count(value) }
        let unit = AttributedString(selected.storage.localized(to: locale, unitStyle: unitStyle) + "/s") { $0.throughput = .unit(selected.unit) }
        
        if includesCount && includesUnit {
            return count + " " + unit
        } else if includesCount {
            return count
        } else if includesUnit {
            return unit
        }
        return AttributedString()
    }
    
    /// Returns an attributed string for the specified throughput in bytes per second.
    open func attributedString(from throughputPerSecond: DataSize) -> AttributedString {
        attributedString(from: throughputPerSecond.bytes)
    }
    
    /// Units for formatting data throughput.
    public struct Units: OptionSet, Hashable, Codable, Sendable {
        /// Bytes per second (B/s).
        public static let bytes = Self(rawValue: 1 << 0)
        /// Kilobytes per second (KB/s).
        public static let kilobytes = Self(rawValue: 1 << 1)
        /// Megabytes per second (MB/s).
        public static let megabytes = Self(rawValue: 1 << 2)
        /// Gigabytes per second (GB/s).
        public static let gigabytes = Self(rawValue: 1 << 3)
        /// Terabytes per second (TB/s).
        public static let terabytes = Self(rawValue: 1 << 4)
        /// Petabytes per second (PB/s).
        public static let petabytes = Self(rawValue: 1 << 5)
        /// Exabytes per second (EB/s).
        public static let exabytes = Self(rawValue: 1 << 6)
        /// Zettabytes per second (ZB/s).
        public static let zettabytes = Self(rawValue: 1 << 7)
        /// Yottabytes per second (YB/s).
        public static let yottabytes = Self(rawValue: 1 << 8)
        
        /// All units.
        public static let all: Self = [.bytes, .kilobytes, .megabytes, .gigabytes, .terabytes, .petabytes, .exabytes, .zettabytes, .yottabytes]
        
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        fileprivate static let orderedUnits: [(unit: Self, storage: UnitInformationStorage, exponent: Int)] = [
            (.bytes, .bytes, 0),
            (.kilobytes, .kilobytes, 1),
            (.megabytes, .megabytes, 2),
            (.gigabytes, .gigabytes, 3),
            (.terabytes, .terabytes, 4),
            (.petabytes, .petabytes, 5),
            (.exabytes, .exabytes, 6),
            (.zettabytes, .zettabytes, 7),
            (.yottabytes, .yottabytes, 8),
        ]
    }
}

/// The component of a formatted throughput value.
public enum ThroughputFormatAttribute: Hashable {
    /// The numeric component and its scaled value.
    case count(Double)
    /// The unit component and its unit.
    case unit(ThroughputFormatter.Units)
}

/// An attributed string key that identifies the component of a formatted throughput value.
public struct ThroughputAttribute: AttributedStringKey {
    public typealias Value = ThroughputFormatAttribute
    public static let name = "FZSwiftUtils.ThroughputAttribute"
}

public extension AttributeScopes {
    /// Attributes used for formatted throughput values.
    struct ThroughputAttributes: AttributeScope {
        /// The component of a formatted throughput value.
        public let throughput: ThroughputAttribute
    }
    
    /// Attributes used for formatted throughput values.
    var throughput: ThroughputAttributes.Type { ThroughputAttributes.self }
}

public extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.ThroughputAttributes, T>) -> T {
        self[T.self]
    }
}

public struct ThroughputFormatStyle: FormatStyle {
    /**
     Creates a format style for formatting data throughput.
     
     - Parameters:
       - units: The allowed units to use for formatting.
       - countStyle: The style used for counting bytes.
       - unitStyle: The style used for displaying units.
       - includesCount: A Boolean value indicating whether the formatted value includes the count.
       - includesUnit: A Boolean value indicating whether the formatted value includes the unit.
       - fractionLength: The number of fractional digits to display.
       - locale: The locale to use for formatting.
     */
    public init(units: Units = .all, countStyle: CountStyle = .file, unitStyle: UnitStyle = .short, includesCount: Bool = true, includesUnit: Bool = true, fractionLength: DigitLength = .range(1...6), locale: Locale = .autoupdatingCurrent) {
        self.units = units
        self.countStyle = countStyle
        self.unitStyle = unitStyle
        self.includesCount = includesCount
        self.includesUnit = includesUnit
        self.fractionLength = fractionLength
        self.locale = locale
    }
    
    /// The locale of the format style.
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
    
    /// The style used to display throughput units.
    public enum UnitStyle: Int, Codable, Hashable {
        /// A short unit style, such as `MB/s`.
        case short = 1
        /// A medium unit style, such as `MByte/s`.
        case medium = 2
        /// A long unit style, such as `megabytes per second`.
        case long = 3
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
    
    /// The style used to determine the units and scaling of throughput values.
    public enum CountStyle: Int, Codable, Hashable {
        /// A file-size style that uses decimal units.
        case file = 0
        /// A memory-size style that uses binary units.
        case memory = 1
        /// A decimal style that uses powers of 1000.
        case decimal = 2
        /// A binary style that uses powers of 1024.
        case binary = 3
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
    
    /**
     The allowed number of digits after the decimal separator.
     
     The default value is `.range(1...6)`
     */
    public var fractionLength: DigitLength = .range(1...6)
    
    /// Sets the allowed number of digits after the decimal separator.
    @discardableResult
    public func fractionLength( _ length: DigitLength) -> Self {
        var copy = self
        copy.fractionLength = length
        return copy
    }

    /// The allowed number of digits.
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
        
        /// A fixed number of digits.
        public static func fixed(_ value: Int) -> Self {
            Self(value, value)
        }
        
        /// A range of allowed digits.
        public static func range(_ range: ClosedRange<Int>) -> Self {
            Self(range.lowerBound, range.upperBound)
        }
        
        /// A minimum number of digits.
        public static func min(_ value: Int) -> Self {
            Self.init(0, value)
        }
        
        /// A maximum number of digits.
        public static func max(_ value: Int) -> Self {
            Self(value, .max)
        }

        
        public var description: String {
            "[min: \(minValue), max: \(maxValue)]"
        }
    }
    
    /// Units for formatting the throughput.
    public struct Units: OptionSet, Hashable, Codable, Sendable {
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

        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
    
    var formatter: ThroughputFormatter {
        Self.cache.withLock {
            $0[FormatKey(locale: locale, units: units.isEmpty ? .bytes : units, unitStyle: unitStyle, countStyle: countStyle, includesUnit: includesUnit, includesCount: includesCount, fractionLength: fractionLength), initial: {
                let formatter = ThroughputFormatter()
                formatter.units = .init(rawValue: (units.isEmpty ? .bytes : units).rawValue)
                formatter.locale = locale
                formatter.countStyle = .init(rawValue: countStyle.rawValue)!
                formatter.unitStyle = .init(rawValue: unitStyle.rawValue)!
                formatter.includesUnit = includesUnit
                formatter.includesCount = includesCount
                formatter.fractionLength = .init(fractionLength.minValue, fractionLength.maxValue)
                return formatter
            }]
        }
    }
    
    public func format(_ throughputPerSecond: DataSize) -> String {
        formatter.string(from: throughputPerSecond)
    }
    
    private struct FormatKey: Hashable {
        let locale: Locale
        let units: Units
        let unitStyle: UnitStyle
        let countStyle: CountStyle
        let includesUnit: Bool
        let includesCount: Bool
        let fractionLength: DigitLength
    }
    
    private static let cache = Mutex([FormatKey: ThroughputFormatter]())
}

public extension FormatStyle where Self == ThroughputFormatStyle {
    /// Returns a format style for formatting data throughput.
    static var throughput: Self { throughput() }
    
    /**
     Returns a format style for formatting data throughput.
     
     - Parameters:
       - units: The allowed units to use for formatting.
       - countStyle: The style used for counting bytes.
       - unitStyle: The style used for displaying units.
       - includesCount: A Boolean value indicating whether the formatted value includes the count.
       - includesUnit: A Boolean value indicating whether the formatted value includes the unit.
       - fractionLength: The number of fractional digits to display.
       - locale: The locale to use for formatting.
     */
    static func throughput(units: Self.Units = .all, countStyle: Self.CountStyle = .file, unitStyle: Self.UnitStyle = .short, includesCount: Bool = true, includesUnit: Bool = true, fractionLength: Self.DigitLength = .range(1...6), locale: Locale = .autoupdatingCurrent) -> Self {
        Self(units: units, countStyle: countStyle, unitStyle: unitStyle, includesCount: includesCount, includesUnit: includesUnit, fractionLength: fractionLength, locale: locale)
    }
}

public extension ThroughputFormatStyle {
    /// An attributed version of this throughput format style.
    var attributed: Attributed {
        Attributed(self)
    }
    
    /// A format style that produces attributed throughput strings.
    struct Attributed: FormatStyle {
        private var style: ThroughputFormatStyle
        
        /**
         Creates a format style for formatting data throughput.
         
         - Parameters:
           - units: The allowed units to use for formatting.
           - countStyle: The style used for counting bytes.
           - unitStyle: The style used for displaying units.
           - includesCount: A Boolean value indicating whether the formatted value includes the count.
           - includesUnit: A Boolean value indicating whether the formatted value includes the unit.
           - fractionLength: The number of fractional digits to display.
           - locale: The locale to use for formatting.
         */
        public init(units: Units = .all, countStyle: CountStyle = .file, unitStyle: UnitStyle = .short, includesCount: Bool = true, includesUnit: Bool = true, fractionLength: DigitLength = .range(1...6), locale: Locale = .autoupdatingCurrent) {
            self.style = .init(units: units, countStyle: countStyle, unitStyle: unitStyle, includesCount: includesCount, includesUnit: includesUnit, fractionLength: fractionLength, locale: locale)
        }
        
        fileprivate init(_ style: ThroughputFormatStyle) {
            self.style = style
        }

        
        /**
         The allowed units to be used for formatting.
         
         The default value is `all`.
         */
        public var units: Units {
            get { style.units }
            set { style.units = newValue }
        }
        
        /**
         Sets the allowed units to be used for formatting.
         
         The default value is `all`.
         */
        @discardableResult
        public func units(_ units: Units) -> Self {
            var copy = self
            copy.units = units
            return copy
        }
        
        /**
         The style used for displaying units.
         
         The default value is `short`.
         */
        public var unitStyle: UnitStyle {
            get { style.unitStyle }
            set { style.unitStyle = newValue }
        }
        
        /**
         Sets the style used for displaying units.
         
         The default value is `short`.
         */
        @discardableResult
        public func unitStyle(_ unitStyle: UnitStyle) -> Self {
            var copy = self
            copy.unitStyle = unitStyle
            return copy
        }
        
        /**
         The style used for determining the units and scaling of throughput values.
         
         The default value is `file`.
         */
        public var countStyle: CountStyle {
            get { style.countStyle }
            set { style.countStyle = newValue }
        }
        
        /**
         Sets the style used for determining the units and scaling of throughput values.
         
         The default value is `file`.
         */
        @discardableResult
        public func countStyle(_ countStyle: CountStyle) -> Self {
            var copy = self
            copy.countStyle = countStyle
            return copy
        }
        
        /**
         A Boolean value indicating whether the formatted value includes the count.
         
         The default value is `true`.
         */
        public var includesCount: Bool {
            get { style.includesCount }
            set { style.includesCount = newValue }
        }
        
        /**
         Sets whether the formatted value includes the count.
         
         The default value is `true`.
         */
        @discardableResult
        public func includesCount(_ includesCount: Bool) -> Self {
            var copy = self
            copy.includesCount = includesCount
            return copy
        }
        
        /**
         A Boolean value indicating whether the formatted value includes the unit.
         
         The default value is `true`.
         */
        public var includesUnit: Bool {
            get { style.includesUnit }
            set { style.includesUnit = newValue }
        }
        
        /**
         Sets whether the formatted value includes the unit.
         
         The default value is `true`.
         */
        @discardableResult
        public func includesUnit(_ includesUnit: Bool) -> Self {
            var copy = self
            copy.includesUnit = includesUnit
            return copy
        }
        
        /**
         The number of fractional digits to display.
         
         The default value is `range(1...6)`.
         */
        public var fractionLength: DigitLength {
            get { style.fractionLength }
            set { style.fractionLength = newValue }
        }
        
        /**
         Sets the number of fractional digits to display.
         
         The default value is `range(1...6)`.
         */
        @discardableResult
        public func fractionLength(_ fractionLength: DigitLength) -> Self {
            var copy = self
            copy.fractionLength = fractionLength
            return copy
        }
        
        /**
         The locale to use for formatting.
         
         The default value is `autoupdatingCurrent`.
         */
        public var locale: Locale {
            get { style.locale }
            set { style.locale = newValue }
        }
        
        /**
         Sets the locale to use for formatting.
         
         The default value is `autoupdatingCurrent`.
         */
        @discardableResult
        public func locale(_ locale: Locale) -> Self {
            var copy = self
            copy.locale = locale
            return copy
        }
        
        /// Returns an attributed string representation of the specified throughput.
        public func format(_ value: DataSize) -> AttributedString {
            style.formatter.attributedString(from: value)
        }
    }
}

public extension FormatStyle where Self == ThroughputFormatStyle.Attributed {
    /// Returns a format style for formatting data throughput.
    @_disfavoredOverload
    static var throughput: Self { throughput() }
    
    /**
     Returns a format style for formatting data throughput.
     
     - Parameters:
       - units: The allowed units to use for formatting.
       - countStyle: The style used for counting bytes.
       - unitStyle: The style used for displaying units.
       - includesCount: A Boolean value indicating whether the formatted value includes the count.
       - includesUnit: A Boolean value indicating whether the formatted value includes the unit.
       - fractionLength: The number of fractional digits to display.
       - locale: The locale to use for formatting.
     */
    @_disfavoredOverload
    static func throughput(units: ThroughputFormatStyle.Units = .all, countStyle: ThroughputFormatStyle.CountStyle = .file, unitStyle: ThroughputFormatStyle.UnitStyle = .short, includesCount: Bool = true, includesUnit: Bool = true, fractionLength: ThroughputFormatStyle.DigitLength = .range(1...6), locale: Locale = .autoupdatingCurrent) -> Self {
        Self(units: units, countStyle: countStyle, unitStyle: unitStyle, includesCount: includesCount, includesUnit: includesUnit, fractionLength: fractionLength, locale: locale)
    }
}
