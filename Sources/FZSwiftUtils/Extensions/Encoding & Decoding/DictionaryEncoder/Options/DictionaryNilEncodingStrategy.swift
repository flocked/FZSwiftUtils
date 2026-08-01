import Foundation

extension DictionaryEncoder {
    /// The strategies for encoding `nil` values.
    public enum NilEncodingStrategy: Sendable {
        /// The strategy that encodes `nil` values as `nil`.
        case useNil
        /// The strategy that encodes `nil` values as `NSNull`.
        case useNSNull
    }
}
