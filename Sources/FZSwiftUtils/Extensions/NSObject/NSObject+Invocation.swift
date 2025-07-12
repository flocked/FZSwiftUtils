//
//  NSObject+Invocation.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 12.07.25.
//

import Foundation
import _NSObjectProxy

extension Invocation {
    /// The arguments of the invocation.
    public var arguments: [Any?] {
        get { _arguments.map({ mappedValue($0) }) }
        set { _arguments = newValue.map({ $0 ?? NSNull()  }) }
    }
    
    /// The return value of the invocation.
    public var returnValue: Any? {
        get {
            guard let value = _returnValue else { return nil }
            return mappedValue(value)
        }
        set { _returnValue = newValue }
    }
    
    open override var description: String {
       description(detailed: false)
    }
    
    open override var debugDescription: String {
        debugDescription(detailed: false)
    }
    
    /**
     A textual representation of this instance.
     
     - Parameter detailed: A Boolean value indicating whether to include detailed representations of the ``target``, ``arguments`` values and ``returnValue``.
     */
    public func description(detailed: Bool) -> String {
        let selector = NSStringFromSelector(selector).removingSuffix(":")
        var description =  selector + "()"
        var components = selector.components(separatedBy: ":")
        if !arguments.isEmpty, components.count == arguments.count {
            for index in 0..<components.count {
                let argument = String(delegateDescribing: arguments[index], detailed: detailed)
                if index == 0 {
                    components[index] = components[index].splitByWithPrefix + argument
                } else {
                    components[index] += ": \(argument)"
                }
            }
            description = components.joined(separator: ", ") + ")"
        }
        if let returnValue = returnValue {
            description += " -> \(String(delegateDescribing: returnValue, detailed: detailed))"
        } else if !isVoidReturnType {
            description += " -> nil"
        }
        return description
    }
    
    /**
     A textual representation of this instance, intended for debugging.
     
     - Parameter detailed: A Boolean value indicating whether to include detailed representations of the ``target``, ``arguments`` values and ``returnValue``.
     */
    public func debugDescription(detailed: Bool = false) -> String {
        var values = ["selector: \"\(NSStringFromSelector(selector))\""]
        if let target = target {
            values += detailed ? "target: \(target)" : "target: \(type(of: target))"
        } else {
            values += "target: nil"
        }
        if !arguments.isEmpty {
            values += "arguments: [\(arguments.map({ String(delegateDescribing: $0, detailed: detailed) }).joined(separator: ", "))]"
        }
        if let returnValue = returnValue {
            values += "returnValue: \(String(delegateDescribing: returnValue, detailed: detailed))"
        } else if !isVoidReturnType {
            values += "returnValue: nil"
        }
        return "Invocation(" + values.joined(separator: ", ") + ")"
    }
    
    /// Sets the arguments of the invocation.
    @discardableResult
    public func arguments(_ arguments: [Any?]) -> Self {
        self.arguments = arguments
        return self
    }
    
    /// Sets the return value of the invocation.
    @discardableResult
    public func returnValue(_ value: Any?) -> Self {
        self.returnValue = value
        return self
    }
    
    /// Sets the target of the invocation.
    @discardableResult
    public func target(_ target: Any?) -> Self {
        self.target = target
        return self
    }
    
    /// Sets the selector of the invocation.
    @discardableResult
    public func selector(_ selector: Selector) -> Self {
        self.selector = selector
        return self
    }
    
    /// Sends the invocation’s message (with its arguments) to its target and returns the it's return value.
    public func invoke<V>() -> V? {
        invoke()
        return returnValue as? V
    }
}

fileprivate func mappedValue(_ value: Any) -> Any? {
    if value is NSNull { return nil }
    let cfValue = value as CFTypeRef
    if CFGetTypeID(cfValue) == CFBooleanGetTypeID(), let intVal = value as? Int {
        return intVal == 1
    }
    return value
}

fileprivate extension String {
    var splitByWithPrefix: String {
        let components = components(separatedBy: "With")
        guard components.count == 2, components[1].first?.isUppercase == true else { return self + "(" }
        return "\(components[0])(\(components[1].lowercasedFirst()): "
    }

    init<Subject>(delegateDescribing instance: Subject, detailed: Bool = false) {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            switch instance {
            case let instance as NSRect: self = "CGRect\(instance as CGRect)"
            case let instance as NSPoint: self = "CGPoint\(instance as CGPoint)"
            case let instance as NSSize: self = "CGSize\(instance as CGSize)"
            default:
                let string = "\(instance)"
                if string == "<null>" {
                    self = "nil"
                } else if !detailed, string.hasPrefix("{length") {
                    self = "<Pointer>"
                } else if !detailed, string.hasPrefix("<NS") {
                    self = "<\(type(of: instance as AnyObject))>"
                } else {
                    self = string
                }
            }
        }
    }
}
