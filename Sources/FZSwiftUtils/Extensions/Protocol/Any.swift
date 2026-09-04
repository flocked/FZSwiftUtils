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
    
    /// Returns the associated value for the specified key.
    public func getAssociatedValue<V>(_ key: String, as type: V.Type = V.self) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: object)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: object, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: object, initial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: object, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: object, weakInitial: initialValue)
    }

    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: object, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: object, initial: initialValue)
    }

    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: object, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: object, weakInitial: initialValue)
    }
    
    /// Sets the associated value for the specified key to the given value.
    public func setAssociatedValue(_ value: Any?, for key: String) {
        FZSwiftUtils.setAssociatedValue(value, for: key, of: object)
    }
    
    /// Sets the associated value for the specified key to the given value using a weak reference.
    public func setAssociatedValue(weak value: AnyObject?, for key: String) {
        FZSwiftUtils.setAssociatedValue(weak: value, for: key, of: object)
    }
    
    /// Returns or sets the associated value for the specified key.
    public subscript<V>(associated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public subscript<V>(associated key: String, initial initialValue: () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public subscript<V>(associated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns or sets the weakly associated value for the specified key.
    public subscript<V: AnyObject>(weakAssociated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
}

/// A type that provides methods and properties for `AnyClass`.
public struct _AnyClass: Identifiable, CustomStringConvertible, Equatable, Codable, Hashable {
    public let cls: AnyClass
    public init(_ cls: AnyClass) {
        self.cls = cls
    }
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(cls)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func encode(to encoder: any Encoder) throws {
       try encoder.encodeSingle(class_getName(cls).string)
    }
    
    public init(from decoder: any Decoder) throws {
        let name = try decoder.decodeSingle(String.self)
        guard let cls = NSClassFromString(name) else {
            throw NSError("No class with the name: \(name)")
        }
        self.init(cls)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
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
    
    public func info() -> ObjCClassInfo {
        ObjCClassInfo(cls)
    }
    
    static func superclass(for cls: AnyClass) -> AnyClass {
        guard let superclass = class_getSuperclass(cls), superclass != cls else { return cls }
        return superclass
    }
    
    static func rootSuperclass(for cls: AnyClass) -> AnyClass {
        guard let superclass = class_getSuperclass(cls), superclass != cls else { return cls }
        return rootSuperclass(for: superclass)
    }
    
    /// Returns the associated value for the specified key.
    public func getAssociatedValue<V>(_ key: String, as type: V.Type = V.self) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: cls)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: cls, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: cls, initial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: cls, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: cls, weakInitial: initialValue)
    }

    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: cls, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: cls, initial: initialValue)
    }

    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: cls, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: cls, weakInitial: initialValue)
    }
    
    /// Sets the associated value for the specified key to the given value.
    public func setAssociatedValue(_ value: Any?, for key: String) {
        FZSwiftUtils.setAssociatedValue(value, for: key, of: cls)
    }
    
    /// Sets the associated value for the specified key to the given value using a weak reference.
    public func setAssociatedValue(weak value: AnyObject?, for key: String) {
        FZSwiftUtils.setAssociatedValue(weak: value, for: key, of: cls)
    }
    
    /// Returns or sets the associated value for the specified key.
    public subscript<V>(associated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public subscript<V>(associated key: String, initial initialValue: () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public subscript<V>(associated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns or sets the weakly associated value for the specified key.
    public subscript<V: AnyObject>(weakAssociated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    public subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
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
        (unwrappedType as? AnyObject.Type) != nil
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
}
