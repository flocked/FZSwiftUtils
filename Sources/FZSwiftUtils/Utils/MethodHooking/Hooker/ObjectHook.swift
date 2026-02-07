//
//  ObjectHook.swift
//  
//
//  Created by Florian Zand on 05.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

/// Hooks methods of an object.
struct ObjectHook<T: AnyObject> {
    let object: T
    var shouldApply = true
    
    public init(_ object: T) {
        self.object = object
    }
    
    init(_ object: T, _ shouldApply: Bool) {
        self.object = object
        self.shouldApply = shouldApply
    }
    
    /**
     Returns the hooks without applying them.
     
     To apply the hooks, use the tokens ``Hook/apply()``.
     */
    public var prepare: Self {
        .init(object, false)
    }
    
    
    // MARK: - empty closure
    
    // before
    /**
     Execute the closure before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     try! ObjectHook(object).hookBefore(#selector(MyObject.sum(_:_:)) {
        print("hooked")
     
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookBefore(.string(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     try! ObjectHook(object).hookBefore(#selector(MyObject.sum(_:_:))) { obj, sel in
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Hook {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Hook {
        try hookBefore(.string(selector), closure: closure)
    }
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     try! ObjectHook(object).hookBefore(#selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class.
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Object(object, selector: selector, mode: .before, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    @discardableResult
    public func hookBefore(_ selector: String, closure: Any) throws -> Hook {
        try hookBefore(.string(selector), closure: closure)
    }
    
    /**
     Execute the closure after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     try! ObjectHook(object).hookAfter(#selector(MyObject.sum(_:_:))) {
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookAfter(.string(selector), closure: closure)
    }
    
    // MARK: - self and selector closure
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     try! ObjectHook(object).hookAfter(#selector(MyObject.sum(_:_:))) { obj, sel in
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Hook {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Hook {
        try hookAfter(.string(selector), closure: closure)
    }
    
    // MARK: - custom closure
    
    
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     try! ObjectHook(object).hookAfter(#selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class.
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Object(object, selector: selector, mode: .after, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    @discardableResult
    public func hookAfter(_ selector: String, closure: Any) throws -> Hook {
        try hookAfter(.string(selector), closure: closure)
    }
    
    /**
     Replace the implementation of object's method by the closure.
     
     Example usage:

     ```
     class MyObject {
        @objc func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     try! ObjectHook(object).hook(#selector(MyObject.sum(_:_:)), closure: { original, obj, sel, number1, numebr2 in
        return original(obj, sel, number1, numebr2) * 2
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int )
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain `AnyObject` and `Selector` at the beginning).
        2. The second parameter has to be `AnyObject` or your class (When it's your class.
        3. The third parameter has to be `Selector`.
        4. The rest parameters are the same as the method's.
        5. The return type has to be the same as the original method's.
        6. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hook(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Object(object, selector: selector, mode: .instead, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    @discardableResult
    public func hook(_ selector: String, closure: Any) throws -> Hook {
        try hook(.string(selector), closure: closure)
    }
    
    // MARK: after deinit
    
    /**
     Execute the closure after the object deinit.
     
     Example usage:

     ```
     try! ObjectHook(object).hookDeinitAfter {
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    public func hookDeinitAfter(closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try Hook.Deinit(object, hookClosure: closure as AnyObject).apply(shouldApply)
    }
}

extension ObjectHook where T: NSObject {
    /**
     Execute the closure with the object before the object deinit.
     
     Example usage:

     ```
     try! ObjectHook(object).hookDeinitBefore { obj in
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - Note: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released.
     */
    @discardableResult
    func hookDeinitBefore(closure: @escaping (_ object: T) -> Void) throws -> Hook {
        let closure = { obj in
            guard let obj = obj as? T else { fatalError() }
            closure(obj)
        } as @convention(block) (NSObject) -> Void
        return try Hook.Object(object, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    
    // MARK: before deinit
    /**
     Execute the closure before the object deinit.
     
     Example usage:

     ```
     try! ObjectHook(object).hookDeinitBefore {
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinitBefore(closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try Hook.Object(object, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    // MARK: replace deinit
    
    /**
     Replace the implementation of object's deinit method by the closure.
     
     Example usage:

     ```
     try! ObjectHook(object).hookDeinit { original in
        print("before release of object")
        original()
        print("after release of object")
     }
     ```
     
     - Parameter closure: The hook closure with the original dealloc method as parameter. You have to call it to avoid memory leak.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinit(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> Hook {
        try Hook.Object(object, selector: .dealloc, mode: .instead, hookClosure: closure as AnyObject).apply(shouldApply)
    }
}

extension ObjectHook {
    @discardableResult
    func hookBefore<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook {
        try hookAfter(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook {
        try hookAfter(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ original: Value)->(Value)) throws -> Hook {
        try hook(try keyPath.getterName(), closure: { original, obj, sel in
            if let value = original(obj, sel) as? Value, let obj = obj as? T {
                return closure(obj, value)
            }
            return original(obj, sel)
        } as @convention(block) ((AnyObject, Selector) -> Any,
                                 AnyObject, Selector) -> Any)
    }
    
    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value, _ original: (Value)->())->()) throws -> Hook {
        try hook(try keyPath.setterName(), closure: { original, obj, sel, val in
            if let val = val as? Value, let ob = obj as? T {
                let original: (Value)->() = { original(obj, sel, $0) }
                closure(ob, val, original)
            } else {
                original(obj, sel, val)
            }
        } as @convention(block) ((AnyObject, Selector, Any) -> Void,
                                 AnyObject, Selector,  Any) -> Void)
    }
}

extension ObjectHook {
    func revertHooks(for selector: Selector, type: HookMode? = nil) {
        var objectHook = self
        if let type = type {
            objectHook.hooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            objectHook.hooks[selector, default: [:]][type] = []
        } else {
            objectHook.hooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            objectHook.hooks[selector] = [:]
        }
    }
    
    func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: .string(selector), type: type)
    }
    
    func revertAllHooks() {
        hooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    var allHooks: [Hook] {
        var hooks: [Hook] = []
        for val in self.hooks.values {
            hooks += val.flatMap({$0.value})
        }
        return hooks
    }
    
    func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return hooks[selector]?[type]?.isEmpty == false
        }
        return hooks[selector]?.isEmpty == false
    }
    
    func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isMethodHooked(.string(selector), type: type)
    }
    
    func addHook(_ token: Hook) {
        var objectHook = self
        objectHook.hooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    func removeHook(_ token: Hook) {
        var objectHook = self
        objectHook.hooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private var hooks: [Selector: [HookMode: Set<Hook>]] {
        get { getAssociatedValue("hooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "hooks") }
    }
    
    var addedMethods: Set<Selector> {
        get { getAssociatedValue("addedMethods") ?? [] }
        set {
            setAssociatedValue(newValue, key: "addedMethods")
            guard let object = object as? NSObject else { return }
            if newValue.count == 1 {
                do {
                    try object.hook(#selector(NSObject.responds(to:)), closure: {
                        original, object, sel, selector in
                        if let selector = selector, let object = object as? T, ObjectHook(object).addedMethods.contains(selector) {
                            return true
                        }
                        return original(object, sel, selector)
                    } as @convention(block) (
                        (NSObject, Selector, Selector?) -> Bool,
                        NSObject, Selector, Selector?) -> Bool)
                } catch {
                    Swift.print(error)
                }
            } else if newValue.isEmpty {
                revertHooks(for: #selector(NSObject.responds(to:)))
            }
        }
    }
    
    func setAssociatedValue<V>(_ value: V?, key: String) {
        FZSwiftUtils.setAssociatedValue(value, key: key, object: object)
    }
    
    func getAssociatedValue<V>(_ key: String) -> V? {
        FZSwiftUtils.getAssociatedValue(key, object: object)
    }
    
    func getAssociatedValue<V>(_ key: String, initialValue: @autoclosure () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, object: object, initialValue: initialValue)
    }
    
    func getAssociatedValue<V>(_ key: String, initialValue: () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, object: object, initialValue: initialValue)
    }
    
    var hookClosures: HookClosures {
        get { getAssociatedValue("hookClosures", initialValue: .init()) }
        set { setAssociatedValue(newValue, key: "hookClosures") }
    }
    
    class HookClosures {
        var closures: [Selector: [HookMode : [ObjectIdentifier: AnyObject]]]  = [:]
                
        var isEmpty: Bool {
            closures.values.allSatisfy { $0.values.allSatisfy(\.isEmpty) }
        }
        
        subscript(selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
            let values = closures[selector, default: [:]]
            return (Array(values[.before, default: [:]].values), Array(values[.after, default: [:]].values), Array(values[.instead, default: [:]].values))
        }
        
        func append(_ hookClosure: AnyObject, selector: Selector, mode: HookMode) throws {
            guard closures[selector, default: [:]][mode]?.updateValue(hookClosure, forKey: .init(hookClosure)) == nil else {
                throw HookError.duplicateHookClosure
            }
        }
        
        func remove(_ hookClosure: AnyObject, selector: Selector, mode: HookMode) throws {
            guard closures[selector, default: [:]][mode]?.removeValue(forKey: .init(hookClosure)) != nil else {
                throw HookError.duplicateHookClosure
            }
        }
    }
}
#endif
