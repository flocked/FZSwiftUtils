//
//  ClassHook.swift
//
//
//  Created by Florian Zand on 05.05.25.
//

import Foundation

/// Hooks class methods.
struct ClassHook<T: AnyObject> {
    let targetClass: AnyClass

    public init(_ targetClass: T.Type) {
        self.targetClass = targetClass
    }
    
    public func revertHooks(for selector: Selector, type: HookMode? = nil) {
        Hook.Storage(targetClass, isInstance: false).revertHooks(for: selector, type: type)
    }
    
    public func revertAllHooks() {
        Hook.Storage(targetClass, isInstance: false).revertAllHooks()
    }
    
    public func isMethodHooked(_ selector: Selector, type: HookMode? = nil) -> Bool {
        Hook.Storage(targetClass, isInstance: false).isMethodHooked(selector, type: type)
    }
    
    // MARK: - Hook Before

    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        return try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ class: T.Type) -> Void) throws -> Hook {
        try hookBefore(selector) { cls,_ in closure(cls) }
    }
    
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ class: T.Type, _ selector: Selector) -> Void) throws -> Hook {
        let closure = { obj, sel in
            guard let obj = obj as? T.Type else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(getClass(), selector: selector, mode: .before, hookClosure: closure as AnyObject).apply(true)
    }
    
    // MARK: - Hook After

    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Hook {
        return try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ class: T.Type) -> Void) throws -> Hook {
        try hookAfter(selector) { cls,_ in closure(cls) }
    }
            
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ class: T.Type, _ selector: Selector) -> Void) throws -> Hook {
        let closure = { obj, sel in
            guard let obj = obj as? T.Type else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(getClass(), selector: selector, mode: .after, hookClosure: closure as AnyObject).apply(true)
    }
    
    // MARK: - Hook Instead

    @discardableResult
    public func hook(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook.Class(getClass(), selector: selector, mode: .instead, hookClosure: closure as AnyObject).apply(true)
    }
    
    private func getClass() throws -> AnyClass {
        guard let targetClass = object_getClass(targetClass) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        return targetClass
    }
}

// MARK: - Hook KeyPath
extension ClassHook where T: NSObject {
    @discardableResult
    func hookBefore<Value>(_ keyPath: KeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type)->()) throws -> Hook {
        try hookBefore(.string(keyPath.getterName())) { cls,_ in closure(cls) }
    }

    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type,_ value: Value)->()) throws -> Hook {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }

    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }

    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, keyPath))
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: T.Type,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: T.Type,_ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hookBefore(.string(keyPath.setterName()), closure: Hook.beforeClosure(for: closure, uniqueValues, keyPath))
    }

    @discardableResult
    func hookAfter<Value>(_ keyPath: KeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type)->()) throws -> Hook {
        try hookAfter(.string(keyPath.getterName())) { cls,_ in closure(cls) }
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type,_ value: Value)->()) throws -> Hook {
        try hookAfter(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type,_ value: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hookAfter(.string(keyPath.setterName()), closure: Hook.closure(for: closure))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, keyPath: keyPath))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: T.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }

    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T.Type, Value>, uniqueValues: Bool = false, closure: @escaping (_ class: T.Type, _ oldValue: Value, _ newValue: Value)->()) throws -> Hook where Value: Equatable & RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.afterClosure(for: closure, uniqueValues, keyPath))
    }
    
    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ original: Value)->(Value)) throws -> Hook {
        try hook(.string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }

    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ original: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(.string(keyPath.getterName()), closure: Hook.getterClosure(for: closure))
    }

    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ value: Value, _ setter: (Value)->())->()) throws -> Hook {
        try hook(.string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }

    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ value: Value, _ setter: (Value)->())->()) throws -> Hook where Value: RawRepresentable {
        try hook(.string(keyPath.setterName()), closure: Hook.setterClosure(for: closure))
    }

    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ value: Value)->(Value)) throws -> Hook {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }

    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class: T.Type, _ value: Value)->(Value)) throws -> Hook where Value: RawRepresentable {
        try hook(set: keyPath) { object, value, origial in origial(closure(object, value)) }
    }
}
