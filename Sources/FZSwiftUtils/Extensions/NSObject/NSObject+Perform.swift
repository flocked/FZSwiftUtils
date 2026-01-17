//
//  NSObject+Perform.swift
//  
//
//  Created by Florian Zand on 11.07.25.
//

import Foundation
import _NSObjectProxy

extension NSObject {
    /**
     Sends a message to the receiver with the specified arguments.
     
     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the message when it is invoked.
     */
    public func perform(_ selector: Selector, withArguments arguments: [Any?] = []) {
        do {
            try NSObject.catchException {
                if arguments.isEmpty {
                    perform(selector)
                } else if arguments.count == 1 {
                    perform(selector, with: arguments[0])
                } else if arguments.count == 2 {
                    perform(selector, with: arguments[0], with: arguments[1])
                } else {
                    guard let signature = getMethodSignature(for: selector) else { return }
                    let invocation = Invocation(signature: signature)
                    invocation.target = self
                    invocation.selector = selector
                    invocation.arguments = arguments
                    invocation.invoke()
                }
            }
        } catch {
            Swift.print(error)
        }
    }
    
    /**
     Sends a message to the receiver with the specified arguments.
     
     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     */
    public func perform(_ selector: String, withArguments arguments: [Any] = []) {
        perform(.string(selector), withArguments: arguments)
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.
     
     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    public func perform<V>(_ selector: Selector, withArguments arguments: [Any?] = []) -> V? {
        do {
            return try NSObject.catchException {
                guard let signature = getMethodSignature(for: selector) else { return nil }
                let invocation = Invocation(signature: signature)
                invocation.target = self
                invocation.selector = selector
                invocation.arguments = arguments
                invocation.invoke()
                return invocation.returnValue as? V
            }
        } catch {
            Swift.print(error)
            return nil
        }
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.

     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    public func perform<V>(_ selector: String, withArguments arguments: [Any?] = []) -> V? {
        perform(.string(selector), withArguments: arguments)
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.

     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    @_disfavoredOverload
    public func perform(_ selector: Selector, withArguments arguments: [Any?] = []) -> Any? {
        do {
          return try NSObject.catchException {
                guard let signature = getMethodSignature(for: selector) else { return nil }
                let invocation = Invocation(signature: signature)
                invocation.target = self
                invocation.selector = selector
                invocation.arguments = arguments
                invocation.invoke()
                return invocation.returnValue
            }
        } catch {
            Swift.print(error)
            return nil
        }
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.

     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    @_disfavoredOverload
    public func perform(_ selector: String, withArguments arguments: [Any?] = []) -> Any? {
        perform(.string(selector), withArguments: arguments)
    }
}

public extension NSObject {
    /**
     Sends a message to the object with the given arguments.
     
     - Note: You
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the object doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    func call(_ selector: Selector, with arguments: [Any] = []) throws {
        _ = try _call(selector, with: arguments) as Any
    }
    
    /**
     Sends a message to the object with the given arguments.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the object doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    func call(_ selector: Selector, with arguments: Any...) throws {
        try call(selector, with: arguments)
    }
    
    /**
     Sends a message to the object with the given arguments.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the object doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    func call(_ selector: String, with arguments: Any...) throws {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the object with the given arguments.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the object doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    func call(_ selector: String, with arguments: [Any] = []) throws {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the object with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Returns: The result of the message.
     - Throws: If the object doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    func call<R>(_ selector: String, with arguments: Any...) throws -> R {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the object with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Returns: The result of the message.
     - Throws: If the object doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    func call<R>(_ selector: String, with arguments: [Any] = []) throws -> R {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the object with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Returns: The result of the message.
     - Throws: If the object doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    func call<R>(_ selector: Selector, with arguments: Any...) throws -> R {
        try call(selector, with: arguments)
    }
    
    /**
     Sends a message to the object with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.un
     - Returns: The result of the message.
     - Throws: If the object doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    func call<R>(_ selector: Selector, with arguments: [Any] = []) throws -> R {
        try _call(selector, with: arguments)
    }
}

public extension NSObject {
    /**
     Sends a message to the class with the given arguments.
     
     - Note: You
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the class doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    static func call(_ selector: Selector, with arguments: [Any] = []) throws {
        _ = try _call(selector, with: arguments) as Any
    }
    
    /**
     Sends a message to the class with the given arguments.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the class doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    static func call(_ selector: Selector, with arguments: Any...) throws {
        try call(selector, with: arguments)
    }
    
    /**
     Sends a message to the class with the given arguments.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the class doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    static func call(_ selector: String, with arguments: Any...) throws {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the class with the given arguments.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Throws: If the class doesn't responds to the selector or the arguments aren't matching the expected argument types or arguments count.
     */
    static func call(_ selector: String, with arguments: [Any] = []) throws {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the class with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Returns: The result of the message.
     - Throws: If the class doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    static func call<R>(_ selector: String, with arguments: Any...) throws -> R {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the class with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Returns: The result of the message.
     - Throws: If the class doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    static func call<R>(_ selector: String, with arguments: [Any] = []) throws -> R {
        try call(.string(selector), with: arguments)
    }
    
    /**
     Sends a message to the class with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.
     - Returns: The result of the message.
     - Throws: If the class doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    static func call<R>(_ selector: Selector, with arguments: Any...) throws -> R {
        try call(selector, with: arguments)
    }
    
    /**
     Sends a message to the class with the given arguments and returns the result of the message.
     
     - Parameters:
        - selector: A selector identifying the message to send.
        - arguments: The arguments for the message.un
     - Returns: The result of the message.
     - Throws: If the class doesn't responds to the selector, the arguments aren't matching the expected argument types or arguments count or the return value type is wrong.
     */
    static func call<R>(_ selector: Selector, with arguments: [Any] = []) throws -> R {
        try _call(selector, with: arguments)
    }
}

fileprivate extension NSObject {
    func _call<R>(_ selector: Selector, with values: [Any] = []) throws -> R {
        try Self._perform(selector, targetObject: self, targetClass: object_getClass(self), values: values)
    }
    
    static func _call<R>(_ selector: Selector, with values: [Any] = []) throws -> R {
        try _perform(selector, targetObject: self, targetClass: object_getClass(self), values: values, isInstance: false)
    }
    
    static func _perform<R>(_ selector: Selector, targetObject: AnyObject, targetClass: AnyClass?, values: [Any], isInstance: Bool = true) throws -> R {
        guard let cls = targetClass else {
            throw CallError.unrecognizedSelector(selector: selector, class: targetClass ?? NSObject.self, isInstance: isInstance)
        }
        guard let method = isInstance ? class_getInstanceMethod(cls, selector) : class_getClassMethod(cls, selector) else {
            throw CallError.unrecognizedSelector(selector: selector, class: cls, isInstance: isInstance)
        }
        /*
        let isMatchingArguments = !zip(values.map({ _Any($0) }), method.argumentTypes).contains(where: {
            let isMatch = $0.0.isMatching(typeEncoding: $0.1)
            if !isMatch { Swift.print("aaa", $0.1, $0.0.value) }
            return !isMatch
        })
         */
        let numberOfArguments = Int(method_getNumberOfArguments(method)-2)
        guard numberOfArguments == values.count else {
            throw CallError.invalidArgumentsCount(selector: selector, class: cls, isInstance: isInstance, provided: values.count, expected: numberOfArguments)
        }
        do {
            let returnValue = try cast(method_getImplementation(method), object: targetObject, selector: selector, with: values)
            guard let returnValue = returnValue as? R else {
                throw CallError.unexpectedReturnType(selector: selector, class: cls, isInstance: isInstance, expected: R.self, returned: type(of: returnValue))
            }
            return returnValue
        } catch {
            if (error as NSError).domain == "NSInvalidArgumentException" {
                throw CallError.invalidArguments(selector: selector, class: cls, isInstance: isInstance)
            }
            throw error
        }
    }
    
    static func cast(_ imp: IMP, object: AnyObject, selector: Selector, with values: [Any]) throws -> Any {
        try NSObject.catchException {
            switch values.count {
            case 0:
                typealias Closure = (@convention(c) (AnyObject, Selector) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector)
            case 1:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0])
            case 2:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1])
            case 3:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2])
            case 4:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2], values[3])
            case 5:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any, Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2], values[3], values[4])
            case 6:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any, Any, Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2], values[3], values[4], values[5])
            case 7:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any, Any, Any, Any,  Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2], values[3], values[4], values[5], values[6])
            case 8:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any, Any, Any, Any,  Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7])
            case 9:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any, Any, Any, Any,  Any, Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8])
            case 10:
                typealias Closure = (@convention(c) (AnyObject, Selector, Any, Any, Any, Any, Any, Any,  Any, Any, Any, Any) -> Any)
                return unsafeBitCast(imp, to: Closure.self)(object, selector, values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8], values[9])
            default:
                guard let signature = getMethodSignature(for: selector) else {
                    throw CallError.unrecognizedSelector(selector: selector, class: type(of: object), isInstance: true)
                }
                let invocation = Invocation(signature: signature)
                invocation.target = object
                invocation.selector = selector
                invocation.arguments = values
                invocation.invoke()
                return invocation.returnValue ?? Void()
            }
        }
    }
    
    enum CallError: Error, CustomStringConvertible {
        /// The target does not implement the specified selector.
        case unrecognizedSelector(selector: Selector, class: AnyClass, isInstance: Bool)

        /// The method returned a value whose type does not match the expected generic result type R.
        case unexpectedReturnType(selector: Selector, class: AnyClass, isInstance: Bool, expected: Any.Type, returned: Any.Type)

        /// The method could not be invoked because the provided argument list
        /// does not match the selector’s expected parameters.
        case invalidArguments(selector: Selector, class: AnyClass, isInstance: Bool)
        
        case invalidArgumentsCount(selector: Selector, class: AnyClass, isInstance: Bool, provided: Int, expected: Int)

        var description: String {
            switch self {
            case let .unrecognizedSelector(selector, cls, isInstance):
                return "Unrecognized \(isInstance ? "instance": "class") selector '\(selector)' for class \(cls)."
            case let .unexpectedReturnType(selector, cls, isInstance, expected, returned):
                return "Unexpected return type when invoking \(isInstance ? "instance": "class") '\(selector)' on class \(cls): received '\(returned)', instead of expected '\(expected)'."
            case let .invalidArguments(selector, cls, isInstance):
                return "Invalid arguments for \(isInstance ? "instance": "class") selector '\(selector)' on class \(cls)."
            case let .invalidArgumentsCount(selector, cls, isInstance, provided, expected):
                return "Invalid number of arguments for \(isInstance ? "instance": "class") selector '\(selector)' on class \(cls): provided \(provided), expected \(expected)."
            }
        }
    }
}
