import Foundation

extension DictionaryEncoder {
    internal struct Options {
        internal var dateEncodingStrategy: DateEncodingStrategy
        internal var dataEncodingStrategy: DataEncodingStrategy
        internal var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy
        internal var nilEncodingStrategy: NilEncodingStrategy
        internal var keyEncodingStrategy: KeyEncodingStrategy
    }
}
