//
//  Hook+Object.swift
//
//
//  Created by Florian Zand on 11.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

extension Hook {
    class Object: Hook {
        weak var object: AnyObject?
        weak var hookContext: HookContext?
        
        init(_ object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
            try hookSerialQueue.syncSafely {
                try Self.parametersCheck(for: object, selector: selector, mode: mode, closure: hookClosure)
            }
            super.init(selector: selector, hookClosure: hookClosure, mode: mode, class_: type(of: object))
            self.object = object
        }
        
        override var isActive: Bool {
            get { hookContext != nil }
            set { newValue ? try? apply() : try? revert() }
        }
        
        override func apply() throws {
            guard !isActive else { return }
            try hookSerialQueue.syncSafely {
                guard let object = object else { return }
                let targetClass: AnyClass
                if let object = object as? NSObject {
                    targetClass = try object.wrapKVOIfNeeded(selector: selector)
                } else {
                    targetClass = try wrapDynamicClassIfNeeded(object: object)
                }
                if class_getInstanceMethod(targetClass, selector) == nil {
                    let resolvedProtocol = try inferProtocolForMethod(targetClass: targetClass, selector: selector, isInstanceMethod: true)
                    if let resolvedProtocol = resolvedProtocol {
                        try addProtocolMethodIfNeeded(targetClass: targetClass, selector: selector, protocolType: resolvedProtocol, isInstanceMethod: true)
                    }
                }
                let hookContext = try HookContext.get(for: targetClass, selector: selector, isSpecifiedInstance: true)
                try appendHookClosure(hookClosure, selector: selector, mode: mode, to: object)
                self.hookContext = hookContext
                Storage(object).addHook(self)
            }
        }
        
        override func revert(remove: Bool) throws {
            guard isActive else { return }
            try hookSerialQueue.syncSafely {
                guard let hookContext = hookContext, let object = object else { return }
                
                try removeHookClosure(hookClosure, selector: hookContext.selector, mode: mode, for: object)
                self.hookContext = nil
                if remove {
                    Storage(object).removeHook(self)
                }
                guard object_getClass(object) == hookContext.targetClass else { return }
                guard !(try hookContext.isIMPChanged()) else { return }
                guard isHookClosuresEmpty(for: object) else { return }
                if let object = object as? NSObject {
                    object.unwrapKVOIfNeeded()
                } else {
                    try unwrapDynamicClass(object: object)
                }
            }
        }
    }
}
#endif
