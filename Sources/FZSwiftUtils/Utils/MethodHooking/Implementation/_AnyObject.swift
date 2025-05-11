//
//  _AnyObject.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 11.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

class _AnyObject {
    let object: AnyObject
    
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
    
    var allHooks: [HookToken] {
        var hooks: [HookToken] = []
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
    
    var addedMethods: Set<Selector> {
        get { getAssociatedValue("addedMethods") ?? [] }
        set {
            setAssociatedValue(newValue, key: "addedMethods")
            guard let object = object as? NSObject else { return }
            if newValue.count == 1 {
                do {
                    try object.hook(#selector(NSObject.responds(to:)), closure: {
                        original, object, sel, selector in
                        if let selector = selector, object.addedMethods.contains(selector) {
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
                revertHooks(for: #selector(NSObject.responds(to:)))
            }
        }
    }
    
    func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(value, key: key, object: object)
    }
    
    func getAssociatedValue<T>(_ key: String) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: object)
    }
    
    func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: object, initialValue: initialValue)
    }
    
    func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: object, initialValue: initialValue)
    }
    
    init(_ object: AnyObject) {
        self.object = object
    }
}
#endif
