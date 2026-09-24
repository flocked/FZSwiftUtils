//
//  PropertyListSerialization+.swift
//
//
//  Created by Florian Zand on 24.11.25.
//

import Foundation

public extension PropertyListSerialization {
    /**
     Returns the data containing a given property list in a specified format.
     
     - Parameters:
        - value: A property list object.
     - format: The property list format.
     - Returns: A data containing the property list in the format specified by format.
     */
    
    static func data(fromPropertyList plist: Any, format: PropertyListSerialization.PropertyListFormat) throws -> Data {
        try data(fromPropertyList: plist, format: format, options: 0)
    }
    
    /**
     Writes a property list to the specified stream.
     
     - Parameters:
        - plist: The property list that you want to write out.
        - stream: An OutputStream instance that is open and ready to receive the property list data.
        - format: The property list format.
     - Returns: The number of bytes written to the stream.
     */
    @discardableResult
    static func writePropertyList(_ plist: Any, to stream: OutputStream, format: PropertyListFormat) throws -> Int {
        var error: NSError?
        let bytes = writePropertyList(plist, to: stream, format: format, options: 0, error: &error)
        if let error { throw error }
        return bytes
    }
    
    /**
     Creates and returns a property list from the specified data.
     
     - Parameters:
        - data: A data object containing a serialized property list.
        - options: The options used to create the property list.
     - Returns: A property list corresponding to the representation in data and the format of the property list.
     */
    static func propertyList(from data: Data, options: PropertyListSerialization.ReadOptions = []) throws -> (propertyList: Any, format: PropertyListFormat) {
        var format: PropertyListFormat = .binary
        let propertyList = try propertyList(from: data, options: options, format: &format)
        return (propertyList, format)
    }
    
    /**
     Creates and returns a property list by reading from the specified stream.
     
     - Parameters:
        - stream: An input stream.
        - options: The options used to create the property list.
     - Returns: A property list corresponding to the representation in data and the format of the property list.
     */
    static func propertyList(with stream: InputStream, options: PropertyListSerialization.ReadOptions = []) throws -> (propertyList: Any, format: PropertyListFormat) {
            var format: PropertyListFormat = .binary
            let propertyList = try propertyList(with: stream, options: options, format: &format)
            return (propertyList, format)
        }
    
    /**
     Returns an data object containing a given property list in a specified format.
     
     - Parameters:
        - value: A value representing the property list.
        - format: The property list format.
     - Returns: A data containing the property list in the format specified by format.
     */
    static func data<T>(from value: T, format: PropertyListFormat) throws -> Data where T: PropertyListValue {
        try data(fromPropertyList: value, format: format, options: 0)
    }
    
    /**
     Returns an data object containing a given property list in a specified format.
     
     - Parameters:
        - value: A value representing the property list.
        - format: The property list format.
     - Returns: A data containing the property list in the format specified by format.
     */
    static func data<T>(from type: T, format: PropertyListFormat) throws -> Data where T: RawRepresentable, T.RawValue: PropertyListValue {
        try data(fromPropertyList: type.rawValue, format: format, options: 0)
    }
     
    /**
     Creates and returns a property list from the specified data.
     
     - Parameters:
        - data: A data object containing a serialized property list.
        - options: The options used to create the property list.
     - Returns: A property list corresponding to the representation in data and the format of the property list.
     */
    @_disfavoredOverload
    static func propertyList<T>(from data: Data) throws -> (propertyList: T, format: PropertyListFormat) where T: PropertyListValue {
        var format = PropertyListFormat.binary
        let propertyList: Any = try propertyList(from: data, format: &format)
        guard let propertyList = propertyList as? T else {
            throw DecodingError.typeMismatch(type(of: propertyList), at: [], debugDescription: "The property list has the wrong type.")
        }
        return (propertyList, format)
    }
}

/**
 A type that can be converted from and to a property list using [PropertyListSerialization](https://developer.apple.com/documentation/foundation/propertylistserialization).

 Only the following types are supported as property list objects:
 
    - `Int`,  `Int8`,  `Int16`,  `Int32`,  `Int64`, `UInt`,  `UInt8`,  `UInt16`,  `UInt32`,  `UInt64`
    -  `Float`, `Double`
    - `Bool`
    - `String`
    - `Data`
    - `Date`
    - `Array` with elements conforming to ``PropertyListValue``.
    - `Dictionary`: Supported if its `Key` is `String` and its `Value` type conforms to ``PropertyListValue``.
 */
public protocol PropertyListValue { }
extension Int: PropertyListValue { }
extension Int8: PropertyListValue { }
extension Int16: PropertyListValue { }
extension Int32: PropertyListValue { }
extension Int64: PropertyListValue { }
extension UInt: PropertyListValue { }
extension UInt8: PropertyListValue { }
extension UInt16: PropertyListValue { }
extension UInt32: PropertyListValue { }
extension UInt64: PropertyListValue { }
extension Double: PropertyListValue { }
extension Float: PropertyListValue { }
extension Bool: PropertyListValue { }
extension NSDate: PropertyListValue { }
extension NSData: PropertyListValue { }
extension NSNumber: PropertyListValue { }
extension String: PropertyListValue { }
extension Data: PropertyListValue { }
extension Date: PropertyListValue { }
extension Array: PropertyListValue where Element == (any PropertyListValue) { }
extension Dictionary: PropertyListValue where Key == String, Value == (any PropertyListValue) { }

/**
 A collection type that can be converted from and to a property list using [PropertyListSerialization](https://developer.apple.com/documentation/foundation/propertylistserialization).
 
 Only the following collection types are supported:
 
    - `Array` with elements conforming to ``PropertyListValue``.
    - `Set` with elements conforming to ``PropertyListValue``.
    - `Dictionary`: Supported if its `Key` is `String` and its `Value` type conforms to ``PropertyListValue``.
 */
public protocol PropertyListCollection { }
extension Array: PropertyListCollection where Element: PropertyListValue { }
extension Dictionary: PropertyListCollection where Key == String, Value: PropertyListValue { }
extension Set: PropertyListCollection where Element: PropertyListValue { }
