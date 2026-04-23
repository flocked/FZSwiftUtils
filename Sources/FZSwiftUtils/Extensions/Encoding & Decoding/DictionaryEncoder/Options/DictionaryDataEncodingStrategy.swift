import Foundation

extension DictionaryEncoder {
    public enum DataEncodingStrategy: Sendable {
        case deferredToData
        case base64
        case custom(@Sendable (_ data: Data, _ encoder: Encoder) throws -> Void)
    }
}
