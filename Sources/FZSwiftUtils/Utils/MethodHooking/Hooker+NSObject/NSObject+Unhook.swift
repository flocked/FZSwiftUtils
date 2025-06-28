//
//  NSObject+Unhook.swift
//  
//
//  Created by Florian Zand on 06.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

extension NSObject {
    /**
     Reverts all hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public func revertHooks(for selector: Selector, type: HookMode? = nil) {
        _AnyObject(self).revertHooks(for: selector, type: type)
    }
    
    /**
     Reverts all hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public func revertHooks(for selector: String, type: HookMode? = nil) {
        _AnyObject(self).revertHooks(for: selector, type: type)
    }
    
    /// Reverts all active hooks.
    public func revertAllHooks() {
        _AnyObject(self).revertAllHooks()
    }
    
    /// A Boolean value indicating whether the method for the specific selector is hooked.
    public func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        _AnyObject(self).isMethodHooked(selector, type: type)
    }
    
    /// A Boolean value indicating whether the method for the specific selector is hooked.
    public func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        _AnyObject(self).isMethodHooked(selector, type: type)
    }
}

extension NSObject {
    /**
     Reverts all hooks for the specified class method.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks(for selector: Selector, type: HookMode? = nil) {
        _AnyClass(self).revertHooks(for: selector, type: type)
    }
    
    /**
     Reverts all hooks for the specified class method.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks(for selector: String, type: HookMode? = nil) {
        _AnyClass(self).revertHooks(for: selector, type: type)
    }
    
    /// Reverts all class method hooks.
    public static func revertAllHooks() {
        _AnyClass(self).revertAllHooks()
    }
    
    /// A Boolean value indicating whether the specified class method is hooked.
    public static func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        _AnyClass(self).isMethodHooked(selector, type: type)
    }
    
    /// A Boolean value indicating whether the specified class method is hooked.
    public static func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        _AnyClass(self).isMethodHooked(selector, type: type)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Reverts all hooks for the specified property.
     
     - Parameters:
        - keyPath: The key path to the property to revert the hook.
        - type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public func revertHooks<Value>(for keyPath: KeyPath<Self, Value>, type: HookMode? = nil) {
        guard let selector = try? keyPath.getterName() else { return }
        revertHooks(for: selector, type: type)
    }
    
    /**
     Reverts all hooks for the specified set property.
     
     - Parameters:
        - keyPath: The key path to the property to revert the hook.
        - type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public func revertHooks<Value>(forSet keyPath: WritableKeyPath<Self, Value>, type: HookMode? = nil) {
        guard let selector = try? keyPath.setterName() else { return }
        revertHooks(for: selector, type: type)
    }
    
    /// A Boolean value indicating whether the property for the specific keypath is hooked.
    public func isMethodHooked<Value>(_ keyPath: KeyPath<Self, Value>, type: HookMode? = nil) -> Bool {
        guard let selector = try? keyPath.getterName() else { return false }
        return _AnyObject(self).isMethodHooked(selector, type: type)
    }
    
    /// A Boolean value indicating whether the set property for the specific keypath is hooked.
    public func isMethodHooked<Value>(set keyPath: KeyPath<Self, Value>, type: HookMode? = nil) -> Bool {
        guard let selector = try? keyPath.setterName() else { return false }
        return _AnyObject(self).isMethodHooked(selector, type: type)
    }
    
    /**
     Reverts all hooks for the specified property.
     
     - Parameters:
        - keyPath: The key path to the property to revert the hook.
        - type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks<Value>(for keyPath: KeyPath<Self, Value>, type: HookMode? = nil) {
        guard let selector = try? keyPath.getterName() else { return }
        revertHooks(for: selector, type: type)
    }
    
    /**
     Reverts all hooks for the specified set property.
     
     - Parameters:
        - keyPath: The key path to the property to revert the hook.
        - type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks<Value>(forSet keyPath: WritableKeyPath<Self, Value>, type: HookMode? = nil) {
        guard let selector = try? keyPath.setterName() else { return }
        revertHooks(for: selector, type: type)
    }
    
    /// A Boolean value indicating whether the property for the specific keypath is hooked.
    public static func isMethodHooked<Value>(_ keyPath: KeyPath<Self, Value>, type: HookMode? = nil) -> Bool {
        guard let selector = try? keyPath.getterName() else { return false }
        return _AnyObject(self).isMethodHooked(selector, type: type)
    }
    
    /// A Boolean value indicating whether the set property for the specific keypath is hooked.
    public static func isMethodHooked<Value>(set keyPath: KeyPath<Self, Value>, type: HookMode? = nil) -> Bool {
        guard let selector = try? keyPath.setterName() else { return false }
        return _AnyObject(self).isMethodHooked(selector, type: type)
    }
}


extension NSObject {
    /**
     Reverts all hooks for the specified method for all instances of the class.

     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertInstanceHooks(for selector: Selector, type: HookMode? = nil) {
        _AnyClass(self).revertInstanceHooks(for: selector, type: type)
    }
    
    /**
     Reverts all hooks for the specified method for all instances of the class.

     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertInstanceHooks(for selector: String, type: HookMode? = nil) {
        _AnyClass(self).revertInstanceHooks(for: selector, type: type)
    }
    
    /// Reverts all instance method hooks.
    public static func revertAllInstanceHooks() {
        _AnyClass(self).revertAllInstanceHooks()
    }
    
    /// A Boolean value indicating whether the specified method is hooked for all instances of the class.
    public static func isInstanceMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        _AnyClass(self).isInstanceMethodHooked(selector, type: type)
    }
    
    /// A Boolean value indicating whether the specified method is hooked for all instances of the class.
    public static func isInstanceMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        _AnyClass(self).isInstanceMethodHooked(selector, type: type)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Reverts all hooks for the specified property.
     
     - Parameters:
        - keyPath: The key path to the property to revert the hook.
        - type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertInstanceHooks<Value>(for keyPath: KeyPath<Self, Value>, type: HookMode? = nil) {
        guard let selector = try? keyPath.getterName() else { return }
        revertHooks(for: selector, type: type)
    }
    
    /**
     Reverts all hooks for the specified set property.
     
     - Parameters:
        - keyPath: The key path to the property to revert the hook.
        - type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertInstanceHooks<Value>(forSet keyPath: WritableKeyPath<Self, Value>, type: HookMode? = nil) {
        guard let selector = try? keyPath.setterName() else { return }
        revertHooks(for: selector, type: type)
    }
}


#endif
