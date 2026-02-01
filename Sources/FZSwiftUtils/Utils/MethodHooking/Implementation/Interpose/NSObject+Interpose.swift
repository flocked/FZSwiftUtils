//
//  NSObject+Interpose.swift
//
//
//  Created by Florian Zand on 11.05.25.
//

#if os(tvOS) || os(watchOS)
import Foundation

extension NSObject {
    /**
     Replace an `@objc dynamic` instance method of the current object.
          
     Example usage that replaces the `mouseDown` method of a view:
     
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
        debugPrint(error)
     }
     ```
     
     To reset the replaced method, use `resetMethod(_:)` with the selector or set tokens `isActive` to false.
          
     - Returns: The token for resetting the replaced method.
     */
    @discardableResult
    public func hook<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws -> Hook {
            let token = Hook(try Interpose.ObjectHook(object: self, selector: selector, implementation: implementation), self)
            try token.apply()
            return token
    }
    
    /**
     Replace an `@objc dynamic` class method of the current class.
     
     To reset the replaced method, use `resetMethod(_:)` with the selector or set tokens `isActive` to false.

     - Returns: The token for resetting the replaced method.
     */
    @discardableResult
    public class func hook<MethodSignature, HookSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws -> Hook {
            let token =  Hook(try Interpose.ClassHook(class: self as AnyClass, selector: selector, implementation: implementation), self)
            try token.apply()
            return token
    }
    
    /// A Boolean value indicating whether the instance method for the specified selector is replaced.
    public func isMethodHooked(_ selector: Selector) -> Bool {
        !hooks[selector, default: []].isEmpty
    }
    
    /// Resets an replaced instance method of the object to it's original state.
    public func revertHooks(for selector: Selector) {
        let all = hooks[selector] ?? []
        for hook in all {
            do {
                _ = try hook.revert()
                hooks[selector, default: []].remove(hook)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    /// Resets all replaced instance methods on the current object to their original state.
    public func resetAllHooks() {
        hooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    /// A Boolean value indicating whether the class method for the selector is replaced.
    public static func isMethodHooked(_ selector: Selector) -> Bool {
        !hooks[selector, default: []].isEmpty
    }
    
    /// Resets an replaced class method of the class to it's original state.
    public static func revertHooks(for selector: Selector) {
        for hook in hooks[selector] ?? [] {
            do {
                _ = try hook.revert()
            } catch {
                debugPrint(error)
            }
        }
        hooks[selector] = nil
    }
    
    /// Resets all replaced class methods of the class to their original state.
    public static func revertAllHooks() {
        hooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    var hooks: [Selector: Set<AnyHook>] {
        get { getAssociatedValue("_hooks", initialValue: [:]) }
        set { setAssociatedValue(newValue, key: "_hooks") }
    }
    
    static var hooks: [Selector: Set<AnyHook>] {
        get { getAssociatedValue("_hooks", initialValue: [:]) }
        set { setAssociatedValue(newValue, key: "_hooks") }
    }
}

///  A token for hooking a method.
public class Hook {
    
    /// The selector of the hooked method.
    public let selector: Selector
    
    /// The class of the hooked method.
    public let `class`: AnyClass
    
    /// A Boolean value indicating whether the hook should revert, restoring the original method implementation.
    public var revertOnDeinit: Bool = false
    
    /// Sets Boolean value indicating whether the hook should revert, restoring the original method implementation.
    @discardableResult
    public func revertOnDeinit(_ revert: Bool) -> Self {
        revertOnDeinit = revert
        return self
    }
            
    /// A Boolean value indicating whether the hook is active.
    public var isActive: Bool {
        get { hook?.state == .interposed }
        set { newValue ? try? apply() : try? revert()  }
    }
    
    /// Applies the hook.
    public func apply() throws {
        guard !isActive, let hook = hook else { return }
        try hook.apply()
        object?.hooks[selector, default: []].insert(hook)
        _class?.hooks[selector, default: []].insert(hook)
    }
    
    /// Reverts the hook.
    public func revert() throws {
        guard isActive, let hook = hook else { return }
        try hook.revert()
        object?.hooks[selector, default: []].remove(hook)
        _class?.hooks[selector, default: []].remove(hook)
    }
    
    func apply(_ shouldApply: Bool) throws -> Hook {
        try apply()
        return self
    }
    
    weak var hook: AnyHook?
    weak var object: NSObject?
    var _class: NSObject.Type?
    
    init(_ hook: AnyHook, _ object: NSObject) {
        self.selector = hook.selector
        self.hook = hook
        self.object = object
        self.class = hook.class
    }
    
    init(_ hook: AnyHook, _ classType: NSObject.Type) {
        self.selector = hook.selector
        self.hook = hook
        self._class = classType
        self.class = hook.class
    }
    
    init(addMethod object: NSObject, selector: Selector, hookClosure: AnyObject) throws {
        self.hook = try AddMethodHook(object: object, selector: selector, hookClosure: hookClosure)
        self.object = object
        self.class = Swift.type(of: object)
        self.selector = selector
    }
    
    #if os(macOS) || os(iOS)
    init<T: NSObject>(addMethod class_: T.Type, selector: Selector, hookClosure: AnyObject) throws {
        self.hook = try AddInstanceMethodHook(class_: class_, selector: selector, hookClosure: hookClosure)
        self.class = class_
        self.selector = selector
    }
    #endif
    
    deinit {
        guard revertOnDeinit else { return }
        try? revert()
    }
}
#endif
