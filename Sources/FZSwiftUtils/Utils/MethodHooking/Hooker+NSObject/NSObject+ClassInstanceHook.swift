//
//  NSObject+ClassInstanceHook.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

import Foundation

public extension NSObject {
    /**
     Hooks before the specified method of all instances of the class.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(all: #selector(MyObject.sum(of:and:)), closure: {
        print("hooked before sum")
     } as @convention(block) (MyObject, Selector, Int, Int) -> Void)
     ```

     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookBefore(all selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(all: selector, closure: closure as Any)
    }
    
    /**
     Hooks before the specified method of all instances of the class.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(all: #selector(MyObject.sum(of:and:)), closure: {
        object, selector, number1, number2 in
        print("hooked before sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure as: `@convention(block) (Self, Selector, Arguments...) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookBefore(all selector: Selector, closure: Any) throws -> Hook {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Hooks after the specified method of all instances of the class.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(all: #selector(MyObject.sum(of:and:)), closure: {
        print("hooked after sum")
     } as @convention(block) (MyObject, Selector, Int, Int) -> Void)
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookAfter(all selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(all: selector, closure: closure as Any)
    }
    
    // MARK: - custom closure
    
    /**
     Hooks after the specified method of all instances of the class.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(all: #selector(MyObject.sum(of:and:)), closure: {
        object, selector, number1, number2 in
        print("hooked before sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure as: `@convention(block) (Self, Selector, Arguments...) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookAfter(all selector: Selector, closure: Any) throws -> Hook {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Replaces the specified method for all instances of the class.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
        @objc func sum(of number1: Int, and number2: Int) -> Int {
            return number1 + number2
        }
     }
          
     try! MyObject.hook(all: #selector(MyObject.sum(of:and:)), closure: {
        original, object, selector, number1, number2 in
        let value = original(object, selector, number1, number2)
        return value * 2
     } as @convention(block) (
     (MyObject, Selector, Int, Int) -> Int,
     MyObject, Selector, Int, Int) -> Int)
     
     MyObject().sum(of: 1, and: 2) // Returns 6
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure as O
         1. The first parameter has to be a closure. This closure represents the original method. Its parameters and return type are the same as the original method's (The parameters contain `Self` and `Selector` at the beginning).
         2. The second parameter has to be `Self`/`AnyObject`.
         3. The third parameter has to be `Selector`.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hook(all selector: Selector, closure: Any) throws -> Hook {
        try ClassInstanceHook(self).hook(selector, closure: closure)
    }

    /**
     Adds an unimplemented optional protocol instance method to all instances of the class.
     
     Example usage:
     
     ```swift
     @objc protocol PingProtocol: NSObjectProtocol {
         @objc optional func didPing(_ value: Int)
     }
     
     class MyObject: NSObject, PingProtocol { }
     
     let token = try MyObject.addMethod(all: #selector(PingProtocol.didPing(_:)), closure: {
         object, value in
         print("didPing:", object, value)
     } as @convention(block) (MyObject, Int) -> Void)
     ```
     
     - Note: The selector must be an optional protocol requirement adopted by the class hierarchy.
     */
    @discardableResult
    class func addMethod(all selector: Selector, closure: Any) throws -> Hook {
        try Hook.AddClassMethod(self, selector: selector, hookClosure: closure as AnyObject, isInstanceMethod: true).apply(true)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(all: #selector(MyObject.sum(of:and:))) { object in
         print("hooked \(object) before sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    static func hookBefore(all selector: Selector, closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     ```swift
     class MyObject: NSObject {
         func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(all: #selector(MyObject.sum(of:and:))) { object in
         print("hooked \(object) after sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    static func hookAfter(all selector: Selector, closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object before the object DeInit.
     
     Example usage:
     
     ```swift
     MyObject.hookDeinitBefore { object in
         print("hooked before DeInit of \(object)")
     }
     ```
     
     - parameter closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released.
     */
    @discardableResult
    static func hookDeinitBefore(closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeinitBefore(closure: closure)
    }
}

public extension NSObject {
    // MARK: before deinit
    /**
     Execute the closure before the object DeInit.
     
     Example usage:
     
     ```swift
     MyObject.hookDeinitBefore {
         print("hooked before DeInit")
     }
     ```
     
     - Parameter closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookDeinitBefore(closure: @escaping () -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeinitBefore(closure: closure)
    }
    
    // MARK: after deinit
    /**
     Execute the closure after the object DeInit.
     
     Example usage:
     
     ```swift
     MyObject.hookDeinitAfter {
         print("hooked after DeInit")
     }
     ```
     
     - parameter closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookDeinitAfter(closure: @escaping () -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeinitAfter(closure: closure)
    }
    
    // MARK: replace deinit
    /**
     Replace the implementation of object's DeInit method by the closure.
     
     Example usage:
     
     ```swift
     MyObject.hookDeinit { original in
         print("before release of MyObject")
         original()
         print("after release of MyObject")
     }
     ```
     
     - Parameter closure: The hook closure with the original DeInit method as parameter. You have to call it to avoid memory leak.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookDeinit(closure: @escaping (_ original: () -> Void) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeinit(closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`:The instance whose property is being accessed.

     Example usage:
     ```swift
     try UILabel.hookBefore(all: \.text) { label in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self)->()) throws -> Hook {
        try hookBefore(all: .string(keyPath.getterName()), closure: closure)
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try UILabel.hookBefore(setAll: \.text) { label, text in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(all: .string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try UILabel.hookBefore(setAll: \.text) { label, text in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(all: .string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - closure: The handler that is invoked before the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `oldValue`: The current value of the property.
            - `newValue`: The new value to be set to the property.

     Example usage:
     ```swift
     try UILabel.hookBefore(set: \.text) { label, oldText newText in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hookBefore(all: .string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - closure: The handler that is invoked before the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `oldValue`: The current value of the property.
            - `newValue`: The new value to be set to the property.

     Example usage:
     ```swift
     try UILabel.hookBefore(set: \.text) { label, oldText newText in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(all: .string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try UILabel.hookBefore(setAll: \.text) { label, text in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(all: .string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try UILabel.hookBefore(setAll: \.text) { label, text in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hookBefore(all: .string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
        
    /**
     Hooks after getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is read. It receives:
         - `object`:The instance whose property is being accessed.

     Example usage:
     ```swift
     try UILabel.hookAfter(all: \.text) { label in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self)->()) throws -> Hook {
        try hookAfter(all: .string(keyPath.getterName()), closure: closure)
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try UILabel.hookAfter(setAll: \.text) { label, text in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(all: .string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try UILabel.hookAfter(setAll: \.text) { label, text in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookAfter(all: .string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try UILabel.hookAfter(setAll: \.text) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(all: .string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try UILabel.hookAfter(setAll: \.text) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(all: .string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`:The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try UILabel.hookAfter(setAll: \.text, uniqueValues: true) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(all: .string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try UILabel.hookAfter(setAll: \.text, uniqueValues: true) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hook(all: .string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance whose property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try UILabel.hook(all: \.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook {
        try hook(all: .string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }
    
    /**
     Hooks getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance whose property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try UILabel.hook(all: \.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(all: .string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - `setter`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try UILabel.hook(setAll: \.text) { label, text, setter in
        if text != "" {
            setter(text)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ setter: (Value)->())->()) throws -> Hook {
        return try hook(all: .string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - `setter`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try UILabel.hook(setAll: \.text) { label, text, setter in
        if text != "" {
            setter(text)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ setter: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        return try hook(all: .string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - Returns: The value to forward to the original setter.

     Example usage:
     ```swift
     try UILabel.hook(setAll: \.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value)->(Value)) throws -> Hook {
        try hook(setAll: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
    
    /**
     Hooks setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - Returns: The value to forward to the original setter.

     Example usage:
     ```swift
     try UILabel.hook(setAll: \.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(setAll: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
}
