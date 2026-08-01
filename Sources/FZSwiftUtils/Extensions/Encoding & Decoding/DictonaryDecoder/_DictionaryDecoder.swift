import Foundation

protocol _DictionaryDecoder {
    var options: DictionaryDecoder.Options { get }
    var userInfo: [CodingUserInfoKey: Any] { get }
}

extension _DictionaryDecoder {
    private func decodePrimitive<T: Decodable>(_ component: Any?, at codingPath: [CodingKey], as type: T.Type = T.self) throws -> T {
        guard let component = component else {
            throw DecodingError.valueNotFound(T.self, at: codingPath)
        }
        guard let value = component as? T else {
            throw DecodingError.typeMismatch(Swift.type(of: component), expected: T.self, at: codingPath)
        }
        return value
    }

    private func decodeNonPrimitive<T: Decodable>(_ component: Any?, at codingPath: [CodingKey]) throws -> T {
        try T(from: DictionaryDecoder.Single(component: component, options: options, userInfo: userInfo, codingPath: codingPath))
    }

    private func decodeCustomized<T: Decodable>(_ component: Any?, at codingPath: [CodingKey], closure: (_ decoder: Decoder) throws -> T) throws -> T {
        try closure(DictionaryDecoder.Single(component: component, options: options, userInfo: userInfo, codingPath: codingPath))
    }
    
    private func decodeFloatingPoint<T: FloatingPoint & Decodable>(_ component: Any?, at codingPath: [CodingKey]) throws -> T {
        guard let component = component else {
            throw DecodingError.valueNotFound(T.self, at: codingPath)
        }
        switch component {
        case let string as String:
            switch options.nonConformingFloatDecodingStrategy {
            case let .convertFromString(positiveInfinity, _, _) where string == positiveInfinity:
                return T.infinity
            case let .convertFromString(_, negativeInfinity, _) where string == negativeInfinity:
                return -T.infinity
            case let .convertFromString(_, _, nan) where string == nan:
                return T.nan
            case .convertFromString, .throw:
                break
            }
        case let number as T where number.isFinite:
            return number
        case let number as T:
            throw DecodingError.dataCorrupted(at: codingPath, debugDescription: "Parsed dictionary number \(number) does not fit in \(T.self).")
        default:
            break
        }
        throw DecodingError.typeMismatch(Swift.type(of: component), expected: T.self, at: codingPath)
    }

    private func decodeDate(_ component: Any?, at codingPath: [CodingKey]) throws -> Date {
        switch options.dateDecodingStrategy {
        case .deferredToDate:
            try decodeNonPrimitive(component, at: codingPath)
        case .secondsSince1970:
            try Date(timeIntervalSince1970: decodePrimitive(component, at: codingPath))
        case .millisecondsSince1970:
            try Date(timeIntervalSince1970: decodePrimitive(component, at: codingPath) / 1000.0)
        case .iso8601:
            try ISO8601DateFormatter().date(from: decodePrimitive(component, at: codingPath)).unwrap(or: DecodingError.dataCorrupted(at: codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
        case let .formatted(dateFormatter):
            try dateFormatter.date(from: decodePrimitive(component, at: codingPath)).unwrap(or: DecodingError.dataCorrupted(at: codingPath, debugDescription: "Date string does not match format expected by formatter."))
        case let .custom(closure):
            try decodeCustomized(component, at: codingPath, closure: closure)
        }
    }

    private func decodeData(_ component: Any?, at codingPath: [CodingKey]) throws -> Data {
        switch options.dataDecodingStrategy {
        case .deferredToData:
            try decodeNonPrimitive(component, at: codingPath)
        case .base64:
            try Data(base64Encoded: decodePrimitive(component, at: codingPath, as: String.self)).unwrap(or: DecodingError.dataCorrupted(at: codingPath, debugDescription: "Encountered Data is not valid Base64."))
        case let .custom(closure):
            try decodeCustomized(component, at: codingPath, closure: closure)
        }
    }

    private func decodeURL(_ component: Any?, at codingPath: [CodingKey]) throws -> URL {
        try component as? URL ?? URL(string: decodePrimitive(component, at: codingPath)).unwrap(or: DecodingError.dataCorrupted(at: codingPath, debugDescription: "String is not valid URL."))
    }
}

extension _DictionaryDecoder {
    func decodeNil(_ component: Any?) -> Bool {
        component.isNil || component is NSNull
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Bool {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Int {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Int8 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Int16 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Int32 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Int64 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> UInt {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> UInt8 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> UInt16 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> UInt32 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> UInt64 {
        try decodePrimitive(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Double {
        try decodeFloatingPoint(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> Float {
        try decodeFloatingPoint(component, at: codingPath)
    }

    func decode(_ component: Any?, at codingPath: [CodingKey]) throws -> String {
        try decodePrimitive(component, at: codingPath)
    }

    func decode<T: Decodable>(_ component: Any?, at codingPath: [CodingKey]) throws -> T {
        switch T.self {
        case is Date.Type:
            try decodeDate(component, at: codingPath) as! T
        case is Data.Type:
            try decodeData(component, at: codingPath) as! T
        case is URL.Type:
            try decodeURL(component, at: codingPath) as! T
        default:
            try decodeNonPrimitive(component, at: codingPath)
        }
    }
}
