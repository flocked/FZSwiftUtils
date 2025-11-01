//
//  Swizzle.swift
//
//  Adopted from github.com/neutralradiance/swift-core
//  Created by Florian Zand on 05.06.22.
//

import Foundation

/**
 Swizzles selectors of the specified class.
 
 Example usage:
 ```swift
 try? Swizzle(NSView.self) {
     #selector(NSView.viewDidMoveToSuperview) <-> #selector(NSView.swizzled_ViewDidMoveToSuperview)
 }
 ```
 
 - Parameters:
    - class:  The class to swizzle.
    - selectorPairs: The selector pairs to swizzle.
 
 - Throws:Throws if swizzling fails.
 */
public func swizzle(_ class: AnyClass, @SelectorPair.Builder _ selectorPairs: () -> [SelectorPair]) throws {
    guard object_isClass(`class`) else {
        throw SwizzleError.classNotFound(String(describing: `class`))
    }
    try swizzle(selectorPairs(), for: `class`)
}

/**
 Swizzles selectors of the class with the specified name.
 
 Example usage:
 ```swift
 try? Swizzle("NSView") {
     #selector(NSView.viewDidMoveToSuperview) <-> #selector(NSView.swizzled_ViewDidMoveToSuperview)
 }
 ```
 
 - Parameters:
    - className:  The name of the class to swizzle.
    - selectorPairs: The selector pairs to swizzle.
 
 - Throws:Throws if swizzling fails.
 */
public func swizzle(_ className: String, @SelectorPair.Builder _ selectorPairs: () -> [SelectorPair]) throws {
    guard let cls = NSClassFromString(className) else {
        throw SwizzleError.classNotFound(className)
    }
    try swizzle(cls, selectorPairs)
}

extension NSObjectProtocol where Self == NSObject {
    /**
     Swizzles the specified selectors for this class, affecting all instances of this class.
     
     Example usage:
     ```swift
     try? NSView.swizzle {
        #selector(NSView.viewDidMoveToSuperview) <-> #selector(NSView.swizzled_ViewDidMoveToSuperview)
     }
     ```
     
     - Parameter selectorPairs: The selector pairs to swizzle.
     - Throws: Throws an error if swizzling fails.
     */
    public static func swizzle(@SelectorPair.Builder _ selectorPairs: () -> [SelectorPair]) throws {
        try FZSwiftUtils.swizzle(self, selectorPairs)
    }
    
    /**
     Swizzles the specified key path on the type, replacing its implementation with another.
     
     Example usage:
     ```swift
     try? NSView.swizzle(\.stringValue, with: \.swizzledStringValue)
     ```
     
     - Parameters:
        - keyPath: The key path to be replaced.
        - newKeyPath: The new key path whose implementation will be used.
     - Throws: Throws an error if swizzling fails.
     */
    public static func swizzle<Value>(_ keyPath: KeyPath<Self, Value>, with newKeyPath: KeyPath<Self, Value>) throws {
        try swizzle { SelectorPair(keyPath, newKeyPath) }
    }
    
    /**
     Swizzles the setter for the specified writable key path on the type, replacing its implementation with another.
     
     Example usage:
     ```swift
     try? NSView.swizzle(set: \.stringValue, with: \.swizzledStringValue)
     ```
     
     - Parameters:
        - keyPath: The writable key path to be replaced.
        - newKeyPath: The new writable key path whose setter implementation will be used.
     - Throws: Throws an error if swizzling fails.
     */
    public static func swizzle<Value>(set keyPath: WritableKeyPath<Self, Value>, with newKeyPath: WritableKeyPath<Self, Value>) throws {
        try swizzle { SelectorPair(set: keyPath, newKeyPath) }
    }
    
    /**
     Swizzles the specified key path on the type, replacing its implementation with another.
     
     Example usage:
     ```swift
     try? NSView.swizzle(\.stringValue, with: \.swizzledStringValue)
     ```
     
     - Parameters:
        - keyPath: The key path to be replaced.
        - newKeyPath: The new key path whose implementation will be used.
     - Throws: Throws an error if swizzling fails.
     */
    public static func swizzle<Value>(class keyPath: KeyPath<Self.Type, Value>, with newKeyPath: KeyPath<Self.Type, Value>) throws {
        try swizzle { SelectorPair(keyPath, newKeyPath) }
    }
    
    /**
     Swizzles the setter for the specified writable key path on the type, replacing its implementation with another.
     
     Example usage:
     ```swift
     try? NSView.swizzle(set: \.stringValue, with: \.swizzledStringValue)
     ```
     
     - Parameters:
        - keyPath: The writable key path to be replaced.
        - newKeyPath: The new writable key path whose setter implementation will be used.
     - Throws: Throws an error if swizzling fails.
     */
    public static func swizzle<Value>(staticSet keyPath: WritableKeyPath<Self.Type, Value>, with newKeyPath: WritableKeyPath<Self.Type, Value>) throws {
        try swizzle { SelectorPair(set: keyPath, newKeyPath) }
    }
}

fileprivate func swizzle(_ selectorPairs: [SelectorPair], for cls: AnyClass) throws {
    try selectorPairs.forEach { pair in
        guard let cls = pair.isStatic ? object_getClass(cls) : cls else {
            throw SwizzleError.classNotFound(cls.description())
        }
        if let failedKeyPath = pair.failedKeyPath.old ?? pair.failedKeyPath.new {
            throw SwizzleError.keyPathNotFound(keyPath: failedKeyPath, class: cls)
        }
        guard let rhs = class_getInstanceMethod(cls, pair.new) else {
            throw SwizzleError.methodNotFound(selector: pair.new, class: cls)
        }
        guard let lhs = class_getInstanceMethod(cls, pair.old) else {
            swizzleOptional(cls, pair: pair, method: rhs)
            return
        }
        guard !didRevertOptionalSwizzle(cls, pair: pair) else { return }
        if pair.isStatic, class_addMethod(cls, pair.old, method_getImplementation(rhs), method_getTypeEncoding(rhs)) {
            class_replaceMethod(cls, pair.new, method_getImplementation(lhs), method_getTypeEncoding(lhs))
        } else {
            method_exchangeImplementations(lhs, rhs)
        }
    }
}

fileprivate func swizzleOptional(_ cls: AnyClass, pair: SelectorPair, method: Method) {
    class_replaceMethod(cls, pair.old,  method_getImplementation(method), method_getTypeEncoding(method))
    if pair.isStatic {
        (cls as? NSObject.Type)?.swizzledStaticOptionals.insert(pair.old)
    } else {
        (cls as? NSObject.Type)?.swizzledOptionals.insert(pair.old)
    }
}

fileprivate func didRevertOptionalSwizzle(_ cls: AnyClass, pair: SelectorPair) -> Bool {
    guard let _cls = cls as? NSObject.Type else { return false }
    guard (pair.isStatic ? _cls.swizzledStaticOptionals : _cls.swizzledOptionals).contains(pair.new) else { return false }
    guard let deleteIMP = class_getMethodImplementation(cls, NSSelectorFromString(NSStringFromSelector(pair.old)+"_Remove")), let method = class_getInstanceMethod(cls, pair.new) else {
        return false
    }
    do {
        if pair.isStatic {
            if _cls.swizzledStaticRespondsTo == nil {
                _cls.swizzledStaticRespondsTo = try _cls.hook(#selector(NSObject.responds(to:)), closure: {
                    original, object, selector, respondSelector in
                    if let responder = respondSelector, object.swizzledStaticOptionalsReset.contains(responder) {
                        return false
                    }
                    return original(object, selector, respondSelector)
                } as @convention(block) ( (NSObject.Type, Selector, Selector?) -> Bool, NSObject.Type, Selector, Selector?) -> Bool)
            }
            _cls.swizzledStaticOptionalsReset += pair.new
            _cls.swizzledStaticOptionals.remove(pair.new)
        } else {
            if _cls.swizzledRespondsTo == nil {
                _cls.swizzledRespondsTo = try _cls.hook(all: #selector(NSObject.responds(to:)), closure: {
                    original, object, selector, respondSelector in
                    if let responder = respondSelector, type(of: object).swizzledOptionalsReset.contains(responder) {
                        return false
                    }
                    return original(object, selector, respondSelector)
                } as @convention(block) ( (NSObject, Selector, Selector?) -> Bool, NSObject, Selector, Selector?) -> Bool)
            }
            _cls.swizzledOptionalsReset += pair.new
            _cls.swizzledOptionals.remove(pair.new)
        }
        method_setImplementation(method, deleteIMP)
    } catch {
        Swift.print(error)
    }
    return true
}

fileprivate enum SwizzleError: LocalizedError {
    case classNotFound(_ className: String)
    case keyPathNotFound(keyPath: String, class: AnyClass)
    case methodNotFound(selector: Selector, class: AnyClass)
    
    var errorDescription: String? {
        switch self {
        case .classNotFound: return "Class not found."
        case .keyPathNotFound: return "Keypath not found."
        case .methodNotFound: return "Method not found."
        }
    }
    
    var failureReason: String? {
        switch self {
        case .classNotFound(let type):
            return "Could not retrieve class metadata for type '\(type)'."
        case .keyPathNotFound(let keyPath, let type):
            return "Could not retrieve keypath \(keyPath) for type '\(type)'."
        case .methodNotFound(let selector, let cls):
            return "The method '\(selector)' could not be found on class '\(cls)'."
        }
    }
}


/// A pair of selectors for swizzling.
public struct SelectorPair {
    /// The old selector.
    public let old: Selector
    /// The new selector to replace the old.
    public let new: Selector
    /// A `Boolean` value indicating whether the selectors are static.
    public let isStatic: Bool
    
    /// Key paths that failed to convert to selectors, if any.
    var failedKeyPath: (old: String?, new: String?) = (nil, nil)
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
        - isStatic: A `Boolean` value indicating whether the selectors are static.
     */
    public init(_ old: Selector, _ new: Selector, isStatic: Bool = false) {
        self.old = old
        self.new = new
        self.isStatic = isStatic
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(_ old: KeyPath<V, Value>, _ new: KeyPath<V, Value>) {
        self.init(old as PartialKeyPath<V>, new, nil)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject>(_ old: PartialKeyPath<V>, _ new: Selector) {
        self.init(old, nil, new)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject>(_ old: PartialKeyPath<V>, _ new: String) {
        self.init(old, nil, NSSelectorFromString(new))
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(set old: WritableKeyPath<V, Value>, _ new: WritableKeyPath<V, Value>) {
        self.init(old as PartialKeyPath<V>, new, nil, isSetter: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(set old: WritableKeyPath<V, Value>, _ new: Selector) {
        self.init(old as PartialKeyPath<V>, nil, new, isSetter: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(set old: WritableKeyPath<V, Value>, _ new: String) {
        self.init(old as PartialKeyPath<V>, nil, NSSelectorFromString(new), isSetter: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(_ old: KeyPath<V.Type, Value>, _ new: KeyPath<V.Type, Value>) {
        self.init(old as PartialKeyPath<V.Type>, new, nil, isStatic: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject>(_ old: PartialKeyPath<V.Type>, _ new: Selector) {
        self.init(old, nil, new, isStatic: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject>(_ old: PartialKeyPath<V.Type>, _ new: String) {
        self.init(old, nil, NSSelectorFromString(new), isStatic: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(set old: WritableKeyPath<V.Type, Value>, _ new: WritableKeyPath<V.Type, Value>) {
        self.init(old as PartialKeyPath<V.Type>, new, nil, isSetter: true, isStatic: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(set old: WritableKeyPath<V.Type, Value>, _ new: Selector) {
        self.init(old as PartialKeyPath<V.Type>, nil, new, isSetter: true, isStatic: true)
    }
    
    /**
     Creates a selector pair for swizzling.
     
     - Parameters:
        - old: The old selector.
        - new: The new selector to replace the old.
     */
    public init<V: AnyObject, Value>(set old: WritableKeyPath<V.Type, Value>, _ new: String) {
        self.init(old as PartialKeyPath<V.Type>, nil, NSSelectorFromString(new), isSetter: true, isStatic: true)
    }
    
    private init<V: AnyObject>(_ old: PartialKeyPath<V>, _ new: PartialKeyPath<V>?, _ newSel: Selector?, isSetter: Bool = false) {
        var failedKeyPath: (old: String?, new: String?) = (nil, nil)
        self.old = SelectorPair.selector(from: old, isSetter: isSetter, failedKeyPath: &failedKeyPath.old)
        self.new = new.map { SelectorPair.selector(from: $0, isSetter: isSetter, failedKeyPath: &failedKeyPath.new) } ?? newSel!
        self.failedKeyPath = failedKeyPath
        self.isStatic = false
    }
    
    private init<V: AnyObject>(_ old: PartialKeyPath<V.Type>, _ new: PartialKeyPath<V.Type>?, _ newSel: Selector?, isSetter: Bool = false, isStatic: Bool = true) {
        var failedKeyPath: (old: String?, new: String?) = (nil, nil)
        self.old = SelectorPair.selector(from: old, isSetter: isSetter, failedKeyPath: &failedKeyPath.old)
        self.new = new.map { SelectorPair.selector(from: $0, isSetter: isSetter, failedKeyPath: &failedKeyPath.new) } ?? newSel!
        self.failedKeyPath = failedKeyPath
        self.isStatic = isStatic
    }
    
    private static func selector<V>(from keyPath: PartialKeyPath<V>, isSetter: Bool, failedKeyPath: inout String?) -> Selector where V: AnyObject {
        do {
            let name = try isSetter ? keyPath.setterName() : keyPath.getterName()
            return NSSelectorFromString(name)
        } catch {
            failedKeyPath = String(describing: keyPath)
            return NSSelectorFromString(failedKeyPath!)
        }
    }
    
    private static func selector<V>(from keyPath: PartialKeyPath<V.Type>, isSetter: Bool, failedKeyPath: inout String?) -> Selector where V: AnyObject {
        do {
            let name = try isSetter ? keyPath.setterName() : keyPath.getterName()
            return NSSelectorFromString(name)
        } catch {
            failedKeyPath = String(describing: keyPath)
            return NSSelectorFromString(failedKeyPath!)
        }
    }
    
    /// A function builder type that produces an array of ``SelectorPair``.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ swizzlePairs: SelectorPair...) -> [SelectorPair] {
            Array(swizzlePairs)
        }
    }
}

precedencegroup SwizzlePrecedence {
    associativity: left
    higherThan: DefaultPrecedence
}

infix operator <-> : SwizzlePrecedence
infix operator <~> : SwizzlePrecedence

public extension Selector {
    /// Creates a selector pair for swizzleing the left selector with the right replacement selector.
    static func <-> (lhs: Selector, rhs: Selector) -> SelectorPair {
        SelectorPair(lhs, rhs)
    }

    /// Creates a selector pair for swizzleing the left selector with the right replacement selector.
    static func <-> (lhs: Selector, rhs: String) -> SelectorPair {
        SelectorPair(lhs, Selector(rhs))
    }

    /// Creates a selector pair for swizzleing the left static selector with the right replacement selector.
    static func <~> (lhs: Selector, rhs: Selector) -> SelectorPair {
        SelectorPair(lhs, rhs, isStatic: true)
    }

    /// Creates a selector pair for swizzleing the left static selector with the right replacement selector.
    static func <~> (lhs: Selector, rhs: String) -> SelectorPair {
        SelectorPair(lhs, Selector(rhs), isStatic: true)
    }
}

public extension String {
    /// Creates a selector pair for swizzleing the left static selector with the right replacement selector.
    static func <-> (lhs: String, rhs: Selector) -> SelectorPair {
        SelectorPair(NSSelectorFromString(lhs), rhs)
    }
    
    /// Creates a selector pair for swizzleing the left selector with the right replacement selector.
    static func <-> (lhs: String, rhs: String) -> SelectorPair {
        SelectorPair(NSSelectorFromString(lhs), NSSelectorFromString(rhs))
    }

    /// Creates a selector pair for swizzleing the left static selector with the right replacement selector.
    static func <~> (lhs: String, rhs: Selector) -> SelectorPair {
        SelectorPair(NSSelectorFromString(lhs), rhs, isStatic: true)
    }
    
    /// Creates a selector pair for swizzleing the left static selector with the right replacement selector.
    static func <~> (lhs: String, rhs: String) -> SelectorPair {
        SelectorPair(NSSelectorFromString(lhs), NSSelectorFromString(rhs), isStatic: true)
    }
}

fileprivate extension NSObject {
    static var swizzledRespondsTo: Hook? {
        get { getAssociatedValue("swizzledRespondsTo") }
        set { setAssociatedValue(newValue, key: "swizzledRespondsTo") }
    }
    
    static var swizzledStaticRespondsTo: Hook? {
        get { getAssociatedValue("swizzledStaticRespondsTo") }
        set { setAssociatedValue(newValue, key: "swizzledStaticRespondsTo") }
    }
    
    static var swizzledOptionals: Set<Selector> {
        get { getAssociatedValue("swizzledOptionals") ?? [] }
        set { setAssociatedValue(newValue, key: "swizzledOptionals") }
    }
    
    static var swizzledOptionalsReset: Set<Selector> {
        get { getAssociatedValue("swizzledOptionalsReset") ?? [] }
        set { setAssociatedValue(newValue, key: "swizzledOptionalsReset") }
    }
    
    static var swizzledStaticOptionals: Set<Selector> {
        get { getAssociatedValue("swizzledStaticOptionals") ?? [] }
        set { setAssociatedValue(newValue, key: "swizzledStaticOptionals") }
    }
    
    static var swizzledStaticOptionalsReset: Set<Selector> {
        get { getAssociatedValue("swizzledStaticOptionalsReset") ?? [] }
        set { setAssociatedValue(newValue, key: "swizzledStaticOptionalsReset") }
    }
}

