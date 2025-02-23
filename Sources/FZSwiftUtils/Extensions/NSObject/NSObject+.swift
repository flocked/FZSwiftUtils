//
//  NSObject+.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

extension NSObject {
    /// The identifier of the object.
    public var objectIdentifier: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// The type of the object.
    public var classType: Self.Type {
        return type(of: self)
    }
}

/// `NSCoding` errors.
enum NSCodingError: LocalizedError {
    /// Casting the object failed.
    case castingFailed(_ fromClass: AnyClass, _ toClass: AnyClass)
    /// Decoding the object failed.
    case decodingFailed
    /// Class isn't a subclass.
    case notASubclass(_ subclass: AnyClass, _ class: AnyClass)
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed:
            return "Couldn't decode the object."
        case .castingFailed(let class1, let class2):
            return "Couldn't cast the object from \(class1) to \(class2)"
        case .notASubclass(let class1, let class2):
            return "\(class1) isn't a subclass of \(class2)"
        }
    }
}

public extension NSCoding where Self: NSObject {
    /**
     Creates an archived-based copy of the object.

     - Throws: An error if copying fails.
     */
    func archiveBasedCopy() throws -> Self {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        guard let copy = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
            throw NSCodingError.decodingFailed
        }
        guard let copy = copy as? Self else {
            throw NSCodingError.castingFailed(type(of: copy as AnyObject), Self.self)
        }
        return copy
    }
    
    /**
     Creates an archived-based copy of the object as the specified subclass.
     
     - Parameter subclass: The type of the subclass for the copy.

     - Throws: An error if copying fails or the specified class isn't a subclass.
     */
    func archiveBasedCopy<Subclass: NSObject & NSCoding>(as subclass: Subclass.Type) throws -> Subclass {
        guard Subclass.self is Self.Type else {
            throw NSCodingError.notASubclass(Subclass.self, Self.self)
        }
        let subclassName = NSStringFromClass(Subclass.self)
        NSKeyedArchiver.setClassName(subclassName, for: Self.self)
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        NSKeyedArchiver.setClassName(nil, for: Self.self)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        unarchiver.setClass(Subclass.self, forClassName: subclassName)
        guard let copy = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
            throw NSCodingError.decodingFailed
        }
        guard let copy = copy as? Subclass else {
            throw NSCodingError.castingFailed(type(of: copy as AnyObject), Subclass.self)
        }
        return copy
    }
    
    /*
    /**
     Creates an archived-based copy of the object as the specified subclass.
     
     - Parameter subclass: The type of the subclass for the copy.

     - Throws: An error if copying fails or the specified class isn't a subclass.
     */
    func archiveBasedCopy<Subclass: NSObject & NSCoding>(as subclass: Subclass.Type) throws -> Subclass {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        guard let object = Subclass(coder: unarchiver) else {
            throw NSCodingError.castingFailed
        }
        return object
    }
     */
    
    /// Returns a new instance that’s a copy of the receiver.
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Registers an observer object to receive KVO notifications for the key path relative to the object receiving this message.

     - Parameters:
        - observer: The object to register for KVO notifications. The observer must implement the key-value observing method `observeValue(forKeyPath:of:change:context:)`.
        - keypath: The key path to stop observing.
        - options: The observation options.
        - context: Arbitrary data that is passed to observer in `observeValue(forKeyPath:of:change:context:)`.
     */
    func addObserver<Value>(_ observer: NSObject, for keypath: KeyPath<Self, Value>,
                            options: NSKeyValueObservingOptions = [],
                            context: UnsafeMutableRawPointer? = nil) {
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
    func removeObserver<Value>(_ observer: NSObject, for keypath: KeyPath<Self, Value>, context: UnsafeMutableRawPointer? = nil) {
        guard let keypathString = keypath._kvcKeyPathString else { return }
        removeObserver(observer, forKeyPath: keypathString, context: context)
    }
}

public extension NSObject {
    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    func value(forKeySafely key: String) -> Any? {
        guard Self.containsProperty(key) else { return nil }
        return value(forKey: key)
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
     Sets the value safely for the specified key, only if the object contains a property with the given key.

     - Parameters:
        - value: The value to set.
        - key: The key of the property to set.
     */
    func setValue(safely value: Any?, forKey key: String) {
        guard Self.containsProperty(key) else { return }
        setValue(value, forKey: key)
    }

    /**
     Checks if the object overrides the specified selector.

     - Parameter selector: The selector to check for override.

     - Returns: `true` if the object overrides the selector, `false` otherwise.
     */
    func overrides(_ selector: Selector) -> Bool {
        var currentClass: AnyClass = type(of: self)
        let method: Method? = class_getInstanceMethod(currentClass, selector)

        while let superClass: AnyClass = class_getSuperclass(currentClass) {
            // Make sure we only check against non-`nil` returned instance methods.
            if class_getInstanceMethod(superClass, selector).map({ $0 != method }) ?? false {
                return true
            }
            currentClass = superClass
        }
        return false
    }

    /**
     Checks if the object is a subclass of the specified class.

     - Parameters:
        - class_: The class to check against.

     - Returns: `true` if the object is a subclass of the specified class, `false` otherwise.
     */
    func isSubclass(of class_: AnyClass) -> Bool {
        var currentClass: AnyClass = type(of: self)
        while let superClass: AnyClass = class_getSuperclass(currentClass) {
            if superClass == class_ {
                return true
            }
            currentClass = superClass
        }
        return false
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// Returns all subclasses for the class.
    public static func allSubclasses() -> [Self.Type] {
        NSObject.allSubclasses(of: self)
    }
}
 
extension NSObject {
    /// Returns all classes.
    public static func allClasses() -> [AnyClass] {
        // Get an approximate amount of classes we are going to need space for.
        // Double it, just to make sure if it returns more we can still accomodate them all
        let expectedClassCount = objc_getClassList(nil, 0) * 2

        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)  // Huh? We should have gotten this for free.
        let actualClassCount = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

        // Take care of the stunningly rare situation where we get more classes back than we have allocated,
        // remembering that we have allocated more than we were told to, to take case of the unexpected case
        // where we recieve more classes than we were told we were going to three lines previously. #paranoid #safe
        let count = min(actualClassCount, expectedClassCount)

        var classes = [AnyClass]()
        for i in 0 ..< count {
            let currentClass: AnyClass = allClasses[Int(i)]
            classes.append(currentClass)
        }

        allClasses.deallocate()

        return classes
    }
    
    /// Returns all subclasses for the specified class.
    public static func allSubclasses<T>(of baseClass: T) -> [T] {
        var matches: [T] = []
        
        for currentClass in allClasses() {
            #if os(macOS)
            let skip = String(describing: currentClass) == "UINSServiceViewController"
            #else
            let skip = false
            #endif
            guard class_getRootSuperclass(currentClass) == NSObject.self && !skip else {
                continue
            }

            if currentClass is T {
                matches.append(currentClass as! T)
            }
        }

        return matches
    }
    
    static func class_getRootSuperclass(_ type: AnyObject.Type) -> AnyObject.Type {
        guard let superclass = class_getSuperclass(type) else { return type }

        return class_getRootSuperclass(superclass)
    }
    
    static func allClasses(implementing p: Protocol) -> [AnyClass] {
        allClasses().filter({ class_conformsToProtocol($0, p) })
    }
}

extension NSObjectProtocol where Self: NSObject {
    static func isProtocolSelector(_ selector: Selector) -> Bool {
        var protocolCount: UInt32 = 0
        if let protocols = class_copyProtocolList(self, &protocolCount) {
            if (0..<Int(protocolCount)).contains(where: { protocols[$0].containsSelector(selector) }) {
                return true
            }
        }
        return (class_getSuperclass(self) as? NSObject.Type)?.isProtocolSelector(selector) ?? false
    }
    
    
    static func typeEncoding(for selector: Selector) -> UnsafePointer<CChar>? {
         var protocolCount: UInt32 = 0
         if let protocols = class_copyProtocolList(self, &protocolCount) {
             for i in 0..<Int(protocolCount) {
                 if let typeEncoding = protocols[i].typeEncoding(for: selector) {
                     return typeEncoding
                 }
             }
         }
        return (class_getSuperclass(self) as? NSObject.Type)?.typeEncoding(for: selector)
     }
}

func typeEncoding(for selector: Selector, _class: AnyClass) -> UnsafePointer<CChar>? {
    var protocolCount: UInt32 = 0
    if let protocols = class_copyProtocolList(_class, &protocolCount) {
        for i in 0..<Int(protocolCount) {
            if let typeEncoding = protocols[i].typeEncoding(for: selector) {
                return typeEncoding
            }
        }
    }
    if let superclass = class_getSuperclass(type(of: _class)) {
        return typeEncoding(for: selector, _class: superclass)
    }
   return nil
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
    
    func typeEncoding(for selector: Selector) -> UnsafePointer<CChar>? {
        var methodDesc = protocol_getMethodDescription(self, selector, true, true)
        if methodDesc.types == nil {
            methodDesc = protocol_getMethodDescription(self, selector, false, true)
        }
        if let types = methodDesc.types {
            return withUnsafePointer(to: &types.pointee) { pointer in
                return pointer
            }
        }
        var protocolCount: UInt32 = 0
        guard let superProtocols = protocol_copyProtocolList(self, &protocolCount) else { return nil }
        for i in 0..<Int(protocolCount) {
            if let typeEncoding = superProtocols[i].typeEncoding(for: selector) {
                return typeEncoding
            }
        }
        return nil
    }
}

extension NSObject {
    /// Returns the value of an Ivar.
    public func getIvarValue<T>(for name: String) -> T? {
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
    
    /// Sets the value of the Ivar with the specified name.
    public func setIvarValue<T>(of name: String, to value: T) -> Bool {
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
}
