//
//  ClassHooks.swift
//  
//
//  Created by Florian Zand on 11.05.25.
//

import Foundation

extension Hook {
    class ClassHooks {
        let targetClass: AnyClass
        let hooksKey: String
        
        init(_ targetClass: AnyClass, isInstance: Bool = false) {
            self.targetClass = targetClass
            self.hooksKey = isInstance ? "instance_hooks" : "hooks"
        }
        
        private var hooks: [Selector: [HookMode: Set<Hook>]] {
            get { FZSwiftUtils.getAssociatedValue(hooksKey, object: targetClass) ?? [:] }
            set { FZSwiftUtils.setAssociatedValue(newValue, key: hooksKey, object: targetClass) }
        }
        
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
        
        func allHooks() -> [Hook] {
            hooks.values.flatMap({ val in val.flatMap({$0.value})  })
        }
        
        var addedMethods: Set<Selector> {
            get { FZSwiftUtils.getAssociatedValue("addedMethods", object: targetClass) ?? [] }
            set {
                FZSwiftUtils.setAssociatedValue(newValue, key: "addedMethods", object: targetClass)
                guard let targetClass = targetClass as? NSObject.Type else { return }
                if newValue.isEmpty {
                    try? addedMethodsHook?.revert()
                    addedMethodsHook = nil
                } else if addedMethodsHook == nil {
                    do {
                        addedMethodsHook = try targetClass.hook(all: #selector(NSObject.responds(to:)), closure: {
                            original, object, sel, selector in
                            if let selector = selector, Hook.ClassHooks(targetClass).addedMethods.contains(selector) {
                                return true
                            }
                            return original(object, sel, selector)
                        } as @convention(block) ((NSObject, Selector, Selector?) -> Bool, NSObject, Selector, Selector?) -> Bool)
                    } catch {
                        Swift.print(error)
                    }
                }
            }
        }
        
        private var addedMethodsHook: Hook? {
            get { FZSwiftUtils.getAssociatedValue("addedMethodsHook", object: targetClass) }
            set { FZSwiftUtils.setAssociatedValue(newValue, key: "addedMethodsHook", object: targetClass) }
        }
    }
}


extension Hook {
    class Storage {
        let object: AnyObject
        let hooksKey: String
        
        init(_ targetClass: AnyClass, isInstance: Bool = false) {
            self.object = targetClass
            self.hooksKey = isInstance ? "instance_hooks" : "hooks"
        }
        
        init(_ object: AnyObject) {
            self.object = object
            self.hooksKey = "hooks"
        }
        
        private var hooks: [Selector: [HookMode: Set<Hook>]] {
            get { FZSwiftUtils.getAssociatedValue(hooksKey, object: object) ?? [:] }
            set { FZSwiftUtils.setAssociatedValue(newValue, key: hooksKey, object: object) }
        }
        
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
        
        func allHooks() -> [Hook] {
            hooks.values.flatMap({ val in val.flatMap({$0.value})  })
        }
        
        var addedMethods: Set<Selector> {
            get { FZSwiftUtils.getAssociatedValue("addedMethods", object: object) ?? [] }
            set {
                FZSwiftUtils.setAssociatedValue(newValue, key: "addedMethods", object: object)
                if newValue.isEmpty {
                    try? addedMethodsHook?.revert()
                    addedMethodsHook = nil
                } else if addedMethodsHook == nil {
                    do {
                        let closure = { original, object, sel, selector in
                            if let selector = selector, Storage(object).addedMethods.contains(selector) {
                                return true
                            }
                            return original(object, sel, selector)
                        } as @convention(block) ((NSObject, Selector, Selector?) -> Bool, NSObject, Selector, Selector?) -> Bool
                        if let targetClass = object as? NSObject.Type {
                            addedMethodsHook = try targetClass.hook(all: #selector(NSObject.responds(to:)), closure: closure)
                        } else if let object = object as? NSObject {
                            addedMethodsHook = try object.hook(#selector(NSObject.responds(to:)), closure: closure)
                        }
                    } catch {
                        Swift.print(error)
                    }
                }
            }
        }
        
        private var addedMethodsHook: Hook? {
            get { FZSwiftUtils.getAssociatedValue("addedMethodsHook", object: object) }
            set { FZSwiftUtils.setAssociatedValue(newValue, key: "addedMethodsHook", object: object) }
        }
    }
}
