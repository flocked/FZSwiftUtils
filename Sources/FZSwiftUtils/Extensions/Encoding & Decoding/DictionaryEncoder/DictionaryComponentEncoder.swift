import Foundation

internal protocol DictionaryComponentEncoder {
    var strategies: DictionaryEncoder.Strategies { get }
    var userInfo: [CodingUserInfoKey: Any] { get }
}

extension DictionaryComponentEncoder {
    private func encodePrimitive(_ value: Any?, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        .value(value)
    }

    private func encodeNonPrimitive<T: Encodable>(_ value: T, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        try encodeCustomized(value, at: codingPath, closure: { try $0.encode(to: $1) })
    }

    private func encodeCustomized<T: Encodable>(_ value: T, at codingPath: [CodingKey], closure: (_ value: T, _ encoder: Encoder) throws -> Void) throws -> DictionaryEncoder.Component {
        let encoder = DictionaryEncoder.Single(strategies: strategies, userInfo: userInfo, codingPath: codingPath)
        try closure(value, encoder)
        return .value(encoder.resolveValue())
    }

    internal func encodeNil(at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        switch strategies.nil {
        case .useNil:
            encodePrimitive(nil, at: codingPath)
        case .useNSNull:
            encodePrimitive(NSNull(), at: codingPath)
        }
    }

    private func encodeDate(_ date: Date, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        switch strategies.date {
        case .deferredToDate:
            try encodeNonPrimitive(date, at: codingPath)
        case .millisecondsSince1970:
            encodePrimitive(date.timeIntervalSince1970 * 1000.0, at: codingPath)
        case .secondsSince1970:
            encodePrimitive(date.timeIntervalSince1970, at: codingPath)
        case .iso8601:
            encodePrimitive(ISO8601DateFormatter.string(from: date, timeZone: .utc, formatOptions: .withInternetDateTime), at: codingPath)
        case let .formatted(dateFormatter):
            encodePrimitive(dateFormatter.string(from: date), at: codingPath)
        case let .custom(closure):
            try encodeCustomized(date, at: codingPath, closure: closure)
        }
    }

    private func encodeData(_ data: Data, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        switch strategies.data {
        case .deferredToData:
            return try encodeNonPrimitive(data, at: codingPath)
        case .base64:
            return encodePrimitive(data.base64EncodedString(), at: codingPath)
        case let .custom(closure):
            return try encodeCustomized(data, at: codingPath, closure: closure)
        }
    }

    private func encodeFloatingPoint<T: FloatingPoint & Encodable>(_ value: T, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        if value.isFinite {
            return encodePrimitive(value, at: codingPath)
        }
        switch strategies.nonConformingFloat {
        case let .convertToString(positiveInfinity, _, _) where value == T.infinity:
            return encodePrimitive(positiveInfinity, at: codingPath)
        case let .convertToString(_, negativeInfinity, _) where value == -T.infinity:
            return encodePrimitive(negativeInfinity, at: codingPath)
        case let .convertToString(_, _, nan):
            return encodePrimitive(nan, at: codingPath)
        case .throw:
            let valueDescription: String
            switch value {
            case T.infinity:
                valueDescription = "\(T.self).infinity"
            case -T.infinity:
                valueDescription = "-\(T.self).infinity"
            default:
                valueDescription = "\(T.self).nan"
            }
            throw EncodingError.invalidValue(value, at: codingPath, debugDescription: """
                Unable to encode \(valueDescription) directly in Dictionary.
                Use DictionaryNonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
                """)
        }
    }

    private func encodeURL(_ url: URL, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        encodePrimitive(url.absoluteString, at: codingPath)
    }

    internal func encode(_ value: Bool, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: Int, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: Int8, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: Int16, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: Int32, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: Int64, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: UInt, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: UInt8, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: UInt16, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: UInt32, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: UInt64, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode(_ value: Double, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        try encodeFloatingPoint(value, at: codingPath)
    }

    internal func encode(_ value: Float, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        try encodeFloatingPoint(value, at: codingPath)
    }

    internal func encode(_ value: String, at codingPath: [CodingKey]) -> DictionaryEncoder.Component {
        encodePrimitive(value, at: codingPath)
    }

    internal func encode<T: Encodable>(_ value: T, at codingPath: [CodingKey]) throws -> DictionaryEncoder.Component {
        switch value {
        case let date as Date:
            try encodeDate(date, at: codingPath)
        case let data as Data:
            try encodeData(data, at: codingPath)
        case let url as URL:
            try encodeURL(url, at: codingPath)
        default:
            try encodeNonPrimitive(value, at: codingPath)
        }
    }
}

extension DictionaryComponentEncoder {
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
