//
//  Any.swift
//
//
//  Created by Florian Zand on 21.11.25.
//

import Foundation

/// A type that provides methods and properties for `AnyObject`.
public struct _AnyObject: Identifiable, CustomStringConvertible {
    public let object: AnyObject
    
    public init(_ object: AnyObject) {
        self.object = object
    }
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(object)
    }
    
    public var description: String {
        "\(object)"
    }
    
    public var type: AnyClass {
        Swift.type(of: object)
    }
    
    public func getAssociatedValue<V>(_ key: String) -> V? {
        FZSwiftUtils.getAssociatedValue(key, object: object)
    }
    
    public func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: object, initialValue: initialValue)
    }
    
    public func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue: () -> T) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: object, weakInitialValue: weakInitialValue)
    }
    
    public func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue: () -> T?) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: object, weakInitialValue: weakInitialValue)
    }
    
    public func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: object, initialValue: initialValue)
    }
    
    public func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(value, key: key, object: object)
    }
    
    public func setAssociatedValue<T: AnyObject>(weak value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(weak: value, key: key, object: object)
    }
    
    public subscript<V>(key: String) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    public subscript<V: AnyObject>(weak key: String) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(weak: newValue, key: key) }
    }
    
    public subscript<V>(key: String, initialValue: () -> V) -> V {
        getAssociatedValue(key, initialValue: initialValue)
    }
        
    public subscript<V>(key: String, initialValue: @autoclosure () -> V) -> V {
        getAssociatedValue(key, initialValue: initialValue)
    }
    
    public subscript<V>(key: String, initialValue: @autoclosure () -> V?) -> V? {
        getAssociatedValue(key, initialValue: initialValue)
    }
    
    public subscript<V: AnyObject>(key: String, weakInitialValue: () -> V) -> V? {
        getAssociatedValue(key, weakInitialValue: weakInitialValue)
    }
    
    public subscript<V: AnyObject>(key: String, weakInitialValue: () -> V?) -> V? {
        getAssociatedValue(key, weakInitialValue: weakInitialValue)
    }
}

/// A type that provides methods and properties for `AnyClass`.
public struct _AnyClass: Identifiable, CustomStringConvertible {
    public let cls: AnyClass
    public init(_ cls: AnyClass) {
        self.cls = cls
    }
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(cls)
    }
    
    public var description: String {
        "\(cls)"
    }
    
    public var unwrapped: AnyClass? {
        guard let _cls = object_getClass(cls), _cls != cls else { return nil }
        return _cls
    }
    
    public var superclass: AnyClass? {
        let superclass: AnyClass = Self.superclass(for: cls)
        guard superclass != cls else { return nil }
        return superclass
    }
    
    public var rootSuperclass: AnyClass? {
        let rootSuperclass: AnyClass = Self.rootSuperclass(for: cls)
        guard rootSuperclass != cls else { return nil }
        return rootSuperclass
    }
    
    public var reflection: ClassReflection? {
        guard let cls = cls as? NSObject.Type else { return nil }
        return ClassReflection(cls)
    }
    
    public func reflection(includeSuperclass: Bool) -> ClassReflection? {
        guard let cls = cls as? NSObject.Type else { return nil }
        return ClassReflection(cls, includeSuperclass: includeSuperclass)
    }
    
    public func getAssociatedValue<V>(_ key: String) -> V? {
        FZSwiftUtils.getAssociatedValue(key, object: cls)
    }
    
    public func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: cls, initialValue: initialValue)
    }
    
    public func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue: () -> T) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: cls, weakInitialValue: weakInitialValue)
    }
    
    public func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue: () -> T?) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: cls, weakInitialValue: weakInitialValue)
    }
    
    public func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: cls, initialValue: initialValue)
    }
    
    public func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(value, key: key, object: cls)
    }
    
    public func setAssociatedValue<T: AnyObject>(weak value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(weak: value, key: key, object: cls)
    }
    
    public subscript<V>(key: String) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    public subscript<V: AnyObject>(weak key: String) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(weak: newValue, key: key) }
    }
    
    public subscript<V>(key: String, initialValue: () -> V) -> V {
        getAssociatedValue(key, initialValue: initialValue)
    }
        
    public subscript<V>(key: String, initialValue: @autoclosure () -> V) -> V {
        getAssociatedValue(key, initialValue: initialValue)
    }
    
    public subscript<V>(key: String, initialValue: @autoclosure () -> V?) -> V? {
        getAssociatedValue(key, initialValue: initialValue)
    }
    
    public subscript<V: AnyObject>(key: String, weakInitialValue: () -> V) -> V? {
        getAssociatedValue(key, weakInitialValue: weakInitialValue)
    }
    
    public subscript<V: AnyObject>(key: String, weakInitialValue: () -> V?) -> V? {
        getAssociatedValue(key, weakInitialValue: weakInitialValue)
    }
    
    static func superclass(for cls: AnyClass) -> AnyClass {
        guard let superclass = class_getSuperclass(cls), superclass != cls else { return cls }
        return superclass
    }
    
    static func rootSuperclass(for cls: AnyClass) -> AnyClass {
        guard let superclass = class_getSuperclass(cls), superclass != cls else { return cls }
        return rootSuperclass(for: superclass)
    }
}

/// A type to access additional methods for any value.
public struct _Any {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    /// A Boolean value indicating whether the value is optional.
    public var isOptional: Bool {
        value is (any OptionalProtocol)
    }
    
    /// A Boolean value indicating whether the valus is a `struct` based.
    public var isStruct: Bool {
        displayStyle == .struct
    }
    
    /// A Boolean value indicating whether the valus is a class based.
    public var isClass: Bool {
        Self.isClassType(unwrappedType)
    }
    
    /// The type of the value.
    public var type: Any.Type {
        Swift.type(of: value)
    }
    
    /// The unwrapped  type of the value, if it's optional.
    public var unwrappedType: Any.Type {
        (type as? (any OptionalProtocol.Type))?.wrappedType ?? type
    }
    
    /// The mirror of the value.
    public var mirror: Mirror {
        Mirror(reflecting: value)
    }
    
    /// The display style of the value (e.g. `class`, `struct`, `tuple` or `enum`).
    public var displayStyle: Mirror.DisplayStyle? {
        let mirror = mirror
        if mirror.displayStyle == .optional {
            if let firstChild = mirror.children.first {
                return Mirror(reflecting: firstChild.value).displayStyle
            } else {
                return nil
            }
        } else {
            return mirror.displayStyle
        }
    }
    
    /// Checks if the value type is matching the specified ObjC type encoding.
    public func isMatching(typeEncoding: String) -> Bool {
        switch typeEncoding {
        case "@": // id / object
            return isClass || (value as? any _ObjectiveCBridgeable)?._bridgeToObjectiveC() != nil
        case "#": // Class
            return value is AnyClass
        case ":": // SEL
            return value is Selector
        case "c": // char / CChar
            return value is CChar || value is Int8
        case "C": // unsigned char / UInt8
            return value is UInt8
        case "s": // short / Int16
            return value is Int16
        case "S": // unsigned short / UInt16
            return value is UInt16
        case "i": // int / Int32
            return value is Int32 || value is Int
        case "I": // unsigned int / UInt32
            return value is UInt32
        case "l": // long / Int32 (32-bit) / Int64 (64-bit)
            return value is Int
        case "L": // unsigned long / UInt
            return value is UInt
        case "q": // long long / Int64
            return value is Int64 || value is Int
        case "Q": // unsigned long long / UInt64
            return value is UInt64 || value is UInt
        case "f": // float
            return value is Float
        case "d": // double
            return value is Double
        case "B": // BOOL
            return value is Bool
        case "^": // pointer
            return true // cannot check pointer type reliably in Swift
        case "*": // C string
            return value is UnsafePointer<CChar> || value is String
        case "{": // struct
            return isStruct
        case "[": // C array
            return true
        case "v": // void
            return true
        default:
            return true
        }
    }
    
    private static func isClassType(_ type: Any.Type) -> Bool {
        return (type as? AnyObject.Type) != nil
    }
}
