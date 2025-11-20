//
//  NSObject+.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation
import _ExceptionCatcher

public extension NSObject {
    /// The identifier of the object.
    var objectID: ObjectIdentifier {
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
        try? NSObject.catchException {
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
        try? NSObject.catchException {
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
        try? NSObject.catchException {
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
        try? NSObject.catchException {
            setValue(value, forKeyPath: keyPath)
        }
    }

    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    class func value(forKeySafely key: String) -> Any? {
        try? NSObject.catchException {
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
        try? NSObject.catchException {
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
        try? NSObject.catchException {
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
        try? NSObject.catchException {
            setValue(value, forKeyPath: keyPath)
        }
    }

    /**
     Checks if the object overrides the specified selector.

     - Parameter selector: The selector to check for override.

     - Returns: `true` if the object overrides the selector, `false` otherwise.
     */
    func overrides(_ selector: Selector) -> Bool {
        var currentClass: AnyClass = type(of: self)
        let method: Method? = class_getInstanceMethod(currentClass, selector)

        while let superClass: AnyClass = class_getSuperclass(currentClass), superClass != currentClass {
            // Make sure we only check against non-`nil` returned instance methods.
            if class_getInstanceMethod(superClass, selector).map({ $0 != method }) ?? false {
                return true
            }
            currentClass = superClass
        }
        return false
    }

    /// Returns the value of the ivar with the specified name.
    func getIvarValue<T>(for name: String) -> T? {
        guard let ivar = class_getInstanceVariable(type(of: self), name) else { return nil }
        let isPrimitive = (T.self is any Numeric.Type || T.self is Bool.Type || T.self is Character.Type)
        if !isPrimitive && (T.self is AnyObject.Type || T.self is any _ObjectiveCBridgeable.Type || T.self is any ReferenceConvertible.Type) {
            return object_getIvar(self, ivar) as? T
        }
        let offset = ivar_getOffset(ivar)
        let objectPointer = Unmanaged.passUnretained(self).toOpaque()
        let pointer = objectPointer.advanced(by: offset)
        if T.self is UnsafeRawPointer.Type || T.self is UnsafeMutableRawPointer.Type {
            return T.self is UnsafeRawPointer.Type ? UnsafeRawPointer(pointer) as? T : UnsafeMutableRawPointer(pointer) as? T
        }
        return pointer.assumingMemoryBound(to: T.self).pointee
    }

    /**
     Sets the value of the ivar with the specified name.

     - Parameters:
        - name: The name of the ivar.
        - value: The new value for the ivar.
     - Returns: `true` if updating the ivar value has been sucessfully, else `false`.
     */
    @discardableResult
    func setIvarValue<T>(_ value: T, of name: String) -> Bool {
        guard let ivar = class_getInstanceVariable(type(of: self), name) else { return false }
        if T.self is UnsafeRawPointer.Type || T.self is UnsafeMutableRawPointer.Type {
            let offset = ivar_getOffset(ivar)
            let objectPointer = Unmanaged.passUnretained(self).toOpaque()
            let pointer = objectPointer.advanced(by: offset)
            if let mutablePointer = value as? UnsafeMutableRawPointer {
                mutablePointer.copyMemory(from: pointer, byteCount: MemoryLayout<T>.size)
            }
            return true
        } else if T.self is any Numeric.Type || T.self is Bool.Type || T.self is Character.Type {
            let offset = ivar_getOffset(ivar)
            let objectPointer = Unmanaged.passUnretained(self).toOpaque()
            let pointer = objectPointer.advanced(by: offset).assumingMemoryBound(to: T.self)
            pointer.pointee = value
            return true
        } else if T.self is AnyObject.Type || T.self is any _ObjectiveCBridgeable.Type || T.self is any ReferenceConvertible.Type {
            object_setIvar(self, ivar, value as AnyObject)
            return true
        }
        return false
    }

    /// A Boolean value indicatingwhether the object is a subclass of, or identical to the specified class.
    func isSubclass(of aClass: AnyClass) -> Bool {
        Self.isSubclass(of: aClass)
    }

    /// Returns an array of all superclasses of the class, in order from immediate superclass up to `NSObject`.
    class var superclasses: [AnyClass] {
        Array(first: superclass(), next: { $0?.superclass() }).nonNil
    }

    /**
     Returns all protocols the class conforms to.

     - Parameters:
       - includeSuperclasses: A Boolean value indicating whether to include protocols of superclasses in the search
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols inherited by each protocol recursively.

     - Returns: An array of `Protocol` objects representing all protocols the class conforms to, optionally including those of its superclasses and inherited protocols.
     */
    class func protocols(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = true) -> [Protocol] {
        var visited = Set<String>()
        var result: [Protocol] = []
        for cls in includeSuperclasses ? [self] + superclasses : [self] {
            var count: UInt32 = 0
            if let protocolList = class_copyProtocolList(cls, &count) {
                for i in 0..<Int(count) {
                    let proto = protocolList[i]
                    guard visited.insert(NSStringFromProtocol(proto)).inserted else { continue }
                    result += proto
                    if includeInheritedProtocols {
                        appendInheritedProtocols(of: proto, into: &result, visited: &visited)
                    }
                }
            }
        }

        return result
    }

    private class func appendInheritedProtocols(of proto: Protocol, into result: inout [Protocol], visited: inout Set<String>) {
        var count: UInt32 = 0
        guard let inherited = protocol_copyProtocolList(proto, &count) else { return }
        for i in 0..<Int(count) {
            let proto = inherited[i]
            guard visited.insert(NSStringFromProtocol(proto)).inserted else { continue }
            result += proto
            appendInheritedProtocols(of: proto, into: &result, visited: &visited)
        }
    }

    /**
      Executes the specified block that may throw an Objective-C `NSException` and catches it.

      This method enables safer bridging of Objective-C code into Swift, where exceptions cannot be caught using `do-try-catch`.

      - Parameter tryBlock: A closure containing Objective-C code that may throw an exception.
     - Returns: The value returned from the given callback.

      Example usage:

     ```swift
     let object: NSObject // …

     do {
         let value = try NSObject.catch {
             object.value(forKey: "someProperty")
         }
         print("Value:", value)
     } catch {
         print("Error:", error.localizedDescription)
         //=> Error: The operation couldn’t be completed. [valueForUndefinedKey:]: this class is not key value coding-compliant for the key nope.
     }
     ```
     */
    @discardableResult
    static func catchException<T>(tryBlock: () throws -> T) throws -> T {
        var result: Result<T, Error>!
        try _catchException {
            do {
                result = .success(try tryBlock())
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }

    /// Returns all classes.
    static func allClasses() -> [AnyClass] {
        if let allClasses = _allClasses {
            return allClasses
        }
        let expectedClassCount = objc_getClassList(nil, 0) * 2
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        let classes = (0 ..< min(actualClassCount, expectedClassCount)).map({ allClasses[Int($0)] })
        allClasses.deallocate()
        _allClasses = classes
        return classes
    }

    /// Returns all protocols.
    static func allProtocols() -> [Protocol] {
        if let allProtocols = _allProtocols {
            return allProtocols
        }
        var count: UInt32 = 0
        guard let protocolList = objc_copyProtocolList(&count) else { return [] }
        let allProtocols = (0..<Int(count)).compactMap { protocolList[$0]  }
        _allProtocols = allProtocols
        return allProtocols
    }

    private static var _allClasses: [AnyClass]? {
        get { getAssociatedValue("allClasses") }
        set { setAssociatedValue(newValue, key: "allClasses") }
    }

    private static var _allProtocols: [Protocol]? {
        get { getAssociatedValue("allProtocols") }
        set { setAssociatedValue(newValue, key: "allProtocols") }
    }

    /// Returns all subclasses for the specified class.
    static func allSubclasses<T>(of baseClass: T) -> [T] {
        allClasses().filter({ cls in
            #if os(macOS)
            if NSStringFromClass(cls) != "UINSServiceViewController" { return false }
            #endif
            return class_getRootSuperclass(cls) == NSObject.self && cls is T
        }).map({ $0 as! T })
    }

    /// Returns all clases implementing the specified protocol.
    static func allClasses(implementing _protocol: Protocol) -> [AnyClass] {
        allClasses().filter({ class_conformsToProtocol($0, _protocol) })
    }
}

extension Protocol {
    /// Returns all classes impelementing the protocol.
    public func allClasses() -> [AnyClass] {
        NSObject.allClasses(implementing: self)
    }

    /// The name of the protocol.
    public var name: String {
        NSStringFromProtocol(self)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// The type of the object.
    public var classType: Self.Type {
        type(of: self)
    }

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

    /// Returns all subclasses of the class.
    public static func allSubclasses() -> [Self.Type] {
        allSubclasses(of: self)
    }
}

fileprivate extension NSObjectProtocol where Self: NSObject {
    static func isProtocolSelector(_ selector: Selector) -> Bool {
        var protocolCount: UInt32 = 0
        if let protocols = class_copyProtocolList(self, &protocolCount) {
            if (0..<Int(protocolCount)).contains(where: { protocols[$0].containsSelector(selector) }) {
                return true
            }
        }
        let superclass = class_getSuperclass(self) as? NSObject.Type
        guard let superclass = superclass, superclass != type(of: self) else { return false }
        return superclass.isProtocolSelector(selector)
    }
}

extension Protocol {
    func containsSelector(_ selector: Selector) -> Bool {
        if protocol_getMethodDescription(self, selector, true, true).name != nil || protocol_getMethodDescription(self, selector, false, true).name != nil {
            return true
        }
        var protocolCount: UInt32 = 0
        guard let superProtocols = protocol_copyProtocolList(self, &protocolCount) else { return false }
        if (0..<Int(protocolCount)).contains(where: { superProtocols[$0].containsSelector(selector) }) {
            return true
        }
        return false
    }

    func typeEncoding(for selector: Selector, optionalOnly: Bool = false) -> UnsafePointer<CChar>? {
        var methodDesc: objc_method_description!
        if optionalOnly {
            methodDesc = protocol_getMethodDescription(self, selector, false, true)
        } else {
            methodDesc = protocol_getMethodDescription(self, selector, true, true)
            if methodDesc.types == nil {
                methodDesc = protocol_getMethodDescription(self, selector, false, true)
            }
        }
        if let types = methodDesc.types {
            return withUnsafePointer(to: &types.pointee) { pointer in
                return pointer
            }
        }
        var protocolCount: UInt32 = 0
        guard let superProtocols = protocol_copyProtocolList(self, &protocolCount) else { return nil }
        for i in 0..<Int(protocolCount) {
            if let typeEncoding = superProtocols[i].typeEncoding(for: selector, optionalOnly: optionalOnly) {
                return typeEncoding
            }
        }
        return nil
    }

    static func typeEncoding(for selector: Selector, protocol proto: Protocol) -> UnsafePointer<CChar>? {
        // Check required methods
        var methodDesc = protocol_getMethodDescription(proto, selector, true, true)
        if methodDesc.name != nil, let types = methodDesc.types {
            return UnsafePointer(types)
        }

        // Check optional methods
        methodDesc = protocol_getMethodDescription(proto, selector, false, true)
        if methodDesc.name != nil, let types = methodDesc.types {
            return UnsafePointer(types)
        }

        // Recursively check inherited protocols
        var inheritedCount: UInt32 = 0
        if let inherited = protocol_copyProtocolList(proto, &inheritedCount) {
            for i in 0..<Int(inheritedCount) {
                if let typeEncoding = typeEncoding(for: selector, protocol: inherited[i]) {
                    return typeEncoding
                }
            }
        }

        return nil
    }
}

/**
 Returns the root superclass of a class.

 - Parameter cls: A class object.
 - Returns: The root superclass of the class.
 */
public func class_getRootSuperclass(_ cls: AnyClass) -> AnyClass {
    guard let superclass = class_getSuperclass(cls), superclass != cls else { return cls }
    return class_getRootSuperclass(superclass)
}

public extension NSObject {
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

     if let function = NSFont.classMethod(for: selector, as: Function.self) {
         let result = function(NSFont.self, selector, .black)
         print(result)
     }
     ```
     */
    func instanceMethod<F>(for selector: Selector, as clsoure: F.Type) -> F? {
        guard let method = class_getInstanceMethod(object_getClass(self), selector) else { return nil }
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

     if let function = NSFont.classMethod(for: selector, as: Function.self) {
         let result = function(NSFont.self, selector, .black)
         print(result)
     }
     ```
     */
    class func classMethod<F>(for selector: Selector, as clsoure: F.Type) -> F? {
        guard let method = class_getClassMethod(object_getClass(self), selector) else { return nil }
        let imp = method_getImplementation(method)
        return unsafeBitCast(imp, to: F.self)
    }
}
