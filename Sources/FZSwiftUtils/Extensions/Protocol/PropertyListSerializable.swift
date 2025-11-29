//
//  PropertyListSerializable.swift
//
//
//  Created by Florian Zand on 24.11.25.
//

import Foundation

/**
 A marker protocol for types that can be safely serialized using [PropertyListSerialization](https://developer.apple.com/documentation/foundation/propertylistserialization).

 Only the following types are supported as property list objects:
 
    - `Int`,  `Int8`,  `Int16`,  `Int32`,  `Int64`, `UInt`,  `UInt8`,  `UInt16`,  `UInt32`,  `UInt64`
    -  `Float`, `Double`
    - `Bool`
    - `String`
    - `Data`
    - `Date`
    - `Array`: Supported if its `Element` type conforms to ``PropertyListSerializable``.
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
extension String: PropertyListSerializable { }
extension Data: PropertyListSerializable { }
extension Date: PropertyListSerializable { }
extension Dictionary: PropertyListSerializable where Key == String { }
extension Array: PropertyListSerializable where Element: PropertyListSerializable { }

/*
public extension PropertyListSerialization {
    static func data<T>(from type: T, format: PropertyListFormat = .binary) throws -> Data where T: PropertyListSerializable {
        try data(fromPropertyList: type, format: format, options: 0)
    }
    
    static func data<T>(from type: T, format: PropertyListFormat = .binary) throws -> Data where T: RawRepresentable, T.RawValue: PropertyListSerializable {
        try data(fromPropertyList: type.rawValue, format: format, options: 0)
    }
    
    static func data(from url: URL, format: PropertyListFormat = .binary) throws -> Data {
        try data(fromPropertyList: url.absoluteString, format: format, options: 0)
    }
     
    @_disfavoredOverload
    static func propertyList<T>(from data: Data, format: PropertyListFormat = .binary) throws -> T where T: PropertyListSerialization {
        let propertyList: Any = try propertyList(from: data, format: format)
        guard let propertyList = propertyList as? T else {
            throw Errors.wrongDataType
        }
        return propertyList
    }
    
    enum Errors: Error {
        case wrongDataType
    }
}
*/
