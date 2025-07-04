//
//  Swizzle.swift
//
//  Adopted from github.com/neutralradiance/swift-core
//  Created by Florian Zand on 05.06.22.
//

import Foundation

precedencegroup SwizzlePrecedence {
    associativity: left
    higherThan: DefaultPrecedence
}

infix operator <-> : SwizzlePrecedence
infix operator <~> : SwizzlePrecedence

/**
 Swizzling of class selectors.

 Example:
 ```swift
 try? Swizzle(NSView.self) {
     #selector(NSView.viewDidMoveToSuperview) <-> #selector(NSView.swizzled_ViewDidMoveToSuperview)
 }
 ```
 */
public struct Swizzle {
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
    public init(_ class: AnyClass, @Builder _ selectorPairs: () -> [SelectorPair]) throws {
        guard object_isClass(`class`) else {
            throw Error.classNotFound(String(describing: `class`))
        }
        try swizzle(`class`, pairs: selectorPairs())
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
    public init(_ className: String, @Builder _ selectorPairs: () -> [SelectorPair]) throws {
        guard let cls = NSClassFromString(className) else {
            throw Error.classNotFound(className)
        }
        try swizzle(cls, pairs: selectorPairs())
    }
    
    private func swizzle(_ type: AnyObject.Type, pairs: [SelectorPair]) throws {
        try pairs.forEach { pair in
            guard let cls = pair.isStatic ? object_getClass(type) : type else {
                throw Error.classNotFound(type.description())
            }
            if let old = pair.failedKeyPath.old {
                throw Error.keyPathNotFound(keyPath: old, className: NSStringFromClass(cls))
            } else if let new = pair.failedKeyPath.new {
                throw Error.keyPathNotFound(keyPath: new, className: NSStringFromClass(cls))
            }
            guard let rhs = class_getInstanceMethod(cls, pair.new) else {
                throw Error.methodNotFound(selector: pair.new, class: cls)
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
    
    private func swizzleOptional(_ cls: AnyClass, pair: SelectorPair, method: Method) {
        class_replaceMethod(cls, pair.old,  method_getImplementation(method), method_getTypeEncoding(method))
        if pair.isStatic {
            (cls as? NSObject.Type)?.swizzledStaticOptionals.insert(pair.old)
        } else {
            (cls as? NSObject.Type)?.swizzledOptionals.insert(pair.old)
        }
    }
    
    private func didRevertOptionalSwizzle(_ cls: AnyClass, pair: SelectorPair) -> Bool {
        guard var _cls = cls as? NSObject.Type else { return false }
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
    
    private enum Error: LocalizedError {
        case classNotFound(_ className: String)
        case keyPathNotFound(keyPath: String, className: String)
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
}

extension Swizzle {
    /// A pair of selectors for swizzling.
    public struct SelectorPair: CustomStringConvertible {
        /// The old selector.
        public let old: Selector
        /// The new selector to replace the old.
        public let new: Selector
        /// A `Boolean` value indicating whether the selectors are static.
        public let isStatic: Bool
        
        var failedKeyPath: (old: String?, new: String?) = (nil, nil)
        
        /**
         Creates a selector pair.
         
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
         Creates a selector pair.
         
         - Parameters:
            - old: The old keypath.
            - new: The new keypath
            - isStatic: A `Boolean` value indicating whether the selectors are static.
         */
        public init<V: AnyObject>(_ old: PartialKeyPath<V>, _ new: PartialKeyPath<V>, isStatic: Bool = false) {
            if let old = try? old.getterName() {
                self.old = NSSelectorFromString(old)
            } else {
                failedKeyPath.old = String(describing: old)
                self.old = NSSelectorFromString(failedKeyPath.old!)
            }
            if let new = try? new.getterName() {
                self.new = NSSelectorFromString(new)
            } else {
                failedKeyPath.new = String(describing: new)
                self.new = NSSelectorFromString(failedKeyPath.new!)
            }
            self.isStatic = isStatic
        }
        
        /**
         Creates a selector pair.
         
         - Parameters:
            - old: The old keypath.
            - new: The new selector
            - isStatic: A `Boolean` value indicating whether the selectors are static.
         */
        public init<V: AnyObject>(_ old: PartialKeyPath<V>, _ new: Selector, isStatic: Bool = false) {
            if let old = try? old.getterName() {
                self.old = NSSelectorFromString(old)
            } else {
                failedKeyPath.old = String(describing: old)
                self.old = NSSelectorFromString(failedKeyPath.old!)
            }
            self.new = new
            self.isStatic = isStatic
        }
        
        /**
         Creates a selector pair.
         
         - Parameters:
            - old: The old keypath.
            - new: The new name of the selector
            - isStatic: A `Boolean` value indicating whether the selectors are static.
         */
        public init<V: AnyObject>(_ old: PartialKeyPath<V>, _ new: String, isStatic: Bool = false) {
            if let old = try? old.getterName() {
                self.old = NSSelectorFromString(old)
            } else {
                failedKeyPath.old = String(describing: old)
                self.old = NSSelectorFromString(failedKeyPath.old!)
            }
            self.new = NSSelectorFromString(new)
            self.isStatic = isStatic
        }
        
        /**
         Creates a selector pair.
         
         - Parameters:
            - old: The old keypath.
            - new: The new keypath
            - isStatic: A `Boolean` value indicating whether the selectors are static.
         */
        public init<V: AnyObject>(set old: PartialKeyPath<V>, _ new: PartialKeyPath<V>, isStatic: Bool = false) {
            if let old = try? old.setterName() {
                self.old = NSSelectorFromString(old)
            } else {
                failedKeyPath.old = String(describing: old)
                self.old = NSSelectorFromString(failedKeyPath.old!)
            }
            if let new = try? new.setterName() {
                self.new = NSSelectorFromString(new)
            } else {
                failedKeyPath.new = String(describing: new)
                self.new = NSSelectorFromString(failedKeyPath.new!)
            }
            self.isStatic = isStatic
        }
        
        /**
         Creates a selector pair.
         
         - Parameters:
            - old: The old keypath.
            - new: The new selector
            - isStatic: A `Boolean` value indicating whether the selectors are static.
         */
        public init<V: AnyObject>(set old: PartialKeyPath<V>, _ new: Selector, isStatic: Bool = false) {
            if let old = try? old.setterName() {
                self.old = NSSelectorFromString(old)
            } else {
                failedKeyPath.old = String(describing: old)
                self.old = NSSelectorFromString(failedKeyPath.old!)
            }
            self.new = new
            self.isStatic = isStatic
        }
        
        /**
         Creates a selector pair.
         
         - Parameters:
            - old: The old keypath.
            - new: The new name of the selector.
            - isStatic: A `Boolean` value indicating whether the selectors are static.
         */
        public init<V: AnyObject>(set old: PartialKeyPath<V>, _ new: String, isStatic: Bool = false) {
            if let old = try? old.setterName() {
                self.old = NSSelectorFromString(old)
            } else {
                failedKeyPath.old = String(describing: old)
                self.old = NSSelectorFromString(failedKeyPath.old!)
            }
            self.new = NSSelectorFromString(new)
            self.isStatic = isStatic
        }
        
        public var description: String {
            "\(old) \(isStatic ? "<~>" : "<->") \(new)"
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

public extension Selector {
    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: Selector, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(lhs, rhs)
    }

    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: Selector, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(lhs, Selector(rhs))
    }

    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: Selector, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(lhs, rhs, isStatic: true)
    }

    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: Selector, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(lhs, Selector(rhs), isStatic: true)
    }
}

public extension String {
    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: String, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(NSSelectorFromString(lhs), rhs)
    }
    
    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: String, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(NSSelectorFromString(lhs), NSSelectorFromString(rhs))
    }

    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: String, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(NSSelectorFromString(lhs), rhs, isStatic: true)
    }
    
    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: String, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(NSSelectorFromString(lhs), NSSelectorFromString(rhs), isStatic: true)
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
        get { getAssociatedValue("swizzledOptionals", initialValue: []) }
        set { setAssociatedValue(newValue, key: "swizzledOptionals") }
    }
    
    static var swizzledOptionalsReset: Set<Selector> {
        get { getAssociatedValue("swizzledOptionalsReset", initialValue: []) }
        set { setAssociatedValue(newValue, key: "swizzledOptionalsReset") }
    }
    
    static var swizzledStaticOptionals: Set<Selector> {
        get { getAssociatedValue("swizzledStaticOptionals", initialValue: []) }
        set { setAssociatedValue(newValue, key: "swizzledStaticOptionals") }
    }
    
    static var swizzledStaticOptionalsReset: Set<Selector> {
        get { getAssociatedValue("swizzledStaticOptionalsReset", initialValue: []) }
        set { setAssociatedValue(newValue, key: "swizzledStaticOptionalsReset") }
    }
}

/*
fileprivate extension String {
    var removingTypePrefix: String {
        guard let backslashIndex = firstIndex(of: "\\") else { return self }
        let start = index(after: backslashIndex)
        guard let dotIndex = self[start...].firstIndex(of: ".") else { return self }
        return String(self[self.index(after: dotIndex)...])
    }
}
*/
