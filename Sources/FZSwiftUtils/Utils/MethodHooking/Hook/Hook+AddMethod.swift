//
//  Hook+AddMethod.swift
//
//
//  Created by Codex on 2/19/26.
//

import Foundation

extension Hook {
    class AddObjectMethod: Hook {
        weak var object: AnyObject?
        var addedToClass: AnyClass?
        var inactiveImplementation: ProtocolMethodImplementation?
        var isApplied = false
        
        init(_ object: AnyObject, selector: Selector, hookClosure: AnyObject) {
            self.object = object
            super.init(selector: selector, hookClosure: hookClosure, mode: .instead, class_: type(of: object))
        }
        
        override var isActive: Bool {
            get { isApplied }
            set { newValue ? try? apply() : try? revert() }
        }
        
        override func apply() throws {
            guard !isActive, let object = object else { return }
            try hookSerialQueue.syncSafely {
                let targetClass: AnyClass
                if let object = object as? NSObject {
                    targetClass = try object.wrapKVOIfNeeded(selector: selector)
                } else {
                    targetClass = try wrapDynamicClassIfNeeded(object: object)
                }
                let replacementIMP = imp_implementationWithBlock(hookClosure)
                if let method = class_getInstanceMethod(targetClass, selector) {
                    guard let addedToClass = addedToClass, addedToClass === targetClass else {
                        throw HookError.methodAlreadyExists
                    }
                    method_setImplementation(method, replacementIMP)
                } else {
                    guard let resolvedProtocol = try ObjCClass(targetClass).protocol(for: selector, isInstanceMethod: true) else {
                        throw HookError.noRespondSelector
                    }
                    guard let typeEncoding = resolvedProtocol.methodTypeEncoding(for: selector, isInstanceMethod: true) else { throw HookError.noRespondSelector }
                    try Self.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure)
                    inactiveImplementation = try makeProtocolMethodImplementation(protocolType: resolvedProtocol, selector: selector, isInstanceMethod: true)
                    guard class_addMethod(targetClass, selector, replacementIMP, typeEncoding) else {
                        throw HookError.methodAlreadyExists
                    }
                    addedToClass = targetClass
                }
                isApplied = true
                Storage(object).addedMethods.insert(selector)
                Storage(object).addHook(self)
            }
        }
        
        override func revert(remove: Bool) throws {
            guard isActive else { return }
            hookSerialQueue.syncSafely {
                guard let object = object, let targetClass = addedToClass else { return }
                if let method = class_getInstanceMethod(targetClass, selector), let inactiveImplementation = inactiveImplementation {
                    method_setImplementation(method, inactiveImplementation.targetIMP)
                }
                Storage(object).addedMethods.remove(selector)
                isApplied = false
                guard remove else { return }
                Storage(object).removeHook(self)
            }
        }
    }
    
    class AddClassMethod: Hook {
        let isInstanceMethod: Bool
        var addedToClass: AnyClass?
        var inactiveImplementation: ProtocolMethodImplementation?
        var isApplied = false
        
        init(_ class_: AnyClass, selector: Selector, hookClosure: AnyObject, isInstanceMethod: Bool) {
            self.isInstanceMethod = isInstanceMethod
            super.init(selector: selector, hookClosure: hookClosure, mode: .instead, class_: class_)
        }
        
        override var isActive: Bool {
            get { isApplied }
            set { newValue ? try? apply() : try? revert() }
        }
        
        override func apply() throws {
            guard !isActive else { return }
            try hookSerialQueue.syncSafely {
                let targetClass: AnyClass = self.class
                let replacementIMP = imp_implementationWithBlock(hookClosure)
                if let method = class_getInstanceMethod(targetClass, selector) {
                    guard let addedToClass = addedToClass, addedToClass === targetClass else {
                        throw HookError.methodAlreadyExists
                    }
                    method_setImplementation(method, replacementIMP)
                } else {
                    guard let resolvedProtocol = try ObjCClass(targetClass).protocol(for: selector, isInstanceMethod: isInstanceMethod) else {
                        throw HookError.noRespondSelector
                    }
                    guard let typeEncoding = resolvedProtocol.methodTypeEncoding(for: selector, isInstanceMethod: isInstanceMethod) else { throw HookError.noRespondSelector }
                    try Self.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure)
                    inactiveImplementation = try makeProtocolMethodImplementation(protocolType: resolvedProtocol, selector: selector, isInstanceMethod: isInstanceMethod)
                    guard class_addMethod(targetClass, selector, replacementIMP, typeEncoding) else {
                        throw HookError.methodAlreadyExists
                    }
                    addedToClass = targetClass
                }
                isApplied = true
                Storage(targetClass, isInstance: isInstanceMethod).addedMethods.insert(selector)
                Storage(targetClass, isInstance: isInstanceMethod).addHook(self)
            }
        }
        
        override func revert(remove: Bool) throws {
            guard isActive else { return }
            hookSerialQueue.syncSafely {
                guard let targetClass = addedToClass else { return }
                if let method = class_getInstanceMethod(targetClass, selector), let inactiveImplementation = inactiveImplementation {
                    method_setImplementation(method, inactiveImplementation.targetIMP)
                }
                Storage(targetClass, isInstance: isInstanceMethod).addedMethods.remove(selector)
                isApplied = false
                guard remove else { return }
                Storage(targetClass, isInstance: isInstanceMethod).removeHook(self)
            }
        }
    }
}
