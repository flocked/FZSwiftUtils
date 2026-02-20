//
//  ClassInstanceHook.swift
//  
//
//  Created by Florian Zand on 05.05.25.
//

import Foundation


/// Hooks methods of all instances of a class.
struct ClassInstanceHook<T: AnyObject> {
    let targetClass: AnyClass

    public init(_ targetClass: T.Type) {
        self.targetClass = targetClass
    }
    
    public func revertHooks(for selector: Selector, type: HookMode? = nil) {
        Hook.Storage(targetClass, isInstance: true).revertHooks(for: selector, type: type)
    }
    
    public func revertAllHooks() {
        Hook.Storage(targetClass, isInstance: true).revertAllHooks()
    }
    
    public func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        Hook.Storage(targetClass, isInstance: true).isMethodHooked(selector, type: type)
    }
    
    // MARK: - Hook Before

    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ object: T) -> Void) throws -> Hook {
        try hookBefore(selector) { obj,_ in closure(obj) }
    }
    
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Hook {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject, isInstance: true).apply(true)
    }
    
    // MARK: - Hook After
    
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ object: T) -> Void) throws -> Hook {
        try hookAfter(selector) { obj,_ in closure(obj) }
    }
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try hookAfter(selector, closure: closure as Any)
    }
        
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Hook {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookAfter(selector, closure: closure as Any)
    }
        
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject, isInstance: true).apply(true)
    }
    
    // MARK: - Hook Instead

    @discardableResult
    public func hook(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject, isInstance: true).apply(true)
    }
}

// MARK: Hook Deinit
extension ClassInstanceHook where T: NSObject {
    @discardableResult
    func hookDeinitBefore(closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try Hook.Class(targetClass, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject, isInstance: true).apply(true)
    }
    
    @discardableResult
    func hookDeinitBefore(closure: @escaping (_ object: T) -> Void) throws -> Hook {
        let closure = { obj in
            guard let obj = obj as? T else { fatalError() }
            closure(obj)
        } as @convention(block) (NSObject) -> Void
        return try Hook.Class(targetClass, selector: .dealloc, mode: .before, hookClosure: closure as AnyObject, isInstance: true).apply(true)
    }
        
    @discardableResult
    func hookDeinitAfter(closure: @escaping @convention(block) () -> Void) throws -> Hook {
        try Hook.Class(targetClass, selector: .dealloc, mode: .after, hookClosure: closure as AnyObject, isInstance: true).apply(true)
    }

    @discardableResult
    func hookDeinit(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> Hook {
        try Hook.Class(targetClass, selector: .dealloc, mode: .instead, hookClosure: closure as AnyObject, isInstance: true).apply(true)
    }
}

// MARK: - Hook KeyPath
extension ClassInstanceHook where T: NSObject {
    @discardableResult
    func hookBefore<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T)->()) throws -> Hook {
        try hookBefore(.string(keyPath.getterName())) { obj,_ in closure(obj) }
    }

    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }

    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: T,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: T,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    @discardableResult
    func hookAfter<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T)->()) throws -> Hook {
        try hookAfter(.string(keyPath.getterName())) { obj,_ in closure(obj) }
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook {
        try hookAfter(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookAfter(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: T, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, uniqueValues: Bool = false, closure: @escaping (_ object: T, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ original: Value)->(Value)) throws -> Hook {
        return try hook(.string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }
    
    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        return try hook(.string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }
    
    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value, _ setter: (Value)->())->()) throws -> Hook {
        return try hook(.string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }
    
    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value, _ setter: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        return try hook(.string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }

    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->(Value)) throws -> Hook {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
    
    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
}
