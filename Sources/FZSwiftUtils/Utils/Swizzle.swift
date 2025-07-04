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

public extension Selector {
    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: Selector, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: lhs, new: rhs)
    }

    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: Selector, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: lhs, new: Selector(rhs))
    }

    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: Selector, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: lhs, new: rhs, static: true)
    }

    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: Selector, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: lhs, new: Selector(rhs), static: true)
    }
}

public extension String {
    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: String, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: Selector(lhs), new: rhs)
    }
    
    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: String, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: NSSelectorFromString(lhs), new: NSSelectorFromString(rhs))
    }

    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: String, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: NSSelectorFromString(lhs), new: rhs, static: true)
    }
    
    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: String, rhs: String) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: NSSelectorFromString(lhs), new: NSSelectorFromString(rhs), static: true)
    }
}

/**
 Swizzling of class selectors.

 Example:
 ```swift
 try? Swizzle(NSView.self) {
     #selector(viewDidMoveToSuperview) <-> #selector(swizzledViewDidMoveToSuperview)
 }
 ```
 */
public struct Swizzle {
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ swizzlePairs: SelectorPair...) -> [SelectorPair] {
            Array(swizzlePairs)
        }
    }

    /**
     Swizzles selectors of the specified class.

     - Parameters:
        - type:  The class to swizzle.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    public init(_ type: AnyClass, @Builder _ makeSelectorPairs: () -> [SelectorPair]) throws {
        try self.init(type, swizzlePairs: makeSelectorPairs())
    }

    /**
     Swizzles selectors of the class with the specified name.

     - Parameters:
        - className:  The name of the class.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    public init(_ className: String, @Builder _ makeSelectorPairs: () -> [SelectorPair]) throws {
        try self.init(className, swizzlePairs: makeSelectorPairs())
    }

    @discardableResult
    init(_ class_: AnyClass, swizzlePairs: [SelectorPair]) throws {
        guard object_isClass(class_) else {
            throw Error.classNotFound(String(describing: class_))
        }
        try swizzle(type: class_, pairs: swizzlePairs)
    }

    @discardableResult
    init(_ className: String, swizzlePairs: [SelectorPair], reset _: Bool = false) throws {
        guard let class_ = NSClassFromString(className) else {
            throw Error.classNotFound(className)
        }
        try swizzle(type: class_, pairs: swizzlePairs)
    }

    private func swizzle(type: AnyObject.Type, pairs: [SelectorPair]) throws {
        try pairs.forEach { pair in
            guard let cls = pair.static ? object_getClass(type) : type else {
                throw Error.classNotFound(type.description())
            }
            guard let rhs = class_getInstanceMethod(cls, pair.new) else {                
                guard !didResetOptional(cls, pair: pair) else { return }
                throw Error.methodNotFound(selector: pair.new, class: cls)
            }
            guard let lhs = class_getInstanceMethod(cls, pair.old) else {
                class_replaceMethod(cls, pair.old,  method_getImplementation(rhs), method_getTypeEncoding(rhs))
                var selectors = getAssociatedValue("swizzledOptionals", object: cls, initialValue: [Selector:Selector]())
                selectors[pair.new] = pair.old
                setAssociatedValue(selectors, key: "swizzledOptionals", object: cls)
                return
            }

            if pair.static, class_addMethod(cls, pair.old, method_getImplementation(rhs), method_getTypeEncoding(rhs)) {
                class_replaceMethod(cls, pair.new, method_getImplementation(lhs), method_getTypeEncoding(lhs))
            } else {
                method_exchangeImplementations(lhs, rhs)
            }
        }
    }
    
    private func didResetOptional(_ cls: AnyClass, pair: SelectorPair) -> Bool {
        var selectors = getAssociatedValue("swizzledOptionals", object: cls, initialValue: [Selector:Selector]())
        guard selectors[pair.old] == pair.new, let deleteIMP = class_getMethodImplementation(cls, NSSelectorFromString(NSStringFromSelector(pair.old)+"_Remove")), let method = class_getInstanceMethod(cls, pair.new) else { return false }
        method_setImplementation(method, deleteIMP)
        selectors[pair.old] = nil
        setAssociatedValue(selectors, key: "swizzledOptionals", object: cls)
        return true
    }
}

extension Swizzle {
    enum Error: LocalizedError {
        case classNotFound(_ className: String)
        case methodNotFound(selector: Selector, class: AnyClass)
        
        var errorDescription: String? {
            switch self {
            case .classNotFound:
                return "Class Not Found"
            case .methodNotFound:
                return "Method Not Found"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .classNotFound(let type):
                return "Could not retrieve class metadata for type '\(type)'."
            case .methodNotFound(let selector, let cls):
                return "The method '\(selector)' could not be found on class '\(cls)'."
            }
        }
    }
    /*
    /// An error for swizzleing.
    enum Error: LocalizedError {
        /// The class is missing.
        case missingClass(_ name: String)
        /// The method is missing.
        case missingMethod(_ type: AnyObject.Type, _ static: Bool, _ old: Bool, SelectorPair)

        static let prefix: String = "Swizzle.Error: "

        public var failureReason: String? {
            switch self {
            case let .missingClass(type):
                return "Missing class: \(type)"
            case let .missingMethod(type, `static`, old, pair):
                return
                    """
                    Missing \(old ? "old" : "new")\(`static` ? " static" : "") method for \
                    \(type.description()): \(pair)
                    """
            }
        }

        public var recoverySuggestion: String? {
            switch self {
            case .missingClass:
                return nil
            case let .missingMethod(type, `static`, old, pair):
                return
                    """
                    Create \(old ? "old" : "new")\(`static` ? " static" : "") method for \
                    \(type.description()): \(pair)
                    """
            }
        }

        public var errorDescription: String? {
            switch self {
            case .missingClass:
                return Self.prefix.appending(failureReason ?? "")
            case .missingMethod:
                return Self.prefix.appending(failureReason ?? "")
            }
        }
    }
     */
}

/*
 enum Error: LocalizedError {
     case classNotFound(class: String)
     case methodNotFound(class: AnyClass, selector: Selector, onClass: AnyClass)
     
     var errorDescription: String? {
         switch self {
         case .classNotFound:
             return "Class Not Found"
         case .methodNotFound:
             return "Method Not Found"
         }
     }

     var failureReason: String? {
         switch self {
         case .classNotFound(let type):
             return "Could not retrieve class metadata for type '\(type)'."
         case .methodNotFound(let _class, let selector, let cls):
             return "The method '\(selector)' could not be found on class '\(cls)'."
         }
     }
 }
 */

public extension Swizzle {
    /// A pair of selectors for swizzleing.
    struct SelectorPair: CustomStringConvertible {
        /// The old selector.
        public let old: Selector
        /// The new selector to replace the old.
        public let new: Selector
        /// A Boolean value indicating whether the selectors are static.
        public let `static`: Bool

        /**
         Creates a selector pair.

         - Parameters:
            - old: The old selector.
            - new: The new selector to replace the old.
            - static: A Boolean value indicating whether the selectors are static. The default value is `false`.
         */
        public init(old: Selector, new: Selector, static: Bool = false) {
            self.old = old
            self.new = new
            self.static = `static`
        }

        public init<V>(get old: PartialKeyPath<V>, new: PartialKeyPath<V>, static: Bool = false) {
            self.old = NSSelectorFromString(old._kvcKeyPathString!)
            self.new = NSSelectorFromString(new._kvcKeyPathString!)
            self.static = `static`
        }

        public init<V>(set old: PartialKeyPath<V>, new: PartialKeyPath<V>, static: Bool = false) {
            self.old = NSSelectorFromString("set" + old._kvcKeyPathString!.capitalized)
            self.new = NSSelectorFromString("set" + new._kvcKeyPathString!.capitalized)
            self.static = `static`
        }

        var `operator`: String {
            `static` ? "<~>" : "<->"
        }

        public var description: String {
            "\(old) \(self.operator) \(new)"
        }
    }
}

/*
public extension Swizzle {
    struct SelectorTriple: CustomStringConvertible {
        /// The old selector.
        public let old: Selector
        /// The new selector to replace the old.
        public let new: Selector
        /// The new selector to replace the old.
        public let original: Selector
        /// A Boolean value indicating whether the selectors are static.
        public let `static`: Bool
        
        /**
         Creates a selector pair.

         - Parameters:
            - old: The old selector.
            - new: The new selector to replace the old.
            - static: A Boolean value indicating whether the selectors are static. The default value is `false`.
         */
        public init(old: Selector, new: Selector, original: Selector, static: Bool = false) {
            self.old = old
            self.new = new
            self.original = original
            self.static = `static`
        }
        
        var `operator`: String {
            `static` ? "<~>" : "<->"
        }

        public var description: String {
            "\(old) \(self.operator) \(new) \(self.operator) \(original)"
        }
    }
}

extension Swizzle.SelectorPair {
    public static func <-> (lhs: Swizzle.SelectorPair, rhs: Selector) -> Swizzle.SelectorTriple {
        Swizzle.SelectorTriple(old: lhs.old, new: lhs.new, original: rhs)
    }

    public static func <-> (lhs: Swizzle.SelectorPair, rhs: String) -> Swizzle.SelectorTriple {
        Swizzle.SelectorTriple(old: lhs.old, new: lhs.new, original: Selector(rhs))
    }

    public static func <~> (lhs: Swizzle.SelectorPair, rhs: Selector) -> Swizzle.SelectorTriple {
        Swizzle.SelectorTriple(old: lhs.old, new: lhs.new, original: rhs, static: true)
    }

    public static func <~> (lhs: Swizzle.SelectorPair, rhs: String) -> Swizzle.SelectorTriple {
        Swizzle.SelectorTriple(old: lhs.old, new: lhs.new, original: Selector(rhs), static: true)
    }
}

public extension String {
    static func <-> (lhs: String, rhs: Swizzle.SelectorPair) -> Swizzle.SelectorTriple {
        Swizzle.SelectorTriple(old: Selector(lhs), new: rhs.old, original: rhs.new)
    }

    static func <~> (lhs: String, rhs: Swizzle.SelectorPair) -> Swizzle.SelectorTriple {
        Swizzle.SelectorTriple(old: Selector(lhs), new: rhs.old, original: rhs.new, static: true)
    }
}

extension Swizzle {
    @resultBuilder
    public enum TrippleBuilder {
        public static func buildBlock(_ swizzleTriples: SelectorTriple...) -> [SelectorTriple] {
            Array(swizzleTriples)
        }
    }
    
    /**
     Swizzles selectors of the specified class.

     - Parameters:
        - type:  The class to swizzle.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    public init(_ type: AnyClass, @TrippleBuilder _ makeSelectorTriples: () -> [SelectorTriple]) throws {
        try self.init(type, swizzleTriples: makeSelectorTriples())
    }

    /**
     Swizzles selectors of the specified class.

     - Parameters:
        - type:  The class to swizzle.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    public init(_ type: AnyClass, @TrippleBuilder _ makeSelectorTriples: () -> SelectorTriple) throws {
        try self.init(type, swizzleTriples: [makeSelectorTriples()])
    }

    /**
     Swizzles selectors of the class with the specified name.

     - Parameters:
        - className:  The name of the class.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    public init(_ className: String, @TrippleBuilder _ makeSelectorTriples: () -> [SelectorTriple]) throws {
        try self.init(className, swizzleTriples: makeSelectorTriples())
    }

    /**
     Swizzles selectors of the class with the specified name.

     - Parameters:
        - className:  The name of the class.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    public init(_ className: String, @TrippleBuilder _ makeSelectorTriples: () -> SelectorTriple) throws {
        try self.init(className, swizzleTriples: [makeSelectorTriples()])
    }
    
    @discardableResult
    init(_ class_: AnyClass, swizzleTriples: [SelectorTriple]) throws {
        guard object_isClass(class_) else { throw Error.missingClass(String(describing: class_)) }
        try swizzle(type: class_, triples: swizzleTriples)
    }
    
    @discardableResult
    init(_ className: String, swizzleTriples: [SelectorTriple], reset _: Bool = false) throws {
        guard let class_ = NSClassFromString(className)
        else { throw Error.missingClass(className) }
        try swizzle(type: class_, triples: swizzleTriples)
    }
    
    private func swizzle(type: AnyObject.Type, triples: [SelectorTriple]) throws {
        try triples.forEach { triple in
            guard let `class` = triple.static ? object_getClass(type) : type
            else { throw Error.missingClass(type.description()) }
            guard let old = triple.static ? class_getClassMethod(`class`, triple.old) : class_getInstanceMethod(`class`, triple.old)
            else { throw TrippleError.missingMethod(`class`, triple.static, .old, triple) }
            guard let new = triple.static ? class_getClassMethod(`class`, triple.new) : class_getInstanceMethod(`class`, triple.new)
            else { throw TrippleError.missingMethod(`class`, triple.static, .new, triple) }
            guard let original = triple.static ? class_getClassMethod(`class`, triple.original) : class_getInstanceMethod(`class`, triple.original)
            else { throw TrippleError.missingMethod(`class`, triple.static, .original, triple) }
            
            method_setImplementation(original, method_getImplementation(old))
            method_setImplementation(old, method_getImplementation(new))
        }
    }
}

extension Swizzle {
    enum TrippleError: LocalizedError {
        enum Destionation: String {
            case old
            case new
            case original
        }
        
        /// The method is missing.
        case missingMethod(_ type: AnyObject.Type, _ static: Bool, _ destionation: Destionation, SelectorTriple)
        
        public var failureReason: String? {
            switch self {
            case let .missingMethod(type, `static`, destionation, pair):
                return
                    """
                    Missing \(destionation)\(`static` ? " static" : "") method for \
                    \(type.description()): \(pair)
                    """
            }
        }
        
        public var recoverySuggestion: String? {
            switch self {
            case let .missingMethod(type, `static`, destionation, pair):
                return
                    """
                    Create \(destionation)\(`static` ? " static" : "") method for \
                    \(type.description()): \(pair)
                    """
            }
        }
    }
}
*/
