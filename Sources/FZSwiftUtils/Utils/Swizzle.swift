//
//  Swizzle.swift
//  
//  Adopted from github.com/neutralradiance/swift-core
//  Created by Florian Zand on 05.06.22.
//

import Foundation

infix operator <->
infix operator <~>

public struct SwizzlaePair: CustomStringConvertible {
    public let old: Selector
    public let new: Selector
    public let `static`: Bool
    public init(old: Selector, new: Selector, `static`: Bool = false) {
        self.old = old
        self.new = new
        self.static = `static`
    }
    
    public init<V>(get old: PartialKeyPath<V>, new: PartialKeyPath<V>, `static`: Bool = false) {
        self.old = NSSelectorFromString(old._kvcKeyPathString!)
        self.new = NSSelectorFromString(new._kvcKeyPathString!)
        self.static = `static`
    }
    
    public init<V>(set old: PartialKeyPath<V>, new: PartialKeyPath<V>, `static`: Bool = false) {
        self.old = NSSelectorFromString("set" + old._kvcKeyPathString!.capitalized)
        self.new = NSSelectorFromString("set" + new._kvcKeyPathString!.capitalized)
        self.static = `static`
    }
    
    internal var `operator`: String {
        `static` ? "<~>" : "<->"
    }

    public var description: String {
        "\(old) \(self.operator) \(new)"
    }
}

public extension Selector {
    static func <-> (lhs: Selector, rhs: Selector) -> SwizzlaePair {
        SwizzlaePair(old: lhs, new: rhs)
    }

    static func <-> (lhs: Selector, rhs: String) -> SwizzlaePair {
        SwizzlaePair(old: lhs, new: Selector(rhs))
    }

    static func <~> (lhs: Selector, rhs: Selector) -> SwizzlaePair {
        SwizzlaePair(old: lhs, new: rhs, static: true)
    }

    static func <~> (lhs: Selector, rhs: String) -> SwizzlaePair {
        SwizzlaePair(old: lhs, new: Selector(rhs), static: true)
    }
}

public extension String {
    static func <-> (lhs: String, rhs: Selector) -> SwizzlaePair {
        SwizzlaePair(old: Selector(lhs), new: rhs)
    }

    static func <~> (lhs: String, rhs: Selector) -> SwizzlaePair {
        SwizzlaePair(old: Selector(lhs), new: rhs, static: true)
    }
}

/// Swizzling of class selectors.
public struct Swizzle {
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ swizzlePairs: SwizzlaePair...) -> [SwizzlaePair] {
            Array(swizzlePairs)
        }
    }

    @discardableResult
    /**
     Swizzles selectors of the specified class.
     - Parameters class_:  The class to swizzle.
     - Parameters makeSwizzlePairs: The swizzle selector pairs.
     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    public init(_ class_: AnyClass, @Builder _ makeSwizzlePairs: () -> [SwizzlaePair]) throws {
        try self.init(class_, swizzlePairs: makeSwizzlePairs())
    }

    @discardableResult
    /**
     Swizzles selectors of the specified class.
     - Parameters class_:  The class to swizzle.
     - Parameters makeSwizzlePairs: The swizzle selector pairs.
     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    public init(_ class_: AnyClass, @Builder _ makeSwizzlePairs: () -> SwizzlaePair) throws {
        try self.init(class_, swizzlePairs: [makeSwizzlePairs()])
    }

    @discardableResult
    /**
     Swizzles selectors of the class with the specified name.
     - Parameters className:  The name of the class.
     - Parameters makeSwizzlePairs: The swizzle selector pairs.
     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    public init(_ className: String, @Builder _ makeSwizzlePairs: () -> [SwizzlaePair]) throws {
        try self.init(className, swizzlePairs: makeSwizzlePairs())
    }

    @discardableResult
    /**
     Swizzles selectors of the class with the specified name.
     - Parameters className:  The name of the class.
     - Parameters makeSwizzlePairs: The swizzle selector pairs.
     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    public init(_ className: String, @Builder _ makeSwizzlePairs: () -> SwizzlaePair) throws {
        try self.init(className, swizzlePairs: [makeSwizzlePairs()])
    }
    
    @discardableResult
    internal init(_ class_: AnyClass, swizzlePairs: [SwizzlaePair]) throws {
        guard object_isClass(class_) else {
            throw Error.missingClass(String(describing: class_))
        }
        try swizzle(type: class_, pairs: swizzlePairs)
    }

    @discardableResult
    internal init(_ className: String, swizzlePairs: [SwizzlaePair], reset: Bool = false) throws {
        guard let class_ = NSClassFromString(className) else {
            throw Error.missingClass(className)
        }
        try swizzle(type: class_, pairs: swizzlePairs)
    }

    private func swizzle(
        type: AnyObject.Type,
        pairs: [SwizzlaePair]
    ) throws {
        try pairs.forEach { pair in
            guard let `class` =
                pair.static ?
                object_getClass(type) : type
            else {
                throw Error.missingClass(type.description())
            }
            guard
                let lhs =
                class_getInstanceMethod(`class`, pair.old)
            else {
                throw Error.missingMethod(`class`, pair.static, true, pair)
            }
            guard let rhs =
                class_getInstanceMethod(`class`, pair.new)
            else {
                throw Error.missingMethod(`class`, pair.static, false, pair)
            }

            if pair.static,
               class_addMethod(
                   `class`, pair.old,
                   method_getImplementation(rhs), method_getTypeEncoding(rhs)
               )
            {
                class_replaceMethod(
                    `class`,
                    pair.new,
                    method_getImplementation(lhs),
                    method_getTypeEncoding(lhs)
                )
                
            } else {
                method_exchangeImplementations(lhs, rhs)
            }
            debugPrint("Swizzled\(pair.static ? " static" : "") method for: \(pair)")
        }
    }
}

extension Swizzle {
    enum Error: LocalizedError {
        static let prefix: String = "Swizzle.Error: "
        case missingClass(_ name: String),
             missingMethod(
                 _ type: AnyObject.Type, _ static: Bool, _ old: Bool, SwizzlaePair
             )
        var failureReason: String? {
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

        var recoverySuggestion: String? {
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

        var errorDescription: String? {
            switch self {
            case .missingClass:
                return Self.prefix.appending(failureReason!)
            case .missingMethod:
                return Self.prefix.appending(failureReason!)
            }
        }
    }
}
