//
//  _AnyClass.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 11.05.25.
//

import Foundation

class _AnyClass {
    let targetClass: AnyClass
    
    init(_ targetClass: AnyClass) {
        self.targetClass = targetClass
    }
    
    #if os(macOS) || os(iOS)
    func revertHooks(for selector: Selector, type: HookMode? = nil) {
        if let type = type {
            hooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            hooks[selector, default: [:]][type] = []
        } else {
            hooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            hooks[selector] = [:]
        }
    }
    
    func revertHooks(for selector: String, type: HookMode? = nil) {
        revertHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    func revertAllHooks() {
        hooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    var allHooks: [Hook] {
        var hooks: [Hook] = []
        for val in self.hooks.values {
            hooks += val.flatMap({$0.value})
        }
        return hooks
    }
    
    func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return hooks[selector]?[type]?.isEmpty == false
        }
        return hooks[selector]?.isEmpty == false
    }
    
    func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    func addHook(_ token: Hook) {
        hooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    func removeHook(_ token: Hook) {
        hooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private var hooks: [Selector: [HookMode: Set<Hook>]] {
        get { getAssociatedValue("hooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "hooks") }
    }
    #endif
}

extension _AnyClass {
    #if os(macOS) || os(iOS)
    func revertInstanceHooks(for selector: Selector, type: HookMode? = nil) {
        if let type = type {
            instanceHooks[selector, default: [:]][type]?.forEach({ try? $0.revert(remove: false) })
            instanceHooks[selector, default: [:]][type] = []
        } else {
            instanceHooks[selector]?.flatMap({$0.value}).forEach({ try? $0.revert(remove: false) })
            instanceHooks[selector] = [:]
        }
    }
    
    func revertInstanceHooks(for selector: String, type: HookMode? = nil) {
        revertInstanceHooks(for: NSSelectorFromString(selector), type: type)
    }
    
    func revertAllInstanceHooks() {
        instanceHooks.keys.forEach({ revertHooks(for: $0) })
    }
    
    func isInstanceMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        if let type = type {
            return instanceHooks[selector]?[type]?.isEmpty == false
        }
        return instanceHooks[selector]?.isEmpty == false
    }
    
    /// A Boolean value indicating whether the specified method is hooked for all instances of the class.
    func isInstanceMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
        isInstanceMethodHooked(NSSelectorFromString(selector), type: type)
    }
    
    func addInstanceHook(_ token: Hook) {
        instanceHooks[token.selector, default: [:]][token.mode, default: []].insert(token)
    }
    
    func removeInstanceHook(_ token: Hook) {
        instanceHooks[token.selector, default: [:]][token.mode, default: []].remove(token)
    }
    
    private var instanceHooks: [Selector: [HookMode: Set<Hook>]] {
        get { getAssociatedValue("instanceHooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "instanceHooks") }
    }
    #endif
    
    
    func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(value, key: key, object: targetClass)
    }
    
    func getAssociatedValue<T>(_ key: String) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: targetClass)
    }
    
    func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: targetClass, initialValue: initialValue)
    }
    
    func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: targetClass, initialValue: initialValue)
    }
    
    var addedMethods: Set<Selector> {
        get { getAssociatedValue("addedMethods") ?? [] }
        set {
            setAssociatedValue(newValue, key: "addedMethods")
            guard let targetClass = targetClass as? NSObject.Type else { return }
            if newValue.count == 1 {
                do {
                    try targetClass.hook(all: "respondsToSelector:", closure: {
                        original, object, sel, selector in
                        if let selector = selector, _AnyClass(targetClass).addedMethods.contains(selector) {
                            return true
                        }
                        return original(object, sel, selector)
                    } as @convention(block) (
                        (NSObject, Selector, Selector?) -> Bool,
                        NSObject, Selector, Selector?) -> Bool)
                } catch {
                    Swift.print(error)
                }
            } else if newValue.isEmpty {
                revertHooks(for: "respondsToSelector:")
            }
        }
    }
}
