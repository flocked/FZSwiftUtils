import Foundation

public extension DictionaryDecoder {
    /// The strategies for decoding raw data.
    enum DataDecodingStrategy: Sendable {
        /// The strategy that encodes data using the encoding specified by the data instance itself.
        case deferredToData
        /// The strategy that decodes data using Base 64 decoding.
        case base64
        /// The strategy that decodes data using a user-defined function.
        case custom(@Sendable (_ decoder: Decoder) throws -> Data)
    }
    
    /// The strategies available for formatting dates when decoding them from Dictionary.
    enum DateDecodingStrategy: Sendable {
        /// The strategy that uses formatting from the Date structure.
        case deferredToDate
        /// The strategy that decodes dates in terms of seconds since midnight UTC on January 1st, 1970.
        case secondsSince1970
        /// The strategy that decodes dates in terms of milliseconds since midnight UTC on January 1st, 1970.
        case millisecondsSince1970
        /// The strategy that formats dates according to the ISO 8601 standard.
        case iso8601
        /// The strategy that defers formatting settings to a supplied date formatter.
        case formatted(DateFormatter)
        /// The strategy that formats custom dates by calling a user-defined function.
        case custom(@Sendable (_ decoder: Decoder) throws -> Date)
        /// The strategy that defers formatting settings to a supplied date format.
        public static func formatted(_ format: String) -> Self {
            formatted(DateFormatter(format))
        }
    }
    
    /// The strategies for encoding nonconforming floating-point numbers, also known as IEEE 754 exceptional values.
    enum NonConformingFloatDecodingStrategy: Sendable {
        /// The strategy that throws an error upon decoding an exceptional floating-point value.
        case `throw`
        /// The strategy that decodes exceptional floating-point values from a specified string representation.
        case convertFromString(positiveInfinity: String,  negativeInfinity: String, nan: String)
    }
    
    /// The values that determine how to decode a type’s coding keys from Dictionary keys.
    enum KeyDecodingStrategy: Sendable {
        /// A key decoding strategy that doesn’t change key names during decoding.
        case useDefaultKeys
        /// A key decoding strategy defined by the closure you supply.
        case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }
}

internal extension DictionaryDecoder {
    struct Options {
        var dateDecodingStrategy: DateDecodingStrategy
        var dataDecodingStrategy: DataDecodingStrategy
        var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        var keyDecodingStrategy: KeyDecodingStrategy
    }
}
