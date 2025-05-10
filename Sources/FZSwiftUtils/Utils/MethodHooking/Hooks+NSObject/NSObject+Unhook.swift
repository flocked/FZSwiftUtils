//
//  NSObject+Unhook.swift
//  SwiftHook
//
//  Created by Florian Zand on 06.05.25.
//

import Foundation

extension NSObject {
    /**
     Reverts all hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public func revertHooks(for selector: Selector, type: HookMode? = nil) {
        if let type = type {
            _hooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            _hooks[selector, default: [:]][type] = []
        } else {
            _hooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            _hooks[selector] = [:]
        }
    }
    
    /**
     Reverts all hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// A Boolean value indicating whether the method for the specific selector is hooked.
    public func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return _hooks[selector]?[type]?.isEmpty == false
        }
        return _hooks[selector]?.isEmpty == false
    }
    
    /// A Boolean value indicating whether the method for the specific selector is hooked.
    public func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    func addHookToken(_ token: HookToken) {
        _hooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    func removeHookToken(_ token: HookToken) {
        _hooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private var _hooks: [Selector: [HookMode: Set<HookToken>]] {
        get { FZSwiftUtils.getAssociatedValue("hooks", object: self) ?? [:] }
        set { FZSwiftUtils.setAssociatedValue(newValue, key: "hooks", object: self) }
    }
}

extension NSObject {
    /**
     Reverts all class instances hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks(for selector: Selector, type: HookMode? = nil) {
        if let type = type {
            _hooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            _hooks[selector, default: [:]][type] = []
        } else {
            _hooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            _hooks[selector] = [:]
        }
    }
    
    /**
     Reverts all class instances hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// A Boolean value indicating whether method for the specific selector is hooked for all instances of the class.
    public static func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return _hooks[selector]?[type]?.isEmpty == false
        }
        return _hooks[selector]?.isEmpty == false
    }
    
    /// A Boolean value indicating whether the method for the specific selector is hooked for all instances of the class.
    public static func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    static func addHookToken(_ token: HookToken) {
        _hooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    static func removeHookToken(_ token: HookToken) {
        _hooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private static var _hooks: [Selector: [HookMode: Set<HookToken>]] {
        get { FZSwiftUtils.getAssociatedValue("hooks", object: self) ?? [:] }
        set { FZSwiftUtils.setAssociatedValue(newValue, key: "hooks", object: self) }
    }
}

/*
extension NSObject {
    /**
     Reverts all class method hooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertClassHooks(for selector: Selector, type: HookMode? = nil) {
        if let type = type {
            classHooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            classHooks[selector, default: [:]][type] = []
        } else {
            classHooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            classHooks[selector] = [:]
        }
    }
    
    /**
     Reverts all methodhooks for the specified selector.
     
     - Parameter type: The type of hooks to revert (`before`, `after` or `instead`). The default value is `nil` and reverts all hook types.
     */
    public static func revertClassHooks(for selector: String, type: HookMode? = nil) {
        revertClassHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// A Boolean value indicating whether the class method for the specific selector is hooked.
    public static func isClassMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return classHooks[selector]?[type]?.isEmpty == false
        }
        return classHooks[selector]?.isEmpty == false
    }
    
    /// A Boolean value indicating whether the class method for the specific selector is hooked.
    public static func isClassMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isClassMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    static func addClossHookToken(_ token: HookToken) {
        classHooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    static func removeClossHookToken(_ token: HookToken) {
        classHooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private static var classHooks: [Selector: [HookMode: Set<HookToken>]] {
        get { FZSwiftUtils.getAssociatedValue("hooks", object: self) ?? [:] }
        set { FZSwiftUtils.setAssociatedValue(newValue, key: "hooks", object: self) }
    }
}
*/
