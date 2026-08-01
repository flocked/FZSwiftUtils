import Foundation

extension DictionaryEncoder {
    internal struct Strategies {
        var date: DateEncodingStrategy
        var data: DataEncodingStrategy
        var nonConformingFloat: NonConformingFloatEncodingStrategy
        var `nil`: NilEncodingStrategy
        var key: KeyEncodingStrategy
    }
}
