import Foundation

internal extension DictionaryEncoder {
    indirect enum Component {
        case value(Any?)
        case container(DictionaryEncoderContainer)
        
        func resolveValue() -> Any? {
            switch self {
            case .value(let value):
                value
            case .container(let container):
                container.resolveValue()
            }
        }
        
        var container: DictionaryEncoderContainer? {
            switch self {
            case .container(let container): container
            default: nil
            }
        }
    }
}
