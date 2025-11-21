//
//  NSObject+Hook.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

#if os(macOS) || os(iOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import CoreMedia

public extension NSObject {
    // MARK: - empty closure

    /**
     Execute the closure before the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookBefore(#selector(setter: UILabel.text) {
        print("hooked before")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookBefore(#selector(setter: UILabel.text) { object, selector, newText
        print("hooked before with \(newText)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `(Self, Selector, ...)`. Return type: `Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: Any) throws -> Hook {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: Any) throws -> Hook {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }

    /**
     Execute the closure after the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookAfter(#selector(setter: UILabel.text) {
        print("hooked after")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }

    // MARK: - custom closure

    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookAfter(#selector(setter: UILabel.text) { object, selector, newText
        print("hooked after with \(newText)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `(Self, Selector, ...)`. Return type: `Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: Any) throws -> Hook {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: Any) throws -> Hook {
        try ObjectHook(self).hookAfter(selector, closure: closure)
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
     
     let object = MyObject()
     
     try! object.hook(#selector(MyObject.sum(of:and:)), closure: {
        original, object, selector, number1, number2 in
        let originalValue = original(object, selector, number1, number2)
        return originalValue * 2
     } as @convention(block) (
         (MyObject, Selector, Int, Int) -> Int,
        MyObject, Selector, Int, Int) -> Int)
     
     object.sum(of: 1, and: 2) // Returns 6
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `((Self, Selector, ...) -> ReturnType, Self, Selector, ...) -> ReturnType`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hook(_ selector: Selector, closure: Any) throws -> Hook {
        try ObjectHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    func hook(_ selector: String, closure: Any) throws -> Hook {
        try ObjectHook(self).hook(selector, closure: closure)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookBefore(#selector(setter: UILabel.text) { object, selector in
        print("before set text of \(object)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookAfter(#selector(setter: UILabel.text) { object, selector in
        print("after set text of \(object)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping (_ object: Self, _ selector: Selector) -> Void) throws -> Hook {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object before the object dealloc.
     
     Example usage:
     
     ```swift     
     try! object.hookDeInitBefore { object in
        print("before dealloc of \(object)")
     }
     ```
     - parameter closure: The hook closure. Parameter: `(Self) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles. Do not capture strong references to the object.
     */
    @discardableResult
    func hookDeInitBefore(_ closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ObjectHook(self).hookDeInitBefore(closure: closure)
    }
}

public extension NSObject {
    // MARK: before deinit
    
    /**
     Execute the closure before the object dealloc.
     
     Example usage:
     
     ```swift
     try! object.hookDeInitBefore {
        print("before dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeInitBefore(closure: @escaping () -> Void) throws -> Hook {
        try ObjectHook(self).hookDeInitBefore(closure: closure)
    }

    // MARK: after deinit
    
    /**
     Execute the closure after the object dealloc.
     
     Example usage:
     
     ```swift
     try! object.hookDeInitAfter {
        print("after dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeInitAfter(closure: @escaping () -> Void) throws -> Hook {
        try ObjectHook(self).hookDeInitAfter(closure: closure)
    }

    // MARK: replace deinit

    /**
     Replace the implementation of object's dealloc method by the closure.
     
     Example usage:
     
     ```swift
     try! object.hookDeInit { original in
        print("before release of object")
        original()
        print("after release of object")
     }
     ```
     - Parameter closure: The hook closure with the original dealloc method as parameter. You have to call it to avoid memory leak.
     - Returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeInit(closure: @escaping (_ original: () -> Void) -> Void) throws -> Hook {
        try ObjectHook(self).hookDeInit(closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value to be returned by the property.

     Example usage:
     ```swift
     try textfield.hookBefore(\.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.getterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The object.
         - `value`: The value to be returned by the property.

     Example usage:
     ```swift
     try textfield.hookBefore(\.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    public func hookBefore<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(try keyPath.getterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try textfield.hookBefore(set: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(try keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try textfield.hookBefore(set: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    public func hookBefore<Value>(set keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(try keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try textfield.hookBefore(set: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(set: keyPath) { object, value in
            guard !uniqueValues || value != object[keyPath: keyPath] else { return }
            closure(object, value)
        }
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The object.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try textfield.hookBefore(set: \.stringValue) { textfield, stringValue in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        try hookBefore(set: keyPath) { object, value in
            guard !uniqueValues || value != object[keyPath: keyPath] else { return }
            closure(object, value)
        }
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
    public func hookAfter<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(try keyPath.getterName(), closure: Hook.closure(for: closure))
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
    public func hookAfter<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookAfter(try keyPath.getterName(), closure: Hook.closure(for: closure))
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
     try textfield.hookAfter(set: \.stringValue) { textfield, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(try keyPath.setterName(), closure: Hook.closure(for: closure))
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
     try textfield.hookAfter(set: \.stringValue) { textfield, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookAfter(try keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try textfield.hookAfter(set: \.stringValue) { textfield, oldStringValue, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try textfield.hookAfter(set: \.stringValue) { textfield, oldStringValue, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try textfield.hookAfter(set: \.stringValue) { textfield, oldStringValue, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The object.
         - `oldValue`: The previous value of the property.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try textfield.hookAfter(set: \.stringValue) { textfield, oldStringValue, stringValue in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable, Value: RawRepresentable {
        try hook(set: keyPath) { object, value, original in
            let oldValue = object[keyPath: keyPath]
            original(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
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
     try textfield.hook(\.stringValue) { object, originalValue in
        return originalValue.uppercased()
     }
     ```
     */
    @discardableResult
    public func hook<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook {
        return try hook(try keyPath.getterName(), closure: Hook.closure(for: closure))
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
     try textfield.hook(\.stringValue) { object, originalValue in
        return originalValue.uppercased()
     }
     ```
     */
    @discardableResult
    public func hook<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        return try hook(try keyPath.getterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks setting the specified property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - `original`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try textfield.hook(set: \.stringValue) { textfield, stringValue, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> Hook {
        return try hook(try keyPath.setterName(), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks setting the specified property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance on which the property is being set.
            - `value`: The new value that is about to be written to the property.
            - `original`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try textfield.hook(set: \.stringValue) { textfield, stringValue, original in
        if stringValue != "" {
            // Sets the stringValue.
            original(stringValue)
        }
     }
     ```
     */
    @discardableResult
    public func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ original: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        return try hook(try keyPath.setterName(), closure: Hook.closure(for: closure))
    }
}
#endif
