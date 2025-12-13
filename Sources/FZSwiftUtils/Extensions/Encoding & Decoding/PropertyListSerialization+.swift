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
    static func data<T>(from value: T, format: PropertyListFormat) throws -> Data where T: PropertyListSerializable {
        try data(fromPropertyList: value, format: format, options: 0)
    }
    
    /**
     Returns an data object containing a given property list in a specified format.
     
     - Parameters:
        - value: A value representing the property list.
        - format: The property list format.
     - Returns: A data containing the property list in the format specified by format.
     */
    static func data<T>(from type: T, format: PropertyListFormat) throws -> Data where T: RawRepresentable, T.RawValue: PropertyListSerializable {
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
    static func propertyList<T>(from data: Data) throws -> (propertyList: T, format: PropertyListFormat) where T: PropertyListSerializable {
        var format = PropertyListFormat.binary
        let propertyList: Any = try propertyList(from: data, format: &format)
        guard let propertyList = propertyList as? T else {
            throw DecodingError.typeMismatch(type(of: propertyList), .init(codingPath: [], debugDescription: "The property list has the wrong type."))
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
    - `Array` with elements conforming to ``PropertyListSerializable``.
    - `Dictionary`: Supported if its `Key` is `String` and its `Value` type conforms to ``PropertyListSerializable``.
 */
public protocol PropertyListSerializable { }
extension Int: PropertyListSerializable { }
extension Int8: PropertyListSerializable { }
extension Int16: PropertyListSerializable { }
extension Int32: PropertyListSerializable { }
extension Int64: PropertyListSerializable { }
extension UInt: PropertyListSerializable { }
extension UInt8: PropertyListSerializable { }
extension UInt16: PropertyListSerializable { }
extension UInt32: PropertyListSerializable { }
extension UInt64: PropertyListSerializable { }
extension Double: PropertyListSerializable { }
extension Float: PropertyListSerializable { }
extension Bool: PropertyListSerializable { }
extension NSNumber: PropertyListSerializable { }
extension String: PropertyListSerializable { }
extension Data: PropertyListSerializable { }
extension Date: PropertyListSerializable { }
extension Array: PropertyListSerializable where Element == (any PropertyListSerializable) { }
extension Dictionary: PropertyListSerializable where Key == String, Value == (any PropertyListSerializable) { }
