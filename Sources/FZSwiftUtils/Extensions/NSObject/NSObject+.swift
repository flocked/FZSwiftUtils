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
        ivar(named: name, verifyType: verifyType)
    }
    
    /// Returns the value of the instance variable with the specified name.
    func ivarValue<T: RawRepresentable>(named name: String, as type: T.Type = T.self, verifyType:  Bool = false) -> T? {
        if let rawValue: T.RawValue = ivar(named: name, verifyType: verifyType) {
            return T(rawValue: rawValue)
        }
        return ivar(named: name, verifyType: verifyType)
    }
    
    private func ivar<T>(named name: String, as type: T.Type = T.self, verifyType:  Bool = false) -> T? {
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
        guard let method = instanceMethod(for: selector) else { return nil }
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
        guard let method = classMethod(for: selector) else { return nil }
        let imp = method_getImplementation(method)
        return unsafeBitCast(imp, to: F.self)
    }
    /*
    /// All active key value (`KVO`) observances on this object.
    var kvoObservances: [KeyValueObservance] {
        kvoObservationInfo?.kvoObservanceObjects.compactMap({ KeyValueObservance($0) }) ?? []
    }
    
    /// Represents a single key-value (`KVO`) observation on an object.
    struct KeyValueObservance: CustomStringConvertible, Hashable {
        /// The object that observers the property.
        public let observer: NSObject
        /// The key path of the property being observed.
        public let keyPath: String
        /// The options of the observation.
        public let options: NSKeyValueObservingOptions
                
        public func hash(into hasher: inout Hasher) {
            hasher.combine(keyPath)
            hasher.combine(options.rawValue)
            hasher.combine(observer.objectID)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.observer === rhs.observer && lhs.keyPath == rhs.keyPath && lhs.options == rhs.options
        }
        
        public var description: String {
            "KeyValueObservance(observer: \(type(of: observer)), keyPath: \(keyPath), options: \(options))"
        }

        init?(_ observance: NSObject) {
            guard let object: NSObject = observance.value(forKey: "_observer"), let keyPath: String = value(forKeyPath: "property.keyPath") else { return nil }
            self.observer = object
            self.keyPath = keyPath
            self.options = .init(rawValue: observance.ivarValue(named: "_options") ?? 0)
        }
    }
    
    var kvoObservers: [KVObserver] {
        kvoObservances.grouped(by: \.observer.objectID).map({ KVObserver($0.value) })
    }
    
    struct KVObserver: Hashable {
        /// The object that observers the property.
        public let observer: NSObject
        /// The properties that the object observes.
        public let observations: [Observation]
        
        init(_ observances: [KeyValueObservance]) {
            self.observer = observances.first!.observer
            self.observations = observances.map({ Observation($0.keyPath, $0.options) }).sorted(by: {
                $0.keyPath != $1.keyPath ? $0.keyPath < $1.keyPath : $0.options.rawValue < $1.options.rawValue
            })
        }
                
        /// The property that an object observes.
        public struct Observation: Hashable {
            /// The key path of the property being observed.
            public let keyPath: String
            /// The options of the observation.
            public let options: NSKeyValueObservingOptions
            
            init(_ keyPath: String, _ options: NSKeyValueObservingOptions) {
                self.keyPath = keyPath
                self.options = options
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(observer.objectID)
            hasher.combine(observations)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.observer === rhs.observer && lhs.observations == rhs.observations
        }
    }
    
    fileprivate var kvoObservationInfo: NSObject? {
        observationInfo?.unretained(as: NSObject.self)
    }
    
    fileprivate var kvoObservanceObjects: [NSObject] {
        value(forKey: "_observances") ?? []
    }
    */
}

public extension NSObject {
    /// All active key-value (`KVO`) observances on this object.
    var kvoObservances: [KeyValueObservance] {
        kvoObservationInfo?.kvoObservanceObjects.compactMap(KeyValueObservance.init) ?? []
    }
    
    /**
     Observes changes to the key-value (`KVO`) observances of the object.

     Keep the returned observation alive for as long as you want to receive changes.

     - Parameter handler: The handler to call when the key-value observances change.
     - Returns: An observation that monitors changes to the key-value observances, or `nil` if observation couldn't be established.
     */
    func observeKVOObservances(handler: @escaping (_ change: KeyValueObservanceObservation.Change) -> Void) -> KeyValueObservanceObservation? {
        KeyValueObservanceObservation(object: self, handler: handler)
    }

    /// Represents a key-value (`KVO`) observance on an object.
    struct KeyValueObservance: CustomStringConvertible, Hashable {
        /// The observer, if it is still alive.
        public let observer: NSObject

        /// The key path of the property being observed.
        public let keyPath: String

        /// The options of the observation.
        public let options: NSKeyValueObservingOptions

        public func hash(into hasher: inout Hasher) {
            hasher.combine(observer.objectID)
            hasher.combine(keyPath)
            hasher.combine(options.rawValue)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.observer === rhs.observer && lhs.keyPath == rhs.keyPath && lhs.options == rhs.options
        }

        public var description: String {
            "KeyValueObservance(observer: \(type(of: observer)), keyPath: \(keyPath), options: \(options))"
        }

        init?(_ observance: NSObject) {
            guard let observer: NSObject = observance.value(forKey: "_observer"), let keyPath: String = observance.value(forKeyPath: "property.keyPath") else { return nil }
            self.observer = observer
            self.keyPath = keyPath
            self.options = .init(rawValue: observance.ivarValue(named: "_options") ?? 0)
        }
    }

    fileprivate var kvoObservationInfo: NSObject? {
        observationInfo?.unretained(as: NSObject.self)
    }

    fileprivate var kvoObservanceObjects: [NSObject] {
        value(forKey: "_observances") ?? []
    }
}

/**
 An object that monitors changes to the key-value (`KVO`) observances of an object.
 
 Keep the observation alive for as long as you want to receive changes.
 */
public final class KeyValueObservanceObservation: NSObject {
    typealias Observance = Change.Observance
    
    private var context = 0
    private weak var object: NSObject?
    private var observances: [Observance] = []
    private let handler: (_ change: Change) -> Void
    private var deinitObservation: DeinitObservation?

    private func processObservationInfo(_ info: NSObject) {
        let observances = info.kvoObservanceObjects.compactMap(Observance.init).uniqued()
        if observances != self.observances {
            let change = Change(old: self.observances, new: observances)
            self.observances = observances
            handler(change)
        }
        deinitObservation = info.observeDeinit { [weak self] in
            guard let info = self?.object?.kvoObservationInfo else { return }
            self?.deinitObservation = nil
            self?.processObservationInfo(info)
        }
    }

    init?(object: NSObject, handler: @escaping (_ change: Change) -> Void) {
        self.object = object
        self.handler = handler
        super.init()
        object.addObserver(self, forKeyPath: "_KeyValueObservanceKey", options: [], context: &context)
        guard let info = object.kvoObservationInfo else {
            object.removeObserver(self, forKeyPath: "_KeyValueObservanceKey", context: &context)
            return nil
        }
        processObservationInfo(info)
    }

    deinit {
        object?.removeObserver(self, forKeyPath: "_KeyValueObservanceKey", context: &context)
    }
}

extension KeyValueObservanceObservation {
    public struct Change: Hashable, CustomStringConvertible {
        /// The previous observances, in the order they were added.
        public let old: [Observance]

        /// The current observances, in the order they were added.
        public let new: [Observance]

        /// The key paths currently being observed, in observation order.
        public var keyPaths: [String] {
            new.map(\.keyPath).uniqued()
        }

        /// The currently active observers that are observing the object, in observation order.
        public var observers: [NSObject] {
            new.uniqued(by: \.observerID).compactMap(\.observer)
        }

        /// The observances that were added.
        public var added: [Observance] {
            new.filter { !old.contains($0) }
        }

        /// The observances that were removed.
        public var removed: [Observance] {
            old.filter { !new.contains($0) }
        }
        
        public var description: String {
            "KeyValueObservanceChange(old: \(old), new: \(new))"
        }

        /// Represents a key-value (`KVO`) observance.
        public struct Observance: CustomStringConvertible, Hashable {
            /// The observer, if it is still alive.
            public weak var observer: NSObject?

            /// The identifier of the observer.
            public let observerID: ObjectIdentifier

            /// The key path of the property being observed.
            public let keyPath: String

            /// The options of the observation.
            public let options: NSKeyValueObservingOptions

            public func hash(into hasher: inout Hasher) {
                hasher.combine(observerID)
                hasher.combine(keyPath)
                hasher.combine(options.rawValue)
            }

            public static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.observerID == rhs.observerID && lhs.keyPath == rhs.keyPath && lhs.options == rhs.options
            }

            public var description: String {
                "Observance(observer: \(observer.map { String(describing: type(of: $0)) } ?? "nil"), keyPath: \(keyPath), options: \(options))"
            }
            
            init(_ observer: NSObject, _ keyPath: String, _ options: NSKeyValueObservingOptions) {
                self.observer = observer
                self.observerID = observer.objectID
                self.keyPath = keyPath
                self.options = options
            }

            init?(_ observance: NSObject) {
                guard let observer: NSObject = observance.value(forKey: "_observer"), let keyPath: String = observance.value(forKeyPath: "property.keyPath"), keyPath != "_KeyValueObservanceKey" else { return nil }
                self.observer = observer
                self.observerID = observer.objectID
                self.keyPath = keyPath
                self.options = .init(rawValue: observance.ivarValue(named: "_options") ?? 0)
            }
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
        guard value is any BinaryInteger || value is Bool else { return }
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


extension NSKeyValueObservingOptions: Swift.Equatable, Swift.Hashable { }

/*
 fileprivate extension Array where Element == KeyValueObservanceObservation.Observance {
     var observers: [NSObject] {
         uniqued(by: \.observerID).compactMap(\.observer)
     }
     
     var keyPaths: [String] {
         map(\.keyPath).uniqued()
     }
 }

 fileprivate struct WeakObject: Hashable {
     weak var object: NSObject?
     let objectID: ObjectIdentifier
     
     func hash(into hasher: inout Hasher) {
         hasher.combine(objectID)
     }
     
     static func == (lhs: Self, rhs: Self) -> Bool {
         lhs.objectID == rhs.objectID
     }
     
     init(_ object: NSObject) {
         self.object = object
         self.objectID = object.objectID
     }
 }

 fileprivate extension NSObject {
     var weak: WeakObject { WeakObject(self) }
 }
 
 private func processObservationInfoAlt(_ info: NSObject) {
     let kvoObjects = info.kvoObservanceObjects
     var observances: [Observance] = .init(reserveCapacity: kvoObjects.count)
     var observerIDs: OrderedSet<WeakObject> = []
     var keyPaths: OrderedSet<String> = []
     for observance in kvoObjects {
         guard let observer: NSObject = observance.value(forKey: "_observer"), let keyPath: String = observance.value(forKeyPath: "property.keyPath") else { continue }
         observerIDs.insert(observer.weak)
         keyPaths.insert(keyPath)
         observances.append(Observance(observer, keyPath, .init(rawValue: observance.ivarValue(named: "_options") ?? 0)))
     }
 }
 */
