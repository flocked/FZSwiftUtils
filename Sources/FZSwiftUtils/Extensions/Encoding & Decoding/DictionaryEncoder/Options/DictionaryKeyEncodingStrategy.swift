import Foundation

extension DictionaryEncoder {
    public enum KeyEncodingStrategy: Sendable {
        case useDefaultKeys
        case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }
}
