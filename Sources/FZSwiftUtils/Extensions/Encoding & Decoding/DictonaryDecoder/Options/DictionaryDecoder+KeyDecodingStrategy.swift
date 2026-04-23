import Foundation

extension DictionaryDecoder {
    /// The values that determine how to decode a type’s coding keys from Dictionary keys.
    public enum KeyDecodingStrategy: Sendable {
        /// A key decoding strategy that doesn’t change key names during decoding.
        case useDefaultKeys
        /// A key decoding strategy defined by the closure you supply.
        case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }
}
