import Foundation

internal indirect enum DictionaryComponent {
    case value(Any?)
    case container(DictionaryComponentContainer)

    internal func resolveValue() -> Any? {
        switch self {
        case .value(let value):
            return value

        case .container(let container):
            return container.resolveValue()
        }
    }
}
