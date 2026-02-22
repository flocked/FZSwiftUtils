//
//  NSObject+.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

public extension NSObject {
    /// The identifier of the object.
    var objectID: ObjectIdentifier {
        ObjectIdentifier(self)
    }
    
    /// The identifier of the class.
    static var classID: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    func value<Value>(forKey key: String) -> Value? {
        value(forKeySafely: key) as? Value
    }

    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    func value(forKeySafely key: String) -> Any? {
        try? ObjCRuntime.catchException {
            self.value(forKey: key)
        }
    }

    /**
     Returns the value for the derived property identified by a given key path.

     - Parameter keyPath: A key path of the form relationship.property (with one or more relationships); for example “department.name” or “department.manager.lastName”.
     - Returns: The value for the derived property identified by keyPath, or `nil` if the key path doesn't exist.
     */
    func value<Value>(forKeyPath keyPath: String) -> Value? {
        value(forKeyPathSafely: keyPath) as? Value
    }

    /**
     Returns the value for the derived property identified by a given key path.

     - Parameter keyPath: A key path of the form relationship.property (with one or more relationships); for example “department.name” or “department.manager.lastName”.
     - Returns: The value for the derived property identified by keyPath, or `nil` if the key path doesn't exist.
     */
    func value(forKeyPathSafely keyPath: String) -> Any? {
        try? ObjCRuntime.catchException {
            self.value(forKeyPath: keyPath)
        }
    }

    /**
     Sets the value safely for the specified key, only if the object contains a property with the given key.

     - Parameters:
        - value: The value to set.
        - key: The key of the property to set.
     */
    func setValue(safely value: Any?, forKey key: String) {
        try? ObjCRuntime.catchException {
            setValue(value, forKey: key)
        }
    }

    /**
     Sets the value for the property identified by a given key path to a given value.

     - Parameters:
        - value: The value to set.
        - keyPath: A key path of the form relationship.property (with one or more relationships): for example “department.name” or “department.manager.lastName.”
     */
    func setValue(safely value: Any?, forKeyPath keyPath: String) {
        try? ObjCRuntime.catchException {
            setValue(value, forKeyPath: keyPath)
        }
    }

    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    class func value(forKeySafely key: String) -> Any? {
        try? ObjCRuntime.catchException {
            self.value(forKey: key)
        }
    }

    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    class func value<Value>(forKey key: String) -> Value? {
        value(forKeySafely: key) as? Value
    }

    /**
     Returns the value for the derived property identified by a given key path.

     - Parameter keyPath: A key path of the form relationship.property (with one or more relationships); for example “department.name” or “department.manager.lastName”.
     - Returns: The value for the derived property identified by keyPath, or `nil` if the key path doesn't exist.
     */
    class func value<Value>(forKeyPath keyPath: String) -> Value? {
        value(forKeyPathSafely: keyPath) as? Value
    }

    /**
     Returns the value for the derived property identified by a given key path.

     - Parameter keyPath: A key path of the form relationship.property (with one or more relationships); for example “department.name” or “department.manager.lastName”.
     - Returns: The value for the derived property identified by keyPath, or `nil` if the key path doesn't exist.
     */
    class func value(forKeyPathSafely keyPath: String) -> Any? {
        try? ObjCRuntime.catchException {
            self.value(forKeyPath: keyPath)
        }
    }

    /**
     Sets the value safely for the specified key, only if the object contains a property with the given key.

     - Parameters:
        - value: The value to set.
        - key: The key of the property to set.
     */
    class func setValue(safely value: Any?, forKey key: String) {
        try? ObjCRuntime.catchException {
            setValue(value, forKey: key)
        }
    }

    /**
     Sets the value for the property identified by a given key path to a given value.

     - Parameters:
        - value: The value to set.
        - keyPath: A key path of the form relationship.property (with one or more relationships): for example “department.name” or “department.manager.lastName.”
     */
    class func setValue(safely value: Any?, forKeyPath keyPath: String) {
        try? ObjCRuntime.catchException {
            setValue(value, forKeyPath: keyPath)
        }
    }

    /// Returns the value of the instance variable with the specified name.
    func ivarValue<T>(named name: String, as type: T.Type = T.self, verifyType:  Bool = false) -> T? {
        guard let ivar = Self.instanceVariable(named: name),
              let info = ObjCIvarInfo(ivar) else { return nil }
        if verifyType {
            guard info.type?.matches(T.self) == true else { return nil }
        }

        if info.isBitfield {
            guard let bitfieldInfo = Self.bitfieldInfo(for: ivar, in: classType) else { return nil }
            let raw = Self.getBitfieldValue(object: self, bitfieldInfo: bitfieldInfo)
            return Self.fromUInt64(raw, width: bitfieldInfo.width, as: T.self)
        }

        guard let ivarSize = info.size, MemoryLayout<T>.stride <= ivarSize else { return nil }
        switch info.typeEncoding.first {
        case "@", "#", ":":
            return object_getIvar(self, ivar) as? T
        default:
            let pointer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
                .advanced(by: info.offset)

            if T.self == UnsafeRawPointer.self {
                return pointer as? T
            }
            if T.self == UnsafeMutableRawPointer.self {
                return UnsafeMutableRawPointer(mutating: pointer) as? T
            }
            if T.self == Bool.self {
                return pointer.load(as: ObjCBool.self).boolValue as? T
            }
            return pointer.load(as: T.self)
        }
    }
     
    /// Sets the value of the instance variable with the specified name.
    func setIvarValue<T>(_ value: T, named name: String, verifyType:  Bool = false) {
        guard let ivar = Self.instanceVariable(named: name),
              let info = ObjCIvarInfo(ivar) else { return }
        if verifyType {
            guard info.type?.matches(T.self) == true else { return }
        }

        if info.isBitfield {
            guard let bitfieldInfo = Self.bitfieldInfo(for: ivar, in: type(of: self)),
                  let rawValue = Self.toUInt64(value) else { return }
            Self.setBitfieldValue(object: self, bitfieldInfo: bitfieldInfo, rawValue: rawValue)
            return
        }

        guard let ivarSize = info.size, MemoryLayout<T>.stride <= ivarSize else { return }
        switch info.typeEncoding.first {
        case "@", "#", ":":
            object_setIvar(self, ivar, value as AnyObject)
        default:
            let pointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
                .advanced(by: info.offset)
            if T.self == Bool.self, let boolValue = value as? Bool {
                pointer.storeBytes(of: ObjCBool(boolValue), as: ObjCBool.self)
            } else if T.self == UnsafeRawPointer.self {
                pointer.storeBytes(of: value as! UnsafeRawPointer, as: UnsafeRawPointer.self)
            } else if T.self == UnsafeMutableRawPointer.self {
                pointer.storeBytes(of: value as! UnsafeMutableRawPointer, as: UnsafeMutableRawPointer.self)
            } else {
                pointer.storeBytes(of: value, as: T.self)
            }
        }
    }
    
    /// The value of the instance variable with the specified name.
    subscript<T>(ivar name: String) -> T? {
        get { ivarValue(named: name) }
        set { setIvarValue(newValue, named: name) }
    }
    
    /// Returns the instance variable with the specified  name of the class.
    static func instanceVariable(named name: String) -> Ivar? {
        class_getInstanceVariable(self, name)
    }
    
    /// Returns the class variable with the specified  name of the class.
    static func classVariable(named name: String) -> Ivar? {
        class_getClassVariable(self, name)
    }
    
    /**
     Returns all protocols the class conforms to.

     - Parameters:
       - includeSuperclasses: A Boolean value indicating whether to include protocols of superclasses in the search
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols inherited by each protocol recursively.

     - Returns: An array of `Protocol` objects representing all protocols the class conforms to, optionally including those of its superclasses and inherited protocols.
     */
    static func protocols(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = true) -> [Protocol] {
        ObjCClass(self).protocols(includeSuperclasses: includeSuperclasses, includeInheritedProtocols: includeInheritedProtocols)
    }
    
    /// Checks if the class overrides the specified instance method.
    static func overrides(_ selector: Selector) -> Bool {
        ObjCClass(self).overrides(selector)
    }
    
    /// Checks if the class overrides the specified class method.
    static func classOverrides(_ selector: Selector) -> Bool {
        ObjCClass(self).classOverrides(selector)
    }
    
    /// A Boolean value indicating whether the object is a subclass of, or identical to the specified class.
    func isSubclass(of aClass: AnyClass) -> Bool {
        Self.isSubclass(of: aClass)
    }
    
    /// A Boolean value indicating whether the object is a superclass of, or identical to the specified class.
    func isSuperclass(of aClass: AnyClass) -> Bool {
        Self.isSuperclass(of: aClass)
    }
    
    /// A Boolean value indicating whether the class is a superclass of, or identical to the specified class.
    static func isSuperclass(of aClass: AnyClass) -> Bool {
        aClass.isSubclass(of: self)
    }
    
    /// Returns all superclasses of the class.
    static func superclasses() -> [AnyClass] {
        Array(first: superclass(), next: { $0?.superclass() }).nonNil
     }

    /// Returns the instance method for the specified selector.
    static func instanceMethod(for selector: Selector) -> Method? {
        class_getInstanceMethod(self, selector)
    }
    
    /// Returns the class method for the specified selector.
    static func classMethod(for selector: Selector) -> Method? {
        class_getClassMethod(self, selector)
    }
    
    /**
     Returns the implementation function for an instance method of this object, cast to the given function type.

     - Parameters:
        - selector: The Objective-C selector identifying the class method.
        - clsoure: The Swift function type that matches the method's IMP signature.
     - Returns: A function pointer of the given type, or `nil` if the selector is not found.
     
     The function type **must** use the C calling convention and include the receiver (`AnyObject`) and selector (`Selector`) as the first two parameters, followed by the method’s actual parameters, and finally its return type.
     
     For example, an Objective-C method declared as:
     ```objc
     - (NSString *)greet:(NSString *)name;
     ```
     should be represented in Swift as:
     ```swift
     typealias Function = @convention(c) (AnyObject, Selector, String) -> String
     ```
     
     - Note: The caller is responsible for ensuring the provided type matches the Objective-C method’s actual signature. Using an incompatible type results in undefined behavior.
     
     Example usage:

     ```swift
     let selector = NSSelectorFromString("_symbolWeightForFontWeight:")
     typealias Function = @convention(c) (AnyObject, Selector, NSFont.Weight) -> NSFont.Weight

     if let method = NSFont.instanceMethod(for: selector, as: Function.self) {
         let result = method(NSFont.self, selector, .black)
         print(result)
     }
     ```
     */
    class func instanceMethod<F>(for selector: Selector, as clsoure: F.Type) -> F? {
        guard let method = class_getInstanceMethod(self, selector) else { return nil }
        let imp = method_getImplementation(method)
        return unsafeBitCast(imp, to: F.self)
    }
    
    
    /**
     Returns the implementation function for a class method of this class, cast to the given function type.

     - Parameters:
        - selector: The Objective-C selector identifying the class method.
        - clsoure: The Swift function type that matches the method's IMP signature.
     - Returns: A function pointer of the given type, or `nil` if the selector is not found.
     
     The function type **must** use the C calling convention and include the receiver (`AnyObject`) and selector (`Selector`) as the first two parameters, followed by the method’s actual parameters, and finally its return type.
     
     For example, an Objective-C method declared as:
     ```objc
     - (NSString *)greet:(NSString *)name;
     ```
     should be represented in Swift as:
     ```swift
     typealias Function = @convention(c) (AnyObject, Selector, String) -> String
     ```
     
     - Note: The caller is responsible for ensuring the provided type matches the Objective-C method’s actual signature. Using an incompatible type results in undefined behavior.
     
     Example usage:

     ```swift
     let selector = NSSelectorFromString("_symbolWeightForFontWeight:")
     typealias Function = @convention(c) (AnyObject, Selector, NSFont.Weight) -> NSFont.Weight

     if let method = NSFont.classMethod(for: selector, as: Function.self) {
         let result = method(NSFont.self, selector, .black)
         print(result)
     }
     ```
     */
    class func classMethod<F>(for selector: Selector, as clsoure: F.Type) -> F? {
        guard let method = class_getClassMethod(self, selector) else { return nil }
        let imp = method_getImplementation(method)
        return unsafeBitCast(imp, to: F.self)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /// The type of the object.
    var classType: Self.Type {
        type(of: self)
    }

    /**
     Returns all subclasses of the class.
     
     - Parameters:
        - includeNested: A Boolean value indicating whether to include nested subclasses.
        - sorted: A Boolean value indicating whether the subclasses should be sorted by name.
     */
    static func subclasses(includeNested: Bool = false, sorted: Bool = false) -> [Self.Type] {
        return ObjCRuntime.subclasses(of: self, includeNested: includeNested, sorted: sorted)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Registers an observer object to receive KVO notifications for the key path relative to the object receiving this message.

     Neither the object receiving this message, nor `observer`, are retained. An object that calls this method must also eventually call  the ``ObjectiveC/NSObjectProtocol/removeObserver(_:for:context:)`` method to unregister the observer when participating in KVO.

     - Parameters:
        - observer: The object to register for KVO notifications. The observer must implement the key-value observing method [observeValue(forKeyPath:of:change:context:)](https://developer.apple.com/documentation/ObjectiveC/NSObject-swift.class/observeValue(forKeyPath:of:change:context:)).
        - keypath: The key path to stop observing.
        - options: The observation options.
        - context: Arbitrary data that is passed to observer in [observeValue(forKeyPath:of:change:context:)](https://developer.apple.com/documentation/ObjectiveC/NSObject-swift.class/observeValue(forKeyPath:of:change:context:)).
     */
    public func addObserver<Value>(_ observer: NSObject, for keypath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer? = nil) {
        guard let keypathString = keypath._kvcKeyPathString else { return }
        addObserver(observer, forKeyPath: keypathString, options: options, context: context)
    }

    /**
     Stops the observer object from receiving change notifications for the property specified by the key path.

     - Parameters:
        - observer: The observer to remove.
        - keypath: The key path to stop observing.
        - context: Arbitrary data that more specifically identifies the observer to be removed.
     */
    public func removeObserver<Value>(_ observer: NSObject, for keypath: KeyPath<Self, Value>, context: UnsafeMutableRawPointer? = nil) {
        guard let keypathString = keypath._kvcKeyPathString else { return }
        removeObserver(observer, forKeyPath: keypathString, context: context)
    }
}

private extension NSObject {
    struct BitfieldInfo {
        let byteOffset: Int
        let bitOffset: Int
        let width: Int
        let storageBytes: Int
    }

    static func bitfieldInfo(for target: Ivar, in cls: AnyClass) -> BitfieldInfo? {
        var count: UInt32 = 0
        guard let ivars = class_copyIvarList(cls, &count) else { return nil }
        defer { free(ivars) }

        let targetOffset = ivar_getOffset(target)
        var bitOffset = 0
        var totalBits = 0
        var targetWidth: Int?

        for i in 0..<Int(count) {
            let iv = ivars[i]
            guard ivar_getOffset(iv) == targetOffset,
                  let encC = ivar_getTypeEncoding(iv) else { continue }

            let enc = String(cString: encC)
            guard enc.first == "b",
                  let width = Int(enc.dropFirst()),
                  width > 0 else { continue }

            if iv == target {
                targetWidth = width
            } else if targetWidth == nil {
                bitOffset += width
            }
            totalBits += width
        }

        guard let width = targetWidth else { return nil }
        let storageBytes = max(1, (totalBits + 7) / 8)
        return BitfieldInfo(
            byteOffset: targetOffset,
            bitOffset: bitOffset,
            width: width,
            storageBytes: storageBytes
        )
    }

    static func getBitfieldValue(object: NSObject, bitfieldInfo: BitfieldInfo) -> UInt64 {
        let base = UnsafeRawPointer(Unmanaged.passUnretained(object).toOpaque())
            .advanced(by: bitfieldInfo.byteOffset)
        let bytes = base.assumingMemoryBound(to: UInt8.self)

        var result: UInt64 = 0
        let count = min(bitfieldInfo.width, 64)

        for i in 0..<count {
            let absoluteBit = bitfieldInfo.bitOffset + i
            let byteIndex = absoluteBit / 8
            guard byteIndex < bitfieldInfo.storageBytes else { break }
            let bitInByte = absoluteBit % 8
            let bit = (bytes[byteIndex] >> bitInByte) & 1
            result |= UInt64(bit) << UInt64(i)
        }
        return result
    }

    static func setBitfieldValue(object: NSObject, bitfieldInfo: BitfieldInfo, rawValue: UInt64) {
        let base = UnsafeMutableRawPointer(Unmanaged.passUnretained(object).toOpaque())
            .advanced(by: bitfieldInfo.byteOffset)
        let bytes = base.assumingMemoryBound(to: UInt8.self)

        let count = min(bitfieldInfo.width, 64)

        for i in 0..<count {
            let absoluteBit = bitfieldInfo.bitOffset + i
            let byteIndex = absoluteBit / 8
            guard byteIndex < bitfieldInfo.storageBytes else { break }
            let bitInByte = absoluteBit % 8
            let mask: UInt8 = 1 << UInt8(bitInByte)
            let bit = UInt8((rawValue >> UInt64(i)) & 1)

            if bit == 1 {
                bytes[byteIndex] |= mask
            } else {
                bytes[byteIndex] &= ~mask
            }
        }
    }

    static func toUInt64<T>(_ value: T) -> UInt64? {
        if let b = value as? Bool { return b ? 1 : 0 }
        if let v = value as? UInt8 { return UInt64(v) }
        if let v = value as? UInt16 { return UInt64(v) }
        if let v = value as? UInt32 { return UInt64(v) }
        if let v = value as? UInt64 { return v }
        if let v = value as? UInt { return UInt64(v) }
        if let v = value as? Int8 { return UInt64(bitPattern: Int64(v)) }
        if let v = value as? Int16 { return UInt64(bitPattern: Int64(v)) }
        if let v = value as? Int32 { return UInt64(bitPattern: Int64(v)) }
        if let v = value as? Int64 { return UInt64(bitPattern: v) }
        if let v = value as? Int { return UInt64(bitPattern: Int64(v)) }
        return nil
    }

    static func fromUInt64<T>(_ raw: UInt64, width: Int, as _: T.Type) -> T? {
        if T.self == Bool.self { return (raw != 0) as? T }

        if T.self == UInt8.self { return UInt8(truncatingIfNeeded: raw) as? T }
        if T.self == UInt16.self { return UInt16(truncatingIfNeeded: raw) as? T }
        if T.self == UInt32.self { return UInt32(truncatingIfNeeded: raw) as? T }
        if T.self == UInt64.self { return raw as? T }
        if T.self == UInt.self { return UInt(truncatingIfNeeded: raw) as? T }

        let signed: Int64 = {
            guard width > 0 && width < 64 else { return Int64(bitPattern: raw) }
            let signBit = UInt64(1) << UInt64(width - 1)
            let fullMask = (UInt64(1) << UInt64(width)) - 1
            let v = raw & fullMask
            if (v & signBit) != 0 {
                return Int64(bitPattern: v | ~fullMask) // sign extend
            } else {
                return Int64(bitPattern: v)
            }
        }()

        if T.self == Int8.self { return Int8(truncatingIfNeeded: signed) as? T }
        if T.self == Int16.self { return Int16(truncatingIfNeeded: signed) as? T }
        if T.self == Int32.self { return Int32(truncatingIfNeeded: signed) as? T }
        if T.self == Int64.self { return signed as? T }
        if T.self == Int.self { return Int(truncatingIfNeeded: signed) as? T }

        return nil
    }
}

