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
        - countStyle: The count style for formatting the data size. Default is `.file`.
      */
    public init<Value: BinaryInteger>(_ bytes: Value, countStyle: CountStyle = .file) {
        self.bytes = Int(bytes)
        self.countStyle = countStyle
    }

    /**
     Initializes a `DataSize` instance with the specified sizes in various units and count style.
     
     - Parameters:
       - terabytes: The size in terabytes. Default is 0.
       - gigabytes: The size in gigabytes. Default is 0.
       - megabytes: The size in megabytes. Default is 0.
       - kilobytes: The size in kilobytes. Default is 0.
       - bytes: The size in bytes. Default is 0.
       - countStyle: The count style for formatting the data size. Default is `.file`.
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

    internal func value(for unit: Unit) -> Double {
        Unit.byte.convert(Double(bytes), to: unit, countStyle: countStyle)
    }

    internal func bytes(for value: Double, _ unit: Unit) -> Int {
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
     
     - Parameters value: The bytes.
     - Returns: `DataSize`with the specified bytes.
     */
    static func bytes(_ value: Int, countStyle: CountStyle = .file) -> Self { Self(bytes: value, countStyle: countStyle) }
    
    /**
     Returns a data size with the specified kilobytes.
     
     - Parameters value: The kilobytes.
     - Returns: `DataSize`with the specified kilobytes.
     */
    static func kilobytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(kilobytes: value, countStyle: countStyle) }
    
    /**
     Returns a data size with the specified megabytes.
     
     - Parameters value: The megabytes.
     - Returns: `DataSize`with the specified megabytes.
     */
    static func megabytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(megabytes: value, countStyle: countStyle) }
    
    /**
     Returns a data size with the specified gigabytes.
     
     - Parameters value: The gigabytes.
     - Returns: `DataSize`with the specified gigabytes.
     */
    static func gigabytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(gigabytes: value, countStyle: countStyle) }
    
    /**
     Returns a data size with the specified terabytes.
     
     - Parameters value: The terabytes.
     - Returns: `DataSize`with the specified terabytes.
     */
    static func terabytes(_ value: Double, countStyle: CountStyle = .file) -> Self { Self(terabytes: value, countStyle: countStyle) }
    
    /**
     Returns a data size with the specified petabytes.
     
     - Parameters value: The petabytes.
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
    /**
      The average size of the data sizes in the collection.
      
      - Returns: A `DataSize` instance representing the average size. If the collection is empty, returns a `DataSize` instance with 0 bytes.
      */
    func average() -> DataSize {
        guard !isEmpty else { return .zero }
        let average = Int(compactMap { $0.bytes }.average().rounded(.down))
        return DataSize(average)
    }

    /**
     The total size of the data sizes in the collection.
     
     - Returns: A `DataSize` instance representing the total size. If the collection is empty, returns a `DataSize` instance with 0 bytes.
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
       - includesUnit: A Boolean value indicating whether to include the unit in the string representation. Default is `true`.
     
     - Returns: A string representation of the data size.
     */
    public func string(for unit: Unit, includesUnit: Bool = true) -> String {
        return string(allowedUnits: unit.byteCountFormatterUnit, includesUnit: includesUnit)
    }

    /**
     Returns a string representation of the data size using the specified allowed units.
     
     - Parameters:
       - allowedUnits: The allowed units for formatting the data size.
       - includesUnit: A Boolean value indicating whether to include the unit in the string representation. Default is `true`.
     
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
}

import ObjectiveC
public extension Timer {
    /**
     Initializes a timer for the specified date and time interval with the specified block.

     - Parameters fire: The time at which the timer should first fire.
     - Parameters interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
     - Parameters repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
     - Parameters block: A block to be executed when the timer fires. The block takes a single Timer parameter and has no return value.
     
     - Returns:A new Timer object, configured according to the specified parameters.
     */
    convenience init(fire: Date, intervalDuration interval: TimeDuration, repeats: Bool, block: @escaping ((Timer)-> Void)) {
        self.init(fire: fire, interval: interval.seconds, repeats: repeats, block: block)
    }
    
    /**
     Initializes a timer using the specified object and selector.

     - Parameters fire: The time at which the timer should first fire.
     - Parameters interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
     - Parameters target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to this object until it (the timer) is invalidated.
     - Parameters selector: The message to send to target when the timer fires.
     The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument). The timer passes itself as the argument, thus the method would adopt the following pattern:
     - Parameters userInfo: Custom user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
     - Parameters repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
     
     - Returns:A new Timer object, configured according to the specified parameters.
     */
    convenience init(fireAt date: Date, intervalDuration interval: TimeDuration, target: Any, selector: Selector, userInfo: Any?, repeats: Bool) {
        self.init(fireAt: date, interval: interval.seconds, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
    }
    
    /**
     Initializes a timer object with the specified time interval and block.

     - Parameters interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
     - Parameters repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
     - Parameters block: A block to be executed when the timer fires. The block takes a single Timer parameter and has no return value.
     
     - Returns:A new Timer object, configured according to the specified parameters.
     */
    convenience init(timeDuration interval: TimeDuration, repeats: Bool, block: @escaping ((Timer)-> Void)) {
        self.init(timeInterval: interval.seconds, repeats: repeats, block: block)
    }
    
    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
     - Parameters target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
     - Parameters selector: The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument).
     - Parameters userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
     - Parameters repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
     
     - Returns:A new Timer object, configured according to the specified parameters.
     */
    convenience init(timeDuration interval: TimeDuration, target: Any, selector: Selector, userInfo: Any?, repeats: Bool) {
        self.init(timeInterval: interval.seconds, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
    }
    
    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
     - Parameters repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
     - Parameters block: A block to be executed when the timer fires. The block takes a single Timer parameter and has no return value.
     
     - Returns:A new Timer object, configured according to the specified parameters.
     */
    @discardableResult
    static func scheduledTimer(withTimeDuration interval: TimeDuration, repeats: Bool, block: @escaping ((Timer)-> Void)) -> Timer {
        return self.scheduledTimer(withTimeInterval: interval.seconds, repeats: repeats, block: block)
    }
    
    /**
     Creates a timer and schedules it on the current run loop in the default mode.

     - Parameters interval: The interval between firings of the timer. If interval is equal to 0.0 seconds, this method chooses the nonnegative value of 0.0001 seconds instead.
     - Parameters target: The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
     - Parameters selector: The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument).
     - Parameters userInfo: The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
     - Parameters repeats: If `true`, the timer will repeatedly reschedule itself until invalidated. If `false`, the timer will be invalidated after it fires.
     
     - Returns:A new Timer object, configured according to the specified parameters.
     */
    static func scheduledTimer(withTimeDuration interval: TimeDuration, target: Any, selector: Selector, userInfo: Any?, repeats: Bool) -> Timer {
        return self.scheduledTimer(timeInterval: interval.seconds, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
    }
}

/*
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
 */
