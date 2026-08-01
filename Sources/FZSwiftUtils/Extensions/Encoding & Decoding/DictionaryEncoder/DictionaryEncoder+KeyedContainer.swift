import Foundation

internal extension DictionaryEncoder {
    final class KeyedStorage: DictionaryEncoderContainer {
                
        private var components: [String: Component] = [:]
        
        let strategies: Strategies
        let userInfo: [CodingUserInfoKey: Any]
        let codingPath: [CodingKey]
                
        init(strategies: Strategies, userInfo: [CodingUserInfoKey: Any], codingPath: [CodingKey]) {
            self.strategies = strategies
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
                
        private func encodeKey<Key: CodingKey>(_ key: Key) -> String {
            switch strategies.key {
            case .useDefaultKeys:
                key.stringValue
            case let .custom(closure):
                closure(codingPath + key).stringValue
            }
        }
        
        subscript<Key: CodingKey>(key: Key) -> Component? {
            get { components[encodeKey(key)] }
            set { components[encodeKey(key)] = newValue }
        }
        
        func nestedContainer<Key: CodingKey, NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            let encodedKey = encodeKey(key)
            if let storage = components[encodedKey]?.container as? Self {
                return KeyedEncodingContainer(Keyed(storage: storage))
            }
            let keyed = Keyed<NestedKey>(storage: KeyedStorage(strategies: strategies, userInfo: userInfo, codingPath: codingPath + key))
            components[encodedKey] = .container(keyed.storage)
            return KeyedEncodingContainer(keyed)
        }
        
        func nestedUnkeyedContainer<Key: CodingKey>(forKey key: Key) -> UnkeyedEncodingContainer {
            let encodedKey = encodeKey(key)
            if let container = components[encodedKey]?.container as? Unkeyed {
                return container
            }
            let container = Unkeyed(strategies: strategies, userInfo: userInfo, codingPath: codingPath + key)
            components[encodedKey] = .container(container)
            return container
        }
        
        func superEncoder<Key: CodingKey>(forKey key: Key) -> Encoder {
            let encodedKey = encodeKey(key)
            if let container = components[encodedKey]?.container as? Single {
                return container
            }
            let encoder = Single(strategies: strategies, userInfo: userInfo, codingPath: codingPath + key)
            components[encodedKey] = .container(encoder)
            return encoder
        }
                
        func resolveValue() -> Any? {
            components.compactMapValues { $0.resolveValue() }
        }
    }
}
