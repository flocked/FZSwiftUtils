//
//  Hook.swift
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

/// A hook that interposes a method on a object, class or all instances of a class.
public class Hook: Hashable {
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
    private var addedHook: AnyHook?
    
    /// The class of the hooked method.
    public let `class`: AnyClass
    
    /// The selector of the method being interposed.
    public let selector: Selector
    
    /// The hooking mode.
    public let mode: HookMode
    
    /// A Boolean value indicating whether the hook is active.
    public var isActive: Bool {
        get { addedHook?.isActive ?? (hookContext != nil) }
        set { newValue ? try? apply() : try? revert() }
    }
    
    /// Applies the hook by interposing the method implementation.
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
    
    /// Reverts the hook, restoring the original method implementation.
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
    
    func apply(_ shouldApply: Bool) throws -> Hook {
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
    
    init(addedMethod object: NSObject, selector: Selector, hookClosure: AnyObject) throws {
        self.addedHook = try AddMethodHook(object: object, selector: selector, hookClosure: hookClosure)
        self.object = object
        self.class = Swift.type(of: object)
        self.selector = selector
        self.hookClosure = hookClosure
        self.mode = .instead
        self.type = .added
    }
    
    init<T: NSObject>(addedMethod class_: T.Type, selector: Selector, hookClosure: AnyObject) throws {
        self.addedHook = try AddInstanceMethodHook(class_: class_, selector: selector, hookClosure: hookClosure)
        self.class = class_
        self.selector = selector
        self.hookClosure = hookClosure
        self.mode = .instead
        self.type = .added
    }
        
    public static func == (lhs: Hook, rhs: Hook) -> Bool {
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
