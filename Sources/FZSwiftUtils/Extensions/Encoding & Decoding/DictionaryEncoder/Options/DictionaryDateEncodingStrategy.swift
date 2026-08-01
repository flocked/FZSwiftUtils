import Foundation

extension DictionaryEncoder {
    /// The formatting strategies available for formatting dates when encoding a date as JSON.
    public enum DateEncodingStrategy: Sendable {
        /// The strategy that uses formatting from the `Date` structure.
        case deferredToDate
        /// The strategy that encodes dates in terms of milliseconds since midnight UTC on January 1, 1970.
        case millisecondsSince1970
        /// The strategy that encodes dates in terms of seconds since midnight UTC on January 1, 1970.
        case secondsSince1970
        /// The strategy that formats dates according to the ISO 8601 and RFC 3339 standards.
        case iso8601
        /// The strategy that defers formatting settings to a supplied date formatter.
        case formatted(DateFormatter)
        /// The strategy that formats custom dates by calling a user-defined function.
        case custom(@Sendable (_ date: Date, _ encoder: Encoder) throws -> Void)
    }
}
