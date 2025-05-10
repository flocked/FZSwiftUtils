//
//  NSObject+Unhook.swift
//  SwiftHook
//
//  Created by Florian Zand on 06.05.25.
//

import Foundation

extension NSObject {
    /**
     Revents all hooks for the specified selector.
     
     - Parameter type: The type of hooks to revent (`before`, `after` or `instead`). The default value is `nil` and removes all hook types.
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
     Revents all hooks for the specified selector.
     
     - Parameter type: The type of hooks to revent (`before`, `after` or `instead`). The default value is `nil` and removes all hook types.
     */
    public func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// A Boolean value indicating whether the method/property for the specific selector is hooked.
    public func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return _hooks[selector]?[type]?.isEmpty == false
        }
        return _hooks[selector]?.isEmpty == false
    }
    
    /**
     Revents all class and class instances hooks for the specified selector.
     
     - Parameter type: The type of hooks to revent (`before`, `after` or `instead`). The default value is `nil` and removes all hook types.
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
     Revents all class and class instances hooks for the specified selector.
     
     - Parameter type: The type of hooks to revent (`before`, `after` or `instead`). The default value is `nil` and removes all hook types.
     */
    public static func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    /// A Boolean value indicating whether the method/property for the specific selector is hooked.
    public static func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return _hooks[selector]?[type]?.isEmpty == false
        }
        return _hooks[selector]?.isEmpty == false
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
