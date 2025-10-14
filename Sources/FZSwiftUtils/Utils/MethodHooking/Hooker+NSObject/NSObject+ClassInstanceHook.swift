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
     Hooks before the specified method of all instances of the class.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(all: #selector(MyObject.sum(with:number2:)), closure: {
         print("hooked before sum")
     } as @convention(block) (MyObject, Selector, Int, Int) -> Void)
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookBefore(all selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(all: selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookBefore(all selector: String, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(all: selector, closure: closure as Any)
    }
    
    /**
     Hooks before the specified method of all instances of the class.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(all: #selector(MyObject.sum(with:number2:)), closure: { object, selector, number1, number2 in
         print("hooked before sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
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
    class func hookBefore(all selector: Selector, closure: Any) throws -> Hook {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    class func hookBefore(all selector: String, closure: Any) throws -> Hook {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Hooks after the specified method of all instances of the class.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(all: #selector(MyObject.sum(with:number2:)), closure: {
         print("hooked after sum")
     } as @convention(block) (MyObject, Selector, Int, Int) -> Void)
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookAfter(all selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(all: selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookAfter(all selector: String, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(all: selector, closure: closure as Any)
    }
    
    // MARK: - custom closure
    
    /**
     Hooks after the specified method of all instances of the class.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(all: #selector(MyObject.sum(with:number2:)), closure: { object, selector, number1, number2 in
         print("hooked before sum of \(number1) and \(number2)")
     } as @convention(block) ((MyObject, Selector, Int, Int) -> Int))
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
    class func hookAfter(all selector: Selector, closure: Any) throws -> Hook {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    class func hookAfter(all selector: String, closure: Any) throws -> Hook {
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
    class func hook(all selector: Selector, closure: Any) throws -> Hook {
        try ClassInstanceHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    class func hook(all selector: String, closure: Any) throws -> Hook {
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
     
     try MyObject.hookBefore(all: #selector(MyObject.sum(with:number2:))) { object, selector in
         print("hooked \(object) before sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookBefore(all selector: Selector, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    static func hookBefore(all selector: String, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(all: #selector(MyObject.sum(with:number2:))) { object, selector in
         print("hooked \(object) after sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookAfter(all selector: Selector, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    static func hookAfter(all selector: String, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object before the object DeInit.
     
     Example usage:
     
     ```swift
     MyObject.hookDeInitBefore { object in
         print("hooked before DeInit of \(object)")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released.
     */
    @discardableResult
    static func hookDeInitBefore(closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeInitBefore(closure: closure)
    }
}

public extension NSObject {
    // MARK: before deinit
    /**
     Execute the closure before the object DeInit.
     
     Example usage:
     
     ```swift
     MyObject.hookDeInitBefore {
         print("hooked before DeInit")
     }
     ```
     
     - Parameter closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookDeInitBefore(closure: @escaping () -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeInitBefore(closure: closure)
    }
    
    // MARK: after deinit
    /**
     Execute the closure after the object DeInit.
     
     Example usage:
     
     ```swift
     MyObject.hookDeInitAfter {
         print("hooked after DeInit")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookDeInitAfter(closure: @escaping () -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeInitAfter(closure: closure)
    }
    
    // MARK: replace deinit
    /**
     Replace the implementation of object's DeInit method by the closure.
     
     Example usage:
     
     ```swift
     MyObject.hookDeInit { original in
         print("before release of MyObject")
         original()
         print("after release of MyObject")
     }
     ```
     
     - Parameter closure: The hook closure with the original DeInit method as parameter. You have to call it to avoid memory leak.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookDeInit(closure: @escaping (_ original: () -> Void) -> Void) throws -> Hook {
        try ClassInstanceHook(self).hookDeInit(closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value to be returned by the property.

     Example usage:
     ```swift
     try NSTextField.hookBefore(all: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(all: try keyPath.getterName(), closure: Hook.beforeAfterClosure(for: closure))
    }
    
    /**
     Hooks before getting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value to be returned by the property.

     Example usage:
     ```swift
     try NSTextField.hookBefore(all: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    public static func hookBefore<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let getterName = try keyPath.getterName()
        if let hook = try? hookBefore(all: getterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookBefore(all: getterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try NSTextField.hookBefore(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(all: try keyPath.setterName(), closure: Hook.beforeAfterClosure(for: closure))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try NSTextField.hookBefore(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    public static func hookBefore<Value>(setAll keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        if let hook = try? hookBefore(all: setterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookBefore(all: setterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try NSTextField.hookBefore(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(setAll: keyPath) { object, value in
            guard !uniqueValues || value != object[keyPath: keyPath] else { return }
            closure(object, value)
        }
    }
    
    /**
     Hooks before setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try NSTextField.hookBefore(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookBefore<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        let _closure: (Self, Value)->() = { object, value in
            guard !uniqueValues || value != object[keyPath: keyPath] else { return }
            closure(object, value)
        }
        if let hook = try? hookBefore(all: setterName, closure: Hook.beforeAfterClosure(for: _closure)) {
            return hook
        }
        let rawClosure: (Self, Value.RawValue)->() = { object, rawValue in
            guard let newValue = Value(rawValue: rawValue) else { return }
            guard !uniqueValues || newValue != object[keyPath: keyPath] else { return }
            closure(object, newValue)
        }
        return try hookBefore(all: setterName, closure: Hook.beforeAfterClosure(for: rawClosure))
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
     try NSTextField.hookAfter(all: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(all: try keyPath.getterName(), closure: Hook.beforeAfterClosure(for: closure))
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
     try NSTextField.hookAfter(all: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    public static func hookAfter<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let getterName = try keyPath.getterName()
        if let hook = try? hookAfter(all: getterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookAfter(all: getterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
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
     try NSTextField.hookAfter(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(all: try keyPath.setterName(), closure: Hook.beforeAfterClosure(for: closure))
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
     try NSTextField.hookAfter(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        if let hook = try? hookAfter(all: setterName, closure: Hook.beforeAfterClosure(for: closure)) {
            return hook
        }
        return try hookAfter(all: setterName, closure: Hook.beforeAfterClosure(for: Hook.rawClosure(for: closure)))
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try NSTextField.hookAfter(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(setAll: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try NSTextField.hookAfter(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(setAll: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try NSTextField.hookAfter(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(setAll: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try NSTextField.hookAfter(setAll: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public static func hookAfter<Value>(setAll keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        try hook(setAll: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
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
     try NSTextField.hook(all: \.stringValue) { object, original in
        return original.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook {
        let _closure: (Self, Value, (Value)->())->() = { object, value, apply in
            apply(closure(object, value))
        }
        return try hook(all: try keyPath.getterName(), closure: Hook.closure(for: _closure))
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
     try NSTextField.hook(all: \.stringValue) { object, original in
        return original.uppercased()
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(all keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        let getterName = try keyPath.getterName()
        let _closure: (Self, Value, (Value)->())->() = { object, value, apply in
            apply(closure(object, value))
        }
        if let hook = try? hook(all: getterName, closure: Hook.closure(for: _closure)) {
            return hook
        }
        let rawClosure: (Self, Value.RawValue, (Value.RawValue)->())->() = { object, rawValue, apply in
            guard let newValue = Value(rawValue: rawValue) else { return }
            apply(closure(object, newValue).rawValue)
        }
        return try hook(all: getterName, closure: Hook.closure(for: rawClosure))
    }
    
    /**
     Hooks setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - `original`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try NSTextField.hook(setAll: \.stringValue) { textfield, stringValue, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> Hook {
        return try hook(all: try keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks setting the specified property for all instances of the class.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - `original`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try NSTextField.hook(setAll: \.stringValue) { textfield, stringValue, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public static func hook<Value>(setAll keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        let setterName = try keyPath.setterName()
        if let hook = try? hook(all: setterName, closure: Hook.closure(for: closure)) {
            return hook
        }
        let rawClosure: (Self, Value.RawValue, (Value.RawValue)->())->() = { object, rawValue, original in
            guard let newValue = Value(rawValue: rawValue) else { return }
            let newOriginal: ((Value)->()) = { original($0.rawValue) }
            closure(object, newValue, newOriginal)
        }
        return try hook(all: setterName, closure: Hook.closure(for: rawClosure))
    }
}
#endif
