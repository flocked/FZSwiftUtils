//
//  DataSize.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import Foundation

/// A struct representing a data size.
public struct DataSize: Hashable, Sendable {
    /// The count style for formatting the data size.
    public typealias CountStyle = ByteCountFormatter.CountStyle

    /**
      Initializes a `DataSize` instance with the given number of bytes and count style.
      
      - Parameters:
        - bytes: The number of bytes.
        - countStyle: The count style for formatting the data size. The default value is `file`.
      */
    public init<Value: BinaryInteger>(_ bytes: Value, countStyle: CountStyle = .file) {
        self.bytes = Int(bytes)
        self.countStyle = countStyle
    }

    /**
     Initializes a `DataSize` instance with the specified sizes in various units and count style.
     
     - Parameters:
       - terabytes: The size in terabytes. The default value is `0`.
       - gigabytes: The size in gigabytes. The default value is `0`.
       - megabytes: The size in megabytes. The default value is `0`.
       - kilobytes: The size in kilobytes. The default value is `0`.
       - bytes: The size in bytes. The default value is `0`.
        - countStyle: The count style for formatting the data size. The default value is `file`.
     */
    public init(petabytes: Double = 0, terabytes: Double = 0, gigabytes: Double = 0, megabytes: Double = 0, kilobytes: Double = 0, bytes: Int = 0, countStyle: CountStyle = .file) {
        self.bytes = bytes
        self.countStyle = countStyle
        self.bytes += self.bytes(for: kilobytes, .kilobyte)
        self.bytes += self.bytes(for: megabytes, .megabyte)
        self.bytes += self.bytes(for: gigabytes, .gigabyte)
        self.bytes += self.bytes(for: terabytes, .terabyte)
        self.bytes += self.bytes(for: petabytes, .petabyte)
    }

    /// The count style for formatting the data size.
    public var countStyle: CountStyle

    /// The size in bytes.
    public var bytes: Int

    /// The size in kilobytes.
    public var kilobytes: Double {
        get { value(for: .kilobyte) }
        set { bytes = bytes(for: newValue, .kilobyte) }
    }

    /// The size in megabytes.
    public var megabytes: Double {
        get { value(for: .megabyte) }
        set { bytes = bytes(for: newValue, .megabyte) }
    }

    /// The size in gigabytes.
    public var gigabytes: Double {
        get { value(for: .gigabyte) }
        set { bytes = bytes(for: newValue, .gigabyte) }
    }

    /// The size in terabytes.
    public var terabytes: Double {
        get { value(for: .terabyte) }
        set { bytes = bytes(for: newValue, .terabyte) }
    }

    /// The size in petabytes.
    public var petabytes: Double {
        get { value(for: .petabyte) }
        set { bytes = bytes(for: newValue, .petabyte) }
    }

    func value(for unit: Unit) -> Double {
        Unit.byte.convert(Double(bytes), to: unit, countStyle: countStyle)
    }

    func bytes(for value: Double, _ unit: Unit) -> Int {
        Int(unit.convert(value, to: .byte, countStyle: countStyle))
    }

    /// Returns a `DataSize`  with zero bytes.
    public static var zero: DataSize {
        return DataSize()
    }
}

public extension DataSize {
    /**
     Returns a data size with the specified bytes.
     
     - Parameters:
        - value: The bytes.
        - countStyle: The count style for formatting the data size. The default value is `file`.
     
     - Returns: `DataSize`with the specified bytes.
     */
    static func bytes(_ value: Int, countStyle: CountStyle = .file) -> Self { Self(bytes: value, countStyle: countStyle) }

    /**
     Returns a data size with the specified kilobytes.
     
     - Parameters:
        - value: The kilobytes.
        - countStyle: The count style for formatting the data size. The default value is `file`.

     - Returns: `DataSize`with the specified kilobytes.
     */
    static func kilobytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(kilobytes: value, countStyle: countStyle) }

    /**
     Returns a data size with the specified megabytes.
     
     - Parameters:
        - value: The megabytes.
        - countStyle: The count style for formatting the data size. The default value is `file`.

     - Returns: `DataSize`with the specified megabytes.
     */
    static func megabytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(megabytes: value, countStyle: countStyle) }

    /**
     Returns a data size with the specified gigabytes.
     
     - Parameters:
        - value: The gigabytes.
        - countStyle: The count style for formatting the data size. The default value is `file`.

     - Returns: `DataSize`with the specified gigabytes.
     */
    static func gigabytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(gigabytes: value, countStyle: countStyle) }

    /**
     Returns a data size with the specified terabytes.
     
     - Parameters:
        - value: The terabytes.
        - countStyle: The count style for formatting the data size. The default value is `file`.

     - Returns: `DataSize`with the specified terabytes.
     */
    static func terabytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(terabytes: value, countStyle: countStyle) }

    /**
     Returns a data size with the specified petabytes.
     
     - Parameters:
        - value: The petabytes.
        - countStyle: The count style for formatting the data size. The default value is `file`.

     - Returns: `DataSize`with the specified petabytes.
     */
    static func petabytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(petabytes: value, countStyle: countStyle) }

}

extension DataSize: Codable {
    enum CodingKeys: CodingKey {
        case bytes
        case countStyle
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys.self)
        try container.encode(bytes, forKey: .bytes)
        try container.encode(countStyle.rawValue, forKey: .countStyle)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let bytes = try container.decode(Int.self, forKey: .bytes)
        let countStyleRaw = try container.decode(Int.self, forKey: .countStyle)
        let countStyle = CountStyle(rawValue: countStyleRaw)!
        self.init(bytes, countStyle: countStyle)
    }
}

extension DataSize: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        bytes = value
        countStyle = .file
    }
}

public extension DataSize {
    ///  Enumeration representing different data size units.
    enum Unit: Int {
        /// Byte
        case byte = 0
        /// Kilobyte
        case kilobyte = 1
        /// Megabyte
        case megabyte = 2
        /// Gigabyte
        case gigabyte = 3
        /// Terabyte
        case terabyte = 4
        /// Petabyte
        case petabyte = 5
        /// Exabyte
        case exabyte = 6
        /// Zettabyte
        case zettabyte = 7
        /// >ottabyte
        case yottabyte = 8

        var byteCountFormatterUnit: ByteCountFormatter.Units {
            switch self {
            case .byte:
                return .useBytes
            case .kilobyte:
                return .useKB
            case .megabyte:
                return .useMB
            case .gigabyte:
                return .useGB
            case .terabyte:
                return .useTB
            case .petabyte:
                return .usePB
            case .exabyte:
                return .useEB
            case .zettabyte:
                return .useZB
            case .yottabyte:
                return .useYBOrHigher
            }
        }

        func convert(_ number: Double, to targetUnit: Unit, countStyle: CountStyle = .file) -> Double {
            let factor: Double = (countStyle == .binary) ? 1024 : 1000
            let conversionFactor = pow(factor, Double(rawValue - targetUnit.rawValue))
            return number * conversionFactor
        }
    }
}

public extension Collection where Element == DataSize {
    /**
      The average size of all data sizes in the collection.
      
      - Returns: A `DataSize` instance representing the average size. If the collection is empty, it returns `zerp`.
      */
    func average() -> DataSize {
        guard !isEmpty else { return .zero }
        let average = Int(compactMap { $0.bytes }.average().rounded(.down))
        return DataSize(average)
    }

    /**
     The total size of all data sizes in the collection.
     
     - Returns: A `DataSize` instance representing the total size. If the collection is empty, it returns `zero`.
     */
    func sum() -> DataSize {
        guard !isEmpty else { return .zero }
        let sum = compactMap { $0.bytes }.sum()
        return DataSize(sum)
    }
}

extension DataSize: CustomStringConvertible {
    /// A string representation of the data size.
    public var description: String {
        let formatter = self.formatter
        formatter.includesActualByteCount = true
        return formatter.string(fromByteCount: Int64(bytes))
    }

    /// A byte count formatter configured with the data size's count style.
    public var formatter: ByteCountFormatter {
        return ByteCountFormatter(allowedUnits: .useAll, countStyle: countStyle)
    }

    /// A string representation of the data size.
    public var string: String {
        return string()
    }

    /**
     Returns a string representation of the data size using the specified unit.
     
     - Parameters:
       - unit: The unit to use for formatting the data size.
       - includesUnit: A Boolean value indicating whether to include the unit in the string representation. The default value is `true`.
     
     - Returns: A string representation of the data size.
     */
    public func string(for unit: Unit, includesUnit: Bool = true) -> String {
        return string(allowedUnits: unit.byteCountFormatterUnit, includesUnit: includesUnit)
    }

    /**
     Returns a string representation of the data size using the specified allowed units.
     
     - Parameters:
       - allowedUnits: The allowed units for formatting the data size. The default value is `useAll`.
       - includesUnit: A Boolean value indicating whether to include the unit in the string representation. The default value is `true`.
     
     - Returns: A string representation of the data size.
     */
    public func string(allowedUnits: ByteCountFormatter.Units = .useAll, includesUnit: Bool = true) -> String {
        let formatter = self.formatter
        formatter.allowedUnits = allowedUnits
        formatter.includesUnit = includesUnit
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

extension DataSize: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let intValue = Int(description) else { return nil }
        bytes = intValue
        countStyle = .binary
    }
}

extension DataSize: Comparable, AdditiveArithmetic {
    /// Adds the two data sizes.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.bytes + rhs.bytes, countStyle: lhs.countStyle)
    }

    /// Adds two data size and stores the result in the left-hand-side variable.
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Subtracts the two data sizes.
    public static func - (lhs: Self, rhs: Self) -> Self {
        var bytes = lhs.bytes - rhs.bytes
        if bytes < 0 { bytes = 0 }
        return Self(bytes, countStyle: lhs.countStyle)
    }

    /// Subtracts the second data size from the first and stores the difference in the left-hand-side variable.
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    /// A Boolean value indicating whether the first data size is smaller than the second data size.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes < rhs.bytes
    }

    /// A Boolean value indicating whether the first data size is smaller or equal to the second data size.
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes <= rhs.bytes
    }

    /// A Boolean value indicating whether the first data size is larger than the second data size.
    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes > rhs.bytes
    }

    /// A Boolean value indicating whether the first data size is larger or equal to the second data size.
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes >= rhs.bytes
    }
}
