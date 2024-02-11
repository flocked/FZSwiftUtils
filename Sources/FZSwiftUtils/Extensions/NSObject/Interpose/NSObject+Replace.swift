//
//  File.swift
//  
//
//  Created by Florian Zand on 11.02.24.
//

import Foundation

extension NSObject {
    /// Hook an `@objc dynamic` instance method via selector  on the current object or class..
    @discardableResult public func replaceMethodNew<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws -> TypedHook<MethodSignature, HookSignature> {
            
        if let klass = self as? AnyClass {
            return try Interpose.ClassHook(class: klass, selector: selector, implementation: implementation).apply()
        } else {
            return try Interpose.ObjectHook(object: self, selector: selector, implementation: implementation).apply()
        }
    }

    /// Hook an `@objc dynamic` instance method via selector  on the current object or class..
    @discardableResult public class func replaceMethod<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws -> AnyHook {
        return try Interpose.ClassHook(class: self as AnyClass,
                                       selector: selector, implementation: implementation).apply()
    }
}
