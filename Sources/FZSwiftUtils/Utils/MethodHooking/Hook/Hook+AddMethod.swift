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
                    guard let resolvedProtocol = try inferProtocolForMethod(targetClass: targetClass, selector: selector, isInstanceMethod: true) else {
                        throw HookError.noRespondSelector
                    }
                    let typeEncoding = try typeEncodingForProtocolMethod(resolvedProtocol, selector: selector, isInstanceMethod: true)
                    try Self.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure)
                    guard class_addMethod(targetClass, selector, replacementIMP, typeEncoding) else {
                        throw HookError.methodAlreadyExists
                    }
                    addedToClass = targetClass
                }
                isApplied = true
                ObjectHooks(object).addedMethods.insert(selector)
                ObjectHooks(object).addHook(self)
            }
        }
        
        override func revert(remove: Bool) throws {
            guard isActive else { return }
            hookSerialQueue.syncSafely {
                guard let object = object, let targetClass = addedToClass else { return }
                if let method = class_getInstanceMethod(targetClass, selector) {
                    let noop: @convention(block) (AnyObject) -> Void = { _ in }
                    method_setImplementation(method, imp_implementationWithBlock(noop))
                }
                ObjectHooks(object).addedMethods.remove(selector)
                isApplied = false
                if remove {
                    ObjectHooks(object).removeHook(self)
                }
            }
        }
    }
    
    class AddClassMethod: Hook {
        let isInstanceMethod: Bool
        var addedToClass: AnyClass?
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
                    guard let resolvedProtocol = try inferProtocolForMethod(targetClass: targetClass, selector: selector, isInstanceMethod: isInstanceMethod) else {
                        throw HookError.noRespondSelector
                    }
                    let typeEncoding = try typeEncodingForProtocolMethod(resolvedProtocol, selector: selector, isInstanceMethod: isInstanceMethod)
                    try Self.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure)
                    guard class_addMethod(targetClass, selector, replacementIMP, typeEncoding) else {
                        throw HookError.methodAlreadyExists
                    }
                    addedToClass = targetClass
                }
                isApplied = true
                ClassHooks(targetClass, isInstance: isInstanceMethod).addedMethods.insert(selector)
                ClassHooks(targetClass, isInstance: isInstanceMethod).addHook(self)
            }
        }
        
        override func revert(remove: Bool) throws {
            guard isActive else { return }
            hookSerialQueue.syncSafely {
                guard let targetClass = addedToClass else { return }
                if let method = class_getInstanceMethod(targetClass, selector) {
                    let noop: @convention(block) (AnyObject) -> Void = { _ in }
                    method_setImplementation(method, imp_implementationWithBlock(noop))
                }
                ClassHooks(targetClass, isInstance: isInstanceMethod).addedMethods.remove(selector)
                isApplied = false
                if remove {
                    ClassHooks(targetClass, isInstance: isInstanceMethod).removeHook(self)
                }
            }
        }
    }
}
