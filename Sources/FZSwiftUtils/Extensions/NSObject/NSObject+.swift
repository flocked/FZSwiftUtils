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
        guard let ivar = Self.instanceVariable(named: name), let ivarInfo = ObjCIvarInfo(ivar), MemoryLayout<T>.stride <= ivarInfo.size else { return nil }
        if verifyType { guard ivarInfo.type?.matches(T.self) == true else { return nil } }
        switch ivarInfo.typeEncoding.first {
        case "@", "#", ":":
            return object_getIvar(self, ivar) as? T
        default:
            let pointer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()).advanced(by: ivarInfo.offset)
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
        guard let ivar = Self.instanceVariable(named: name), let ivarInfo = ObjCIvarInfo(ivar), MemoryLayout<T>.stride <= ivarInfo.size else { return }
        if verifyType { guard ivarInfo.type?.matches(T.self) == true else { return } }
        switch ivarInfo.typeEncoding.first {
        case "@", "#", ":":
            object_setIvar(self, ivar, value as AnyObject)
        default:
            let pointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()).advanced(by: ivarInfo.offset)
            if T.self == Bool.self, let boolValue = value as? Bool {
                pointer.storeBytes(of: ObjCBool(boolValue), as: ObjCBool.self)
            } else if T.self == UnsafeRawPointer.self {
                pointer.storeBytes(of: value as! UnsafeRawPointer, as: UnsafeRawPointer.self)
            }  else if T.self == UnsafeMutableRawPointer.self {
                pointer.storeBytes(of: value as! UnsafeMutableRawPointer, as: UnsafeMutableRawPointer.self)
            }  else {
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
}

public extension NSObjectProtocol where Self: NSObject {
    /// The type of the object.
    var classType: Self.Type {
        type(of: self)
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
        ObjCRuntime.superclasses(of: self)
    }

    /**
     Returns all protocols the class conforms to.

     - Parameters:
       - includeSuperclasses: A Boolean value indicating whether to include protocols of superclasses in the search
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols inherited by each protocol recursively.

     - Returns: An array of `Protocol` objects representing all protocols the class conforms to, optionally including those of its superclasses and inherited protocols.
     */
    static func protocols(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = true) -> [Protocol] {
        ObjCRuntime.protocols(of: self, includeSuperclasses: includeSuperclasses, includeInheritedProtocols: includeInheritedProtocols)
    }
    
    /**
     Checks if the object overrides the specified selector.

     - Parameters:
        - selector: The selector to check for override.
        - isInstance: A Boolean value indicating whether the method is a instance or class method.

     - Returns: `true` if the object overrides the selector, `false` otherwise.
     */
    static func overrides(_ selector: Selector, isInstance: Bool) -> Bool {
        guard let method = isInstance ? class_getInstanceMethod(self, selector) : class_getClassMethod(self, selector) else { return false }
        var currentClass: AnyClass? = class_getSuperclass(self)
        while let superClass = currentClass {
            let superMethod = isInstance ? class_getInstanceMethod(superClass, selector) : class_getClassMethod(superClass, selector)
            if let superMethod = superMethod, superMethod != method {
                return true
            }
            currentClass = class_getSuperclass(superClass)
        }
        return false
    }

    /**
     Returns all subclasses of the class.
     
     - Parameters:
        - includeNested: A Boolean value indicating whether to include nested subclasses.
        - sorted: A Boolean value indicating whether the subclasses should be sorted by name.
     */
    static func subclasses(includeNested: Bool = false, sorted: Bool = false) -> [Self.Type] {
        ObjCRuntime.subclasses(of: self, includeNested: includeNested, sorted: sorted)
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

public extension NSObject {
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

     if let function = NSFont.instanceMethod(for: selector, as: Function.self) {
         let result = function(NSFont.self, selector, .black)
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
     Returns the implementation function for an instance method of this object, cast to the given function type.

     - Parameters:
        - selector: The Objective-C selector identifying the class method.
        - clsoure: The Swift function type that matches the method's IMP signature.
     - Returns: A function pointer of the given type, or `nil` if the selector is not found.
     */
    class func instanceMethod<F>(for selector: String, as clsoure: F.Type) -> F? {
        instanceMethod(for: .string(selector), as: clsoure)
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
        guard let method = class_getClassMethod(self, selector) else { return nil }
        let imp = method_getImplementation(method)
        return unsafeBitCast(imp, to: F.self)
    }
    
    /**
     Returns the implementation function for a class method of this class, cast to the given function type.

     - Parameters:
        - selector: The Objective-C selector identifying the class method.
        - clsoure: The Swift function type that matches the method's IMP signature.
     - Returns: A function pointer of the given type, or `nil` if the selector is not found.
     */
    class func classMethod<F>(for selector: String, as clsoure: F.Type) -> F? {
        classMethod(for: .string(selector), as: clsoure)
    }
}
