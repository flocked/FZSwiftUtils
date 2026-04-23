import Foundation

extension DictionaryEncoder {
    public enum NonConformingFloatEncodingStrategy: Sendable {
        case `throw`
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
}
