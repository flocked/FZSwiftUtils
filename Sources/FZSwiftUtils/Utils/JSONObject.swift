//
//  JSONObject.swift
//
//
//  Created by Florian Zand on 29.04.25.
//

import Foundation

/// A json object.
public struct JSONObject: Sequence, Collection, BidirectionalCollection, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByNilLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral, RangeReplaceableCollection, Equatable {
    
    public var value: Any?
    
    /// The current path of the json object.
    public let codingPath: [CodingKey]
    
    public init() {
        self.value = nil
        self.codingPath = []
    }
    
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
    
    public init(dictionaryLiteral elements: (String, (any JSONSerializable))...) {
        value = Dictionary(uniqueKeysWithValues: elements)
        codingPath = []
    }
    
    public init(arrayLiteral elements: (any JSONSerializable)...) {
        value = elements
        codingPath = []
    }
    
    public init(booleanLiteral value: Bool) {
        self.value = value
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
        self.value = NSNull()
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
        get { (value as? [String: Any])?.mapKeyValues({ ($0, Self($1, codingPath + .key($0))) }) }
        //  set { value = newValue ?? NSNull() }
    }
        
    /// The array value of the json object.
    public var array: [Self]? {
        get { value is [Any] ? collect() : nil }
        //  set { value = newValue ?? NSNull() }
    }
        
    /// The string value of the json object.
    public var string: String? {
        get { value as? String }
        //  set { value = newValue ?? NSNull() }
    }
        
    /// The integer value of the json object.
    public var integer: Int? {
        get { bool == nil ? value as? Int : nil }
        //  set { value = newValue ?? NSNull() }
    }
        
    /// The double value of the json object.
    public var double: Double? {
        get { bool == nil ? value as? Double : nil }
        //   set { value = newValue ?? NSNull() }
    }
        
    /// The boolean value of the json object.
    public var bool: Bool? {
        get { (value as? NSNumber)?.safeBoolValue }
        //  set { value = newValue ?? NSNull() }
    }
        
    /// A Boolean value indicating whether the json object is `Null`.
    public var isNull: Bool {
        get { value is NSNull }
        /*
         set {
             guard newValue else { return }
             value = NSNull()
         }
          */
    }
    
    @_disfavoredOverload
    public subscript (index: Int) -> Self {
        get { Self(array?[safe: index], codingPath + .index(index)) }
        set {
            guard var value = value as? [Any], index < value.count else {
                return
            }
            Swift.print("SET array", newValue.value ?? "nil")
            value[index] = newValue.value ?? NSNull()
            self.value = value
        }
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
        get { array?[indexes.filter({ $0 >= 0 && $0 < endIndex })] ?? [] }
    }
        
    @_disfavoredOverload
    public subscript(key: String) -> Self {
        get { Self(dictionary?[key], codingPath + .key(key)) }
        set {
            guard var value = value as? [String:Any] else { return }
            Swift.print("SET DIC", newValue.value ?? "nil")
            value[key] = newValue.value
            self.value = value
        }
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
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, JSONObject == C.Element {
        guard var array = array else { return }
        array.replaceSubrange(subrange, with: newElements)
        value = array
    }
          
    /// Decodes the json object to the specified type.
    public func decoded<T: Decodable>(as type: T.Type = T.self, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> T {
        guard let value = value else {
            throw DecodingError.typeMismatch(NSNull.self, DecodingError.Context(codingPath: codingPath, debugDescription: "The value doesn't represent any json."))
        }
        return try JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy).decode(T.self, from: try JSONSerialization.data(withJSONObject: value))
    }
    
    /// Returns a JSON-encoded data representation of the object.
    public func encoded(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, outputFormatting: JSONEncoder.OutputFormatting = []) throws -> Data {
        guard let value = value else {
            throw EncodingError.invalidValue(value as Any, .init(codingPath: codingPath, debugDescription: "Cannot encode nil as JSON"))
        }
        // return try JSONSerialization.data(withJSONObject: value)
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
public protocol JSONSerializable { }
extension String: JSONSerializable { }
extension Int: JSONSerializable { }
extension Double: JSONSerializable { }
extension Bool: JSONSerializable { }
extension NSNull: JSONSerializable { }
extension NSNumber: JSONSerializable { }
extension Array: JSONSerializable where Element == (any JSONSerializable) { }
extension Dictionary: JSONSerializable where Key == String, Value == (any JSONSerializable) { }
extension Optional: JSONSerializable where Wrapped: JSONSerializable { }

extension NSNull: Swift.Encodable, Swift.Decodable {
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

/*
 extension JSONSerializable {
     func toJSONData(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
                   keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
                   dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64,
                   outputFormatting: JSONEncoder.OutputFormatting = []) throws -> Data {
         try JSONEncoder(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, outputFormatting: outputFormatting).encode(self)
     }
    
     func toJSONString(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
                   keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
                   dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64,
                   outputFormatting: JSONEncoder.OutputFormatting = []) throws -> String {
         guard let string = String(data: try toJSONData(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, outputFormatting: outputFormatting), encoding: .utf8) else {
             throw EncodingError.invalidValue("", .init(codingPath: [], debugDescription: "Failed to create String from json data."))
         }
         return string
     }
 }
  */

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

/*
 protocol JSONCollection {
     func value(forKey key: JSONValue.CodingKey) throws -> Any
     func settingValue(_ value: Any?, forKey key: JSONValue.CodingKey) throws -> Any
 }

 // MARK: - Array Conformance
 extension Array: JSONCollection where Element == Any {
     func value(forKey key: JSONValue.CodingKey) throws -> Any {
         switch key {
         case .key:
             throw NSError(domain: "JSONError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access Array with key"])
         case .index(let idx):
             guard indices.contains(idx) else { throw NSError(domain: "JSONError", code: 2, userInfo: nil) }
             return self[idx]
         }
     }
     
     func settingValue(_ value: Any?, forKey key: JSONValue.CodingKey) throws -> Any {
         switch key {
         case .key:
             throw NSError(domain: "JSONError", code: 3, userInfo: nil)
         case .index(let idx):
             guard indices.contains(idx), let v = value else { throw NSError(domain: "JSONError", code: 4, userInfo: nil) }
             var copy = self
             copy[idx] = v
             return copy
         }
     }
 }

 // MARK: - Dictionary Conformance
 extension Dictionary: JSONCollection where Key == String, Value == Any {
     func value(forKey key: JSONValue.CodingKey) throws -> Any {
         switch key {
         case .key(let k):
             guard let v = self[k] else { throw NSError(domain: "JSONError", code: 5, userInfo: nil) }
             return v
         case .index:
             throw NSError(domain: "JSONError", code: 6, userInfo: nil)
         }
     }
     
     func settingValue(_ value: Any?, forKey key: JSONValue.CodingKey) throws -> Any {
         switch key {
         case .key(let k):
             var copy = self
             copy[k] = value
             return copy
         case .index:
             throw NSError(domain: "JSONError", code: 7, userInfo: nil)
         }
     }
 }

 // MARK: - JSONValue
 public struct JSONValue:
     ExpressibleByStringLiteral,
     ExpressibleByFloatLiteral,
     ExpressibleByNilLiteral,
     ExpressibleByArrayLiteral,
     ExpressibleByDictionaryLiteral,
     ExpressibleByIntegerLiteral,
     ExpressibleByBooleanLiteral
 {
     
     // MARK: - Storage
     public final class Storage {
         public var root: Any
         public init(root: Any) { self.root = root }
     }
     
     private var storage: Storage
     private var codingPath: [CodingKey]
     
     // MARK: - Public Initializers
     public init(_ root: Any = [String: Any]()) {
         self.storage = Storage(root: root)
         self.codingPath = []
     }
     
     private init(storage: Storage, codingPath: [CodingKey]) {
         self.storage = storage
         self.codingPath = codingPath
     }
     
     // MARK: - Subscripts
     public subscript(key: String) -> JSONValue {
         get { JSONValue(storage: storage, codingPath: codingPath + [.key(key)]) }
         set { _ = try? self.mutateValue(newValue.storage.root, at: codingPath + [.key(key)]) }
     }
     
     public subscript(index: Int) -> JSONValue {
         get { JSONValue(storage: storage, codingPath: codingPath + [.index(index)]) }
         set { _ = try? self.mutateValue(newValue.storage.root, at: codingPath + [.index(index)]) }
     }
     
     // MARK: - Typed accessors
     public var intValue: Int? {
         get { unboxedValue() as? Int }
         set { _ = try? mutateValue(newValue) }
     }
     
     public var stringValue: String? {
         get { unboxedValue() as? String }
         set { _ = try? mutateValue(newValue) }
     }
     
     public var doubleValue: Double? {
         get { unboxedValue() as? Double }
         set { _ = try? mutateValue(newValue) }
     }
     
     public var boolValue: Bool? {
         get { unboxedValue() as? Bool }
         set { _ = try? mutateValue(newValue) }
     }
     
     public var arrayValue: [Any]? { unboxedValue() as? [Any] }
     public var dictionaryValue: [String: Any]? { unboxedValue() as? [String: Any] }
     public var isNull: Bool { (unboxedValue() as? NSNull) != nil }
     
     // MARK: - Private helpers
     private func unboxedValue() -> Any? {
         JSONValue.valueAt(storage.root, path: codingPath)
     }
     
     private mutating func ensureUnique() {
         
         if !isKnownUniquelyReferenced(&storage) {
             storage = Storage(root: deepCopy(storage.root))
         }
     }
     
     private func deepCopy(_ value: Any) -> Any {
         switch value {
         case let dict as [String: Any]:
             return dict.mapValues { deepCopy($0) }
         case let arr as [Any]:
             return arr.map { deepCopy($0) }
         default:
             return value
         }
     }
     
     // MARK: - Core mutation
     @discardableResult
     private mutating func mutateValue(_ newValue: Any?, at path: [CodingKey]? = nil) throws -> Any? {
         let actualPath = path ?? codingPath
         guard !actualPath.isEmpty else { storage.root = newValue ?? NSNull(); return storage.root }
         ensureUnique()
         let updatedRoot = try applyMutation(storage.root, path: actualPath[...], newValue: newValue)
         storage.root = updatedRoot
         return updatedRoot
     }
     
     private func applyMutation(_ currentValue: Any, path: ArraySlice<CodingKey>, newValue: Any?) throws -> Any {
         var path = path
         guard let head = path.first else { return newValue ?? NSNull() }
         path = path.dropFirst()
         
         guard let collection = currentValue as? JSONCollection else {
             throw NSError(domain: "JSONError", code: 100, userInfo: nil)
         }
         
         if path.isEmpty {
             return try collection.settingValue(newValue, forKey: head)
         } else {
             let child = try collection.value(forKey: head)
             let mutatedChild = try applyMutation(child, path: path, newValue: newValue)
             return try collection.settingValue(mutatedChild, forKey: head)
         }
     }
     
     // MARK: - Static value access
     public static func valueAt(_ root: Any, path: [CodingKey]) -> Any? {
         var node: Any? = root
         for key in path {
             switch (node, key) {
             case (let dict as [String: Any], .key(let k)):
                 node = dict[k]
             case (let arr as [Any], .index(let i)):
                 guard arr.indices.contains(i) else { return nil }
                 node = arr[i]
             default:
                 return nil
             }
         }
         return node
     }
     
     // MARK: - CodingKey
     public enum CodingKey: Swift.CodingKey {
         case key(String)
         case index(Int)
         
         public var stringValue: String {
             switch self { case .key(let k): return k; case .index(let i): return "[\(i)]" }
         }
         
         public var intValue: Int? { switch self { case .index(let i): return i; case .key: return nil } }
         
         public init?(stringValue: String) { self = .key(stringValue) }
         public init?(intValue: Int) { self = .index(intValue) }
     }
     
     // MARK: - Literal conformances
     public init(stringLiteral value: String) { self.storage = Storage(root: value); self.codingPath = [] }
     public init(floatLiteral value: Double) { self.storage = Storage(root: value); self.codingPath = [] }
     public init(nilLiteral: ()) { self.storage = Storage(root: NSNull()); self.codingPath = [] }
     public init(arrayLiteral elements: Any...) { self.storage = Storage(root: elements); self.codingPath = [] }
     public init(dictionaryLiteral elements: (String, Any)...) {
         self.storage = Storage(root: Dictionary(uniqueKeysWithValues: elements))
         self.codingPath = []
     }
     public init(integerLiteral value: Int) { self.storage = Storage(root: value); self.codingPath = [] }
     public init(booleanLiteral value: Bool) { self.storage = Storage(root: value); self.codingPath = [] }
 }

 */

/*
 public struct JSONValue: ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByNilLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral {
    
    private class Storage {
         var value: Any?
         init(_ value: Any? = nil) {
             self.value = value
         }
     }
    
     private var storage: Storage
     var codingPath: [CodingKey]
    
     public subscript(index: Int) -> Self {
         get { Self(storage: storage, codingPath: codingPath + [.index(index)]) }
     }
    
     public subscript(key: String) -> Self {
         get { Self(storage: storage, codingPath: codingPath + [.key(key)]) }
     }
    
     public var stringValue: String? {
         get { unboxedValue() as? String }
     }
        
     public var intValue: Int? {
         get { unboxedValue() as? Int }
     }
    
     public var doubleValue: Double? {
         get { unboxedValue() as? Double }
     }
    
     public var boolValue: Bool? {
         get { unboxedValue() as? Bool }
     }
    
     public  var arrayValue: [Any]? {
         get { unboxedValue() as? [Any] }
     }
    
     public var dictionaryValue: [String: Any]? {
         get { unboxedValue() as? [String: Any] }
     }
    
     public var isNull: Bool {
         get { unboxedValue() is NSNull }
     }
    
     private init(storage: Storage, codingPath: [CodingKey]) {
         self.storage = storage
         self.codingPath = codingPath
     }
    
     public init(integerLiteral value: Int) {
         self.storage = Storage(value)
         self.codingPath = []
     }
    
     public init(dictionaryLiteral elements: (String, (any JSONSerializable))...) {
         self.storage = Storage(Dictionary(uniqueKeysWithValues: elements))
         codingPath = []
     }
    
     public init(arrayLiteral elements: (any JSONSerializable)...) {
         storage = Storage(elements)
         codingPath = []
     }
    
     public init(booleanLiteral value: Bool) {
         storage = Storage(value)
         codingPath = []
     }
    
     public init(stringLiteral value: String) {
         storage = Storage(value)
         codingPath = []
     }
    
     public init(floatLiteral value: Double) {
         storage = Storage(value)
         codingPath = []
     }
    
     public init(nilLiteral: ()) {
         storage = Storage(NSNull())
         codingPath = []
     }
    
     private func unboxedValue() -> Any? {
         unboxValue(storage.value, codingPath: codingPath)
     }
    
     private func unboxValue(_ value: Any?, codingPath: [CodingKey]) -> Any? {
         guard let value = value else { return nil }
         guard !codingPath.isEmpty else { return value }
         var codingPath = codingPath
         switch codingPath.removeFirst() {
         case .index(let index):
             guard let array = value as? [Any], index < array.count else { return nil }
             return unboxValue(array[index], codingPath: codingPath)
         case .key(let key):
             guard let dic = value as? [String: Any] else { return nil }
             return unboxValue(dic[key], codingPath: codingPath)
         }
     }
    
     public enum CodingKey: Swift.CodingKey {
         case key(String)
         case index(Int)
        
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
     }
 }
 */
