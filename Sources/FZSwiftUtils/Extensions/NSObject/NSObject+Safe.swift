//
//  NSObject+Safe.swift
//  
//
//  Created by Florian Zand on 11.09.26.
//

import Foundation
import _FZSwiftUtilsObjC

extension NSObjectProtocol {
    /// Provides exception-safe access to the properties of this object.
    public var safe: NSObject.ExceptionSafe<Self> {
        .init(self)
    }
}

extension NSObject {
    /// Provides exception-safe access to an Objective-C object's properties.
    @dynamicMemberLookup
    public struct ExceptionSafe<Object> {
        /// The wrapped object.
        let object: Object
        
        /// Returns the value at the specified key path, or `nil` if accessing it raises an Objective-C exception.
        public subscript<T>(dynamicMember keyPath: KeyPath<Object, T>) -> T? {
            try? ObjCRuntime.catchException { object[keyPath: keyPath] }
        }
        
        init(_ object: Object) {
            self.object = object
        }
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     A proxy  of the object that can perform methods that might hrow an Objective-C [NSException](https://developer.apple.com/documentation/foundation/nsexception) and crash.
     
     This property allows safer bridging of Objective-C code into Swift, where exceptions cannot be caught and crash the application.
     
     It's a convient way of using `ObjCRuntime's` ``ObjCRuntime/catchException(_:)-93ggk``.
     */
    @_disfavoredOverload
    public var safe: Self {
        SafeObjectProxy(of: self).asObject()
    }
}

fileprivate class SafeObjectProxy<Object: NSObject>: NSObjectProxy<Object> {
    override func forwardingInvocation(_ invocation: Invocation) {
        try? ObjCRuntime.catchException {
            super.forwardingInvocation(invocation)
        }
    }
}
