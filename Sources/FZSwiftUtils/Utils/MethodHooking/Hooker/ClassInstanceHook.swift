//
//  ClassInstanceHook.swift
//  
//
//  Created by Florian Zand on 05.05.25.
//

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
     
     To apply the hooks, use the tokens ``Hook/apply()``.
     */
    public var prepare: Self {
        .init(targetClass, false)
    }
    
    // MARK: - Hook Before

    /**
     Execute the closure before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
          
     try! ClassInstanceHook(MyObject.self).hookBefore(#selector(MyObject.sum(_:_:)) {
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)) { obj, sel in
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```
     
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
    public func hookBefore(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject, isInstance: true).apply(shouldApply)
    }
    
    @discardableResult
    public func hookBefore(_ selector: String, closure: Any) throws -> Hook {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    // MARK: - Hook After
    
    /**
     Execute the closure after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)) {
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
        
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)) { obj, sel in
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
        
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked", number1, number2)
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```
     
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
    public func hookAfter(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject, isInstance: true).apply(shouldApply)
    }
    
    @discardableResult
    public func hookAfter(_ selector: String, closure: Any) throws -> Hook {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
    
    // MARK: - Hook
    
    /**
     Replace the implementation of object's method by the closure.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hook(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { original, obj, sel, number1, numebr2 in
        return original(obj, sel, number1, numebr2) * 2
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int )
     ```
     
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
    public func hook(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject, isInstance: true).apply(shouldApply)
    }
    
    @discardableResult
    public func hook(_ selector: String, closure: Any) throws -> Hook {
        try hook(NSSelectorFromString(selector), closure: closure)
    }
}

// MARK: Hook Dealloc
extension ClassInstanceHook where T: NSObject {
    
    /**
     Execute the closure before the object deinit.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDeinitBefore {
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinitBefore(closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try Hook.Class(targetClass, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject, isInstance: true).apply(shouldApply)
    }
    
    /**
     Execute the closure with the object before the object deinit.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDeinitBefore { object in
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinitBefore(closure: @escaping (_ object: T) -> Void) throws -> Hook {
        let closure = { obj in
            guard let obj = obj as? T else { fatalError() }
            closure(obj)
        } as @convention(block) (NSObject) -> Void
        return try Hook.Class(targetClass, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject, isInstance: true).apply(shouldApply)
    }
        
    /**
     Execute the closure after the object deinit.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDeinitAfter {
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinitAfter(closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try Hook.Class(targetClass, selector: .dealloc, mode: .after, hookClosure: closure as AnyObject, isInstance: true).apply(shouldApply)
    }
        
    /**
     Replace the implementation of object's deinit method by the closure.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDeinit { original in
        print("before release")
        original()
        print("after release")
     }
     ```
     
     - Parameter closure: The hook closure with the original dealloc method as parameter. You have to call it to avoid memory leak.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinit(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> Hook {
        try Hook.Class(targetClass, selector: .dealloc, mode: .instead, hookClosure: closure as AnyObject, isInstance: true).apply(shouldApply)
    }
}

// MARK: - Hook Property

extension ClassInstanceHook where T: NSObject {
    @discardableResult
    func hookBefore<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Hook {
        try hookAfter(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Hook {
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

