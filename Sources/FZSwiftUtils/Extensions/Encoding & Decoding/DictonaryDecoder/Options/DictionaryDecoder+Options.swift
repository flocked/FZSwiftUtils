import Foundation

extension DictionaryDecoder {
    internal struct Options {
        internal var dateDecodingStrategy: DictionaryDecoder.DateDecodingStrategy
        internal var dataDecodingStrategy: DictionaryDecoder.DataDecodingStrategy
        internal var nonConformingFloatDecodingStrategy: DictionaryDecoder.NonConformingFloatDecodingStrategy
        internal var keyDecodingStrategy: DictionaryDecoder.KeyDecodingStrategy
    }
}
