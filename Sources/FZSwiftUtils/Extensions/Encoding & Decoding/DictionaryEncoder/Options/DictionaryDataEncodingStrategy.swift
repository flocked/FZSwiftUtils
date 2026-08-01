import Foundation

extension DictionaryEncoder {
    /// The strategies for encoding raw data.
    public enum DataEncodingStrategy: Sendable {
        /// The strategy that encodes data using the encoding specified by the data instance itself.
        case deferredToData
        /// The strategy that encodes data using Base 64 encoding.
        case base64
        /// The strategy that encodes data using a user-defined function.
        case custom(@Sendable (_ data: Data, _ encoder: Encoder) throws -> Void)
    }
}
