import Foundation

extension DictionaryEncoder {
    /// The values that determine how to encode a type’s coding keys.
    public enum KeyEncodingStrategy: Sendable {
        /// The key encoding strategy that doesn’t change keys during encoding.
        case useDefaultKeys
        /// The key strategy that formats keys by calling a user-defined function.
        case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }
}
