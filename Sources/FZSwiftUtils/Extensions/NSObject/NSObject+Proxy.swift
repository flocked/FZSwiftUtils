//
//  NSObject+Proxy.swift
//
//
//  Created by Florian Zand on 22.04.24.
//

import Foundation
import _NSObjectProxy

extension NSObject {
    /**
     Invokes the specified method of the object.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     */
    public func perform(_ selector: Selector, with arguments: [Any] = []) {
        _performing(selector, withArguments: arguments)
    }
    
    /**
     Invokes the specified method of the object.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     */
    public func perform(_ selector: String, with arguments: [Any] = []) {
        _performing(NSSelectorFromString(selector), withArguments: arguments)
    }
    
    /**
     Invokes the specified method of the object and returns its value.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func perform<V>(_ selector: Selector, with arguments: [Any] = []) -> V? {
        _performSelectorAndReturn(selector, withArguments: arguments) as? V
    }
    
    /**
     Invokes the specified method of the object and returns its value.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func perform<V>(_ selector: String, with arguments: [Any] = []) -> V? {
        _performSelectorAndReturn(NSSelectorFromString(selector), withArguments: arguments) as? V
    }
    
    /**
     Invokes the specified method of the object and returns its value.

     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func performAndReturn(_ selector: Selector, with arguments: [Any] = []) -> Any? {
        _performSelectorAndReturn(selector, withArguments: arguments)
    }
    
    /**
     Invokes the specified method of the object and returns its value.

     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func performAndReturn(_ selector: String, with arguments: [Any] = []) -> Any? {
        _performSelectorAndReturn(NSSelectorFromString(selector), withArguments: arguments)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// A proxy ([NSProxy](https://developer.apple.com/documentation/foundation/nsproxy)) of the object.
    func proxy() -> Self {
        _objectProxy()
    }
    
    /**
     A proxy ([NSProxy](https://developer.apple.com/documentation/foundation/nsproxy)) of the object.
     
     The invocation handler is called whenever a method of the object is called. It provides the method invocation.
     
     The invocation provides the `selector` and `arguments` of the method call. The arguments can be changed.
          
     To invoke the method call with the invocation's arguments, use it's `invoke()` method. Without invoking it, the object's method isn't called.
     
     To get the returned value of the method call, use the inovcations's `returnValue` property.
                         
     - Parameter invocationHandler: The handler that provides the inovcation whenever a method of the object is called.
     */
    public func proxy(invocationHandler: @escaping (_ invocation: Invocation)->()) -> Self {
        _objectProxy(invocationHandler: invocationHandler)
    }
    
    /**
     A proxy ([NSProxy](https://developer.apple.com/documentation/foundation/nsproxy)) of the object.
     
     The invocation handler is called whenever a method of the object is called. It provides the method invocation.
     
     The invocation provides the `selector` and `arguments` of the method call. The arguments can be changed.
          
     To invoke the method call with the invocation's arguments, use it's `invoke()` method. Without invoking it, the object's method isn't called.
     
     To get the returned value of the method call, use the inovcations's `returnValue` property.
                         
     - Parameters:
        - invocationHandler: The handler that provides the inovcation whenever a method of the object is called.
        - respondsHandler: The handler that determinates if the proxy responds to a selector.
     */
    public func proxy(invocationHandler: @escaping (_ invocation: Invocation)->(), respondsHandler: @escaping (_ selector: Selector, _ responds: Bool)->(Bool)) -> Self {
        _objectProxy { invocation in
            if invocation.selector == #selector(NSObject.responds(to:)), let selector = invocation.arguments.first as? String, let responds = invocation.returnValue as? Int {
                invocation.returnValue = respondsHandler(NSSelectorFromString(selector), responds == 1) ? 1 : 0
                invocation.invoke()
            } else {
                invocationHandler(invocation)
            }
        }
    }
    
    /**
     A proxy ([NSProxy](https://developer.apple.com/documentation/foundation/nsproxy)) of the object that can allows to provide a `target` and `selector` for methods the object isn't responding to.
     
     The responds handler is called whenever a method of the object is called that the object isn't responding to (e.g. for `optional` methods and properties of a protocol the object conforms to).
     
     Return a `target` and `selector`, so that the object can responds to the method.

     - Parameter respondsHandler: The handler that provides a `target` and `selector` for methods the object isn't responding to.
     */
    public func proxy(respondsHandler: @escaping (_ target: Self, _ selector: Selector)->((target: NSObject, selector: Selector)?)) -> Self {
        let id = UUID()
        return _objectProxy { invocation in
            if let target = invocation.target as? Self {
                if let responding = target.proxyResponders[id, default: [:]][invocation.selector] {
                    invocation.target = responding.target
                    invocation.selector = responding.selector
                    target.proxyResponders[id, default: [:]][invocation.selector] = nil
                } else if invocation.selector == #selector(NSObject.responds(to:)), let selector = invocation.arguments.first as? String, let responds = invocation.returnValue as? Int, responds == 0, let responding = respondsHandler(target, invocation.selector) {
                    target.proxyResponders[id, default: [:]][NSSelectorFromString(selector)] = responding
                    invocation.returnValue = 1
                }
            }
            invocation.invoke()
        }
    }
    
    /// Returns the real `self`, if the object is a proxy.
    var realSelf: Self {
        guard isProxy() else { return self }
        return Self.toRealSelf(self)
    }
}

fileprivate extension NSObject {
    var proxyResponders: [UUID: [Selector: (target: NSObject, selector: Selector)]] {
        get { getAssociatedValue("proxyResponders") ?? [:] }
        set { setAssociatedValue(newValue, key: "proxyResponders") }
    }
    
    @objc func _realSelf() -> NSObject { self }
    static func toRealSelf<Object: NSObject>(_ v: Object) -> Object {
        v.perform(#selector(_realSelf))!.takeUnretainedValue() as! Object
    }
}

extension Invocation {
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
            for (index, component) in components.indexed() {
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
                } else if !detailed, string.hasPrefix("<NS"), let instance = instance as? AnyObject {
                    self = "<\(type(of: instance))>"
                } else {
                    self = string
                }
            }
        }
    }
}
