//
//  HookToken.swift
//  SwiftHook
//
//  Created by Florian Zand on 05.05.25.
//

import Foundation

/// Hooking mode.
public enum HookMode: String {
    /// Before.
    case before
    /// After.
    case after
    /// Instead.
    case instead
    /// Add
    case add
}

///  A hooking token.
public class HookToken {
    private let id = UUID()
    private weak var object: AnyObject?
    private let `class`: AnyClass?
    private let hookClosure: AnyObject
    private weak var hookContext: HookContext?
    private weak var deinitDelegate: DeallocDelegate?
    private var hooksDealloc = false
    private var addReplacement: IMP?
    private var addTargetClass: AnyClass?
    private var addHook: AnyHook?
    
    /// The hooking mode.
    public let mode: HookMode
    
    /// The selector of the hook.
    public let selector: Selector
    
    /// A Boolean value indicating whether the hook is active.
    public var isActive: Bool {
        get { addHook?.isActive ?? (hookContext != nil || deinitDelegate != nil) }
        set { newValue ? try? apply() : try? revert() }
    }
    
    /// Applies the hook.
    public func apply() throws {
        guard !isActive else { return }
        try swiftHookSerialQueue.sync {
            if let addHook = addHook {
                try addHook.apply()
                (object as? NSObject)?.addHookToken(self)
                /*
                guard let object = object, let class_ = `class` else { return }
                let targetClass: AnyClass
                if let object = object as? NSObject {
                    guard try object.isSupportedKVO() else {
                        throw SwiftHookError.hookKVOUnsupportedInstance
                    }
                    try object.wrapKVOIfNeeded(selector: selector)
                    guard let KVOedClass = object_getClass(object) else {
                        throw SwiftHookError.internalError(file: #file, line: #line)
                    }
                    targetClass = KVOedClass
                } else {
                    targetClass = try wrapDynamicClassIfNeeded(object: object)
                }
                try appendHookClosure(hookClosure, selector: selector, mode: mode, to: object)
                guard let typeEncoding = typeEncoding(for: selector, _class: class_) else {
                    throw NSObject.SwizzleError.unknownError("typeEncoding failed")
                }
                addTargetClass = targetClass
                class_replaceMethod(targetClass, selector, addReplacement, typeEncoding)
                (object as? NSObject)?.addedMethods.insert(selector)
                (object as? NSObject)?.addHookToken(self)
                 */
            } else if hooksDealloc {
                guard let object = object else { return }
                deinitDelegate = getAssociatedValue("deinitDelegate", object: object, initialValue: DeallocDelegate())
                deinitDelegate?.hookClosures.append(hookClosure)
                (object as? NSObject)?.addHookToken(self)
            } else if let class_ = `class` {
                let hookContext = try HookContext.get(for: class_, selector: selector, isSpecifiedInstance: false)
                try hookContext.append(hookClosure: hookClosure, mode: mode)
                self.hookContext = hookContext
                (class_ as? NSObject.Type)?.addHookToken(self)
            } else if let object = object {
                let targetClass: AnyClass
                if let object = object as? NSObject {
                    guard try object.isSupportedKVO() else {
                        throw SwiftHookError.hookKVOUnsupportedInstance
                    }
                    // use KVO for specified instance hook
                    try object.wrapKVOIfNeeded(selector: selector)
                    guard let KVOedClass = object_getClass(object) else {
                        throw SwiftHookError.internalError(file: #file, line: #line)
                    }
                    targetClass = KVOedClass
                } else {
                    // create dynamic class for specified instance hook
                    targetClass = try wrapDynamicClassIfNeeded(object: object)
                }
                // hook
                let hookContext = try HookContext.get(for: targetClass, selector: selector, isSpecifiedInstance: true)
                // set hook closure
                try appendHookClosure(hookClosure, selector: selector, mode: mode, to: object)
                self.hookContext = hookContext
                (object as? NSObject)?.addHookToken(self)
            }
        }
    }
    
    /// Reverts the hook.
    public func revert() throws {
        try revert(remove: true)
    }
    
    func revert(remove: Bool) throws {
        guard isActive else { return }
        try swiftHookSerialQueue.sync {
            if let addHook = addHook {
                try addHook.revert()
                /*
                guard let object = object else { return }
                guard let deleteIMP = class_getMethodImplementation(addTargetClass, NSSelectorFromString(NSStringFromSelector(selector)+"_Remove")), let method = class_getInstanceMethod(addTargetClass, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
               method_setImplementation(method, deleteIMP)
                (object as? NSObject)?.addedMethods.remove(selector)
                self.addTargetClass = nil
                try removeHookClosure(hookClosure, selector: selector, mode: mode, for: object)
                guard isHookClosuresEmpty(for: object) else { return }
                if let object = object as? NSObject {
                    object.unwrapKVOIfNeeded()
                } else {
                    try unwrapDynamicClass(object: object)
                }
                 */
                guard remove else { return }
                (object as? NSObject)?.removeHookToken(self)
            } else if hooksDealloc {
                deinitDelegate?.hookClosures.removeAll(where: { $0 === self.hookClosure })
                deinitDelegate = nil
                guard remove else { return }
                (object as? NSObject)?.removeHookToken(self)
            } else {
                _ = try cancel()
                guard remove, !isActive else { return }
                (object as? NSObject)?.removeHookToken(self)
                (self.class as? NSObject.Type)?.removeHookToken(self)
            }
        }
    }
    
    func apply(_ shouldApply: Bool) throws -> HookToken {
        try apply()
        if !shouldApply {
            _ = try cancel()
        }
        return self
    }
    
    private func cancel() throws -> Bool? {
        guard let hookContext = hookContext else {
            // This token has been cancelled.
            return nil
        }
        if hookContext.isSpecifiedInstance {
            // This hook is for specified instance
            guard let hookObject = object else {
                // The object has been deinit.
                return nil
            }
            try removeHookClosure(hookClosure, selector: hookContext.selector, mode: mode, for: hookObject)
            self.hookContext = nil
            guard object_getClass(hookObject) == hookContext.targetClass else {
                // The class is changed after hooking by SwiftHook.
                return false
            }
            guard !(try hookContext.isIMPChanged()) else {
                // The IMP is changed after hooking by SwiftHook.
                return false
            }
            
            guard isHookClosuresEmpty(for: hookObject) else {
                // There are still some hooks on this object.
                return false
            }
            if let object = hookObject as? NSObject {
                object.unwrapKVOIfNeeded()
            } else {
                try unwrapDynamicClass(object: hookObject)
            }
            // Can't call `hookContext.remove()` to remove the hookContext because we don't know if there are any objects needed this hookContext
            return true
        } else {
            // This hook is for all instance or class method
            try hookContext.remove(hookClosure: hookClosure, mode: mode)
            self.hookContext = nil
            guard !(try hookContext.isIMPChanged()) else {
                // The IMP is changed after hooking by SwiftHook.
                return false
            }
            guard hookContext.isHoolClosurePoolEmpty() else {
                // There are still some hooks on this hookContext.
                return false
            }
            hookContext.remove()
            return true
        }
    }
    
    init(for object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        try swiftHookSerialQueue.sync {
            try parametersCheck(for: object, selector: selector, mode: mode, closure: hookClosure)
        }
        self.mode = mode
        self.hookClosure = hookClosure
        self.selector = selector
        self.object = object
        self.class = nil
    }
    
    init(for class_: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        try swiftHookSerialQueue.sync {
            try parametersCheck(for: class_, selector: selector, mode: mode, closure: hookClosure)
        }
        self.mode = mode
        self.selector = selector
        self.class = class_
        self.hookClosure = hookClosure
    }
    
    init(deallocAfter object: AnyObject, hookClosure: AnyObject) {
        self.mode = .after
        self.hookClosure = hookClosure
        self.selector = deallocSelector
        self.class = nil
        self.hooksDealloc = true
    }
    
    init<MethodSignature>(add object: AnyObject, selector: Selector, hookClosure: MethodSignature) throws {
        self.mode = .add
        self.hookClosure = hookClosure as AnyObject
        self.selector = selector
        self.object = object
        self.class = type(of: object)
        self.addHook = try OptionalObjectHook(object: object, selector: selector, implementation: hookClosure)
    }
    
    class DeallocDelegate {
        var hookClosures: [AnyObject] = []
        
        deinit {
            for item in hookClosures.reversed() {
                unsafeBitCast(item, to: (@convention(block) () -> Void).self)()
            }
        }
    }
}

extension HookToken: Hashable {
    public static func == (lhs: HookToken, rhs: HookToken) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AnyHook {
    var isActive: Bool {
        get { state == .interposed }
    }
}

extension HookToken {
    /// A hook that adds an unimplemented optional instance method from a protocol to a single object.
    final public class OptionalObjectHook<MethodSignature>: AnyHook {
        /// The object that is being hooked.
        public let object: AnyObject

        /// Subclass that we create on the fly
        var interposeSubclass: InterposeSubclass?

        // Logic switch to use super builder
        let generatesSuperIMP = InterposeSubclass.supportsSuperTrampolines
        
        var dynamicSubclass: AnyClass {
            interposeSubclass!.dynamicClass
        }
        
        override func replaceImplementation() throws {
            interposeSubclass = try InterposeSubclass(object: object)
            guard let typeEncoding = typeEncoding(for: selector, _class: `class`) else {
                throw NSObject.SwizzleError.unknownError("typeEncoding failed")
            }
            class_replaceMethod(dynamicSubclass, selector, replacementIMP, typeEncoding)
            (object as? NSObject)?.addedMethods.insert(selector)
        }
        
        override func resetImplementation() throws {
            guard let deleteIMP = class_getMethodImplementation(dynamicSubclass, NSSelectorFromString(NSStringFromSelector(selector)+"_Remove")), let method = class_getInstanceMethod(dynamicSubclass, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
           method_setImplementation(method, deleteIMP)
            (object as? NSObject)?.addedMethods.remove(selector)
        }
        
        /// Initialize a new hook to add an unimplemented instance method from a conforming protocol.
        public init(object: AnyObject, selector: Selector,
                    implementation: MethodSignature) throws {
            guard !object.responds(to: selector) else {
                throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
            }
            self.object = object
            try super.init(class: type(of: object), selector: selector, shouldValidate: false)
            let block = implementation as AnyObject
            replacementIMP = imp_implementationWithBlock(block)
            guard replacementIMP != nil else {
                throw NSObject.SwizzleError.unknownError("imp_implementationWithBlock failed for \(block) - slots exceeded?")
            }

            // Weakly store reference to hook inside the block of the IMP.
            Interpose.storeHook(hook: self, to: block)
        }
    }
}
