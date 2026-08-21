//
//  DataSize.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import Foundation

/**
 A structure representing a data size.

 Use the provided formatting methods to generate localized string representations:

 - ``string(for:unitStyle:zeroPadsFractionDigits:includesActualByteCount:locale:)``
 - ``string(allowedUnits:unitStyle:zeroPadsFractionDigits:includesActualByteCount:locale:)``
 - ``stringDetailed(unitStyle:zeroPadsFractionDigits:locale:)``

 You can also format a `DataSize` using ``Foundation/ByteCountFormatter`` and it's [string(for:)](https://developer.apple.com/documentation/foundation/bytecountformatter/string(for:)).
 */
public struct DataSize: Hashable, Sendable {
    /**
     Initializes a `DataSize` instance with the given number of bytes and count style.

     - Parameters:
       - bytes: The number of bytes.
       - countStyle: Specify the number of bytes to be used for ``kilobytes``.
     */
    public init<V: BinaryInteger>(_ bytes: V, countStyle: CountStyle = .file) {
        guard let bytes = UInt64(exactly: bytes) else {
            preconditionFailure("The byte count must be representable as UInt64.")
        }
        self.bytes = bytes
        self.countStyle = countStyle
    }

    /**
     Initializes a `DataSize` instance with the specified sizes in various units and count style.

     - Parameters:
        - bytes: The bytes.
        - kilobytes: The kilobytes.
        - megabytes: The megabytes.
        - gigabytes: The gigabytes.
        - terabytes: The terabytes.
        - petabytes: The petabytes.
        - exabytes: The exabytes.
        - zettabytes: The zettabytes.
        - yottabytes: The yottabytes.
        - countStyle: The number of bytes to be used for ``kilobytes``.
     */
    public init(bytes: UInt64 = 0, kilobytes: Double = 0, megabytes: Double = 0, gigabytes: Double = 0, terabytes: Double = 0, petabytes: Double = 0, exabytes: Double = 0, zettabytes: Double = 0, yottabytes: Double = 0, countStyle: CountStyle = .file) {
        self.bytes = bytes
        self.countStyle = countStyle
        self.bytes += self.bytes(for: kilobytes, .kilobyte)
        self.bytes += self.bytes(for: megabytes, .megabyte)
        self.bytes += self.bytes(for: gigabytes, .gigabyte)
        self.bytes += self.bytes(for: terabytes, .terabyte)
        self.bytes += self.bytes(for: petabytes, .petabyte)
        self.bytes += self.bytes(for: exabytes, .exabyte)
        self.bytes += self.bytes(for: zettabytes, .zettabyte)
        self.bytes += self.bytes(for: yottabytes, .yottabyte)
    }

    /**
     Specify the number of bytes to be used for kilobytes.

     The default setting is `file`, which is the system specific value for file and storage sizes.
     */
    public var countStyle: CountStyle = .file

    /// The size in bytes.
    public var bytes: UInt64

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

    /// The size in exabytes.
    public var exabytes: Double {
        get { value(for: .exabyte) }
        set { bytes = bytes(for: newValue, .exabyte) }
    }

    /// The size in zettabytes.
    public var zettabytes: Double {
        get { value(for: .zettabyte) }
        set { bytes = bytes(for: newValue, .zettabyte) }
    }

    /// The size in yottabytes.
    public var yottabytes: Double {
        get { value(for: .yottabyte) }
        set { bytes = bytes(for: newValue, .yottabyte) }
    }

    private func value(for unit: Unit) -> Double {
        convert(Double(bytes), from: .byte, to: unit)
    }

    private func bytes(for value: Double, _ unit: Unit) -> UInt64 {
        UInt64(convert(value, from: unit, to: .byte))
    }

    private func convert(_ number: Double, from: Unit, to targetUnit: Unit) -> Double {
        number * pow(countStyle.factor, Double(from.rawValue - targetUnit.rawValue))
    }

    private enum Unit: Int {
        case byte = 0
        case kilobyte
        case megabyte
        case gigabyte
        case terabyte
        case petabyte
        case exabyte
        case zettabyte
        case yottabyte
    }

    /// Returns a `DataSize`  with zero bytes.
    public static var zero: DataSize {
        DataSize()
    }

    /// Specifies display of file or storage byte counts.
    public enum CountStyle: Int, Hashable, Codable, Sendable {
        /**
         Specifies display of file byte counts.

         The actual behavior for this is platform-specific; in macOS, this uses the decimal style, but that may change over time.
         */
        case file = 0
        /**
         Specifies display of memory byte counts.

         The actual behavior for this is platform-specific; in macOS, this uses the binary style, but that may change over time.
         */
        case memory = 1

        /**
         Causes 1000 bytes to be shown as 1 KB.

         It is better to use ``file`` or ``memory`` in most cases.
         */
        case decimal = 2

        /**
         Causes 1024 bytes to be shown as 1 KB.

         It is better to use ``file`` or ``memory`` in most cases.
         */
        case binary = 3

        var factor: Double {
            switch self {
            case .binary, .memory: 1_024
            default: 1_000
            }
        }
    }
}

public extension DataSize {
    /**
     Returns a data size with the specified bytes.

     - Parameters:
        - value: The bytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified bytes.
     */
    static func bytes<V: BinaryInteger>(_ value: V, countStyle: CountStyle = .file) -> Self {
        Self(value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified kilobytes.

     - Parameters:
        - value: The kilobytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified kilobytes.
     */
    static func kilobytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(kilobytes: value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified megabytes.

     - Parameters:
        - value: The megabytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified megabytes.
     */
    static func megabytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(megabytes: value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified gigabytes.

     - Parameters:
        - value: The gigabytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified gigabytes.
     */
    static func gigabytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(gigabytes: value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified terabytes.

     - Parameters:
        - value: The terabytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified terabytes.
     */
    static func terabytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(terabytes: value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified petabytes.

     - Parameters:
        - value: The petabytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified petabytes.
     */
    static func petabytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(petabytes: value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified exabytes.

     - Parameters:
        - value: The exabytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified exabytes.
     */
    static func exabytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(exabytes: value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified zettabytes.

     - Parameters:
        - value: The zettabytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified zettabytes.
     */
    static func zettabytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(zettabytes: value, countStyle: countStyle)
    }

    /**
     Returns a data size with the specified yottabytes.

     - Parameters:
        - value: The yottabytes.
        - countStyle: The count style for formatting the data size.

     - Returns: `DataSize`with the specified yottabytes.
     */
    static func yottabytes(_ value: Double, countStyle: CountStyle = .file) -> Self {
        Self(yottabytes: value, countStyle: countStyle)
    }
}

extension DataSize: Codable {
    public enum CodingKeys: CodingKey {
        case bytes
        case countStyle
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bytes, forKey: .bytes)
        try container.encode(countStyle, forKey: .countStyle)
    }

    public init(from decoder: Decoder) throws {
        if let bytes = try? decoder.decodeSingle(UInt64.self) {
            self.bytes = bytes
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.bytes = try container.decode(UInt64.self, forKey: .bytes)
            self.countStyle = try container.decode(CountStyle.self, forKey: .countStyle)
        }
    }
}

extension DataSize: RawRepresentable {
    /**
     Initializes a `DataSize` instance with the given number of bytes.

     - Parameter rawValue: The number of bytes.
     */
    public init(rawValue: UInt64) {
        self.bytes = rawValue
    }

    /// The size in bytes.
    public var rawValue: UInt64 {
        bytes
    }
}

extension DataSize: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt64) {
        bytes = value
        countStyle = .file
    }
}

public extension Sequence where Element == DataSize {
    /**
     The total size of all data sizes in the sequence.

     - Returns: A `DataSize` instance representing the total size. If the sequence is empty, it returns `zero`.
     */
    func sum() -> DataSize {
        let bytes = compactMap(\.bytes).sum()
        return DataSize(bytes)
    }
}

public extension Collection where Element == DataSize {
    /**
     The average size of all data sizes in the collection.

     - Returns: A `DataSize` instance representing the average size. If the collection is empty, it returns `zero`.
     */
    func average() -> DataSize {
        guard !isEmpty else { return .zero }
        let average = Int(compactMap(\.bytes).average().rounded(.down))
        return DataSize(average)
    }
}

extension DataSize: CustomStringConvertible {
    /// A string representation of the data size.
    public var description: String {
        string(includesActualByteCount: true)
    }

    /**
     A detailed string representation of the data size that includes the units.

     Example usage:

     ```swift
     let dataSize1 = DataSize(gigabytes: 1, megabytes: 15)
     dataSize1.stringDetailed() // "1.015 MB"

     let dataSize2 = DataSize(terabytes: 2.5, gigabytes: 1)
     dataSize2.stringDetailed() // "2.501 GB"
     ```

     - Parameters:
        - unitStyle: The unit style. Specify `none` to not include the unit.
        - zeroPadsFractionDigits: A Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
        - includesActualByteCount: A Boolean value indicating whether to include the number of bytes after the formatted string.
        - locale: The locale of the string.

     - Returns: A detailed string representation of the data size.
     */
    public func stringDetailed(unitStyle: DataSizeFormatStyle.UnitStyle = .short, zeroPadsFractionDigits: Bool = false, includesActualByteCount: Bool = false, locale: Locale = .autoupdatingCurrent) -> String {
        string(allowedUnits: largestUnit, unitStyle: unitStyle, includesActualByteCount: includesActualByteCount, zeroPadsFractionDigits: zeroPadsFractionDigits, locale: locale)
    }

    private var largestUnit: DataSizeFormatStyle.Units {
        if yottabytes >= 1 {
            return .ybOrHigher
        } else if zettabytes >= 1 {
            return .zb
        } else if exabytes >= 1 {
            return .eb
        } else if petabytes >= 1 {
            return .pb
        } else if terabytes >= 1 {
            return .tb
        } else if gigabytes >= 1 {
            return .gb
        } else if megabytes >= 1 {
            return .mb
        } else if kilobytes >= 1 {
            return .kb
        }
        return .bytes
    }

    /**
     Returns a string representation of the data size using the specified unit.

     Example usage:

     ```swift
     let dataSize = DataSize(gigabytes: 1, megabytes: 2, bytes: 3)

     dataSize.string(for: .byte, includesUnit: false) // "1.002.000.003"
     dataSize.string(for: .megabyte, includesUnit: true) // "1.002 MB"
     ```

     - Parameters:
        - unit: The unit to use for formatting the data size.
        - unitStyle: The unit style. Specify `none` to not include the unit.
        - zeroPadsFractionDigits: A Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
        - includesActualByteCount: A Boolean value indicating whether to include the number of bytes after the formatted string.
        - locale: The locale of the string.

     - Returns: A string representation of the data size.
     */
    public func string(for unit: DataSizeFormatStyle.Unit, unitStyle: DataSizeFormatStyle.UnitStyle = .short, zeroPadsFractionDigits: Bool = false, includesActualByteCount: Bool = false, locale: Locale = .autoupdatingCurrent) -> String {
        string(allowedUnits: .init(rawValue: unit.rawValue), unitStyle: unitStyle, includesActualByteCount: includesActualByteCount, zeroPadsFractionDigits: zeroPadsFractionDigits, locale: locale)
    }

    /**
     Returns a string representation of the data size using the specified allowed units.

     Example usage:

     ```swift
     let dataSize = DataSize(gigabytes: 1, megabytes: 2, bytes: 3)

     dataSize.string(allowedUnits: .useAll, includesUnit: true) // "1 GB"
     dataSize.string(allowedUnits: .useMB, includesUnit: false) // "1.002"
     ```

     - Parameters:
        - allowedUnits: The allowed units for formatting the data size.
        - unitStyle: The unit style. Specify `none` to not include the unit.
        - spellsOutZero: A Boolean value indicating whether `zero` data sizes should be spelled out as text.
        - zeroPadsFractionDigits: A Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
        - includesActualByteCount: A Boolean value indicating whether to include the number of bytes after the formatted string.
        - locale: The locale of the string.

     - Returns: A string representation of the data size.
     */
    public func string(allowedUnits: DataSizeFormatStyle.Units = .all,
                       unitStyle: DataSizeFormatStyle.UnitStyle = .short,
                       includesCount: Bool = true,
                       includesActualByteCount: Bool = false,
                       spellsOutZero: Bool = true,
                       isAdaptive: Bool = true,
                       zeroPadsFractionDigits: Bool = false, locale: Locale = .autoupdatingCurrent) -> String
    {
        formatted(.dataSize(allowedUnits: allowedUnits, unitStyle: unitStyle, includesCount: includesCount, includesActualByteCount: includesActualByteCount, spellsOutZero: spellsOutZero, isAdaptive: isAdaptive, zeroPadsFractionDigits: zeroPadsFractionDigits).locale(locale))
    }
}

extension DataSize: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let intValue = UInt64(description) else { return nil }
        bytes = intValue
        countStyle = .binary
    }
}

extension DataSize: Comparable, AdditiveArithmetic {
    /// Adds the two data sizes.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.bytes + rhs.bytes, countStyle: lhs.countStyle)
    }

    /// Subtracts the two data sizes.
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.bytes - rhs.bytes, countStyle: lhs.countStyle)
    }

    /// A Boolean value indicating whether the first data size is smaller than the second data size.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.bytes < rhs.bytes
    }

    /// A Boolean value indicating whether the first data size is larger than the second data size.
    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.bytes > rhs.bytes
    }

    /// Multiplies the data size by the specified amount.
    public static func * <V: BinaryInteger>(lhs: Self, rhs: V) -> Self {
        guard let rhs = UInt64(exactly: rhs) else {
            preconditionFailure("The multiplier must be representable as UInt64.")
        }
        return Self(lhs.bytes * rhs, countStyle: lhs.countStyle)
    }

    /// Returns the specified value multiplied by the data size.
    public static func * <V: BinaryInteger>(lhs: V, rhs: Self) -> Self {
        rhs * lhs
    }

    /// Multiplies the data size by the specified amount.
    public static func *= <V: BinaryInteger>(lhs: inout Self, rhs: V) {
        guard let rhs = UInt64(exactly: rhs) else {
            preconditionFailure("The multiplier must be representable as UInt64.")
        }
        lhs.bytes *= rhs
    }

    /// Divides the data size by the specified amount.
    public static func / <V: BinaryInteger>(lhs: Self, rhs: V) -> Self {
        guard let rhs = UInt64(exactly: rhs) else {
            preconditionFailure("The divisor must be representable as UInt64.")
        }
        precondition(rhs != 0, "The divisor must not be zero.")
        return Self(lhs.bytes / rhs, countStyle: lhs.countStyle)
    }

    /// Divides the data size by the specified amount.
    public static func /= <V: BinaryInteger>(lhs: inout Self, rhs: V) {
        guard let rhs = UInt64(exactly: rhs) else {
            preconditionFailure("The divisor must be representable as UInt64.")
        }
        precondition(rhs != 0, "The divisor must not be zero.")
        lhs.bytes /= rhs
    }

    /// Returns the data size multiplied by the specified value, rounded to the nearest byte.
    public static func * <V: BinaryFloatingPoint>(lhs: Self, rhs: V) -> Self {
        guard let value = UInt64(exactly: (Double(lhs.bytes) * Double(rhs)).rounded()) else {
            preconditionFailure("The resulting data size must be representable as UInt64.")
        }
        return Self(value, countStyle: lhs.countStyle)
    }

    /// Returns the specified value multiplied by the data size, rounded to the nearest byte.
    public static func * <V: BinaryFloatingPoint>(lhs: V, rhs: Self) -> Self {
        rhs * lhs
    }

    /// Multiplies the data size by the specified value, rounding to the nearest byte.
    public static func *= <V: BinaryFloatingPoint>(lhs: inout Self, rhs: V) {
        guard let value = UInt64(exactly: (Double(lhs.bytes) * Double(rhs)).rounded()) else {
            preconditionFailure("The resulting data size must be representable as UInt64.")
        }
        lhs.bytes = value
    }

    /// Returns the data size divided by the specified value, rounded to the nearest byte.
    public static func / <V: BinaryFloatingPoint>(lhs: Self, rhs: V) -> Self {
        precondition(rhs != 0, "The divisor must not be zero.")
        guard let value = UInt64(exactly: (Double(lhs.bytes) / Double(rhs)).rounded()) else {
            preconditionFailure("The resulting data size must be representable as UInt64.")
        }
        return Self(value, countStyle: lhs.countStyle)
    }

    /// Divides the data size by the specified value, rounding to the nearest byte.
    public static func /= <V: BinaryFloatingPoint>(lhs: inout Self, rhs: V) {
        precondition(rhs != 0, "The divisor must not be zero.")
        guard let value = UInt64(exactly: (Double(lhs.bytes) / Double(rhs)).rounded()) else {
            preconditionFailure("The resulting data size must be representable as UInt64.")
        }
        lhs.bytes = value
    }

    /// Returns the ratio of the two data sizes.
    public static func / (lhs: Self, rhs: Self) -> Double {
        Double(lhs.bytes) / Double(rhs.bytes)
    }

    /// Returns the remainder of dividing the first data size by the second.
    public static func % (lhs: Self, rhs: Self) -> Self {
        precondition(rhs.bytes != 0, "The divisor must not be zero.")
        return Self(lhs.bytes % rhs.bytes, countStyle: lhs.countStyle)
    }

    /// Replaces the first data size with the remainder of dividing it by the second.
    public static func %= (lhs: inout Self, rhs: Self) {
        precondition(rhs.bytes != 0, "The divisor must not be zero.")
        lhs.bytes %= rhs.bytes
    }
}

public extension Data {
    /// The size of the data.
    var size: DataSize {
        DataSize(count)
    }
}

extension DataSize: ReferenceConvertible {
    /// The Objective-C type for the data size.
    public typealias ReferenceType = __DataSize

    public var debugDescription: String {
        description
    }

    public func _bridgeToObjectiveC() -> __DataSize {
        return __DataSize(size: self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __DataSize, result: inout DataSize?) {
        result = source.size
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __DataSize, result: inout DataSize?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __DataSize?) -> DataSize {
        if let source = source {
            var result: DataSize?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return .zero
    }
}

/// The Objective-C type for `DataSize`.
public class __DataSize: NSObject, NSCopying, NSCoding {
    let size: DataSize

    init(size: DataSize) {
        self.size = size
    }

    public func encode(with coder: NSCoder) {
        coder.encode(size.bytes, forKey: "bytes")
        coder.encode(size.countStyle, forKey: "countStyle")
    }

    public required init?(coder: NSCoder) {
        size = .init(coder.decode("bytes") ?? 0, countStyle: coder.decode("countStyle") ?? .file)
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || size == other.size
    }

    override public var hash: Int {
        Hasher.hash(size)
    }
}

public extension DataSize {
    /// Formats the data size value with the specified format.
    func formatted<F: FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == DataSize {
        style.format(self)
    }

    /// Formats the data size using ``DataSizeFormatStyle``()
    func formatted() -> String {
        DataSizeFormatStyle().format(self)
    }
}

/// A format style that formats ``DataSize`` values as strings.
public struct DataSizeFormatStyle: FormatStyle {
    /**
     The units the format style can use to express the byte count.

     The default value is ``Units/all``.
     */
    public var allowedUnits: Units

    /**
     The style used to format the data size unit.

     When this value is ``UnitStyle/none``, the format style doesn't include a unit. For example, a data size that would otherwise be formatted as `723 KB` is formatted as `723`.

     The default value is ``UnitStyle/short``.
     */
    public var unitStyle: UnitStyle

    /**
     A Boolean value that indicates whether the format style zero pads fraction digits.

     When this value is `true`, trailing zeros are added to produce a consistent number of fraction digits. For example, when ``isAdaptive`` is `true`, values that would otherwise be formatted as `1.19 GB` and `1.2 GB` are formatted as `1.19 GB` and `1.20 GB`, respectively.

     The default value is `false`.
     */
    public var zeroPadsFractionDigits: Bool

    /**
     A Boolean value that indicates whether the format style should include the exact byte count, in addition to expressing it in terms of units.

     When this value is `true`, a format style produces output like `1 kB (1,024 bytes)`.

     The default value is `false`.
     */
    public var includesActualByteCount: Bool

    /**
     The locale to use to format the numeric part of the data size.

     To change the format style’s locale, use ``locale(_:)``.
     */
    public var locale: Locale

    /**
     A Boolean value that indicates whether the format style should spell out zero-byte values as text.

     When this value is `true`, the format style produces output like `Zero kB`.

     The default value is `true`.
     */
    public var spellsOutZero: Bool

    /**
     A Boolean value that indicates whether the format style adaptively determines the number of fraction digits.

     When this value is `true`, the format style uses a platform-specific number of fraction digits based on the magnitude of the data size. When `false`, the format style attempts to display at least three significant digits, introducing fraction digits as necessary.

     The default value is `true`.
     */
    public var isAdaptive: Bool

    /**
     A Boolean value that indicates whether the format style includes the numeric value.

     When this value is `false`, the format style includes only the unit.

     The default value is `true`.

     - Note: Setting this value to `false` and ``unitStyle`` to ``UnitStyle/none`` results in an empty string.
     */
    public var includesCount: Bool

    /**
     Initializes a data size format style.

     - Parameters:
        - allowedUnits: The units the format style can use to express the byte count.
        - unitStyle: The style used to format the data size unit.  Specify ``UnitStyle/none`` to not include the unit.
        - includesCount: A Boolean value indicating whether to include the numeric value in the formatted string.
        - includesActualByteCount: A Boolean value that indicates whether the format style should include the exact byte count, in addition to expressing it in terms of units. For example, `1 kB (1,024 bytes)`.
        - spellsOutZero: A Boolean value that indicates whether the format style should spell out zero-byte values as text, like `Zero kB`.
        - isAdaptive: A Boolean value indicating the display style of the size representation.
        - zeroPadsFractionDigits: A Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
        - locale: The locale to use to format the numeric part of the byte count.

     In situations that can infer the ``DataSizeFormatStyle`` type, you can call ``Foundation/FormatStyle/dataSize(allowedUnits:unitStyle:includesCount:includesActualByteCount:spellsOutZero:isAdaptive:zeroPadsFractionDigits:)`` instead of explicitly using this initializer. This is the case when you call ``DataSize/formatted(_:)`` on a ``DataSize``.
     */
    public init(allowedUnits: Units = .all,
                unitStyle: UnitStyle = .short,
                includesCount: Bool = true,
                includesActualByteCount: Bool = false,
                spellsOutZero: Bool = true,
                isAdaptive: Bool = true,
                zeroPadsFractionDigits: Bool = false,
                locale: Locale = .autoupdatingCurrent)
    {
        self.allowedUnits = allowedUnits
        self.unitStyle = unitStyle
        self.spellsOutZero = spellsOutZero
        self.zeroPadsFractionDigits = zeroPadsFractionDigits
        self.includesActualByteCount = includesActualByteCount
        self.isAdaptive = isAdaptive
        self.includesCount = includesCount
        self.locale = locale
    }

    /**
     Initializes a data size format style.

     - Parameters:
        - fixedUnit: The unit the format style should use to express the byte count.
        - unitStyle: The style used to format the data size unit.  Specify ``UnitStyle/none`` to not include the unit.
        - includesCount: A Boolean value indicating whether to include the numeric value in the formatted string.
        - includesActualByteCount: A Boolean value that indicates whether the format style should include the exact byte count, in addition to expressing it in terms of units. For example, `1 kB (1,024 bytes)`.
        - spellsOutZero: A Boolean value that indicates whether the format style should spell out zero-byte values as text, like `Zero kB`.
        - isAdaptive: A Boolean value indicating the display style of the size representation.
        - zeroPadsFractionDigits: A Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
        - locale: The locale to use to format the numeric part of the byte count.

     In situations that can infer the ``DataSizeFormatStyle`` type, you can call ``Foundation/FormatStyle/dataSize(fixedUnit:unitStyle:includesCount:includesActualByteCount:spellsOutZero:isAdaptive:zeroPadsFractionDigits:)`` instead of explicitly using this initializer. This is the case when you call ``DataSize/formatted(_:)`` on a ``DataSize``.
     */
    public init(fixedUnit: Unit,
                unitStyle: UnitStyle = .short,
                includesCount: Bool = true,
                includesActualByteCount: Bool = false,
                spellsOutZero: Bool = true,
                isAdaptive: Bool = true,
                zeroPadsFractionDigits: Bool = false,
                locale: Locale = .autoupdatingCurrent)
    {
        self.init(allowedUnits: .init(rawValue: fixedUnit.rawValue), unitStyle: unitStyle, includesCount: includesCount, includesActualByteCount: includesActualByteCount, spellsOutZero: spellsOutZero, isAdaptive: isAdaptive, zeroPadsFractionDigits: zeroPadsFractionDigits, locale: locale)
    }

    public func locale(_ locale: Locale) -> Self {
        var copy = self
        copy.locale = locale
        return copy
    }

    /// An attributed format style based on the data size format style.
    public var attributed: Attributed {
        Attributed(style: self)
    }

    /// Formats the specified data size, using this style.
    public func format(_ dataSize: DataSize) -> String {
        var string = Self.formatterCache.withLock {
           $0[FormatterKey(allowedUnits: allowedUnits, countStyle: dataSize.countStyle, includesActualByteCount: includesActualByteCount, spellsOutZero: spellsOutZero, locale: locale, unitStyle: unitStyle, zeroPadsFractionDigits: zeroPadsFractionDigits, isAdaptive: isAdaptive, includesCount: includesCount), default: {
                let formatter = ByteCountFormatter()
                formatter.spellsOutZero = false
                formatter.allowedUnits = .init(rawValue: allowedUnits.rawValue)
                formatter.countStyle = .init(rawValue: dataSize.countStyle.rawValue) ?? .file
                formatter.includesUnit = unitStyle != .none
                formatter.includesActualByteCount = includesActualByteCount
                formatter.locale = locale
                formatter.isAdaptive = isAdaptive
                formatter.includesCount = includesCount
                formatter.unitStyle = unitStyle == .none ? .short : .init(rawValue: unitStyle.rawValue) ?? .short
                formatter.zeroPadsFractionDigits = zeroPadsFractionDigits
                return formatter
            }()].string(fromByteCount: Int64(dataSize.bytes))
        }
        if useSpelloutZero, dataSize == .zero, includesCount {
            let formatter = NumberFormatter.decimal.locale(locale)
            if let zero = formatter.string(for: 0), let spelledOutZero = formatter.style(.spellOut).formattingContext(.beginningOfSentence).string(for: 0)?.uppercasedFirst(with: locale), let range = string.range(of: zero) {
                string.replaceSubrange(range, with: spelledOutZero)
            }
        }
        return string
    }

    /// The unit style for a string representation of the data size.
    public enum UnitStyle: Int, Hashable, Codable, CustomStringConvertible {
        /// No unit.
        case none
        /// Short (e.g. `KB`, `TB`… )
        case short
        /// Medium (e.g. `kByte`, `TByte`… )
        case medium
        /// Long (e.g. `kilobytes`, `terabytes`… )
        case long

        public var description: String {
            switch self {
            case .none: "none"
            case .short: "short"
            case .medium: "medium"
            case .long: "long"
            }
        }
    }

    /// The unit to use when formatting a data size.
    public enum Unit: UInt, Codable, Hashable, CaseIterable {
        /// The bytes unit.
        case bytes = 1
        /// The kilobytes unit.
        case kb = 2
        /// The megabytes unit.
        case mb = 4
        /// The gigabytes unit.
        case gb = 8
        /// The terabytes unit.
        case tb = 16
        /// The petabytes unit.
        case pb = 32
        /// The exabytes unit.
        case eb = 64
        /// The zettabytes unit.
        case zb = 128
        /// A value that indicates a format style should express byte counts as yottabytes or higher.
        case ybOrHigher = 65_280
    }

    /// The units to use when formatting a data size.
    public struct Units: OptionSet, Hashable, Codable, CustomStringConvertible {
        /// A value that indicates a format style should use the most appropriate units to express a byte count.
        public static let `default`: Self = []
        /// A value that allows the use of all byte-count units.
        public static let all: Self = [.bytes, .kb, .mb, .gb, .tb, .pb, .eb, .zb, .ybOrHigher] // 65535
        /// The bytes unit.
        public static let bytes = Self(rawValue: 1 << 0)
        /// The kilobytes unit.
        public static let kb = Self(rawValue: 1 << 1)
        /// The megabytes unit.
        public static let mb = Self(rawValue: 1 << 2)
        /// The gigabytes unit.
        public static let gb = Self(rawValue: 1 << 3)
        /// The terabytes unit.
        public static let tb = Self(rawValue: 1 << 4)
        /// The petabytes unit.
        public static let pb = Self(rawValue: 1 << 5)
        /// The exabytes unit.
        public static let eb = Self(rawValue: 1 << 6)
        /// The zettabytes unit.
        public static let zb = Self(rawValue: 1 << 7)
        /// A value that indicates a format style should express byte counts as yottabytes or higher.
        public static let ybOrHigher = Self(rawValue: 65_280)

        public let rawValue: UInt
        
        var smallestUnit: Unit {
            Unit.allCases.first(where: { !intersection(.init(rawValue: $0.rawValue)).isEmpty }) ?? .pb
        }

        public var description: String {
            if self == .default { return ".default" }
            var strings: [String] = []
            if contains(.bytes) { strings += ".bytes" }
            if contains(.kb) { strings += ".kb" }
            if contains(.mb) { strings += ".mb" }
            if contains(.gb) { strings += ".gb" }
            if contains(.tb) { strings += ".tb" }
            if contains(.pb) { strings += ".pb" }
            if contains(.eb) { strings += ".eb" }
            if contains(.zb) { strings += ".zb" }
            if contains(.ybOrHigher) { strings += ".ybOrHigher" }
            if strings.count == 1 { return strings.first! }
            return "[\(strings.joined(separator: ", "))]"
        }

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    private static let formatterCache = Mutex([FormatterKey: ByteCountFormatter]())

    private struct FormatterKey: Hashable {
        let allowedUnits: Units
        let countStyle: DataSize.CountStyle
        let includesActualByteCount: Bool
        let spellsOutZero: Bool
        let locale: Locale
        let unitStyle: UnitStyle
        let zeroPadsFractionDigits: Bool
        let isAdaptive: Bool
        let includesCount: Bool
    }
}

public extension FormatStyle where Self == DataSizeFormatStyle {
    /// Returns a format style to format a data size value.
    static var dataSize: Self {
        dataSize()
    }

    /**
     Returns a format style to format a data size value.

     - Parameters:
        - allowedUnits: The units the format style can use to express the byte count.
        - unitStyle: The style used to format the data size unit.  Specify ``UnitStyle/none`` to not include the unit.
        - includesCount: A Boolean value indicating whether to include the numeric value in the formatted string.
        - includesActualByteCount: A Boolean value that indicates whether the format style should include the exact byte count, in addition to expressing it in terms of units. For example, `1 kB (1,024 bytes)`.
        - spellsOutZero: A Boolean value that indicates whether the format style should spell out zero-byte values as text, like `Zero kB`.
        - isAdaptive: A Boolean value indicating the display style of the size representation.
        - zeroPadsFractionDigits: A Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
     - Returns: A format style for formatting a data size value, customized with the provided behaviors.
     */
    static func dataSize(allowedUnits: Self.Units = .all, unitStyle: Self.UnitStyle = .short, includesCount: Bool = true, includesActualByteCount: Bool = false, spellsOutZero: Bool = true, isAdaptive: Bool = true, zeroPadsFractionDigits: Bool = false) -> Self {
        DataSizeFormatStyle(allowedUnits: allowedUnits, unitStyle: unitStyle, includesCount: includesCount, includesActualByteCount: includesActualByteCount, spellsOutZero: spellsOutZero, isAdaptive: isAdaptive, zeroPadsFractionDigits: zeroPadsFractionDigits)
    }

    /**
     Returns a format style to format a data size value.

     - Parameters:
        - fixedUnit: The unit the format style should use to express the byte count.
        - unitStyle: The style used to format the data size unit.  Specify ``UnitStyle/none`` to not include the unit.
        - includesCount: A Boolean value indicating whether to include the numeric value in the formatted string.
        - includesActualByteCount: A Boolean value that indicates whether the format style should include the exact byte count, in addition to expressing it in terms of units. For example, `1 kB (1,024 bytes)`.
        - spellsOutZero: A Boolean value that indicates whether the format style should spell out zero-byte values as text, like `Zero kB`.
        - isAdaptive: A Boolean value indicating the display style of the size representation.
        - zeroPadsFractionDigits: A Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
     - Returns: A format style for formatting a data size value, customized with the provided behaviors.
     */
    static func dataSize(fixedUnit: Self.Unit, unitStyle: Self.UnitStyle = .short, includesCount: Bool = true, includesActualByteCount: Bool = false, spellsOutZero: Bool = true, isAdaptive: Bool = true, zeroPadsFractionDigits: Bool = false) -> Self {
        DataSizeFormatStyle(fixedUnit: fixedUnit, unitStyle: unitStyle, includesCount: includesCount, includesActualByteCount: includesActualByteCount, spellsOutZero: spellsOutZero, isAdaptive: isAdaptive, zeroPadsFractionDigits: zeroPadsFractionDigits)
    }
}

public extension DataSizeFormatStyle {
    /// A format style that returns the formatted data size as an `AttributedString`.
    struct Attributed: FormatStyle {
        /**
         The units the format style can use to express the byte count.

         The default value is ``Units/all``.
         */
        public var allowedUnits: Units {
            get { style.allowedUnits }
            set { style.allowedUnits = newValue }
        }

        /**
         The style used to format the data size unit.

         When this value is ``UnitStyle/none``, the format style doesn't include a unit. For example, a data size that would otherwise be formatted as `723 KB` is formatted as `723`.

         The default value is ``UnitStyle/short``.
         */
        public var unitStyle: UnitStyle {
            get { style.unitStyle }
            set { style.unitStyle = newValue }
        }

        /**
         A Boolean value that indicates whether the format style zero pads fraction digits.

         When this value is `true`, trailing zeros are added to produce a consistent number of fraction digits. For example, when ``isAdaptive`` is `true`, values that would otherwise be formatted as `1.19 GB` and `1.2 GB` are formatted as `1.19 GB` and `1.20 GB`, respectively.

         The default value is `false`.
         */
        public var zeroPadsFractionDigits: Bool {
            get { style.zeroPadsFractionDigits }
            set { style.zeroPadsFractionDigits = newValue }
        }

        /**
         A Boolean value that indicates whether the format style should include the exact byte count, in addition to expressing it in terms of units.

         When this value is `true`, a format style produces output like `1 kB (1,024 bytes)`.

         The default value is `false`.
         */
        public var includesActualByteCount: Bool {
            get { style.includesActualByteCount }
            set { style.includesActualByteCount = newValue }
        }

        /**
         The locale to use to format the numeric part of the data size.

         To change the format style’s locale, use ``locale(_:)``.
         */
        public var locale: Locale {
            get { style.locale }
            set { style.locale = newValue }
        }

        /**
         A Boolean value that indicates whether the format style should spell out zero-byte values as text.

         When this value is `true`, the format style produces output like `Zero kB`.

         The default value is `true`.
         */
        public var spellsOutZero: Bool {
            get { style.spellsOutZero }
            set { style.spellsOutZero = newValue }
        }

        /**
         A Boolean value that indicates whether the format style adaptively determines the number of fraction digits.

         When this value is `true`, the format style uses a platform-specific number of fraction digits based on the magnitude of the data size. When `false`, the format style attempts to display at least three significant digits, introducing fraction digits as necessary.

         The default value is `true`.
         */
        public var isAdaptive: Bool {
            get { style.isAdaptive }
            set { style.isAdaptive = newValue }
        }

        /**
         A Boolean value that indicates whether the format style includes the numeric value.

         When this value is `false`, the format style includes only the unit.

         The default value is `true`.

         - Note: Setting this value to `false` and ``unitStyle`` to ``UnitStyle/none`` results in an empty string.
         */
        public var includesCount: Bool {
            get { style.includesCount }
            set { style.includesCount = newValue }
        }

        private var style: DataSizeFormatStyle

        init(style: DataSizeFormatStyle) {
            self.style = style
        }

        public func locale(_ locale: Locale) -> Self {
            Self(style: style.locale(locale))
        }

        public func format(_ dataSize: DataSize) -> AttributedString {
            var output = AttributedString(style.format(dataSize))
            if style.useSpelloutZero {
                if let zero = NumberFormatter.spellOut.locale(locale).formattingContext(.dynamic).string(for: 0)?.uppercasedFirst(with: locale), let range = output.range(of: zero) {
                    output[range].byteCount = .spelledOutValue
                }
            }
            return output
        }
    }
}

fileprivate extension DataSizeFormatStyle {
    var useSpelloutZero: Bool {
        guard spellsOutZero else { return false }
        guard let languageCode = locale.resolvedLanguageCode else { return false }
        switch languageCode {
        case "ar", "da", "el", "en", "fr", "hi", "hr", "id", "it", "ms", "pt", "ro", "th":
            return true
        default:
            break
        }
        guard !allowedUnits.contains(.kb) else { return false }
        // These only uses spellout zero with byte but not with kilobyte
        switch languageCode {
        case "ca", "no":
            return true
        default:
            break
        }
        return false
    }
}

fileprivate extension Locale {
    var resolvedLanguageCode: String? {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            language.languageCode?.identifier.lowercased()
        } else {
            languageCode?.lowercased()
        }
    }
}

extension DataSize.CountStyle {
    var maxSizes: [UInt64] {
        isDecimal ? Self.maxSizes.decimal : Self.maxSizes.binary
    }
    
    var isDecimal: Bool {
        switch self {
        case .file, .decimal: true
        default: false
        }
    }
    
    private static let maxSizes: (decimal: [UInt64], binary: [UInt64]) = (
        [999, 999_499, 999_949_999, 999_994_999_999, 999_994_999_999_999, .max],
        [1_023, 1_048_063, 1_073_689_395, 1_099_506_259_066, 1_125_894_409_284_485, .max])
}

extension DataSizeFormatStyle {
    func bestUnit(for size: DataSize) -> Unit {
        var bestUnit = allowedUnits.smallestUnit
        for (index, maxSize) in size.countStyle.maxSizes.enumerated() {
            let unit = Unit(rawValue: UInt(index))!
            guard allowedUnits.contains(.init(rawValue: unit.rawValue)) else { continue }
            bestUnit = unit
            if size.bytes < maxSize {
                break
            }
        }
        return bestUnit
    }
}

extension DataSizeFormatStyle.Unit {
    private var index: Int {
        Self.allCases.firstIndex(of: self)!
    }
    
    var decimalSize: Int64 {
        Self.decimalByteSizes[index]
    }

    var binarySize: Int64 {
        Self.binaryByteSizes[index]
    }
    
    private static let unitNames = ["byte", "kilobyte", "megabyte", "gigabyte", "terabyte", "petabyte"]
    private static let decimalByteSizes: [Int64] = [1, 1_000, 1_000_000, 1_000_000_000, 1_000_000_000_000, 1_000_000_000_000_000]
    private static let binaryByteSizes: [Int64] = [1, 1024, 1048576, 1073741824, 1099511627776, 1125899906842624]
}
