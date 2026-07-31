//
//  JSONObject.swift
//
//
//  Created by Florian Zand on 29.04.25.
//

import Foundation

/// A json object.
public struct JSONObject: Sequence, Collection, BidirectionalCollection, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByNilLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral, RangeReplaceableCollection, Equatable {
    
    /// The kind of a JSON object.
    public enum JSONKind {
        /// Missing.
        case missing
        /// Null.
        case null
        /// Boolean
        case bool
        /// Number.
        case number
        /// String.
        case string
        /// Array.
        case array
        /// Dictionary.
        case dictionary
    }
    
    /// The kind of the JSON object.
    public var kind: JSONKind {
        guard let value else { return .missing }
        if value is NSNull { return .null }
        if (value as? NSNumber)?.safeBoolValue != nil { return .bool }
        if value is NSNumber || value is Int || value is Double { return .number }
        if value is String { return .string }
        if value is [String: Any] { return .dictionary }
        if value is [Any] { return .array }
        return .missing
    }
    
    /// The value of the JSON object.
    public var value: Any?
    
    /// The current path of the `JSON` object.
    public let codingPath: [CodingKey]
    
    public init() {
        self.value = nil
        self.codingPath = []
    }
    
    /// Creates a `JSON` object from the specified data.
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        value = try JSONSerialization.jsonObject(with: data, options: options)
        codingPath = []
    }
    
    /// Creates a `JSON` object from the `JSON` file at the specified url.
    public init(contentsOf url: URL, options: JSONSerialization.ReadingOptions = []) throws {
        try self.init(data: Data(contentsOf: url), options: options)
    }
    
    /// Creates a `JSON` object from the specified `JSON` string.
    public init(jsonString: String, using encoding: String.Encoding = .utf8, options: JSONSerialization.ReadingOptions = []) throws {
        guard let data = jsonString.data(using: encoding) else {
            throw EncodingError.invalidValue(jsonString, .init(codingPath: [], debugDescription: "Couldn't encodde string."))
        }
        try self.init(data: data, options: options)
    }
    
    /// Creates a `JSON` object from the specified Integer value.
    public init(integerLiteral value: Int) {
        self.value = value
        self.codingPath = []
    }
    
    public init(dictionaryLiteral elements: (String, any JSONSerializable)...) {
        self.value = Dictionary(elements)
        self.codingPath = []
    }
    
    public init(arrayLiteral elements: (any JSONSerializable)...) {
        self.value = elements
        self.codingPath = []
    }

    /// Creates a `JSON` object from the specified Boolean value.
    public init(booleanLiteral value: Bool) {
        self.value = value
        self.codingPath = []
    }
    
    /// Creates a `JSON` object from the specified String value.
    public init(stringLiteral value: String) {
        self.value = value
        self.codingPath = []
    }
    
    /// Creates a `JSON` object from the specified Double value.
    public init(floatLiteral value: Double) {
        self.value = value
        self.codingPath = []
    }
    
    /// Creates a `JSON` object from the specified `nil` value.
    public init(nilLiteral: ()) {
        self.value = NSNull()
        self.codingPath = []
    }
    
    public init<V: Encodable>(_ value: V, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, outputFormatting: JSONEncoder.OutputFormatting = []) throws {
        if value is JSONSerializable {
            self.value = value
        } else {
            self.value = try JSONSerialization.jsonObject(with: JSONEncoder(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, outputFormatting: outputFormatting).encode(value))
        }
        self.codingPath = []
    }
        
    private init(_ value: Any?, _ codingPath: [CodingKey]) {
        self.value = value
        self.codingPath = codingPath
    }
        
    /// The dictionary value of the json object.
    public var dictionary: [String: Self]? {
        get { (value as? [String: Any])?.mapKeyValues { ($0, Self($1, codingPath + .key($0))) } }
        set { setValue(newValue?.compactMapValues { $0.value }) }
    }
        
    /// The array value of the json object.
    public var array: [Self]? {
        get { (value as? [Any])?.enumerated().map { Self($0.element, codingPath + .index($0.offset)) } }
        set { setValue(newValue?.map { $0.value ?? NSNull() }) }
    }
        
    /// The string value of the json object.
    public var string: String? {
        get { value as? String }
        set { value = setValue(newValue) }
    }
        
    /// The integer value of the json object.
    public var integer: Int? {
        get { bool == nil ? value as? Int : nil }
        set { value = setValue(newValue) }
    }
        
    /// The double value of the json object.
    public var double: Double? {
        get { bool == nil ? value as? Double : nil }
        set { value = setValue(newValue) }
    }
        
    /// The boolean value of the json object.
    public var bool: Bool? {
        get { (value as? NSNumber)?.safeBoolValue ?? value as? Bool }
        set { value = setValue(newValue) }
    }
        
    /// A Boolean value indicating whether the json object is `Null`.
    public var isNull: Bool {
        get { value is NSNull }
        set {
            guard newValue else { return }
            value = setValue(newValue)
        }
    }
    
    private mutating func setValue(_ newValue: Any?) {
        guard kind != .missing else { return }
        value = newValue ?? NSNull()
    }
    
    @_disfavoredOverload
    public subscript(index: Int) -> Self {
        get { Self((value as? [Any])?[safe: index], codingPath + .index(index)) }
        set {
            guard var value = value as? [Any], index < value.count else {
                return
            }
            value[index] = newValue.value ?? NSNull()
            self.value = value
        }
    }
        
    public subscript(index: Int) -> Self? {
        get { (value as? [Any])?[safe: index].map({ Self($0, codingPath + .index(index)) }) }
        set {
            guard var value = value as? [Any], index < value.count else {
                return
            }
            value[index] = newValue?.value ?? NSNull()
            self.value = value
        }
    }
    
    public subscript<V: Decodable>(index: Int) -> V? {
        guard let jsonObject = self[index] as Self? else { return nil }
        return jsonObject.value as? V ?? (try? jsonObject.decoded())
    }
    
    public subscript(indexes: IndexSet) -> [Self] {
        array?[indexes.filter { $0 >= 0 && $0 < endIndex }] ?? []
    }
        
    @_disfavoredOverload
    public subscript(key: String) -> Self {
        get { Self((value as? [String: Any])?[key], codingPath + .key(key)) }
        set {
            guard var value = value as? [String: Any] else { return }
            value[key] = newValue.value
            self.value = value
        }
    }
    
    public subscript(key: String) -> Self? {
        get { (value as? [String: Any])?[key].map({ Self($0, codingPath + .key(key)) }) }
        set {
            guard var value = value as? [String: Any] else { return }
            value[key] = newValue?.value
            self.value = value
        }
    }
    
    public subscript<V: Decodable>(key: String) -> V? {
        guard let jsonObject = self[key] as Self? else { return nil }
        return jsonObject.value as? V ?? (try? jsonObject.decoded())
    }
        
    @_disfavoredOverload
    public subscript(codingPath: [CodingKey]) -> Self {
        guard !codingPath.isEmpty else { return self }
        var codingPath = codingPath
        let path = codingPath.removeFirst()
        switch path {
        case .key(let key): return self[key][codingPath]
        case .index(let index): return self[index][codingPath]
        }
    }
    
    @_disfavoredOverload
    public subscript(codingPath: CodingKey...) -> Self {
        self[codingPath]
    }
        
    public subscript(codingPath: [CodingKey]) -> Self? {
        guard !codingPath.isEmpty else { return nil }
        var codingPath = codingPath
        let path = codingPath.removeFirst()
        switch path {
        case .key(let key): return self[key]?[codingPath]
        case .index(let index): return self[index]?[codingPath]
        }
    }
    
    public subscript(codingPath: CodingKey...) -> Self? {
        self[codingPath]
    }
    
    public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C) where JSONObject == C.Element {
        guard var array = array else { return }
        array.replaceSubrange(subrange, with: newElements)
        value = array.map { $0.value ?? NSNull() }
    }
    
    public func decoded<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder) throws -> T {
        guard let value = value else {
            throw DecodingError.typeMismatch(NSNull.self, DecodingError.Context(codingPath: codingPath, debugDescription: "The value doesn't represent any json."))
        }
        return try decoder.decode(T.self, from: JSONSerialization.data(withJSONObject: value))
    }
          
    /// Decodes the json object to the specified type.
    public func decoded<T: Decodable>(as type: T.Type = T.self, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> T {
        try decoded(decoder: JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy))
    }
    
    public func encoded(encoder: JSONEncoder) throws -> Data {
        guard let value = value else {
            throw EncodingError.invalidValue(value as Any, .init(codingPath: codingPath, debugDescription: "Cannot encode nil as JSON"))
        }
        return try encoder.encode(AnyEncodable(value))
    }
    
    /// Returns a JSON-encoded data representation of the object.
    public func encoded(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, outputFormatting: JSONEncoder.OutputFormatting = []) throws -> Data {
        try encoded(encoder: JSONEncoder(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, outputFormatting: outputFormatting))
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
            
        public mutating func next() -> JSONObject? {
            guard let item = objects[safe: index] else { return nil }
            index += 1
            return JSONObject(item, codingPath + .index(index - 1))
        }
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
        } else if lhs.isNull {
            return rhs.isNull
        }
        return lhs.value == nil && rhs.value == nil
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

public extension JSONObject {
    enum CodingKey: Swift.CodingKey, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
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
        
        public init(intValue: Int) {
            self = .index(intValue)
        }
        
        public init(stringValue: String) {
            self = .key(stringValue)
        }
        
        public var description: String {
            stringValue
        }
    }
}

/// A type that can be converted to JSON.
public protocol JSONSerializable {}
extension String: JSONSerializable {}
extension Int: JSONSerializable {}
extension Double: JSONSerializable {}
extension Bool: JSONSerializable {}
extension NSNull: JSONSerializable {}
extension NSNumber: JSONSerializable {}
extension [any JSONSerializable]: JSONSerializable {}
extension [String: any JSONSerializable]: JSONSerializable {}
extension Optional: JSONSerializable where Wrapped: JSONSerializable {}
