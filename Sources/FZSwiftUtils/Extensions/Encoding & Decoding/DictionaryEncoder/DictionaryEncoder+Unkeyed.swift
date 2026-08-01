import Foundation

extension DictionaryEncoder {
    final class Unkeyed: UnkeyedEncodingContainer, DictionaryEncoderContainer, DictionaryComponentEncoder {
        private var components: [Component] = []
        
        let strategies: Strategies
        let userInfo: [CodingUserInfoKey: Any]
        let codingPath: [CodingKey]
        
        var currentCodingPath: [CodingKey] {
            codingPath + AnyCodingKey.index(count)
        }
        
        var count: Int {
            components.count
        }
                
        init(strategies: Strategies, userInfo: [CodingUserInfoKey: Any], codingPath: [CodingKey]) {
            self.strategies = strategies
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
                
        func encodeNil() throws {
            components += encodeNil(at: currentCodingPath)
        }
        
        func encode(_ value: Bool) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: Int) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: Int8) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: Int16) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: Int32) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: Int64) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: UInt) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: UInt8) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: UInt16) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: UInt32) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: UInt64) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: Double) throws {
            components += try encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: Float) throws {
            components += try encode(value, at: currentCodingPath)
        }
        
        func encode(_ value: String) throws {
            components += encode(value, at: currentCodingPath)
        }
        
        func encode<T: Encodable>(_ value: T) throws {
            components += try encode(value, at: currentCodingPath)
        }
        
        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
            let keyed = Keyed<NestedKey>(storage: KeyedStorage(strategies: strategies, userInfo: userInfo, codingPath: currentCodingPath))
            components += .container(keyed.storage)
            return KeyedEncodingContainer(keyed)
        }
        
        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let container = Unkeyed(strategies: strategies, userInfo: userInfo, codingPath: currentCodingPath)
            components += .container(container)
            return container
        }
        
        func superEncoder() -> Encoder {
            let encoder = Single(strategies: strategies, userInfo: userInfo, codingPath: currentCodingPath)
            components += .container(encoder)
            return encoder
        }
     
        func resolveValue() -> Any? {
            components.map({ $0.resolveValue() })
        }
    }
}
