//
//  ClassInstanceHook.swift
//  
//
//  Created by Florian Zand on 05.05.25.
//

#if os(macOS) || os(iOS)
import Foundation


/// Hooks methods of all instances of a class.
struct ClassInstanceHook<T: AnyObject> {
    let targetClass: AnyClass
    var shouldApply = true

    public init(_ targetClass: T.Type) {
        self.targetClass = targetClass
    }
    
    init(_ targetClass: AnyClass, _ shouldApply: Bool) {
        self.targetClass = targetClass
        self.shouldApply = shouldApply
    }
    
    /**
     Returns the hooks without applying them.
     
     To apply the hooks, use the tokens ``HookToken/apply()``.
     */
    public var prepare: Self {
        .init(targetClass, false)
    }
    
    // MARK: - empty closure
    
    // before
    /**
     Execute the closure before the execution of object's method.
     
     # Example
     ```
     class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
     return number1 + number2
     }
     }
     let token = try! hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: {
     print("hooked")
     })
     _ = MyObject().sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookBefore(selector, closure: closure as Any)
    }
    
    // after
    /**
     Execute the closure after the execution of object's method.
     
     # Example
     ```
     class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
     return number1 + number2
     }
     }
     let token = try! hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: {
     print("hooked")
     })
     _ = MyObject().sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookAfter(selector, closure: closure as Any)
    }
    
    // MARK: - self and selector closure
    
    // before
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     # Example
     ```
     class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
     return number1 + number2
     }
     }
     let token = try! hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel in
     print("hooked")
     })
     _ = MyObject().sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookBefore(selector, closure: closure as Any)
    }
    
    // after
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     # Example
     ```
     class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
     return number1 + number2
     }
     }
     let token = try! hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel in
     print("hooked")
     })
     _ = MyObject().sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookAfter(selector, closure: closure as Any)
    }
    
    // MARK: - custom closure
    
    // before
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     # Example
     ```
     class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
     return number1 + number2
     }
     }
     let token = try! hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
     print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     _ = MyObject().sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from `NSObject`.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be AnyObject or your class (When it's your class).
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try HookToken(for: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    // after
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     # Example
     ```
     class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
     return number1 + number2
     }
     }
     let token = try! hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
     print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     _ = MyObject().sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from `NSObject`.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class).
        2. The second parameter has to be Selector.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try HookToken(for: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    // instead
    /**
     Replace the implementation of object's method by the closure.
     
     # Example
     ```
     class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
     return number1 + number2
     }
     }
     let token = try! hook(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { original, obj, sel, number1, numebr2 in
     // You may call the original method with some different parameters. You can even not call the original method.
     return original(obj, sel, number1, numebr2)
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int )
     _ = MyObject().sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from `NSObject`.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning)..
        2. The second parameter has to be AnyObject or your class (When it's your class).
        3. The third parameter has to be `Selector`.
        4. The rest parameters are the same as the method's.
        5. The return type has to be the same as the original method's.
        6. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hook(_ selector: Selector, closure: Any) throws -> HookToken {
        try HookToken(for: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject).apply(shouldApply)
    }
}

extension ClassInstanceHook where T: NSObject {
    // MARK: before deinit
    
    /**
     Execute the closure before the object deinit.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     let token = try! hookDeallocBefore(targetClass: MyObject.self, closure: {
     print("hooked")
     })
     autoreleasepool {
     let object = MyObject()
     }
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookDeallocBefore(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try HookToken(for: targetClass, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    /**
     Execute the closure with the object before the object deinit.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     let token = try! hookDeallocBefore(targetClass: MyObject.self, closure: { obj in
     print("hooked")
     })
     autoreleasepool {
     let object = MyObject()
     }
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released.
     */
    @discardableResult
    func hookDeallocBefore(closure: @escaping (_ object: T) -> Void) throws -> HookToken {
        let closure = { obj in
            guard let obj = obj as? T else { fatalError() }
            closure(obj)
        } as @convention(block) (NSObject) -> Void
        return try HookToken(for: targetClass, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    // MARK: after deinit
    
    /**
     Execute the closure after the object deinit.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     let token = try! hookDeallocAfter(targetClass: MyObject.self, closure: {
     print("hooked")
     })
     autoreleasepool {
     let object = MyObject()
     }
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookDeallocAfter(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try HookToken(for: targetClass, selector: .dealloc, mode: .after, hookClosure: closure as AnyObject).apply(shouldApply)
    }
    
    // MARK: replace deinit
    
    /**
     Replace the implementation of object's deinit method by the closure.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     let token = try! hookDeallocInstead(targetClass: MyObject.self, closure: { original in
     print("before release")
     original()
     print("after release")
     })
     autoreleasepool {
     let object = MyObject()
     }
     token.cancelHook() // cancel hook
     ```
     - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure.
     
     - parameter original: The original dealloc method.
     
     **WARNING**: Have to call original to avoid memory leak.
     
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookDeallocInstead(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> HookToken {
        try HookToken(for: targetClass, selector: .dealloc, mode: .instead, hookClosure: closure as AnyObject).apply(shouldApply)
    }
}

extension ClassInstanceHook where T: NSObject {
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    func hookBefore(_ selector: String, closure: Any) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    func hookAfter(_ selector: String, closure: Any) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    func hook(_ selector: String, closure: Any) throws -> HookToken {
        try hook(NSSelectorFromString(selector), closure: closure)
    }
}

extension ClassInstanceHook where T: NSObject {
    @discardableResult
    func hookBefore<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> HookToken {
        try hookBefore(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> HookToken {
        try hookBefore(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> HookToken {
        try hookAfter(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> HookToken {
        try hookAfter(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ original: Value)->(Value)) throws -> HookToken {
        try hook(try keyPath.getterName(), closure: { original, obj, sel in
            if let value = original(obj, sel) as? Value, let obj = obj as? T {
                return closure(obj, value)
            }
            return original(obj, sel)
        } as @convention(block) ((AnyObject, Selector) -> Any,
                                 AnyObject, Selector) -> Any)
    }
    
    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value, _ original: (Value)->())->()) throws -> HookToken {
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

/*
extension ClassInstanceHook where T: NSObject {
    @discardableResult
    public func hookBefore(_ keyPath: PartialKeyPath<T>, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        guard let getterName = keyPath.getterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookBefore(getterName, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(set keyPath: PartialKeyPath<T>, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        guard let setterName = keyPath.setterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookBefore(setterName, closure: closure as Any)
    }
    
    @discardableResult
    public func hookAfter(_ keyPath: PartialKeyPath<T>, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        guard let getterName = keyPath.getterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookAfter(getterName, closure: closure as Any)
    }
    
    @discardableResult
    public func hookAfter(set keyPath: PartialKeyPath<T>, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        guard let setterName = keyPath.setterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookAfter(setterName, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ keyPath: PartialKeyPath<T>, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        guard let getterName = keyPath.getterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookBefore(getterName, closure: closure)
    }
    
    @discardableResult
    public func hookBefore(set keyPath: PartialKeyPath<T>, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        guard let setterName = keyPath.setterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookBefore(setterName, closure: closure)
    }
    
    @discardableResult
    public func hookAfter(_ keyPath: PartialKeyPath<T>, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        guard let getterName = keyPath.getterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookAfter(getterName, closure: closure)
    }
    
    @discardableResult
    public func hookAfter(set keyPath: PartialKeyPath<T>, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        guard let setterName = keyPath.setterName else {
            throw HookError.noKVOKeyPath
        }
        return try hookAfter(setterName, closure: closure)
    }
    
    @discardableResult
    public func hook(_ keyPath: PartialKeyPath<T>, closure: Any) throws -> HookToken {
        try hook(try keyPath.getterName(), closure: closure)
    }
    
    @discardableResult
    public func hook(set keyPath: PartialKeyPath<T>, closure: Any) throws -> HookToken {
        return try hook(try keyPath.setterName(), closure: closure)
    }
}
*/
#endif
