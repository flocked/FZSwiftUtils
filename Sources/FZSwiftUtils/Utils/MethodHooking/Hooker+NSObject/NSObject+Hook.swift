//
//  NSObject+Hook.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

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
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookBefore(#selector(setter: UILabel.text), closure: { object, selector, newText
        print("hooked before with \(newText)")
     } as @convention(block) (Self, Selector, String) -> Void)
     ```
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure as: `@convention(block) (Self, Selector, Arguments...) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: Any) throws -> Hook {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }

    /**
     Execute the closure after the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookAfter(#selector(setter: UILabel.text)) {
        print("hooked after")
     }
     ```
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }

    // MARK: - custom closure

    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookAfter(#selector(setter: UILabel.text), closure: { object, selector, newText
        print("hooked before with \(newText)")
     } as @convention(block) (Self, Selector, String) -> Void)
     ```
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure as: `@convention(block) (Self, Selector, Arguments...) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: Any) throws -> Hook {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }

    /**
     Replace the implementation of object's method by the closure.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
        @objc dynamic func sum(of number1: Int, and number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     let object = MyObject()
     
     try! object.hook(#selector(MyObject.sum(of:and:)), closure: {
        original, object, selector, number1, number2 in
        let value = original(object, selector, number1, number2)
        return value * 2
     } as @convention(block) (
         (MyObject, Selector, Int, Int) -> Int,
        MyObject, Selector, Int, Int) -> Int)
     
     object.sum(of: 1, and: 2) // 6
     ```
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure as: `@convention(block) ((Self, Selector, Arguments...) -> ReturnType, Self, Selector, Arguments...) -> ReturnType`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hook(_ selector: Selector, closure: Any) throws -> Hook {
        try ObjectHook(self).hook(selector, closure: closure)
    }
    
    /**
     Adds an unimplemented optional protocol method to this object.
     
     Example usage:
     
     ```swift
     @objc protocol PingProtocol: NSObjectProtocol {
         @objc optional func didPing(_ value: Int)
     }
     
     class MyObject: NSObject, PingProtocol { }
     
     let object = MyObject()
     let token = try object.addMethod(#selector(PingProtocol.didPing(_:)), closure: {
         object, value in
         print("didPing:", value)
     } as @convention(block) (MyObject, Int) -> Void)
     ```
     
     - Note: The selector must be an optional protocol requirement adopted by the object's class hierarchy.
     */
    @discardableResult
    func addMethod(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.AddObjectMethod(self, selector: selector, hookClosure: closure as AnyObject).apply(true)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookBefore(#selector(setter: UILabel.text) { object in
        print("before set text of \(object)")
     }
     ```
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     try label.hookAfter(#selector(setter: UILabel.text) { object in
        print("after set text of \(object)")
     }
     ```
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Execute the closure with the object before the object dealloc.
     
     Example usage:
     
     ```swift     
     try! object.hookDeinitBefore { object in
        print("before dealloc of \(object)")
     }
     ```
     - parameter closure: The hook closure. Parameter: `(Self) -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. Avoid retain cycles. Do not capture strong references to the object.
     */
    @discardableResult
    func hookDeinitBefore(_ closure: @escaping (_ object: Self) -> Void) throws -> Hook {
        try ObjectHook(self).hookDeinitBefore(closure: closure)
    }
}

public extension NSObject {
    // MARK: before deinit
    
    /**
     Execute the closure before the object dealloc.
     
     Example usage:
     
     ```swift
     try! object.hookDeinitBefore {
        print("before dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinitBefore(closure: @escaping () -> Void) throws -> Hook {
        try ObjectHook(self).hookDeinitBefore(closure: closure)
    }

    // MARK: after deinit
    
    /**
     Execute the closure after the object dealloc.
     
     Example usage:
     
     ```swift
     try! object.hookDeinitAfter {
        print("after dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinitAfter(closure: @escaping () -> Void) throws -> Hook {
        try ObjectHook(self).hookDeinitAfter(closure: closure)
    }

    // MARK: replace deinit

    /**
     Replace the implementation of object's dealloc method by the closure.
     
     Example usage:
     
     ```swift
     try! object.hookDeinit { original in
        print("before release of object")
        original()
        print("after release of object")
     }
     ```
     - Parameter closure: The hook closure with the original dealloc method as parameter. You have to call it to avoid memory leak.
     - Returns: The token of this hook that can be used to cancel or reapply the hook.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeinit(closure: @escaping (_ original: () -> Void) -> Void) throws -> Hook {
        try ObjectHook(self).hookDeinit(closure: closure)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Hooks before getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is get. It receives:
         - `object`: The instance whose property is being accessed.

     Example usage:
     ```swift
     try label.hookBefore(\.text) { label in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self)->()) throws -> Hook {
        try hookBefore(.string(keyPath.getterName()), closure: closure)
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try label.hookBefore(set: \.text) { label, text in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked before the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value to be set to the property.

     Example usage:
     ```swift
     try label.hookBefore(set: \.text) { label, text in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - closure: The handler that is invoked before the property is set. It receives:
            - `object`: The instance whose property is being set.
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
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - closure: The handler that is invoked before the property is set. It receives:
            - `object`: The instance whose property is being set.
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
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `oldValue`: The current value of the property.
            - `newValue`: The new value to be set to the property.
     Example usage:
     ```swift
     try label.hookBefore(set: \.text, uniqueValues: true) { label, oldText, newText in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks before setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value will change (i.e., when the new value is not equal to the current one).
       - closure: The handler that is invoked before the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `oldValue`: The current value of the property.
            - `newValue`: The new value to be set to the property.
     Example usage:
     ```swift
     try label.hookBefore(set: \.text, uniqueValues: true) { label, oldText, newText in
        // hooks before.
     }
     ```
     */
    @discardableResult
    public func hookBefore<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks after getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is read. It receives:
         - `object`: The instance whose property is being accessed.

     Example usage:
     ```swift
     try label.hookAfter(\.text) { label in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self)->()) throws -> Hook {
        try hookAfter(.string(keyPath.getterName()), closure: closure)
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try label.hookAfter(set: \.text) { label, text in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook {
        try hookAfter(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `value`: The new value of the property.

     Example usage:
     ```swift
     try label.hookAfter(set: \.text) { label, text in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookAfter(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try label.hookAfter(set: \.text) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try label.hookAfter(set: \.text) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try label.hookAfter(set: \.text, uniqueValues: true) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks after setting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
        - uniqueValues: A Boolean value indicating whether the handler should be called only when the property's value did change (i.e., when the new value is not equal to the previous value).
       - closure: The handler that is invoked after the property is set. It receives:
         - `object`: The instance whose property is being set.
         - `oldValue`: The previous value of the property.
         - `newValue`: The new value of the property.

     Example usage:
     ```swift
     try label.hookAfter(set: \.text, uniqueValues: true) { label, oldText, newText in
        // hooks after.
     }
     ```
     */
    @discardableResult
    public func hookAfter<Value>(set keyPath: WritableKeyPath<Self, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: Self, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    /**
     Hooks getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance whose property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try label.hook(\.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public func hook<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook {
        try hook(.string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }
    
    /**
     Hooks getting the specified property.

     - Parameters:
        - keyPath: The key path to the property to hook.
       - closure: A closure that is invoked whenever the property is read. It receives:
         - `object`: The instance whose property is being accessed.
         - `original`: The value returned by the original getter.
         - Returns: The value to return from the getter. This can be the original value or a modified one.

     Example usage:
     ```swift
     try label.hook(\.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public func hook<Value>(_ keyPath: KeyPath<Self, Value>, closure: @escaping (_ object: Self, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(.string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - `setter`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try label.hook(set: \.text) { label, text, setter in
        if text != "" {
            setter(text)
        }
     }
     ```
     */
    @discardableResult
    public func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ setter: (Value)->())->()) throws -> Hook {
        try hook(.string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - `setter`: A block that invokes the original setter. If the block isn't called, the property will not be updated.

     Example usage:
     ```swift
     try label.hook(set: \.text) { label, text, setter in
        if text != "" {
            setter(text)
        }
     }
     ```
     */
    @discardableResult
    public func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value, _ setter: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }
    
    /**
     Hooks setting the specified property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`: The instance whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - Returns: The value to forward to the original setter.

     Example usage:
     ```swift
     try label.hook(set: \.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value)->(Value)) throws -> Hook {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
    
    /**
     Hooks setting the specified property.

     - Parameters:
        - keyPath: The key path to the writable property to hook.
        - closure: The handler that is invoked whenever the property is set. It receives:
            - `object`:The instance whose property is being set.
            - `value`: The new value that is about to be written to the property.
            - Returns: The value to forward to the original setter.

     Example usage:
     ```swift
     try label.hook(set: \.text) { label, text in
        return text.uppercased()
     }
     ```
     */
    @discardableResult
    public func hook<Value>(set keyPath: WritableKeyPath<Self, Value>, closure: @escaping (_ object: Self, _ value: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
}
