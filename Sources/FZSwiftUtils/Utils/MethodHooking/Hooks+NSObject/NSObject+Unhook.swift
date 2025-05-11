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
        if let type = type {
            hooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            hooks[selector, default: [:]][type] = []
        } else {
            hooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            hooks[selector] = [:]
        }
    }
    
    /**
     Reverts all hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// Reverts all active hooks.
    public func revertAllHooks() {
        hooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    /// A Boolean value indicating whether the method for the specific selector is hooked.
    public func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return hooks[selector]?[type]?.isEmpty == false
        }
        return hooks[selector]?.isEmpty == false
    }
    
    /// A Boolean value indicating whether the method for the specific selector is hooked.
    public func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    func addHook(_ token: HookToken) {
        hooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    func removeHook(_ token: HookToken) {
        hooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private var hooks: [Selector: [HookMode: Set<HookToken>]] {
        get { getAssociatedValue("hooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "hooks") }
    }
}

extension NSObject {
    /**
     Reverts all hooks for the specified class method.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks(for selector: Selector, type: HookMode? = nil) {
        if let type = type {
            hooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            hooks[selector, default: [:]][type] = []
        } else {
            hooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            hooks[selector] = [:]
        }
    }
    
    /**
     Reverts all hooks for the specified class method.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// Reverts all class method hooks.
    public static func revertAllHooks() {
        hooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    /// A Boolean value indicating whether the specified class method is hooked.
    public static func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return hooks[selector]?[type]?.isEmpty == false
        }
        return hooks[selector]?.isEmpty == false
    }
    
    /// A Boolean value indicating whether the specified class method is hooked.
    public static func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    static func addHook(_ token: HookToken) {
        hooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    static func removeHook(_ token: HookToken) {
        hooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private static var hooks: [Selector: [HookMode: Set<HookToken>]] {
        get { getAssociatedValue("hooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "hooks") }
    }
}

extension NSObject {
    /**
     Reverts all hooks for the specified method for all instances of the class.

     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertInstanceHooks(for selector: Selector, type: HookMode? = nil) {
        if let type = type {
            instanceHooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            instanceHooks[selector, default: [:]][type] = []
        } else {
            instanceHooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            instanceHooks[selector] = [:]
        }
    }
    
    /**
     Reverts all hooks for the specified method for all instances of the class.

     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertInstanceHooks(for selector: String, type: HookMode? = nil) {
        revertInstanceHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// Reverts all instance method hooks.
    public static func revertAllInstanceHooks() {
        instanceHooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    /// A Boolean value indicating whether the specified method is hooked for all instances of the class.
    public static func isInstanceMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return instanceHooks[selector]?[type]?.isEmpty == false
        }
        return instanceHooks[selector]?.isEmpty == false
    }
    
    /// A Boolean value indicating whether the specified method is hooked for all instances of the class.
    public static func isInstanceMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isInstanceMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    static func addInstanceHook(_ token: HookToken) {
        instanceHooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    static func removeInstanceHook(_ token: HookToken) {
        instanceHooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private static var instanceHooks: [Selector: [HookMode: Set<HookToken>]] {
        get { getAssociatedValue("instanceHooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "instanceHooks") }
    }
}
#endif
