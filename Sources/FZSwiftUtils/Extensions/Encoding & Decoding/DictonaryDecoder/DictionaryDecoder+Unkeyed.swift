import Foundation

extension [CodingKey] {
    static func +(lhs: Self, rhs: String) -> Self {
        lhs + AnyCodingKey.key(rhs)
    }
    
    static func +(lhs: Self, rhs: Int) -> Self {
        lhs + AnyCodingKey.index(rhs)
    }
}

internal extension DictionaryDecoder {
    final class Unkeyed: UnkeyedDecodingContainer, _DictionaryDecoder {
                
        let components: [Any?]
        let options: Options
        let userInfo: [CodingUserInfoKey: Any]
        let codingPath: [CodingKey]
        private(set) var currentIndex = 0
        
        var currentCodingPath: [CodingKey] {
            codingPath + currentIndex
        }
        
        var count: Int? {
            components.count
        }
        
        var isAtEnd: Bool {
            currentIndex == count
        }
                
        init(components: [Any?], options: Options, userInfo: [CodingUserInfoKey: Any], codingPath: [CodingKey]) {
            self.components = components
            self.options = options
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
        
        private func decodeNext<T>(_ block: (_ value: Any?, _ codingPath: [CodingKey]) throws -> T) throws -> T {
            let codingPath = currentCodingPath
            guard currentIndex < components.count else {
                throw DecodingError.valueNotFound(T.self, at: codingPath, debugDescription: "Unkeyed container is at end at index \(currentIndex).")
            }
            defer { currentIndex += 1 }
            return try block(components[currentIndex], codingPath)
        }
                
        func decodeNil() throws -> Bool {
            try decodeNext { value,_ in decodeNil(value) }
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode(_ type: String.Type) throws -> String {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            try decodeNext { try decode($0, at: $1) }
        }
        
        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
            try superDecoder().container(keyedBy: keyType)
        }
        
        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            try superDecoder().unkeyedContainer()
        }
        
        func superDecoder() throws -> Decoder {
            try decodeNext { Single(component: $0, options: options, userInfo: userInfo, codingPath: $1) }
        }
    }
}
