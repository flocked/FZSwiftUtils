//
//  NSObject+Swizzle.swift
//
//  Created by Florian Zand on 05.10.23.
//
//  Adopted from:
//  InterposeKit - https://github.com/steipete/InterposeKit/
//  Copyright (c) 2020 Peter Steinberger

import Foundation

extension NSObject {
    /**
     Replace an `@objc dynamic` instance method via selector on the current object.

     Example usage that replaces the `mouseDown`method of a view:

     ```swift
     let view = NSView()
     do {
         try view.replaceMethod(
             #selector(NSView.mouseDown(with:)),
             methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
             hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in {
                object, event in
                let view = (object as! NSView)
                // handle replaced `mouseDown`

                // calls `super.mouseDown`
                store.original(object, #selector(NSView.mouseDown(with:)), event)
             }
        }
     } catch {
     // handle error
     }
     ```
     */
    public func replaceMethod<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws {
            try hooks[selector]?.revert()
            hooks[selector] = try Interpose.ObjectHook(object: self, selector: selector, implementation: implementation).apply()
    }

    /// Replace an `@objc dynamic` class method via selector on the object.
    public static func replaceMethod<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws {
            try hooks[selector]?.revert()
            hooks[selector] = try Interpose.ClassHook(class: self as AnyClass,
                                       selector: selector, implementation: implementation).apply()
    }
    
    /// Resets an `@objc dynamic` instance method on the current object to it's original state.
    public func resetMethod(_ selector: Selector) {
        _ = try? hooks[selector]?.revert()
        hooks[selector] = nil
    }
    
    /// Resets an `@objc dynamic` class method on the object to it's original state.
    public static func resetMethod(_ selector: Selector) {
        _ = try? hooks[selector]?.revert()
        hooks[selector] = nil
    }
    
    var hooks: [Selector: AnyHook] {
        get { getAssociatedValue(key: "_hooks", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "_hooks", object: self) }
    }
    
    static var hooks: [Selector: AnyHook] {
        get { getAssociatedValue(key: "_hooks", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "_hooks", object: self) }
    }
}
