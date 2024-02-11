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
            let hook = try Interpose.ObjectHook(object: self, selector: selector, implementation: implementation).apply()
            addHook(hook, for: selector)
    }

    /// Replace an `@objc dynamic` class method via selector on the object.
    public static func replaceMethod<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws {
            let hook = try Interpose.ClassHook(class: self as AnyClass,
                                       selector: selector, implementation: implementation).apply()
            var _hooks = hooks[selector] ?? []
            _hooks.append(hook)
            hooks[selector] = _hooks
    }
    
    /// Resets an `@objc dynamic` instance method on the current object to it's original state.
    public func resetMethod(_ selector: Selector) {
        for hook in hooks[selector] ?? [] {
            do {
                _ = try hook.revert()
            } catch {
                Swift.debugPrint(error)
            }
        }
        hooks[selector] = nil
    }
    
    /// Resets an `@objc dynamic` class method on the object to it's original state.
    public static func resetMethod(_ selector: Selector) {
        for hook in hooks[selector] ?? [] {
            do {
                _ = try hook.revert()
            } catch {
                Swift.debugPrint(error)
            }
        }
        hooks[selector] = nil
    }
        
    func addHook(_ hook: AnyHook, for selector: Selector) {
        var _hooks = hooks[selector] ?? []
        _hooks.append(hook)
        hooks[selector] = _hooks
    }
    
    func removeHooks(for selector: Selector) {
        for hook in hooks[selector] ?? [] {
            do {
                try hook.revert()
            } catch {
                Swift.print(error)
            }
        }
        hooks[selector] = nil
    }
    
    public var hooks: [Selector: [AnyHook]] {
        get { getAssociatedValue(key: "_hooks", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "_hooks", object: self) }
    }
    
    static var hooks: [Selector: [AnyHook]] {
        get { getAssociatedValue(key: "_hooks", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "_hooks", object: self) }
    }
}
