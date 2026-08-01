//
//  DictionaryEncoder+ComponentEncoder.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

import Foundation

extension DictionaryEncoder {
    protocol ComponentEncoder {
        var strategies: Strategies { get }
        var userInfo: [CodingUserInfoKey: Any] { get }
        var codingPath: [CodingKey] { get }
    }
    
    protocol Container {
        func resolveValue() -> Any?
    }
}

extension DictionaryEncoder.ComponentEncoder {
    func encodeNil(at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        switch strategies.nil {
        case .useNil:
            .value(nil)
        case .useNSNull:
            .value(NSNull())
        }
    }

    func encode(_ value: Bool, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: Int, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: Int8, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: Int16, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: Int32, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: Int64, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: UInt, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: UInt8, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: UInt16, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: UInt32, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: UInt64, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    func encode(_ value: String, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }
    
    func encode(_ value: Double, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        try encodeFloatingPoint(value, at: codingPath)
    }

    func encode(_ value: Float, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        try encodeFloatingPoint(value, at: codingPath)
    }

    func encode<T: Encodable>(_ value: T, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        switch value {
        case let date as Date:
            try encodeDate(date, at: codingPath)
        case let data as Data:
            try encodeData(data, at: codingPath)
        case let url as URL:
            .value(url.absoluteString)
        default:
            try encodeCustom(value, at: codingPath)
        }
    }
    
    private func encodeCustom<T: Encodable>(_ value: T, at codingPath: [CodingKey], using closure: ((_ value: T, _ encoder: Encoder) throws -> Void) = { try $0.encode(to: $1) }) throws -> DictionaryEncoder.Component {
        let encoder = DictionaryEncoder.Single(strategies: strategies, userInfo: userInfo, codingPath: codingPath)
        try closure(value, encoder)
        return .value(encoder.resolveValue())
    }

    private func encodeDate(_ date: Date, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        switch strategies.date {
        case .deferredToDate:
            try encodeCustom(date, at: codingPath)
        case .millisecondsSince1970:
            .value(date.timeIntervalSince1970 * 1000.0)
        case .secondsSince1970:
            .value(date.timeIntervalSince1970)
        case .iso8601:
            .value(ISO8601DateFormatter.string(from: date, timeZone: .utc, formatOptions: .withInternetDateTime))
        case let .formatted(dateFormatter):
            .value(dateFormatter.string(from: date))
        case let .custom(closure):
            try encodeCustom(date, at: codingPath, using: closure)
        }
    }

    private func encodeData(_ data: Data, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        switch strategies.data {
        case .deferredToData:
            try encodeCustom(data, at: codingPath)
        case .base64:
            .value(data.base64EncodedString())
        case let .custom(closure):
            try encodeCustom(data, at: codingPath, using: closure)
        }
    }

    private func encodeFloatingPoint<T: FloatingPoint & Encodable>(_ value: T, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        if value.isFinite {
            return .value(value)
        }
        switch strategies.nonConformingFloat {
        case let .convertToString(positiveInfinity, _, _) where value == T.infinity:
            return .value(positiveInfinity)
        case let .convertToString(_, negativeInfinity, _) where value == -T.infinity:
            return .value(negativeInfinity)
        case let .convertToString(_, _, nan):
            return .value(nan)
        case .throw:
            throw EncodingError.invalidValue(value, at: codingPath, debugDescription: "Unable to encode \((value == -T.infinity ? "-" : "") + "\(T.self).\(value)") directly in Dictionary. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.")
        }
    }
}

/*
extension ComponentEncoder {
    func single(at codingPath: [CodingKey]) -> DictionaryEncoder.Single {
        .init(strategies: strategies, userInfo: userInfo, codingPath: codingPath)
    }

    func unkeyed(at codingPath: [CodingKey]) -> DictionaryEncoder.Unkeyed {
        .init(strategies: strategies, userInfo: userInfo, codingPath: codingPath)
    }

    func keyed(at codingPath: [CodingKey]) -> DictionaryEncoder.KeyedStorage {
        .init(strategies: strategies, userInfo: userInfo, codingPath: codingPath)
    }
}
*/
