import Foundation

extension DictionaryEncoder {
    /// The strategies for encoding nonconforming floating-point numbers, also known as IEEE 754 exceptional values.
    public enum NonConformingFloatEncodingStrategy: Sendable {
        /// The strategy that throws an error upon encoding an exceptional floating-point value.
        case `throw`
        /// The strategy that encodes exceptional floating-point values from a specified string representation.
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
}
