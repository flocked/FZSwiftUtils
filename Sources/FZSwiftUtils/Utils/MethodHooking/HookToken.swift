//
//  HookToken.swift
//
//
//  Created by Florian Zand on 05.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

/// Hooking mode.
public enum HookMode: String {
    /// Before.
    case before
    /// After.
    case after
    /// Instead.
    case instead
}

///  A token for hooking a method.
public class HookToken: Hashable {
    private enum HookType {
        case object
        case `class`
        case classInstance
        case dealloc
        case added
    }
    
    private let id = UUID()
    private let type: HookType
    private weak var object: AnyObject?
    private let hookClosure: AnyObject
    private weak var hookContext: AnyObject?
    var addedHook: AnyHook?
    
    /// The class of the hooked method.
    public let `class`: AnyClass
    
    /// The selector of the hooked method.
    public let selector: Selector
    
    /// The hooking mode.
    public let mode: HookMode
    
    /// A Boolean value indicating whether the hook is active.
    public var isActive: Bool {
        get { addedHook?.isActive ?? (hookContext != nil) }
        set { newValue ? try? apply() : try? revert() }
    }
    
    /// Applies the hook.
    public func apply() throws {
        guard !isActive else { return }
        try hookSerialQueue.syncSafely {
            switch type {
            case .object:
                guard let object = object else { return }
                let targetClass: AnyClass
                if let object = object as? NSObject {
                    targetClass = try object.wrapKVOIfNeeded(selector: selector)
                } else {
                    targetClass = try wrapDynamicClassIfNeeded(object: object)
                }
                let hookContext = try HookContext.get(for: targetClass, selector: selector, isSpecifiedInstance: true)
                try appendHookClosure(hookClosure, selector: selector, mode: mode, to: object)
                self.hookContext = hookContext
                _AnyObject(object).addHook(self)
            case .class, .classInstance:
                let hookContext = try HookContext.get(for: self.class, selector: selector, isSpecifiedInstance: false)
                try hookContext.append(hookClosure: hookClosure, mode: mode)
                self.hookContext = hookContext
                type == .class ? _AnyClass(self.class).addHook(self) : _AnyClass(self.class).addInstanceHook(self)
            case .dealloc:
                guard let object = object else { return }
                let delegate = getAssociatedValue("deinitDelegate", object: object, initialValue: DeallocDelegate())
                delegate.hookClosures.append(hookClosure)
                hookContext = delegate
                _AnyObject(object).addHook(self)
            case .added:
                guard let hook = addedHook, let object = object else { return }
                try hook.apply()
                _AnyObject(object).addHook(self)
            }
        }
    }
    
    /// Reverts the hook.
    public func revert() throws {
        try revert(remove: true)
    }
    
    func revert(remove: Bool) throws {
        guard isActive else { return }
        try hookSerialQueue.syncSafely {
            switch type {
            case .object:
                guard let hookContext = hookContext as? HookContext, let object = object else { return }
                try removeHookClosure(hookClosure, selector: hookContext.selector, mode: mode, for: object)
                self.hookContext = nil
                if remove {
                    _AnyObject(object).removeHook(self)
                }
                guard object_getClass(object) == hookContext.targetClass else { return }
                guard !(try hookContext.isIMPChanged()) else { return }
                guard isHookClosuresEmpty(for: object) else { return }
                if let object = object as? NSObject {
                    object.unwrapKVOIfNeeded()
                } else {
                    try unwrapDynamicClass(object: object)
                }
            case .class, .classInstance:
                guard let hookContext = hookContext as? HookContext else { return }
                try hookContext.remove(hookClosure: hookClosure, mode: mode)
                self.hookContext = nil
                if remove {
                    type == .class ? _AnyClass(self.class).removeHook(self) : _AnyClass(self.class).removeInstanceHook(self)
                }
                guard !(try hookContext.isIMPChanged()) else { return }
                guard hookContext.isHookClosurePoolEmpty else { return }
                hookContext.remove()
            case .dealloc:
                guard let delegate = hookContext as? DeallocDelegate else { return }
                delegate.hookClosures.removeFirst(where: { $0 === self.hookClosure })
                hookContext = nil
                guard remove, let object = object else { return }
                _AnyObject(object).removeHook(self)
            case .added:
                guard let hook = addedHook else { return }
                try hook.revert()
                guard remove, let object = object else { return }
                _AnyObject(object).removeHook(self)
            }
        }
    }
    
    func apply(_ shouldApply: Bool) throws -> HookToken {
        try apply()
        if !shouldApply {
            _ = try revert()
        }
        return self
    }
    
    init(for object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        try hookSerialQueue.syncSafely {
            try Self.parametersCheck(for: object, selector: selector, mode: mode, closure: hookClosure)
        }
        self.mode = mode
        self.type = .object
        self.selector = selector
        self.hookClosure = hookClosure
        self.object = object
        self.class = Swift.type(of: object)
    }
    
    init(for class_: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject, isInstance: Bool = false) throws {
        try hookSerialQueue.syncSafely {
            try Self.parametersCheck(for: class_, selector: selector, mode: mode, closure: hookClosure)
        }
        self.mode = mode
        self.type = isInstance ? .classInstance : .class
        self.selector = selector
        self.hookClosure = hookClosure
        self.class = class_
    }
    
    init(deinitAfter object: AnyObject, hookClosure: AnyObject) {
        self.mode = .after
        self.type = .dealloc
        self.hookClosure = hookClosure
        self.selector = .dealloc
        self.object = object
        self.class = Swift.type(of: object)
    }
    
    init<Method>(addedMethod object: AnyObject, selector: Selector, implementation: Method) throws {
        self.addedHook = try AddedMethodHook(object: object, selector: selector, implementation: implementation)
        self.object = object
        self.class = Swift.type(of: object)
        self.selector = selector
        self.hookClosure = implementation as AnyObject
        self.mode = .instead
        self.type = .added
    }
    
    public static func == (lhs: HookToken, rhs: HookToken) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
#endif

/*
 extension AnyHook {
     var isActive: Bool {
         get { state == .interposed }
     }
 }
 
 init<MethodSignature>(add object: AnyObject, selector: Selector, hookClosure: MethodSignature) throws {
     self.mode = .add
     self.hookClosure = hookClosure as AnyObject
     self.selector = selector
     self.object = object
     self.class = type(of: object)
     self.addHook = try OptionalObjectHook(object: object, selector: selector, implementation: hookClosure)
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
 
 
 /// Add
 if let addHook = addHook {
     try addHook.apply()
     (object as? NSObject)?.addHook(self)
     /*
     guard let object = object, let class_ = `class` else { return }
     let targetClass: AnyClass
     if let object = object as? NSObject {
         guard try object.isSupportedKVO() else {
             throw HookError.hookKVOUnsupportedInstance
         }
         try object.wrapKVOIfNeeded(selector: selector)
         guard let KVOedClass = object_getClass(object) else {
             throw HookError.internalError(file: #file, line: #line)
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
     (object as? NSObject)?.addHook(self)
      */
 }
 
 /// Revert
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
     (object as? NSObject)?.removeHook(self)
 } else
 */
