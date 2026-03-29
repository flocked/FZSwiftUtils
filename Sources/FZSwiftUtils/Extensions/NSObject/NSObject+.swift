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
        guard let ivar = Self.instanceVariable(named: name), let info = ObjCIvarInfo(ivar) else { return nil }
        guard !verifyType || info.type?.matches(T.self) == true else { return nil }

        if info.isBitfield {
            return bitfieldValue(for: ivar)
        }

        guard let ivarSize = info.size, MemoryLayout<T>.stride <= ivarSize || (T.self is (any _ObjectiveCBridgeable.Type) && MemoryLayout<NSObject>.stride <= ivarSize) else { return nil }
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
        guard let ivar = Self.instanceVariable(named: name), let info = ObjCIvarInfo(ivar) else { return }
        guard !verifyType || info.type?.matches(T.self) == true else { return }

        if info.isBitfield {
            setBitfieldValue(value, for: ivar)
            return
        }
        guard let ivarSize = info.size, MemoryLayout<T>.stride <= ivarSize || (T.self is (any _ObjectiveCBridgeable.Type) && MemoryLayout<NSObject>.stride <= ivarSize) else { return }
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
    
    /// Sets the value of the instance variable with the specified name.
    func setIvarValue<T>(_ value: T?, named name: String, verifyType: Bool = false) {
        if let value = value {
            setIvarValue(value, named: name, verifyType: verifyType)
        } else if let ivar = Self.instanceVariable(named: name), ObjCIvarInfo(ivar)?.isObjectLike == true {
            object_setIvar(self, ivar, nil)
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
    
    /// All active key value (`KVO`) observances on this object.
    var kvoObservances: [KeyValueObservance] {
        guard let observances: [NSObject] = observationInfo?.unretained(as: NSObject.self).value(forKey: "_observances") else { return [] }
        return observances.compactMap({ KeyValueObservance($0) })
    }
    
    /// Represents a single key-value (`KVO`) observation on an object.
    struct KeyValueObservance: CustomStringConvertible {
        /// The object that observers the property.
        public let observer: NSObject
        /// The key path of the property being observed.
        public let keyPath: String
        /// The options of the observation.
        public let options: NSKeyValueObservingOptions
        
        public var description: String {
            "KeyValueObservance(observer: \(type(of: observer)), keyPath: \(keyPath), options: \(options))"
        }

        init?(_ obj: NSObject) {
            guard let obj = obj.value(forKeySafely: "_observer") as? NSObject else { return nil }
            observer = obj
            keyPath = (obj.value(forKeySafely: "property") as? NSObject)?.value(forKeyPath: "keyPath") ?? "unknown"
            options = NSKeyValueObservingOptions(rawValue: obj.ivarValue(named: "_options") ?? 0)
        }
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /// The type of the object.
    var classType: Self.Type {
        type(of: self)
    }

    /**
     Returns all subclasses of the class.
     
     - Parameter includeNested: A Boolean value indicating whether to include nested subclasses.
     */
    static func subclasses(includeNested: Bool = false) -> [Self.Type] {
        return ObjCRuntime.subclasses(of: self, includeNested: includeNested)
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
    func bitfieldValue<T>(for ivar: Ivar, type: T.Type = T.self) -> T? {
        guard T.self is any BinaryInteger.Type || T.self is Bool.Type else { return nil }
        guard let bitfieldInfo = bitfieldInfo(for: ivar) else { return nil }
        let base = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
            .advanced(by: bitfieldInfo.byteOffset)
        let bytes = base.assumingMemoryBound(to: UInt8.self)
        var raw: UInt64 = 0
        let count = min(bitfieldInfo.width, 64)
        for i in 0..<count {
            let absoluteBit = bitfieldInfo.bitOffset + i
            let byteIndex = absoluteBit / 8
            guard byteIndex < bitfieldInfo.storageBytes else { break }
            let bitInByte = absoluteBit % 8
            let bit = (bytes[byteIndex] >> bitInByte) & 1
            raw |= UInt64(bit) << UInt64(i)
        }
        return Self.fromUInt64(raw, width: bitfieldInfo.width)
    }
    
    func setBitfieldValue(_ value: Any, for ivar: Ivar) {
        guard value is BinaryInteger || value is Bool else { return }
        guard let bitfieldInfo = bitfieldInfo(for: ivar), let rawValue = Self.toUInt64(value) else { return }
        let base = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
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
    
    struct BitfieldInfo {
        let byteOffset: Int
        let bitOffset: Int
        let width: Int
        let storageBytes: Int
    }
    
    func bitfieldInfo(for ivar: Ivar) -> BitfieldInfo? {
        let key = UnsafeRawPointer(ivar)
        if let cached = Self.bitfieldCache[key] {
            return cached
        }
        var count: UInt32 = 0
        guard let list = class_copyIvarList(type(of: self), &count) else { return nil }
        defer { free(list) }
        let targetOffset = ivar_getOffset(ivar)
        var bitOffset = 0
        var totalBits = 0
        var targetWidth: Int?
        for iv in list.buffer(count: count) {
            guard ivar_getOffset(iv) == targetOffset, let enc = ivar_getTypeEncoding(iv)?.string else { continue }
            guard enc.first == "b", let width = Int(enc.dropFirst()), width > 0 else { continue }
            if iv == ivar {
                targetWidth = width
            } else if targetWidth == nil {
                bitOffset += width
            }
            totalBits += width
        }
        guard let width = targetWidth else { return nil }
        let storageBytes = max(1, (totalBits + 7) / 8)
        let info = BitfieldInfo(byteOffset: targetOffset, bitOffset: bitOffset, width: width, storageBytes: storageBytes)
        Self.bitfieldCache[key] = info
        return info
    }
    
    static var bitfieldCache: SynchronizedDictionary<UnsafeRawPointer, BitfieldInfo> = [:]
    
    static func toUInt64<T>(_ value: T) -> UInt64? {
        if let int = value as? any BinaryInteger {
            return UInt64(truncatingIfNeeded: int)
        } else if let b = value as? Bool {
            return b ? 1 : 0
        }
        return nil
    }

    static func fromUInt64<T>(_ raw: UInt64, width: Int, as _: T.Type = T.self) -> T? {
        if T.self == Bool.self { return (raw != 0) as? T }
        if T.self == UInt.self   { return UInt(truncatingIfNeeded: raw) as? T }
        if T.self == UInt8.self  { return UInt8(truncatingIfNeeded: raw) as? T }
        if T.self == UInt16.self { return UInt16(truncatingIfNeeded: raw) as? T }
        if T.self == UInt32.self { return UInt32(truncatingIfNeeded: raw) as? T }
        if T.self == UInt64.self { return raw as? T }
        let signed = signExtend(raw, width: width)
        if T.self == Int.self   { return Int(truncatingIfNeeded: signed) as? T }
        if T.self == Int8.self  { return Int8(truncatingIfNeeded: signed) as? T }
        if T.self == Int16.self { return Int16(truncatingIfNeeded: signed) as? T }
        if T.self == Int32.self { return Int32(truncatingIfNeeded: signed) as? T }
        if T.self == Int64.self { return signed as? T }
        return nil
    }

    static func signExtend(_ raw: UInt64, width: Int) -> Int64 {
        guard width > 0, width < 64 else { return Int64(bitPattern: raw) }
        let shift = 64 - width
        return (Int64(bitPattern: raw << shift)) >> shift
    }
}

/*
public extension NSObject {
    func bitfieldValueAlt<T>(for name: String, type: T.Type = T.self) -> T? {
        guard let ivar = Self.instanceVariable(named: name) else { return nil }
        return bitfieldValueAlt(for: ivar)
    }

    func bitfieldValueAlt<T>(for ivar: Ivar, type: T.Type = T.self) -> T? {
        guard let info = bitfieldInfoAlt(for: ivar) else { return nil }
        
        let basePtr = Unmanaged.passUnretained(self).toOpaque().advanced(by: info.byteOffset)
        
        // Load the storage bytes into a 64-bit container safely
        var container: UInt64 = 0
        withUnsafeMutableBytes(of: &container) { buffer in
            buffer.copyMemory(from: UnsafeRawBufferPointer(start: basePtr, count: info.storageBytes))
        }
        let mask: UInt64 = (info.width >= 64) ? .max : (1 << UInt64(info.width)) - 1
        let extracted = (container >> UInt64(info.bitOffset)) & mask
        return Self.fromUInt64(extracted, width: info.width)
    }
    
    func setBitfieldValueAlt(_ value: Any, for name: String) {
        guard let ivar = Self.instanceVariable(named: name) else { return }
        setBitfieldValueAlt(value, for: ivar)
    }

    func setBitfieldValueAlt(_ value: Any, for ivar: Ivar) {
        guard let info = bitfieldInfoAlt(for: ivar), let rawNewValue = Self.toUInt64(value) else { return }
        let basePtr = Unmanaged.passUnretained(self).toOpaque().advanced(by: info.byteOffset)
        // 1. Load existing bytes
        var container: UInt64 = 0
        withUnsafeMutableBytes(of: &container) { buffer in
            buffer.copyMemory(from: UnsafeRawBufferPointer(start: basePtr, count: info.storageBytes))
        }
        // 2. Clear old bits and set new bits
        let mask: UInt64 = (info.width >= 64) ? .max : (1 << UInt64(info.width)) - 1
        let shiftedMask = mask << UInt64(info.bitOffset)
        let shiftedValue = (rawNewValue & mask) << UInt64(info.bitOffset)
        container = (container & ~shiftedMask) | shiftedValue
        // 3. Write back to memory
        withUnsafeBytes(of: &container) { buffer in
            basePtr.copyMemory(from: buffer.baseAddress!, byteCount: info.storageBytes)
        }
    }

    // MARK: - Metadata & Caching

    private func bitfieldInfoAlt(for ivar: Ivar) -> BitfieldInfo? {
        let key = UnsafeRawPointer(ivar)
        if let cached = Self.bitfieldCache[key] {
            return cached
        }
        var count: UInt32 = 0
        guard let list = class_copyIvarList(type(of: self), &count) else { return nil }
        defer { free(list) }

        let targetOffset = ivar_getOffset(ivar)
        var bitOffset = 0
        var totalBits = 0
        var targetWidth: Int?

        for iv in list.buffer(count: count) {
            guard ivar_getOffset(iv) == targetOffset, let enc = ivar_getTypeEncoding(iv)?.string else { continue }
            guard enc.first == "b", let width = Int(enc.dropFirst()) else { continue }
            if iv == ivar {
                targetWidth = width
                bitOffset = totalBits
            }
            totalBits += width
        }
        guard let width = targetWidth else { return nil }
        let storageBytes = (totalBits + 7) / 8
        let info = BitfieldInfo(byteOffset: targetOffset, bitOffset: bitOffset, width: width, storageBytes: storageBytes)
        Self.bitfieldCache[key] = info
        return info
    }
    
}
*/
