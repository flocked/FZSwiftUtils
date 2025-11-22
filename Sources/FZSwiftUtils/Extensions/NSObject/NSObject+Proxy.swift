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
        super.init(targetObject: object)
    }
        
    /// The object of the proxy.
    public var object: Object {
        _target as! Object
    }
    
    /// Returns the proxy as it's object.
    public func asObject() -> Object {
        object._map(to: self)
    }
    
    override init(targetObject: NSObject) {
        super.init(targetObject: targetObject)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     A proxy  of the object that lcan perform methods that might hrow an Objective-C `NSException` and crash.
     
     This property allows safer bridging of Objective-C code into Swift, where exceptions cannot be caught and crash the application.
     
     It's a convient way of using NSObject `catchException`.
     */
    public var safe: Self {
        SafeObjectProxy(object: self).asObject()
    }
}

fileprivate class SafeObjectProxy<Object: NSObject>: NSObjectProxy<Object> {
    override func forwardingInvocation(_ invocation: Invocation) {
        try? NSObject.catchException {
            super.forwardingInvocation(invocation)
        }
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
    
    init(object: Object, invocationHandler: ((Invocation)->())? = nil) {
        self.invocationHandler = invocationHandler
        super.init(targetObject: object)
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
