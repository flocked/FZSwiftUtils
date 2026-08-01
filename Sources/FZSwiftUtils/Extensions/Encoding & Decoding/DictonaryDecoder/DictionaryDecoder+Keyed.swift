import Foundation

internal extension DictionaryDecoder {
    class Keyed<Key: CodingKey>: KeyedDecodingContainerProtocol, _DictionaryDecoder {
                
        let components: [String: Any]
        let options: Options
        let userInfo: [CodingUserInfoKey: Any]
        let codingPath: [CodingKey]
        
        var allKeys: [Key] {
            components.keys.compactMap { Key(stringValue: $0) }
        }
                
        init(components: [String: Any], options: Options, userInfo: [CodingUserInfoKey: Any], codingPath: [CodingKey]) {
            switch options.keyDecodingStrategy {
            case .useDefaultKeys:
                self.components = components
            case let.custom(closure):
                self.components = Dictionary(components.map { (closure(codingPath + AnyCodingKey.key($0.key)).stringValue, $0.value) })
            }
            self.options = options
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
                
        private func component<T>(of type: T.Type = T.self, forKey key: Key) throws -> T {
            guard let value = components[key.stringValue] else {
                throw DecodingError.valueNotFound(T.self, at: codingPath + key)
            }
            guard let value = value as? T else {
                throw DecodingError.typeMismatch(Swift.type(of: value), expected: type, at: codingPath + key)
            }
            return value
        }
                
        func contains(_ key: Key) -> Bool {
            components.contains { $0.key == key.stringValue }
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            try decodeNil(component(forKey: key))
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            try decode(component(forKey: key), at: codingPath + key)
        }
        
        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
            try superDecoder(for: key).container(keyedBy: keyType)
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            try superDecoder(for: key).unkeyedContainer()
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            try superDecoder(for: key)
        }
        
        func superDecoder() throws -> Decoder {
            try superDecoder(for: AnyCodingKey.key("super"))
        }
        
        private func superDecoder(for key: CodingKey) throws -> Decoder {
            Single(component: components[key.stringValue], options: options, userInfo: userInfo,  codingPath: codingPath + key)
        }
    }
}
