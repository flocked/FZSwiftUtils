//
//  JSONObject.swift
//
//
//  Created by Florian Zand on 29.04.25.
//

import Foundation

/// A json object.
public struct JSONObject: Sequence, Collection, BidirectionalCollection, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByNilLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByIntegerLiteral, Equatable {
    let value: Any?
    
    /// The current path of the json object.
    public let codingPath: [CodingKey]
    
    /// Creates a json object from the specified data.
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        value = try JSONSerialization.jsonObject(with: data, options: options)
        codingPath = []
    }
    
    /// Creates a json object from the JSON file at the specified url.
    public init(contentsOf url: URL, options: JSONSerialization.ReadingOptions = []) throws {
        try self.init(data: try Data(contentsOf: url), options: options)
    }
    
    /// Creates a json object from the JSON string.
    public init(jsonString: String, using encoding: String.Encoding = .utf8, options: JSONSerialization.ReadingOptions = []) throws {
        guard let data = jsonString.data(using: encoding) else {
            throw EncodingError.invalidValue(jsonString, .init(codingPath: [], debugDescription: "Couldn't encodde string."))
        }
        try self.init(data: data, options: options)
    }
    
    public init(integerLiteral value: Int) {
        self.value = value
        self.codingPath = []
    }
    
    public init(dictionaryLiteral elements: (String, JSONObject)...) {
        value = Dictionary(uniqueKeysWithValues: elements)
        codingPath = []
    }
    
    public init(arrayLiteral elements: JSONObject...) {
        value = elements
        codingPath = []
    }
    
    public init(stringLiteral value: String) {
        self.value = value
        self.codingPath = []
    }
    
    public init(floatLiteral value: Double) {
        self.value = value
        self.codingPath = []
    }
    
    public init(nilLiteral: ()) {
        self.value = nil
        self.codingPath = []
    }
                        
    public init?(_ jsonObject: Any) {
        guard JSONSerialization.isValidJSONObject(jsonObject) else { return nil }
        value = jsonObject
        codingPath = []
    }
    
    public init<V: Encodable>(_ value: V, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, outputFormatting: JSONEncoder.OutputFormatting = []) throws {
        if value is JSONSerializable {
            self.value = value
        } else {
            self.value = try JSONSerialization.jsonObject(with: try JSONEncoder(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, outputFormatting: outputFormatting).encode(value))
        }
        self.codingPath = []
    }
        
    init(_ value: Any?, _ codingPath: [CodingKey]) {
        self.value = value
        self.codingPath = codingPath
    }
        
    /// The dictionary value of the json object.
    public var dictionary: [String: Self]? {
        (value as? [String: Any])?.mapKeyValues({ ($0, Self($1, codingPath + .key($0))) })
    }
        
    /// The array value of the json object.
    public var array: [Self]? {
        value is [Any] ? collect() : nil
    }
        
    /// The string value of the json object.
    public var string: String? {
        value as? String
    }
        
    /// The integer value of the json object.
    public var integer: Int? {
        bool == nil ? value as? Int : nil
    }
        
    /// The double value of the json object.
    public var double: Double? {
        bool == nil ? value as? Double : nil
    }
        
    /// The boolean value of the json object.
    public var bool: Bool? {
        (value as? NSNumber)?.safeBoolValue
    }
        
    /// A Boolean value indicating whether the json object is `Null`.
    public var isNull: Bool {
        value is NSNull
    }
    
    @_disfavoredOverload
    public subscript (index: Int) -> Self {
        Self(array?[safe: index], codingPath + .index(index))
    }
        
    public subscript (index: Int) -> Self? {
        guard let value = array?[safe: index] else { return nil }
        return Self(value, codingPath + .index(index))
    }
    
    public subscript<V: Decodable>(index: Int) -> V? {
        guard let jsonObject = array?[safe: index] else { return nil }
        return jsonObject.value as? V ?? (try? jsonObject.decoded())
    }
    
    public subscript(indexes: IndexSet) -> [Self] {
        array?[indexes.filter({ $0 >= 0 && $0 < endIndex })] ?? []
    }
        
    @_disfavoredOverload
    public subscript(key: String) -> Self {
        Self(dictionary?[key], codingPath + .key(key))
    }
    
    public subscript (key: String) -> Self? {
        guard let value = dictionary?[key] else { return nil }
        return Self(value, codingPath + .key(key))
    }
    
    public subscript<V: Decodable>(key: String) -> V? {
        guard let jsonObject = dictionary?[key] else { return nil }
        return jsonObject.value as? V ?? (try? jsonObject.decoded())
    }
        
    @_disfavoredOverload
    public subscript (codingPath: [CodingKey]) -> Self {
        guard !codingPath.isEmpty else { return self }
        var codingPath = codingPath
        let path = codingPath.removeFirst()
        switch path {
        case .key(let key): return self[key][codingPath]
        case .index(let index): return self[index][codingPath]
        }
    }
    
    @_disfavoredOverload
    public subscript (codingPath: CodingKey...) -> Self {
        self[codingPath]
    }
        
    public subscript (codingPath: [CodingKey]) -> Self? {
        guard !codingPath.isEmpty else { return nil }
        var codingPath = codingPath
        let path = codingPath.removeFirst()
        switch path {
        case .key(let key): return self[key]?[codingPath]
        case .index(let index): return self[index]?[codingPath]
        }
    }
    
    public subscript (codingPath: CodingKey...) -> Self? {
        self[codingPath]
    }
    
    /// Decodes the json object to the specified type.
    public func decoded<T: Decodable>(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> T {
        guard let value = value else {
            throw DecodingError.typeMismatch(NSNull.self, DecodingError.Context(codingPath: codingPath, debugDescription: "The value doesn't represent any json."))
        }
        return try JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy).decode(T.self, from: try JSONSerialization.data(withJSONObject: value))
    }
          
    /// Decodes the json object to the specified type.
    public func decoded<T: Decodable>(as type: T.Type = T.self, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> T {
        try decoded(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy)
    }
    
    /// Returns a JSON-encoded data representation of the object.
    public func encoded(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, outputFormatting: JSONEncoder.OutputFormatting = []) throws -> Data {
        guard let value = value else {
            throw EncodingError.invalidValue(NSNull(), .init(codingPath: codingPath, debugDescription: "Cannot encode nil as JSON"))
        }
        return try JSONEncoder(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, outputFormatting: outputFormatting).encode(AnyEncodable(value))
    }
        
    public func index(before i: Int) -> Int {
        precondition(i > startIndex, "Index out of bounds")
        return i - 1
    }
        
    public func index(after i: Int) -> Int {
        precondition(i < endIndex, "Index out of bounds")
        return i + 1
    }
        
    public var startIndex: Int {
        0
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        if let lhs = lhs.bool {
            return rhs.bool == lhs
        } else if let lhs = lhs.double {
            return rhs.double == lhs
        } else if let lhs = lhs.string {
            return rhs.string == lhs
        } else if let lhs = lhs.array {
            return rhs.array == lhs
        } else if let lhs = lhs.dictionary {
            return rhs.dictionary == lhs
        }
        return lhs.value == nil && rhs.value == nil
    }
        
    public var endIndex: Int {
        (value as? [Any])?.endIndex ?? 0
    }
        
    public func makeIterator() -> Iterator {
        Iterator(value as? [Any] ?? [], codingPath)
    }
        
    public struct Iterator: IteratorProtocol {
        let objects: [Any]
        let codingPath: [CodingKey]
        var index = 0
            
        init(_ objects: [Any], _ codingPath: [CodingKey]) {
            self.objects = objects
            self.codingPath = codingPath
        }
            
        mutating public func next() -> JSONObject? {
            guard let item = objects[safe: index] else { return nil }
            index += 1
            return JSONObject(item, codingPath + .index(index-1))
        }
    }
}

extension JSONObject: Codable {
    public func encode(to encoder: any Encoder) throws {
        guard let value = value else {
            throw EncodingError.invalidValue(NSNull(), .init(codingPath: codingPath, debugDescription: "Cannot encode nil as JSON"))
        }
        var container = encoder.singleValueContainer()
        try container.encode(AnyEncodable(value))
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(AnyDecodable.self).value
        codingPath = []
    }
}

extension JSONObject {
    public enum CodingKey: Swift.CodingKey, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
        case key(String)
        case index(Int)
        
        public init(stringLiteral value: String) {
            self = .key(value)
        }
        
        public init(integerLiteral value: Int) {
            self = .index(value)
        }
        
        public var stringValue: String {
            switch self {
            case .key(let key): return key
            case .index(let index): return "[\(index)]"
            }
        }
        
        public var intValue: Int? {
            switch self {
            case .index(let index): return index
            case .key: return nil
            }
        }
        
        public init?(intValue: Int) {
            self = .index(intValue)
        }
        
        public init?(stringValue: String) {
            self = .key(stringValue)
        }
        
        public var description: String {
            stringValue
        }
    }
}

/// A type that can be converted to JSON.
public protocol JSONSerializable: Codable { }
extension String: JSONSerializable { }
extension Int: JSONSerializable { }
extension Double: JSONSerializable { }
extension Bool: JSONSerializable { }
extension NSNull: JSONSerializable { }
extension Array: JSONSerializable where Element: JSONSerializable { }
extension Dictionary: JSONSerializable where Key == String, Value: JSONSerializable { }
extension NSNumber: JSONSerializable { }

extension NSNull: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

extension Decodable where Self: NSNull {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard container.decodeNil() else {
            throw DecodingError.typeMismatch(NSNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected null"))
        }
        self.init()
    }
}

fileprivate struct AnyEncodable: Encodable {
    let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = value as? NSNumber {
            try container.encode(value)
            return
        }
        switch value {
        case let v as Bool: try container.encode(v)
        case let v as String: try container.encode(v)
        case let v as Int: try container.encode(v)
        case let v as Double: try container.encode(v)
        case _ as NSNull: try container.encodeNil()
        case let v as [Any]:
            try container.encode(v.map { AnyEncodable($0) })
        case let v as [String: Any]:
            try container.encode(v.mapValues { AnyEncodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported JSON value"))
        }
    }
}

fileprivate struct AnyDecodable: Decodable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.init(NSNull())
        } else if let value = try? container.decode(Bool.self) {
            self.init(value)
        } else if let bool = try? container.decode(Int.self) {
            self.init(bool)
        } else if let bool = try? container.decode(Double.self) {
            self.init(bool)
        } else if let bool = try? container.decode(String.self) {
            self.init(bool)
        } else if let array = try? container.decode([AnyDecodable].self) {
            self.init(array.map(\.value))
        } else if let dictionary = try? container.decode([String: AnyDecodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}
