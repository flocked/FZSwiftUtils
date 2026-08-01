import Foundation

internal extension DictionaryDecoder {
    final class Single: Decoder, SingleValueDecodingContainer, _DictionaryDecoder {
        
        let component: Any?
        let options: Options
        let userInfo: [CodingUserInfoKey: Any]
        let codingPath: [CodingKey]
                
        init(component: Any?, options: Options, userInfo: [CodingUserInfoKey: Any], codingPath: [CodingKey]) {
            self.component = component
            self.options = options
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
                
        func decodeNil() -> Bool {
            decodeNil(component)
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            try decode(component, at: codingPath)
        }
        
        func decode(_ type: String.Type) throws -> String {
            try decode(component, at: codingPath)
        }
        
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            try decode(component, at: codingPath)
        }
                
        func container<Key: CodingKey>(keyedBy keyType: Key.Type) throws -> KeyedDecodingContainer<Key> {
            guard let components = component as? [String: Any] else {
                throw DecodingError.keyedContainerTypeMismatch(at: codingPath, component: component)
            }
            return KeyedDecodingContainer(Keyed(components: components, options: options, userInfo: userInfo, codingPath: codingPath))
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            guard let components = component as? [Any?] else {
                throw DecodingError.unkeyedContainerTypeMismatch(at: codingPath, component: component)
            }
            return Unkeyed(components: components, options: options, userInfo: userInfo, codingPath: codingPath)
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            self
        }
    }
}

extension DecodingError {

    // MARK: - Type Methods

    fileprivate static func keyedContainerTypeMismatch(
        at codingPath: [CodingKey],
        component: Any?
    ) -> Self {
        let debugDescription: String

        switch component {
        case let value?:
            debugDescription = "Expected to decode \([String: Any].self) but found \(type(of: value)) instead."

        case nil:
            debugDescription = "Cannot get keyed decoding container -- found null value instead."
        }

        return .typeMismatch([String: Any].self, Context(codingPath: codingPath, debugDescription: debugDescription))
    }

    fileprivate static func unkeyedContainerTypeMismatch(
        at codingPath: [CodingKey],
        component: Any?
    ) -> Self {
        let debugDescription: String

        switch component {
        case let value?:
            debugDescription = "Expected to decode \([Any].self) but found \(type(of: value)) instead."

        case nil:
            debugDescription = "Cannot get unkeyed decoding container -- found null value instead."
        }

        return .typeMismatch([Any].self, Context(codingPath: codingPath, debugDescription: debugDescription))
    }
}
