//
//  Hook+Storage.swift
//  
//
//  Created by Florian Zand on 11.05.25.
//

import Foundation

extension Hook {
    class Storage {
        let object: AnyObject
        let hooksKey: String
        
        init(_ targetClass: AnyClass, isInstance: Bool = false) {
            self.object = targetClass
            self.hooksKey = isInstance ? "instance_" : "__"
        }
        
        init(_ object: AnyObject) {
            self.object = object
            self.hooksKey = "__"
        }
        
        private var hooks: [Selector: [HookMode: Set<Hook>]] {
            get { FZSwiftUtils.getAssociatedValue("\(hooksKey)hooks", object: object) ?? [:] }
            set { FZSwiftUtils.setAssociatedValue(newValue, key: "\(hooksKey)hooks", object: object) }
        }
        
        func revertHooks(for selector: Selector, type: HookMode? = nil) {
            if let type = type {
                var allHooks = hooks
                guard var modes = allHooks[selector], let modeHooks = modes[type] else { return }
                modeHooks.forEach({ try? $0.revert(remove: false) })
                modes[type] = nil
                allHooks[selector] = modes.isEmpty ? nil : modes
                hooks = allHooks
            } else {
                var allHooks = hooks
                guard let modes = allHooks[selector] else { return }
                modes.values.flatMap({ $0 }).forEach({ try? $0.revert(remove: false) })
                allHooks[selector] = nil
                hooks = allHooks
            }
        }
        
        func revertAllHooks() {
            hooks.keys.forEach({ revertHooks(for: $0) })
        }
        
        func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
            if let type = type {
                return hooks[selector]?[type]?.isEmpty == false
            }
            return hooks[selector]?.values.contains(where: { !$0.isEmpty }) == true
        }
        
        func isMethodHooked(_ selector: String, type: HookMode? = nil) -> Bool {
            isMethodHooked(NSSelectorFromString(selector), type: type)
        }
        
        func addHook(_ token: Hook) {
            hooks[token.selector, default: [:]][token.mode, default: []].insert(token)
        }
        
        func removeHook(_ token: Hook) {
            var allHooks = hooks
            guard var modes = allHooks[token.selector], var modeHooks = modes[token.mode] else { return }
            modeHooks.remove(token)
            modes[token.mode] = modeHooks.isEmpty ? nil : modeHooks
            allHooks[token.selector] = modes.isEmpty ? nil : modes
            hooks = allHooks
        }
        
        func allHooks() -> [Hook] {
            hooks.values.flatMap({ val in val.flatMap({$0.value}) })
        }
        
        var addedMethods: Set<Selector> {
            get { FZSwiftUtils.getAssociatedValue("\(hooksKey)addedMethods", object: object) ?? [] }
            set {
                FZSwiftUtils.setAssociatedValue(newValue, key: "\(hooksKey)addedMethods", object: object)
                if newValue.isEmpty {
                    try? addedMethodsHook?.revert()
                    addedMethodsHook = nil
                } else if addedMethodsHook == nil {
                    do {
                        let key = "\(hooksKey)addedMethods"
                        if let targetClass = object as? NSObject.Type {
                            let closure = { original, object, sel, selector in
                                if let selector = selector,
                                   (FZSwiftUtils.getAssociatedValue(key, object: targetClass) as Set<Selector>?)?.contains(selector) == true {
                                    return true
                                }
                                return original(object, sel, selector)
                            } as @convention(block) ((NSObject, Selector, Selector?) -> Bool, NSObject, Selector, Selector?) -> Bool
                            addedMethodsHook = try targetClass.hook(all: #selector(NSObject.responds(to:)), closure: closure)
                        } else if let object = object as? NSObject {
                            let closure = { original, object, sel, selector in
                                if let selector = selector,
                                   (FZSwiftUtils.getAssociatedValue(key, object: object) as Set<Selector>?)?.contains(selector) == true {
                                    return true
                                }
                                return original(object, sel, selector)
                            } as @convention(block) ((NSObject, Selector, Selector?) -> Bool, NSObject, Selector, Selector?) -> Bool
                            addedMethodsHook = try object.hook(#selector(NSObject.responds(to:)), closure: closure)
                        }
                    } catch {
                        Swift.print(error)
                    }
                }
            }
        }
        
        private var addedMethodsHook: Hook? {
            get { FZSwiftUtils.getAssociatedValue("\(hooksKey)addedMethodsHook", object: object) }
            set { FZSwiftUtils.setAssociatedValue(newValue, key: "\(hooksKey)addedMethodsHook", object: object) }
        }
    }
}
