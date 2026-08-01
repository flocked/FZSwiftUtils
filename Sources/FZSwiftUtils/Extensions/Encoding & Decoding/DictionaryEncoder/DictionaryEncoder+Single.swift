import Foundation

internal extension DictionaryEncoder {
    final class Single: Encoder, SingleValueEncodingContainer, DictionaryEncoderContainer, DictionaryComponentEncoder {
                
        private var component: Component?
        
        let strategies: Strategies
        let userInfo: [CodingUserInfoKey: Any]
        let codingPath: [CodingKey]
                
        init(strategies: Strategies, userInfo: [CodingUserInfoKey: Any], codingPath: [CodingKey]) {
            self.strategies = strategies
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
                
        private func setComponent(_ component: Component, for value: Any? = nil) throws {
            guard self.component == nil else {
                throw EncodingError.invalidValue(value as Any, at: codingPath, debugDescription: "Single value container already has encoded value")
            }
            self.component = component
        }
                
        func encodeNil() throws {
            try setComponent(encodeNil(at: codingPath))
        }
        
        func encode(_ value: Bool) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: Int) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: Int8) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: Int16) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: Int32) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: Int64) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: UInt) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: UInt8) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: UInt16) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: UInt32) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: UInt64) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: Double) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: Float) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode(_ value: String) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
        
        func encode<T: Encodable>(_ value: T) throws {
            try setComponent(encode(value, at: codingPath), for: value)
        }
                
        func container<Key: CodingKey>(keyedBy keyType: Key.Type) -> KeyedEncodingContainer<Key> {
            if let storage = component?.container as? KeyedStorage {
                return KeyedEncodingContainer(Keyed(storage: storage))
            }
            let keyed = Keyed<Key>(storage: KeyedStorage(strategies: strategies, userInfo: userInfo, codingPath: codingPath))
            component = .container(keyed.storage)
            return KeyedEncodingContainer(keyed)
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            if let container = component?.container as? Unkeyed {
                return container
            }
            let container = Unkeyed(strategies: strategies, userInfo: userInfo, codingPath: codingPath)
            component = .container(container)
            return container
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            self
        }
                
        func resolveValue() -> Any? {
            component?.resolveValue()
        }
    }
}
