//
//  _CFConvertible.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

/// A type that can be converted to/from a Core Founation type.
public protocol __CFConvertible {
    func __bridgeToCF() -> CFTypeRef
    static func __bridgeFromCF(_ source: CFTypeRef) -> Self
}

/// A type that can be converted to/from a Core Founation type.
public protocol _CFConvertible: __CFConvertible, _ObjectiveCBridgeable {
    associatedtype _CFType: CFType
    func _bridgeToCF() -> _CFType
    static func _bridgeFromCF(_ source: _CFType) -> Self
}

public extension _CFConvertible {
    /// Returns the Core Foundation representation of the value.
    func asCF() -> _CFType {
        _bridgeToCF()
    }
}

public extension _CFConvertible where _CFType: AnyObject {
    func __bridgeToCF() -> CFTypeRef {
        _bridgeToCF()
    }
    
    static func __bridgeFromCF(_ source: CFTypeRef) -> Self {
        guard let s = _CFType(source) else {
            preconditionFailure("failed to bridge \(source) to incompatible CoreFoundation type \(_CFType.self)")
        }
        return _bridgeFromCF(s)
    }
}

public extension _CFConvertible where _CFType: _CFTollFreeBridgeable, _ObjectiveCType == _CFType.BridgedNSType {
    func _bridgeToCF() -> _CFType {
        _CFType._bridgeFromNS(_bridgeToObjectiveC())
    }
    
    static func _bridgeFromCF(_ source: _CFType) -> Self {
        _unconditionallyBridgeFromObjectiveC(source._bridgeToNS())
    }    
}

// MARK: Container

extension Array: _CFConvertible {
    public func _bridgeToCF() -> CFArray {
        CFArray._bridgeFromNS(map(_bridgeToCFIfNeeded)._bridgeToObjectiveC())
    }
    
    public static func _bridgeFromCF(_ source: CFArray) -> [Element] {
        source as! [Element]
    }
}

extension Dictionary: _CFConvertible {
    public func _bridgeToCF() -> CFDictionary {
        CFDictionary._bridgeFromNS(mapValues(_bridgeToCFIfNeeded)._bridgeToObjectiveC())
    }
    
    public static func _bridgeFromCF(_ source: CFDictionary) -> [Key: Value] {
        source as! [Key: Value]
    }
}

extension Set: _CFConvertible {
    public func _bridgeToCF() -> CFSet {
        CFSet._bridgeFromNS(NSSet(array: self.map(_bridgeToCFIfNeeded)))
    }
    
    public static func _bridgeFromCF(_ source: CFSet) -> Set<Element> {
        source as! Set<Element>
    }
}

// MARK: - Value

extension Bool: _CFConvertible {
    public typealias _CFType = CFBoolean
}

extension Calendar: _CFConvertible {
    public typealias _CFType = CFCalendar
}

extension CharacterSet: _CFConvertible {
    public typealias _CFType = CFCharacterSet
}

extension Data: _CFConvertible {
    public typealias _CFType = CFData
}

extension Date: _CFConvertible {
    public typealias _CFType = CFDate
}

extension Locale: _CFConvertible {
    public typealias _CFType = CFLocale
}

extension String: _CFConvertible {
    public typealias _CFType = CFString
}

extension TimeZone: _CFConvertible {
    public typealias _CFType = CFTimeZone
}

extension URL: _CFConvertible {
    public typealias _CFType = CFURL
}

// MARK: CFNumber

extension FixedWidthInteger where Self: _CFConvertible {
    public typealias _CFType = CFNumber
}

extension FloatingPoint where Self: _CFConvertible {
    public typealias _CFType = CFNumber
}

extension Int: _CFConvertible {}
extension Int8: _CFConvertible {}
extension Int16: _CFConvertible {}
extension Int32: _CFConvertible {}
extension Int64: _CFConvertible {}
extension UInt: _CFConvertible {}
extension UInt8: _CFConvertible {}
extension UInt16: _CFConvertible {}
extension UInt32: _CFConvertible {}
extension UInt64: _CFConvertible {}
extension Float32: _CFConvertible {}
extension Float64: _CFConvertible {}

// MARK: - Helper

private func _bridgeToCFIfNeeded<T>(_ v: T) -> Any {    
    if let bridgeable = v as? __CFConvertible {
        return bridgeable.__bridgeToCF()
    } else {
        return v
    }
}

