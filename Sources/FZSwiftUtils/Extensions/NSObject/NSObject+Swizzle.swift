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
    /// Object to reset an replaced method.
    public class ReplacedMethod {
        /// The selector for the replaced method.
        public let selector: Selector
        
        weak var object: NSObject?
        var `class`: NSObject.Type?
        let id: UUID
        
        /// Resets an replaced method to it's original state.
        public func reset() {
            Swift.print("has object", object != nil)
            if let _class = self.class {
                if var hooks = _class.hooks[selector], let index = hooks.firstIndex(where: {$0.id == id}) {
                    _ =  try? hooks[safe: index]?.revert()
                    hooks.remove(at: index)
                    object?.hooks[selector] = hooks
                }
            } else if var hooks = object?.hooks[selector], let index = hooks.firstIndex(where: {$0.id == id}) {
                _ =  try? hooks[safe: index]?.revert()
                hooks.remove(at: index)
                object?.hooks[selector] = hooks
            }
        }
        
        init(_ object: NSObject?, hook: AnyHook) {
            self.object = object
            self.selector = hook.selector
            self.id = hook.id
        }
        
        init(_ _class: NSObject.Type?, hook: AnyHook) {
            self.object = nil
            self.class = _class
            self.selector = hook.selector
            self.id = hook.id
        }
    }
    
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
        Swift.debugPrint(error)
     }
     ```
     
     To reset the replaced method, use `replaceMethod(_:)`.
     */
    @discardableResult
    public func replaceMethod<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws -> ReplacedMethod {
            let hook = try Interpose.ObjectHook(object: self, selector: selector, implementation: implementation).apply()
            var _hooks = hooks[selector] ?? []
            _hooks.append(hook)
            hooks[selector] = _hooks
            return ReplacedMethod(self, hook: hook)
        }
    
    /// Replace an `@objc dynamic` class method via selector on the object.
    @discardableResult
    public static func replaceMethod<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws -> ReplacedMethod {
            let hook = try Interpose.ClassHook(class: self as AnyClass,
                                               selector: selector, implementation: implementation).apply()
            var _hooks = hooks[selector] ?? []
            _hooks.append(hook)
            hooks[selector] = _hooks
            return ReplacedMethod(self, hook: hook)
        }
    
    /// Resets an replaced instance method on the current object to it's original state.
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
    
    /// Resets all replaced instance methods on the current object to their original state.
    public func resetAllMethods() {
        for selector in hooks.keys {
            resetMethod(selector)
        }
    }
    
    /// A Boolean value indicating whether the instance method for the specified selector is replaced.
    public func isMethodReplaced(_ selector: Selector) -> Bool {
        (hooks[selector] ?? []).isEmpty == false
    }
    
    /// Resets an replaced class method on the object to it's original state.
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
    
    /// Resets all replaced class methods on the current object to their original state.
    public static func resetAllMethods() {
        for selector in hooks.keys {
            resetMethod(selector)
        }
    }
    
    /// A Boolean value indicating whether the class method for the selector is replaced.
    public static func isMethodReplaced(_ selector: Selector) -> Bool {
        (hooks[selector] ?? []).isEmpty == false
    }
    
    var hooks: [Selector: [AnyHook]] {
        get { getAssociatedValue(key: "_hooks", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "_hooks", object: self) }
    }
    
    static var hooks: [Selector: [AnyHook]] {
        get { getAssociatedValue(key: "_hooks", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "_hooks", object: self) }
    }
}

