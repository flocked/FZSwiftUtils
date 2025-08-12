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
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(#selector(MyObject.sum(with:number2:)), closure: {
         print("hooked before class sum")
     } as @convention(block) (MyObject, Selector, Int, Int) -> Void)
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(with:number2:))) {
         print("hooked after class sum")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(#selector(MyObject.sum(with:number2:)), closure: { object, selector, number1, number2 in
         print("hooked before class sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(with:number2:)), closure: { object, selector, number1, number2 in
         print("hooked after class sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookBefore(_ selector: Selector, closure: @escaping (_ cls: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    static func hookBefore(_ selector: String, closure: @escaping (_ cls: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
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
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookAfter(_ selector: Selector, closure: @escaping (_ cls: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    static func hookAfter(_ selector: String, closure: @escaping (_ cls: Self.Type, _ selector: Selector) -> Void) throws -> Hook {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value to be returned by the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(\.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.getterName(), closure: Hook.beforeAfterClosure(for: closure))
    }
    
    /**
     Hooks before getting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value to be returned by the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(\.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    public static func hookBefore<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let getterName = try keyPath.getterName()
        if let hook = try? hookBefore(getterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookBefore(getterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
    }
    
    /**
     Hooks before setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.setterName(), closure: Hook.beforeAfterClosure(for: closure))
    }
    
    /**
     Hooks before setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    public static func hookBefore<Value>(set keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        if let hook = try? hookBefore(setterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookBefore(setterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
    }
    
    /**
     Hooks before setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(set: keyPath) { object, value in
            guard !uniqueValues || value != object[keyPath: keyPath] else { return }
            closure(object, value)
        }
    }
    
    /**
     Hooks before setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try MyObject.hookBefore(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        let _closure: (Self, Value)->() = { object, value in
            guard !uniqueValues || value != object[keyPath: keyPath] else { return }
            closure(object, value)
        }
        if let hook = try? hookBefore(setterName, closure: Hook.beforeAfterClosure(for: _closure)) {
            return hook
        }
        let rawClosure: (Self, Value.RawValue)->() = { object, rawValue in
            guard let newValue = Value(rawValue: rawValue) else { return }
            guard !uniqueValues || newValue != object[keyPath: keyPath] else { return }
            closure(object, newValue)
        }
        return try hookBefore(setterName, closure: Hook.beforeAfterClosure(for: rawClosure))
    }
    
    /**
     Hooks after getting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is read. It receives:
         - `object`: The object.
         - `value`: The current value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(\.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(try keyPath.getterName(), closure: Hook.beforeAfterClosure(for: closure))
    }
    
    /**
     Hooks after getting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is read. It receives:
         - `object`: The object.
         - `value`: The current value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(\.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    public static func hookAfter<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let getterName = try keyPath.getterName()
        if let hook = try? hookAfter(getterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookAfter(getterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
    }
    
    /**
     Hooks after setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(try keyPath.setterName(), closure: Hook.beforeAfterClosure(for: closure))
    }
    
    /**
     Hooks after setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    public static func hookAfter<Value>(set keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        if let hook = try? hookAfter(setterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookAfter(setterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
    }
    
    /**
     Hooks after setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try MyObject.hookAfter(set: \.classProperty) { cls, value in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks getting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance on which the property is being accessed.
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
    public static func hook<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook {
        let _closure: (Self, Value, (Value)->())->() = { object, value, apply in
            apply(closure(object, value))
        }
        return try hook(try keyPath.getterName(), closure: Hook.closure(for: _closure))
    }
    
    /**
     Hooks getting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance on which the property is being accessed.
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
    public static func hook<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        let getterName = try keyPath.getterName()
        let _closure: (Self, Value, (Value)->())->() = { object, value, apply in
            apply(closure(object, value))
        }
        if let hook = try? hook(getterName, closure: Hook.closure(for: _closure)) {
            return hook
        }
        let rawClosure: (Self, Value.RawValue, (Value.RawValue)->())->() = { object, rawValue, apply in
            guard let newValue = Value(rawValue: rawValue) else { return }
            apply(closure(object, newValue).rawValue)
        }
        return try hook(getterName, closure: Hook.closure(for: rawClosure))
    }
    
    /**
     Hooks setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - `original`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try MyObject.hook(set: \.classProperty) { cls, value, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> Hook {
        return try hook(try keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks setting the specified property of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - `original`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try MyObject.hook(set: \.classProperty) { cls, value, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        if let hook = try? hook(setterName, closure: Hook.closure(for: closure)) {
            return hook
        }
        let rawClosure: (Self, Value.RawValue, (Value.RawValue)->())->() = { object, rawValue, original in
            guard let newValue = Value(rawValue: rawValue) else { return }
            let newOriginal: ((Value)->()) = { original($0.rawValue) }
            closure(object, newValue, newOriginal)
        }
        return try hook(setterName, closure: Hook.closure(for: rawClosure))
    }
}
#endif
