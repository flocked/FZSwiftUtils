import Foundation

extension DictionaryEncoder {
    public enum NilEncodingStrategy: Sendable {
        case useNil
        case useNSNull
    }
}
