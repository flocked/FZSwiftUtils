//
//  NSObject+Proxy.swift
//
//
//  Created by Florian Zand on 22.04.24.
//

import Foundation
import _NSObjectProxy

/// An object proxy.
open class NSObjectProxy<Object: NSObject>: ObjectProxy {
    /// Creates a proxy for the specified object.
    public init(object: Object) {
        super.init(target: object)
    }
        
    /// The object of the proxy.
    public var object: Object {
        _target as! Object
    }
    
    /// Returns the proxy as it's object.
    public func asObject() -> Object {
        object._map(to: self)
    }
    
    override init(target: NSObject) {
        super.init(target: target)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     A proxy ([NSProxy](https://developer.apple.com/documentation/foundation/nsproxy)) of the object.
     
     The invocation handler is called whenever a method of the object is called.
     
     The invocation provides the `selector`, `arguments` and `returnValue` of the method call. The properties can be changed.
     
     To invoke the method call, use the invocation's `invoke()` method. If you don't use it, the object's method isn't called.
     
     To get the returned value of the method call, use the inovcations's `returnValue` property.
                         
     - Parameter invocationHandler: The handler that provides the inovcation whenever a method of the object is called.
     */
    public func proxy(invocationHandler: @escaping (_ invocation: Invocation)->()) -> Self {
        HandlerProxy(object: self, invocationHandler: invocationHandler).asObject()
    }
}

fileprivate class HandlerProxy<Object: NSObject>: ObjectProxy {
    let invocationHandler: ((Invocation)->())?
    let respondsToHandler: ((Selector)->(Bool))?
    
    init(object: Object, invocationHandler: ((Invocation)->())? = nil, respondsToHandler: ((Selector)->(Bool))? = nil) {
        self.invocationHandler = invocationHandler
        self.respondsToHandler = respondsToHandler
        super.init(target: object)
    }
    
    override func responds(to aSelector: Selector) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return respondsToHandler?(aSelector) ?? false
    }
    
    override func forwardingInvocation(_ invocation: Invocation) {
        if let handler = invocationHandler {
            invocation.target = _target
            handler(invocation)
        } else {
            super.forwardingInvocation(invocation)
        }
    }
    
    func asObject() -> Object {
        (_target as! Object)._map(to: self)
    }
}

/*
extension NSObjectProtocol where Self: NSObject {
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
    public func proxy(invocationHandler: @escaping (_ invocation: Invocation)->(), respondsHandler: @escaping (_ selector: Selector)->(Bool)) -> Self {
        HandlerProxy(object: self, invocationHandler: invocationHandler, respondsToHandler: respondsHandler).asObject()
    }
    
    /**
     A proxy ([NSProxy](https://developer.apple.com/documentation/foundation/nsproxy)) of the object that can allows to provide a `target` and `selector` for methods the object isn't responding to.
     
     The responds handler is called whenever a method of the object is called that the object isn't responding to (e.g. for `optional` methods and properties of a protocol the object conforms to).
     
     Return a `target` and `selector`, so that the object can responds to the method.

     - Parameter respondsHandler: The handler that provides a `target` and `selector` for methods the object isn't responding to.
     */
    public func proxy(respondsHandler: @escaping (_ selector: Selector)->((target: NSObject, selector: Selector)?)) -> Self {
        MappingProxy.init(object: self, respondsToHandler: respondsHandler).asObject()
    }
}

fileprivate class MappingProxy<Object: NSObject>: ObjectProxy {
    let respondsToHandler: ((Selector)->((target: NSObject, selector: Selector)?))
    var mappings: [Selector: (target: Weak<NSObject>, selector: Selector)] = [:]

    var object: Object {
        _target as! Object
    }
    
    override func getMethodSignature(for sel: Selector) -> MethodSignature? {
        if let signature = super.getMethodSignature(for: sel) {
            return signature
        } else if let signature = mappings[sel]?.target.object?.getMethodSignature(for: sel) {
            return signature
        }
        return nil
    }
    
    init(object: Object, respondsToHandler: @escaping ((Selector)->((target: NSObject, selector: Selector)?))) {
        self.respondsToHandler = respondsToHandler
        super.init(target: object)
    }
        
    override func responds(to aSelector: Selector) -> Bool {
        if super.responds(to: aSelector) {
            return true
        } else if let mapping = respondsToHandler(aSelector), mapping.target.responds(to: mapping.selector) {
            mappings[aSelector] = (Weak(mapping.target), mapping.selector)
            return true
        }
        return false
    }
    
    override func forwardingInvocation(_ invocation: Invocation) {
        if let mapping = mappings[invocation.selector] {
            guard let target = mapping.target.object else { return }
            invocation.target = target
            invocation.selector = mapping.selector
            invocation.invoke()
        } else {
            super.forwardingInvocation(invocation)
        }
    }
    
    func asObject() -> Object {
        object._map(to: self)
    }
}
*/
