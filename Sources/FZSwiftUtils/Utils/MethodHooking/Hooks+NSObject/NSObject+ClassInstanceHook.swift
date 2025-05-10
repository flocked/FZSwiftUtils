//
//  NSObject+ClassInstanceHook.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

public extension NSObject {
    
    
    /**
     Execute the closure before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookInstancesBefore(#selector(MyObject.sum(with:number2:))) {
         print("hooked before sum")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookInstancesBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookInstancesBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookInstancesBefore(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookInstancesBefore(NSSelectorFromString(selector), closure: closure as Any)
    }
    
    /**
     Execute the closure after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookInstancesAfter(#selector(MyObject.sum(with:number2:))) {
         print("hooked after sum")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookInstancesAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookInstancesAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookInstancesAfter(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookInstancesAfter(NSSelectorFromString(selector), closure: closure as Any)
    }
    
    // MARK: - custom closure
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookInstancesBefore(#selector(MyObject.sum(with:number2:))) { (obj: MyObject, sel: Selector, number1: Int, number2: Int) in
         print("hooked before sum with \(number1) and \(number2)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `Self` or `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookInstancesBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    class func hookInstancesBefore(_ selector: String, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookInstancesAfter(#selector(MyObject.sum(with:number2:))) { (obj: MyObject, sel: Selector, number1: Int, number2: Int) in
         print("hooked after sum with \(number1) and \(number2)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `Self` or `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookInstancesAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    class func hookInstancesAfter(_ selector: String, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Replace the implementation of object's method by the closure.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
        @objc func sum(of number1: Int, and number2: Int) -> Int {
            return number1 + number2
        }
     }
          
     try! MyObject.hookInstances(#selector(MyObject.sum(of:and:)), closure: {
        original, object, selector, number1, number2 in
        let originalValue = original(object, selector, number1, number2)
        return originalValue * 2
     } as @convention(block) (
         (MyObject, Selector, Int, Int) -> Int,
        MyObject, Selector, Int, Int) -> Int)
     
     MyObject().sum(of: 1, and: 2) // Returns 6
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be a closure. This closure represents the original method. Its parameters and return type are the same as the original method's (The parameters contain `Self` and `Selector` at the beginning).
         2. The second parameter has to be `Self` or `NSObject`.
         3. The third parameter has to be `Selector`.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookInstances(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    class func hookInstances(_ selector: String, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hook(selector, closure: closure)
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
     
     try MyObject.hookInstancesBefore(#selector(MyObject.sum(with:number2:))) { object, selector in
         print("hooked \(object) before sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookInstancesBefore(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    static func hookInstancesBefore(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookInstancesBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookInstancesAfter(#selector(MyObject.sum(with:number2:))) { object, selector in
         print("hooked \(object) after sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookInstancesAfter(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    static func hookInstancesAfter(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookInstancesAfter(NSSelectorFromString(selector), closure: closure)
    }
}

public extension NSObject {
    // MARK: before deinit
    /**
     Execute the closure before the object dealloc.
     
     Example:
     
     ```swift
     NSTextField.hookInstancesDeallocBefore {
         print("hooked before dealloc of NSTextField")
     }
     ```
     
     - Parameter closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookInstancesDeallocBefore(closure: @escaping () -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocBefore(closure: closure)
    }
    
    /**
     Execute the closure with the object before the object dealloc.
     
     ```swift
     NSTextField.hookInstancesDeallocBefore { object in
         print("hooked before dealloc of \(object)")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released.
     */
    @discardableResult
    class func hookInstancesDeallocBefore(closure: @escaping (_ object: NSObject) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocBefore(closure: closure)
    }
    
    // MARK: after deinit
    /**
     Execute the closure after the object dealloc.
     
     Example usage:
     
     ```swift
     NSTextField.hookInstancesDeallocAfter {
         print("hooked after dealloc of NSTextField")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookInstancesDeallocAfter(closure: @escaping () -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocAfter(closure: closure)
    }
    
    // MARK: replace deinit
    /**
     Replace the implementation of object's dealloc method by the closure.
     
     Example usage:
     
     ```swift
     NSTextField.hookInstancesDealloc { (original: @escaping () -> Void) in
         print("before release of NSTextField")
         original()
         print("after release of NSTextField")
     }
     ```
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: You have to call `original()` to avoid memory leak.
     */
    @discardableResult
    class func hookInstancesDealloc(closure: @escaping (_ original: () -> Void) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocInstead(closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value of the property to be get.

     Example usage:
     ```swift
     try NSTextField.hookInstancesBefore(\.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookInstancesBefore<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookInstancesBefore(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value of the property to be set.

     Example usage:
     ```swift
     try NSTextField.hookInstancesBefore(set \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookInstancesBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookInstancesBefore(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks after getting the specified property for all instances of the class.
     
     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is read. It receives:
         - `object`: The object.
         - `value`: The current value of the property.

     Example usage:
     ```swift
     try NSTextField.hookInstancesAfter(\.stringValue) { textfield, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookInstancesAfter<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookInstancesAfter(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.
     
     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try NSTextField.hookInstancesAfter(set \.stringValue) { textfield, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookInstancesAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> HookToken {
        try hookInstancesAfter(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? Self else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    /**
     Hooks getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance on which the property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try NSTextField.hookInstances(\.stringValue) { object, original in
        return original.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hookInstances<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> HookToken {
        try hookInstances(try keyPath.getterName(), closure: { original, obj, sel in
            if let value = original(obj, sel) as? Value, let obj = obj as? Self {
                return closure(obj, value)
            }
            return original(obj, sel)
        } as @convention(block) ((AnyObject, Selector) -> Any,
                                 AnyObject, Selector) -> Any)
    }
    
    /**
     Hooks setting the specified property for all instances of the class.
     
     - Parameters:
        - keyPath: The key path to the writable property to hook.
       - closure: The handler that is invoked whenever the property is set. It receives:
         - `object`: The instance on which the property is being set.
         - `value`: The new value that is about to be written to the property.
         - `original`: A block that invokes the original setter behavior. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try NSTextField.hookInstances(set \.stringValue) { textfield, stringValue, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public static func hookInstances<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> HookToken {
        try hookInstances(try keyPath.setterName(), closure: { original, obj, sel, val in
            if let val = val as? Value, let ob = obj as? Self {
                let original: (Value)->() = { original(obj, sel, $0) }
                closure(ob, val, original)
            } else {
                original(obj, sel, val)
            }
        } as @convention(block) ((AnyObject, Selector, Any) -> Void,
                                 AnyObject, Selector,  Any) -> Void)
    }
}

#endif
