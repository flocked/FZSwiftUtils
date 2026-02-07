//
//  NSObject+ClassHook.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

public extension NSObject {
    /**
     Execute the closure before the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
        static func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
        }
     }
     
     try MyObject.hookBefore(#selector(MyObject.sum(of:and:)), closure: {
         print("hooked before class sum")
     } as @convention(block) (MyObject, Selector, Int, Int) -> Void)
     ```

     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookBefore(_ selector: String, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure after the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
        static func sum(of number1: Int, and number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(of:and:))) {
         print("hooked after class sum")
     }
     ```
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookAfter(_ selector: String, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }
    
    // MARK: - custom closure
    
    /**
     Execute the closure with all parameters before the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
        static func sum(of number1: Int, and number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try MyObject.hookBefore(#selector(MyObject.sum(of:and:)), closure: {
        object, selector, number1, number2 in
        print("hooked before class sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure as: `@convention(block) (Self, Selector, Arguments...) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookBefore(_ selector: Selector, closure: Any) throws -> Hook {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    class func hookBefore(_ selector: String, closure: Any) throws -> Hook {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with all parameters after the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(of:and:)), closure: {
     object, selector, number1, number2 in
        print("hooked after class sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure as: `@convention(block) (Self, Selector, Arguments...) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hookAfter(_ selector: Selector, closure: Any) throws -> Hook {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    class func hookAfter(_ selector: String, closure: Any) throws -> Hook {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Replace the implementation of class's method by the closure.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
        @objc class func sum(of number1: Int, and number2: Int) -> Int {
            return number1 + number2
        }
     }
          
     try! MyObject.hook(#selector(MyObject.sum(of:and:)), closure: {
        original, object, selector, number1, number2 in
        let originalValue = original(object, selector, number1, number2)
        return originalValue * 2
     } as @convention(block) (
         (AnyObject, Selector, Int, Int) -> Int,
         AnyObject, Selector, Int, Int) -> Int)
     
     MyObject.sum(of: 1, and: 2) // returns 6
     ```
     
     ```swift
     class MyObject: NSObject {
         class func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hook(#selector(MyObject.sum(of:and:))) { (original: @escaping (NSObject.Type, Selector, Int, Int) -> Int, obj: NSObject.Type, sel: Selector, number1: Int, number2: Int) -> Int in
         print("hooked instead of class sum")
         return original(obj, sel, number1, number2) * 3
     }
     
     MyObject.sum(of: 1, and: 2) // Returns 6
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be a closure. This closure represents the original method. Its parameters and return type are the same as the original method's (The parameters contain `Self.Type` and `Selector` at the beginning).
         2. The second parameter has to be `NSObject.Type`.
         3. The third parameter has to be `Selector`.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    class func hook(_ selector: Selector, closure: Any) throws -> Hook {
        try ClassHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    class func hook(_ selector: String, closure: Any) throws -> Hook {
        try ClassHook(self).hook(selector, closure: closure)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the class and the selector before the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(#selector(MyObject.sum(with:number2:))) { cls, sel in
         print("hooked before class sum on \(cls)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    static func hookBefore(_ selector: Selector, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    static func hookBefore(_ selector: String, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with the class and the selector after the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(with:number2:)), closure: { cls, sel in
         print("hooked after class sum on \(cls)")
     } as @convention(block) (MyObject, Selector, Int, Int) -> Void)
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     */
    @discardableResult
    static func hookAfter(_ selector: Selector, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    static func hookAfter(_ selector: String, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `class`: The class whose property is being accessed.

     Example usage:
     ```swift
     try MyObject.hookBefore(\.classProperty) { cls in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(_ keyPath: KeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type)->()) throws -> Hook {
        try hookBefore(keyPath.getterName()) { cls,_ in closure(cls) }
    }
    
    /**
     Hooks before setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `class`: The class whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: KeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type,_ value: Value)->()) throws -> Hook {
        try hookBefore(keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `class`: The class whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: KeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - closure: The handler that is invoked before the property is set. It receives:
            - `class`: The class whose property is being set.
            - `oldValue`: The current value of the property.
            - `newValue`: The new value to be set to the property.

     Example usage:
     ```swift
     try label.hookBefore(set: \.text) { label, oldText newText in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hookBefore(keyPath.setterName(), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    /**
     Hooks before setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - closure: The handler that is invoked before the property is set. It receives:
            - `class`: The class whose property is being set.
            - `oldValue`: The current value of the property.
            - `newValue`: The new value to be set to the property.

     Example usage:
     ```swift
     try label.hookBefore(set: \.text) { label, oldText newText in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(keyPath.setterName(), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    /**
     Hooks before setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `class`: The class whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: Self.Type,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(keyPath.setterName(), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks before setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `class`: The class whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: Self.Type,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        try hookBefore(keyPath.setterName(), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks after getting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is read. It receives:
         - `class`: The class whose property is being accessed.

     Example usage:
     ```swift
     try MyObject.hookAfter(\.classProperty) { cls in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(_ keyPath: KeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type)->()) throws -> Hook {
        try hookAfter(keyPath.getterName()) { cls,_ in closure(cls) }
    }
    
    /**
     Hooks after setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `class`: The class whose property is being set.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type,_ value: Value)->()) throws -> Hook {
        try hookAfter(keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks after setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `class`: The class whose property is being set.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: KeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookAfter(keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks after setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `class`:The class whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, oldValue, newValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(keyPath.setterName(), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }
    
    /**
     Hooks after setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `class`: The class whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(keyPath.setterName(), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }
    
    /**
     Hooks after setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `class`: The class whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: Self.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(keyPath.setterName(), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks after setting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `class`: The class whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: Self.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        try hook(keyPath.setterName(), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks getting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `class`: The class whose property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try textfield.hook(\.stringValue) { object, originalValue in
        return originalValue.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(_ keyPath: KeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ original: Value)->(Value)) throws -> Hook {
        try hook(keyPath.getterName(), closure: Hook.getterClosure(for: closure))
    }
    
    /**
     Hooks getting the specified class property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `class`: The class whose property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try MyObject.hook(\.classProperty) { cls, originalValue in
        return original.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(_ keyPath: KeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(keyPath.getterName(), closure: Hook.getterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified class property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `class`: The class whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - `setter`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try MyObject.hook(set: \.classProperty) { cls, value, original in
        if stringValue != "" {
            // Sets the stringValue.
            setter(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ value: Value, _ setter: (Value)->())->()) throws -> Hook {
        try hook(keyPath.setterName(), closure: Hook.setterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified class property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `class`: The class whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - `setter`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try MyObject.hook(set: \.classProperty) { cls, value, original in
        if stringValue != "" {
            // Sets the stringValue.
            setter(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ value: Value, _ setter: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        try hook(keyPath.setterName(), closure: Hook.setterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified class property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `class`: The class whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - Returns: The value to forward to the original setter.

     Example usage:
     ```swift
     try MyObject.hook(set: \.classProperty) { cls, value in
        value.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ value: Value)->(Value)) throws -> Hook {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
    
    /**
     Hooks setting the specified class property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `class`:The class whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - Returns: The value to forward to the original setter.

     Example usage:
     ```swift
     try MyObject.hook(set: \.classProperty) { cls, value in
        value.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(set keyPath: WritableKeyPath<Self.Type, Value>, closure: @escaping (_ class: Self.Type, _ value: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
}
#endif
