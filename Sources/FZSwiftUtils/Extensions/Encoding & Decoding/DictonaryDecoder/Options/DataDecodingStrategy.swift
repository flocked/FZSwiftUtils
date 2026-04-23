import Foundation

extension DictionaryDecoder {
    /// The strategies for decoding raw data.
    public enum DataDecodingStrategy: Sendable {
        
        // MARK: - Enumeration Cases
        
        /// The strategy that encodes data using the encoding specified by the data instance itself.
        case deferredToData
        
        /// The strategy that decodes data using Base 64 decoding.
        case base64
        
        /// The strategy that decodes data using a user-defined function.
        case custom(@Sendable (_ decoder: Decoder) throws -> Data)
    }
}
