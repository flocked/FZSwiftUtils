//
//  DataSize.swift
//  DataSize
//
//  Created by Florian Zand on 19.01.23.
//

import Foundation

public struct DataSize: Hashable, Sendable {
    public typealias CountStyle = ByteCountFormatter.CountStyle

    public init(_ bytes: Int, countStyle: CountStyle = .file) {
        self.bytes = bytes
        self.countStyle = countStyle
    }

    public init(terabytes: Double = 0, gigabytes: Double = 0, megabytes: Double = 0, kilobytes: Double = 0, bytes: Int = 0, countStyle: CountStyle = .file) {
        self.bytes = bytes
        self.countStyle = countStyle
        self.bytes += self.bytes(for: kilobytes, .kilobyte)
        self.bytes += self.bytes(for: megabytes, .megabyte)
        self.bytes += self.bytes(for: gigabytes, .gigabyte)
        self.bytes += self.bytes(for: terabytes, .terabyte)
    }

    public var countStyle: CountStyle

    public var bytes: Int

    public var kilobytes: Double {
        get { value(for: .kilobyte) }
        set { bytes = bytes(for: newValue, .kilobyte) }
    }

    public var megabytes: Double {
        get { value(for: .megabyte) }
        set { bytes = bytes(for: newValue, .megabyte) }
    }

    public var gigabytes: Double {
        get { value(for: .gigabyte) }
        set { bytes = bytes(for: newValue, .gigabyte) }
    }

    public var terabytes: Double {
        get { value(for: .terabyte) }
        set { bytes = bytes(for: newValue, .terabyte) }
    }

    public var petabytes: Double {
        get { value(for: .petabyte) }
        set { bytes = bytes(for: newValue, .petabyte) }
    }

    internal func value(for unit: Unit) -> Double {
        Unit.byte.convert(Double(bytes), to: unit, countStyle: countStyle)
    }

    internal func bytes(for value: Double, _ unit: Unit) -> Int {
        Int(unit.convert(value, to: .byte, countStyle: countStyle))
    }

    public static var zero: DataSize {
        return DataSize()
    }
}

extension DataSize: Codable {
    enum CodingKeys: CodingKey {
        case bytes
        case countStyle
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
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
    enum Unit: Int {
        case byte = 0
        case kilobyte = 1
        case megabyte = 2
        case gigabyte = 3
        case terabyte = 4
        case petabyte = 5
        case exabyte = 6
        case zettabyte = 7
        case yottabyte = 8

        internal var byteCountFormatterUnit: ByteCountFormatter.Units {
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

        internal func convert(_ number: Double, to targetUnit: Unit, countStyle: CountStyle = .file) -> Double {
            let factor: Double = (countStyle == .binary) ? 1024 : 1000
            let conversionFactor = pow(factor, Double(rawValue - targetUnit.rawValue))
            return number * conversionFactor
        }
    }
}

public extension Collection where Element == DataSize {
    func averageSize() -> DataSize {
        guard !isEmpty else { return .zero }
        let average = Int(compactMap { $0.bytes }.average().rounded(.down))
        return DataSize(average)
    }

    func totalSize() -> DataSize {
        guard !isEmpty else { return .zero }
        var total = 0
        forEach { total += $0.bytes }
        return DataSize(total)
    }
}

extension DataSize: Comparable {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.bytes + rhs.bytes, countStyle: lhs.countStyle)
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var bytes = lhs.bytes - rhs.bytes
        if bytes < 0 { bytes = 0 }
        return Self(bytes, countStyle: lhs.countStyle)
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes < rhs.bytes
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes <= rhs.bytes
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes > rhs.bytes
    }

    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.bytes >= rhs.bytes
    }

    /*
     public static func +(lhs: Self, rhs: Int) -> Self {
         Self(lhs.bytes+rhs, countStyle: lhs.countStyle)
     }

     public static func +=(lhs: inout Self, rhs: Int) {
         lhs = lhs + rhs
     }

     public static func -(lhs: Self, rhs: Int) -> Self {
         var bytes = lhs.bytes-rhs
         if (bytes < 0) { bytes = 0 }
         return Self(bytes, countStyle: lhs.countStyle)
     }

     public static func -=(lhs: inout Self, rhs: Int) {
         lhs = lhs - rhs
     }

     public static func <(lhs: Self, rhs: Int) -> Bool {
         return lhs.bytes < rhs
     }

     public static func <=(lhs: Self, rhs: Int) -> Bool {
         return lhs.bytes <= rhs
     }

     public static func >(lhs: Self, rhs: Int) -> Bool {
         return lhs.bytes > rhs
     }

     public static func >=(lhs: Self, rhs: Int) -> Bool {
         return lhs.bytes >= rhs
     }
      */
}

extension DataSize: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let intValue = Int(description) else { return nil }
        bytes = intValue
        countStyle = .binary
    }
}

extension DataSize: CustomStringConvertible {
    public var description: String {
        let formatter = self.formatter
        formatter.includesActualByteCount = true
        return formatter.string(fromByteCount: Int64(bytes))
    }

    public var formatter: ByteCountFormatter {
        return ByteCountFormatter(allowedUnits: .useAll, countStyle: countStyle)
    }

    public var string: String {
        return string()
    }

    public func string(for unit: Unit, includesUnit: Bool = true) -> String {
        return string(allowedUnits: unit.byteCountFormatterUnit, includesUnit: includesUnit)
    }

    public func string(allowedUnits: ByteCountFormatter.Units = .useAll, includesUnit: Bool = true) -> String {
        let formatter = self.formatter
        formatter.allowedUnits = allowedUnits
        formatter.includesUnit = includesUnit
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
