//
//  NSObject+Hook.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

public extension NSObject {
    
    // MARK: - empty closure

    // before
    /**
     Execute the closure before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookBefore(#selector(MyObject.sum(with:number2:))) {
        print("hooked before")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    // after
    /**
     Execute the closure after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookAfter(#selector(MyObject.sum(with:number2:))) {
        print("hooked after")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure as Any)
    }

    // MARK: - custom closure

    // before
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookBefore(#selector(MyObject.sum(with:number2:))) { object, selector, num1, num2 in
         print("hooked before sum with \(n1), \(n2)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `(Self, Selector, ...)`. Return type: `Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }

    // after
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookAfter(#selector(MyObject.sum(with:number2:))) { object, selector, num1, num2 in
     print("hooked after sum with \(n1), \(n2)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `(Self, Selector, ...)`. Return type: `Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }

    // instead
    /**
     Replace the implementation of object's method by the closure.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         @objc func sum(of number1: Int, and number2: Int) -> Int { return number1 + number2 }
     }
     
     try MyObject().hook(#selector(MyObject.sum(of:and:))) { original, obj, sel, n1, n2 in
         print("instead of sum")
         return original(obj, sel, n1, n2) * 2
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int
     
     // returns 6
     MyObject().sum(of: 1, and: 2)
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `((Self, Selector, ...) -> ReturnType, Self, Selector, ...) -> ReturnType`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hook(_ selector: Selector, closure: Any) throws -> HookToken {
        try ObjectHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    func hook(_ selector: String, closure: Any) throws -> HookToken {
        try ObjectHook(self).hook(selector, closure: closure)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookBefore(#selector(MyObject.sum(with:number2:))) { obj, sel in
         print("before sum of \(obj)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookAfter(#selector(MyObject.sum(with:number2:))) { obj, sel in
         print("after sum of \(obj)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object before the object dealloc.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDeallocBefore { obj in
        print("before dealloc of \(obj)")
     }
     ```
     - parameter closureObj: The hook closure. Parameter: `(Self) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles. Do not capture strong references to the object.
     */
    @discardableResult
    func hookDeallocBefore(_ closure: @escaping (Self) -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocBefore(closure: closure)
    }
}

public extension NSObject {
    // MARK: before deinit
    
    /**
     Execute the closure before the object dealloc.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDeallocBefore {
        print("before dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookDeallocBefore(closure: @escaping () -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocBefore(closure: closure)
    }

    // MARK: after deinit
    
    /**
     Execute the closure after the object dealloc.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDeallocAfter {
        print("after dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookDeallocAfter(closure: @escaping () -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocAfter(closure: closure)
    }

    // MARK: replace deinit

    /**
     Replace the implementation of object's dealloc method by the closure.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDealloc { original in
         print("instead of dealloc")
         original()
     }
     ```
     - parameter closure: The hook closure. Parameter: `(() -> Void) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles. Call `original()` to prevent memory leaks.
     */
    @discardableResult
    func hookDealloc(closure: @escaping (_ original: () -> Void) -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocInstead(closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value of the property to be get.

     Example usage:
     ```swift
     try textfield.hookBefore(\.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookBefore(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value of the property to be set.

     Example usage:
     ```swift
     try textfield.hookBefore(set \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookBefore(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks after getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is read. It receives:
         - `object`: The object.
         - `value`: The current value of the property.

     Example usage:
     ```swift
     try textfield.hookAfter(\.stringValue) { textfield, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookAfter(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try textfield.hookAfter(set \.stringValue) { textfield, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookAfter(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance on which the property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try textfield.hook(\.stringValue) { object, original in
        return original.uppercased()
     }
     ```
     */
    @discardableResult
    public func hook<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> HookToken {
        try hook(try keyPath.getterName(), closure: { original, obj, sel in
            if let value = original(obj, sel) as? Value, let obj = obj as? Self {
                return closure(obj, value)
            }
            return original(obj, sel)
        } as @convention(block) ((AnyObject, Selector) -> Any,
                                 AnyObject, Selector) -> Any)
    }
    
    /**
     Hooks setting the specified property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - `original`: A block that invokes the original setter behavior. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try textfield.hook(set \.stringValue) { textfield, stringValue, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, handler: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> HookToken {
        try hook(try keyPath.setterName(), closure: { original, obj, sel, val in
            if let val = val as? Value, let ob = obj as? Self {
                let original: (Value)->() = { original(obj, sel, $0) }
                handler(ob, val, original)
            } else {
                original(obj, sel, val)
            }
        } as @convention(block) ((AnyObject, Selector, Any) -> Void,
                                 AnyObject, Selector,  Any) -> Void)
    }
}
#endif
