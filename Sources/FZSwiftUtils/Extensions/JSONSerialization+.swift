//
//  JSONSerialization+.swift
//
//
//  Created by Florian Zand on 29.04.25.
//

import Foundation

extension JSONSerialization {
    /**
     Returns a JSON object from given JSON data.
     
     - Parameters:
        - data: A data object containing JSON data.
        - options: Options for reading the JSON data and creating the Foundation objects.
     */
    public class func json(with data: Data, options: ReadingOptions = []) throws -> JSON {
        JSON(try jsonObject(with: data, options: options), [])
    }
    
    /**
     Returns a JSON object from given JSON string.
     
     - Parameters:
        - string: A JSON string.
        - encoding: The string encoding.
        - options: Options for reading the JSON data and creating the Foundation objects.
     */
    public class func json(with string: String, using encoding: String.Encoding = .utf8, options: ReadingOptions = []) throws -> JSON {
        JSON(try jsonObject(with: string, using: encoding, options: options), [])
    }
    
    /**
     Returns a Foundation object from given JSON string.
     
     - Parameters:
        - string: A JSON string.
        - encoding: The string encoding.
        - options: Options for reading the JSON data and creating the Foundation objects.
     */
    public class func jsonObject(with string: String, using encoding: String.Encoding = .utf8, options: ReadingOptions = []) throws -> Any {
        guard let data = string.data(using: encoding) else {
            throw Errors.stringToData
        }
        return try jsonObject(with: data, options: options)
    }
}

extension JSONSerialization {
    /// A json object.
    public struct JSON: Sequence, Collection, BidirectionalCollection {
        let value: Any?
                
        private var pathComponents: [String] = []
        
        public init?(_ jsonObject: Any) {
            guard JSONSerialization.isValidJSONObject(jsonObject) else { return nil }
            value = jsonObject
        }
        
        init(_ value: Any?, _ pathComponents: [String]) {
            self.value = value
            self.pathComponents = pathComponents
        }
        
        public subscript (index: Int) -> JSON {
            if let value = array?[safe: index] {
                return JSON(value, pathComponents + "[\(index)]")
            }
            return JSON(nil, pathComponents)
        }
        
        public subscript (key: String) -> JSON {
            self[safe: key] ?? JSON(nil, pathComponents)
        }
        
        public subscript (safe key: String) -> JSON? {
            guard let value = dictionary?[key] else { return nil }
            return JSON(value, pathComponents + key)
        }
        
        public subscript (keyPaths: [String]) -> JSON {
            self[safe: keyPaths] ?? JSON(nil, pathComponents)
        }
        
        public subscript (safe keyPaths: [String]) -> JSON? {
            guard !keyPaths.isEmpty else { return self }
            var keys = keyPaths
            let key = keys.removeFirst()
            if let index = Int(key) {
                return self[safe: index]?[safe: keys]
            }
            return self[safe: key]?[safe: keys]
        }
        
        public func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
            guard let value = value else { throw Errors.noValue }
            return try JSONSerialization.data(withJSONObject: value, options: options)
        }
        
        /// Decodes the JSON to the specified type.
        public func decode<T: Decodable>(to type: T.Type = T.self, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> T {
            try JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy).decode(T.self, from: try jsonData())
        }
        
        /// Finds the first json object with the specified key.
        public func findFirst(_ key: String) -> JSON? {
            find(key, findOne: true).first
        }
        
        /// Finds all json objects with the specified key.
        public func find(_ key: String) -> [JSON] {
            find(key, findOne: false)
        }
        
        private func find(_ key: String, findOne: Bool = false) -> [JSON] {
            var results: [JSON] = []
            results += self[key]
            if !results.isEmpty && findOne {
                return results
            }
            for dicKey in (dictionary ?? [:]).keys {
                results += self[safe: dicKey]?.find(key, findOne: findOne) ?? []
                if !results.isEmpty && findOne {
                    return results
                }
            }
            for value in self {
                results += value.find(key, findOne: findOne)
                if !results.isEmpty && findOne {
                    return results
                }
            }
            return results
        }
        
        /// The dictionary value of the json object.
        public var dictionary: [String: JSON]? {
            _dictionary?.mapKeyValues({ ($0, JSON($1, pathComponents + $0)) })
        }
        
        var _dictionary: [String: Any]? {
            value as? [String: Any]
        }
        
        var _array: [Any]? {
            value as? [Any]
        }
        
        /// The array value of the json object.
        public var array: [JSON]? {
            _array != nil ? collect() : nil
        }
        
        /// The string value of the json object.
        public var string: String? {
            value as? String
        }
        
        /// The integer value of the json object.
        public var integer: Int? {
            guard bool == nil else { return nil }
            return value as? Int
        }
        
        /// The double value of the json object.
        public var double: Double? {
            guard bool == nil else { return nil }
            return value as? Double
        }
        
        /// The boolean value of the json object.
        public var bool: Bool? {
            guard let number = value as? NSNumber, CFGetTypeID(number) == CFBooleanGetTypeID() else { return nil }
            return number.boolValue
        }
        
        /// A Boolean value indicating whether the json object is `Null`.
        public var isNull: Bool {
            value is NSNull
        }
        
        /// The current path of the json object.
        public var currentPath: String {
            pathComponents.joined(separator: ".")
        }
        
        public func index(before i: Int) -> Int {
            _array?.index(before: i) ?? 0
        }
        
        public func index(after i: Int) -> Int {
            _array?.index(after: i) ?? 0
        }
        
        public var startIndex: Int {
            0
        }
        
        public var endIndex: Int {
            _array?.endIndex ?? 0
        }
        
        public func makeIterator() -> Iterator {
            Iterator(_array ?? [], pathComponents)
        }
        
        public struct Iterator: IteratorProtocol {
            let objects: [Any]
            let pathComponents: [String]
            var index = 0
            
            init(_ objects: [Any], _ pathComponents: [String]) {
                self.objects = objects
                self.pathComponents = pathComponents
            }
            
            mutating public func next() -> JSON? {
                guard let item = objects[safe: index] else { return nil }
                index += 1
                return JSON(item, pathComponents + "[\(index-1)]")
            }
        }
    }
    
    enum Errors: Error {
        case noValue
        case stringToData
    }
}
