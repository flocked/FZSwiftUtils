//
//  PropertyWrappers.swift
//  FZExtensions
//
//  Created by Florian Zand on 07.06.22.
//

import Foundation

public typealias DefaultZero = DefaultCodable<Zero>
public typealias DefaultTrue = DefaultCodable<True>
public typealias DefaultFalse = DefaultCodable<False>
public typealias DefaultEmptyArray<T> = DefaultCodable<DefaultEmptyArrayStrategy<T>> where T: Decodable

public struct Zero: DefaultCodableStrategy {
    public static var defaultValue: Int { return 0 }
}

public struct True: DefaultCodableStrategy {
    public static var defaultValue: Bool { return true }
}

public struct False: DefaultCodableStrategy {
    public static var defaultValue: Bool { return false }
}

public struct DefaultEmptyArrayStrategy<T: Decodable>: DefaultCodableStrategy {
    public static var defaultValue: [T] { return [] }
}

public struct DefaultEmptyDictionaryStrategy<Key: Decodable & Hashable, Value: Decodable>: DefaultCodableStrategy {
    public static var defaultValue: [Key: Value] { return [:] }
}

public struct TimestampStrategy: DateValueCodableStrategy {
    public static func decode(_ value: TimeInterval) throws -> Date {
        return Date(timeIntervalSince1970: value)
    }

    public static func encode(_ date: Date) -> TimeInterval {
        return date.timeIntervalSince1970
    }
}

public typealias DateValueTimestamp = DateValue<TimestampStrategy>
public typealias DateValueISO8601 = DateValue<ISO8601Strategy>
public typealias DateValueYearMonthDay = DateValue<YearMonthDayStrategy>

public struct ISO8601Strategy: DateValueCodableStrategy {
    public static func decode(_ value: String) throws -> Date {
        guard let date = ISO8601DateFormatter().date(from: value) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Date Format!"))
        }
        return date
    }

    public static func encode(_ date: Date) -> String {
        return ISO8601DateFormatter().string(from: date)
    }
}

public struct YearMonthDayStrategy: DateValueCodableStrategy {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "y-MM-dd"
        return dateFormatter
    }()

    public static func decode(_ value: String) throws -> Date {
        if let date = YearMonthDayStrategy.dateFormatter.date(from: value) {
            return date
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Date Format!"))
        }
    }

    public static func encode(_ date: Date) -> String {
        return YearMonthDayStrategy.dateFormatter.string(from: date)
    }
}
